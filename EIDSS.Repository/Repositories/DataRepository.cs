
//using AutoMapper;
using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;
using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Serilog;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Repository.Repositories
{
    /// <summary>
    /// Contains a single context method parameter value and is the product of calling the 
    /// <see cref="DataRepository.BuildContextMethodParameterValues"/> method.
    /// </summary>
    internal class DataOpModelInfo
    {
        /// <summary>
        /// Indicates the <see cref="EIDSSContextProcedures"/> method that will be assigned the property value.
        /// </summary>
        public string MethodParameterName { get; set; }

        /// <summary>
        /// The ordinal position of the method parameter.
        /// </summary>
        public int MethodParameterPosition { get; set; }

        /// <summary>
        /// The property name of the model passed into the data repository.
        /// </summary>
        public string PropertyName { get; set; }

        /// <summary>
        /// The model property value which will be assigned to the method parameter.
        /// </summary>
        public object PropertyValue { get; set; }
    }

    internal class propertyInfoObjectContainer
    {
        public Object Model { get; set; }
        public string PropertyClassName { get; set; }

        public propertyInfoObjectContainer(object model) => Model = model;

        public propertyInfoObjectContainer(object model, string propertyClassName) : this(model) =>
            PropertyClassName = propertyClassName;
    }

    /// <summary>
    /// This class interfaces with the database context
    /// </summary>
    public class DataRepository : IDataRepository
    {
        private readonly IMapper _mapper;
        private EIDSSContextProcedures _spcontext;
        private EIDSSContext _dbContext;
        private IModelPropertyMapper _modelPropertyMapper;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly IModelProcessHelper _modelProcessHelper;

        public DataRepository(EIDSSContextProcedures spcontext, EIDSSContext dbContext, IMapper mapper, IModelPropertyMapper modelPropertyMapper, IHttpContextAccessor httpContextAccessor, IModelProcessHelper modelprocesshelper)
        {
            _spcontext = spcontext;
            _dbContext = dbContext;
            _mapper = mapper;
            _modelPropertyMapper = modelPropertyMapper;
            _httpContextAccessor = httpContextAccessor;
            _modelProcessHelper = modelprocesshelper;

            _dbContext.ChangeTracker.QueryTrackingBehavior = QueryTrackingBehavior.NoTracking;

        }
        /// <summary>
        /// Executes delete operations on the context object
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task<object> Delete(DataRepoArgs args)
        {
            // Currently the Delete and Save methods call the Get method.  Eventually, these'll diverge.
            return await Get(args);
        }

        /// <summary>
        /// Executes get operations on the context object
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task<object> Get(DataRepoArgs args)
        {
            object result = null;
            List<DataOpModelInfo> expandedModelProps = null;
            //List<AuditColumnInfo> auditColumns = null;

            // Get the context method that returns this model...
            var meth = GetMethodInfo(args.RepoMethodReturnType);

            object model = null;

            // execute the method...
            if (meth != null)
            {
                // if the args contains a domain model class, this means we'll to get the property values and map to their respective method parameter.
                var modelarg = args.Args.Where(a => a != null && a.GetType().IsClass && _modelProcessHelper.IsDomainModel(a.ToString()));

                if (modelarg.Count() > 0)
                {
                    model = modelarg.FirstOrDefault();

                    // do we have the args cached already...
                    if (_modelPropertyMapper.ContainsMap(meth.Name))
                        expandedModelProps = BuildContextMethodParameterValuesFromCache(meth.Name, model);
                    else
                        expandedModelProps = BuildContextMethodParameterValuesFromModel(model, meth);
                }

                // if a domain model was passed in, here we test to see if those properties were extracted...
                if (expandedModelProps != null && expandedModelProps.Count > 0)
                {
                    foreach (var a in expandedModelProps)
                        // set the cancellation token...
                        if (a.MethodParameterName.ToLower() == "cancellationtoken")
                        {
                            a.PropertyName = a.MethodParameterName;
                            a.PropertyValue = args.Args.Where(a => a != null && a.GetType() == typeof(CancellationToken)).FirstOrDefault();
                            break;
                        }
                    // add the parameter values to the argument member to be passed into the context method...
                    args.Args = expandedModelProps.OrderBy(o => o.MethodParameterPosition).Select(s => s.PropertyValue).ToArray();
                    // set args...
                }
                // Make the call to the context...
                // If there is an async function, call that one...
                if (meth.ReturnType.GetMethod(nameof(Task.GetAwaiter)) != null)
                {
                    result = await (dynamic)meth.Invoke(_spcontext, args.Args);
                }
                else
                {
                    result = meth.Invoke(_spcontext, args.Args);
                }
            }
            // This should never happen!!!!!!
            else throw new Exception(string.Format("Internal Error:  Unable to locate a method that returns type {0}", args.RepoMethodReturnType.ToString()));

            // Map it and return...
            return _mapper.Map(result, args.RepoMethodReturnType, args.MappedReturnType);
        }

        /// <summary>
        /// Executes get operations on the context object
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public object GetSynchronously(DataRepoArgs args)
        {
            return Get(args);
        }
        /// <summary>
        /// Executes save operations on the context object
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task<object> Save(DataRepoArgs args)
        {
            return await Get(args);
        }

        /// <summary>
        /// Reflects on the injected context object to find the associated method that returns the type specified in repoReturnType.
        /// </summary>
        /// <param name="repoReturnType">A type of model (EIDSS.Repository.ReturnModel) generated by the EF Core Power Tools Generator</param>
        /// <returns></returns>
        private System.Reflection.MethodInfo GetMethodInfo(Type repoReturnType)
        {
            // Find the method in the context that returns repo return type...
            return _spcontext.GetType().GetMethods().Where(w => w.ReturnType.FullName.ToLower().Contains(
            repoReturnType.FullName.ToLower())).FirstOrDefault();

        }

        /// <summary>
        /// Builds context method parameters by matching the object's (model) properties to method parameters by:
        /// (1) Checking for a <see cref="MapToParameterAttribute"/> decoration and,
        /// (2) by matching the property name to the context method name.
        /// </summary>
        /// <param name="model"></param>
        /// <param name="mi"></param>
        /// <returns></returns>
        private List<DataOpModelInfo> BuildContextMethodParameterValuesFromModel(object model, MethodInfo mi)
        {
            List<DataOpModelInfo> ret = new List<DataOpModelInfo>();
            //Dictionary<PropertyInfo, object> modelpropertylist = new Dictionary<PropertyInfo, object>();
            Dictionary<PropertyInfo, propertyInfoObjectContainer> modelpropertylist = 
                new Dictionary<PropertyInfo, propertyInfoObjectContainer>();

            if (model is null) return null;

            // Get the method's parameters, we'll use these in a bit...
            var methParameters = mi.GetParameters().OrderBy(o => o.Position);

            // Enumerate all public properties of the model... 
            var modelPropArray = model.GetType()
                .GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.FlattenHierarchy);

            // For each property in the model property array, create a model property object...
            foreach (var m in modelPropArray)
                modelpropertylist.Add(m, new propertyInfoObjectContainer(model));
                //modelpropertylist.Add(m, model);

            // If there are properties that are models themselves, then get them as well...
            // We do this by checking if the property type is a domain model...
            var propertyClasses = modelPropArray
                .Where(w => _modelProcessHelper.IsDomainModel(w.PropertyType.FullName));

            // If the property is a domain model, get its properties...
            if (propertyClasses != null && propertyClasses.Count() > 0)
            {
                // for each property this is also a class, enumerate the properties from this class...
                foreach (var propertyClass in propertyClasses)
                {
                    var list = propertyClass.PropertyType
                        .GetProperties(BindingFlags.Public | BindingFlags.Instance | BindingFlags.FlattenHierarchy);

                    // for each property in the list, create a model property object...
                    foreach (var m in list)
                        //    modelpropertylist.Add(m,
                        //    model.GetType().GetProperty(propertyClass.Name).GetValue(model));
                        modelpropertylist.Add(m, new propertyInfoObjectContainer(
                        model.GetType().GetProperty(propertyClass.Name).GetValue(model),
                            propertyClass.Name));
                }
            }
            // For each method parameter, assign the property that either maps to the parameter using the MapToParameterAttribute or
            // where the property name matches the parameter name...
            foreach (var p in methParameters)
            {
                var propWithmpAttribs = modelpropertylist
                    .Where(w =>
                        w.Key.GetCustomAttribute<MapToParameterAttribute>(true) != null &&
                        w.Key.GetCustomAttribute<MapToParameterAttribute>(true)
                            .ParameterNames.Any(a => a.ToLower() == p.Name.ToLower()))
                    .FirstOrDefault();

                var propertyHasmpAttrib = propWithmpAttribs;

                if (propWithmpAttribs.Key != null ||
                    modelpropertylist.Any(a => a.Key.Name.ToLower() == p.Name.ToLower()))
                {

                    // try to map the property name to the method name...
                    var mp = modelpropertylist
                        .Where(w => w.Key.Name.ToLower() == p.Name.ToLower())
                        .Select(s => s.Key)
                        .FirstOrDefault();

                    var om = modelpropertylist
                        .Where(w => w.Key.Name.ToLower() == p.Name.ToLower())
                        .Select(s => s.Value)
                        .FirstOrDefault();

                    ret.Add(new DataOpModelInfo
                    {
                        MethodParameterName = p.Name,
                        MethodParameterPosition = p.Position,
                        PropertyName = propWithmpAttribs.Key != null
                            ? propWithmpAttribs.Key.Name
                            : mp.Name,
                        PropertyValue = propWithmpAttribs.Key != null
                            ? propWithmpAttribs.Key.GetValue(propWithmpAttribs.Value.Model)
                            : mp.GetValue(om.Model) //om) //om.Model)
                    });
                    if( propWithmpAttribs.Key != null)
                        _modelPropertyMapper.AddModelMap(propWithmpAttribs.Key, mi, p, propWithmpAttribs.Value.PropertyClassName);
                    else
                        _modelPropertyMapper.AddModelMap(mp, mi, p, om.PropertyClassName); // ""); //om.PropertyClassName);
                }
                else // no property maps to this parameter... this is either the returnValue or cancellationToken.  In either case, we don't set the value...
                {
                    ret.Add(new DataOpModelInfo
                    {
                        MethodParameterName = p.Name,
                        MethodParameterPosition = p.Position
                    });

                    _modelPropertyMapper.AddModelMap(null, mi, p);
                }

            }
            return ret;
        }

        /// <summary>
        /// Retrieves the cached method parameter info along with the cached mapped property info
        /// and gets the current value from the property given the model
        /// </summary>
        /// <param name="model">The model 
        /// who's properties will be retrieved from cached</param>
        /// <param name="methodname">The method indicating the parameters to retrieve from cache</param>
        /// <returns></returns>
        private List<DataOpModelInfo> BuildContextMethodParameterValuesFromCache(string methodname, object model)
        {
            List<object> args = new List<object>();
            List<DataOpModelInfo> ret = new List<DataOpModelInfo>();

            // Get the map from cache...
            var mapinfo = GetModelMappingInfo(methodname);

            // Iterate thru the mapinfo objects and set the model's property value...
            foreach (var mi in mapinfo)
            {
                // if the property isn't a model...
                if (mi.ModelPropertyInfo != null && mi.ModelPropertyInfo.ReflectedType.Name == model.GetType().Name)
                    ret.Add(new DataOpModelInfo
                    {
                        MethodParameterName = mi.MethodParameterInfo.Name,
                        MethodParameterPosition = mi.MethodParameterInfo.Position,
                        PropertyName = mi.ModelPropertyInfo.Name,
                        PropertyValue = mi.ModelPropertyInfo.GetValue(model, null)
                    });
                // the property is a model...
                else if (mi.ModelPropertyInfo != null && mi.ModelPropertyInfo.ReflectedType.Name != model.GetType().Name)
                {
                    // Get the sub model...
                    var submodel = model.GetType().GetProperties().Where(w => w.PropertyType.Name == mi.ModelPropertyInfo.ReflectedType.Name).First().GetValue(model, null);

                    // Get the property value...
                    var propvalue = mi.ModelPropertyInfo.GetValue(submodel, null);

                    ret.Add(new DataOpModelInfo
                    {
                        MethodParameterName = mi.MethodParameterInfo.Name,
                        MethodParameterPosition = mi.MethodParameterInfo.Position,
                        PropertyName = mi.ModelPropertyInfo.Name,
                        PropertyValue = propvalue
                    });
                }
                else
                    // This method parameter isn't in the model, no need to assign a property value...
                    ret.Add(new DataOpModelInfo
                    {
                        MethodParameterName = mi.MethodParameterInfo.Name,
                        MethodParameterPosition = mi.MethodParameterInfo.Position,
                        PropertyName = mi.MethodParameterInfo.Name

                    });
            }
            return ret;
        }

        /// <summary>
        /// Retrieves model mapping info for the method
        /// </summary>
        /// <param name="methodname"></param>
        /// <param name="model"></param>
        /// <returns></returns>
        private IEnumerable<MappingInfo> GetModelMappingInfo(string methodname) //, object model)
        {
            var cache = _modelPropertyMapper.GetModelMapCollection(methodname);
            return cache
                //.Where(w => w.MethodInfo.Name == methodname)
                .Select(s => s.MapInfo);
        }


    }

}