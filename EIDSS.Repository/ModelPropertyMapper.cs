using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.InteropServices.ComTypes;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using EIDSS.Repository.ReturnModels;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace EIDSS.Repository
{
    /// <summary>
    /// (1) Maps model properties to EIDSSContexProcedures method parameters and,
    /// (2) Maps audit tracking information to each mapped property.
    /// When a model is passed into the repository on a Get or Post operation, the first time thru
    /// the system reflects to determine how to map each model property to its respective method parameter.
    /// It does this (1), by attempt to match 1:1 the model property name to the method parameter name. And if not found,
    /// (2) By using the <see cref="EIDSS.Domain.Attributes.MapToParameterAttribute"/> decorated above each model property to indicate
    /// which method parameter that property maps to.
    /// When the system creates the map, it stores it in an instance of this class, so on each subsequent pass thru the system,
    /// if a mapping is found it uses that instead of reflecting.
    /// This class must be registered as a singleton.
    /// </summary>
    public interface IModelPropertyMapper
    {
        /// <summary>
        /// Adds a new model map to the cache.
        /// </summary>
        /// <param name="modelname"></param>
        /// <param name="propertyInfo"></param>
        /// <param name="methodInfo"></param>
        /// <param name="parameterinfo"></param>
        /// <param name="dataEntryModel"></param>
        void AddModelMap(PropertyInfo propertyInfo, MethodInfo methodInfo, ParameterInfo parameterinfo, string? propertyParentObjectName = null);

        /// <summary>
        /// Is there a map collection for the given method name
        /// </summary>
        /// <param name="methodname"></param>
        /// <returns></returns>
        bool ContainsMap(string methodname);

        /// <summary>
        /// Is there a mapping for the given method parameter
        /// </summary>
        /// <param name="methodname"></param>
        /// <param name="parametername"></param>
        /// <returns></returns>
        bool ContainsMap(string methodname, string parametername);

        /// <summary>
        /// Get the map for the given method parameter
        /// </summary>
        /// <param name="methodname"></param>
        /// <param name="parametername"></param>
        /// <returns></returns>
        ModelMap GetModelMap(string methodname, string parametername);

        /// <summary>
        /// Get the entire mapping collection for the given method
        /// </summary>
        /// <param name="methodname"></param>
        /// <returns></returns>
        List<ModelMap> GetModelMapCollection(string methodname);
    }

    /// <summary>
    /// Singleton service that maps context method parameters to DTO model properties.
    /// </summary>
    public class ModelPropertyMapper : IModelPropertyMapper
    {
        private object _concurrencyLock = new object();
        private Dictionary<string, List<ModelMap>> _modelMaps { get; set; } =
            new Dictionary<string, List<ModelMap>>(StringComparer.OrdinalIgnoreCase);


        public ModelPropertyMapper()
        {
        }

        /// <summary>
        /// Add a model map to the collection.  Additionally add an Audit map to the colleciton if this column is being audited.
        /// </summary>
        /// <param name="propertyInfo"></param>
        /// <param name="methodInfo"></param>
        /// <param name="parameterinfo"></param>
        /// <param name="dataEntryModel></param>
        public void AddModelMap(PropertyInfo propertyInfo, MethodInfo methodInfo, ParameterInfo parameterinfo,
            string? propertyParentObjectName = null)
        {
            lock (_concurrencyLock)
            {
                // Check if a map exists...
                if (ContainsMap(methodInfo.Name, parameterinfo.Name)) return;

                ModelMap mm = null;

                // Create new model map...
                mm =
                    new ModelMap
                    {
                        MethodInfo = methodInfo,
                        MapInfo = new MappingInfo()
                        {
                            ModelPropertyInfo = propertyInfo,
                            MethodParameterInfo = parameterinfo,
                            IsPropertyOfProperty = !String.IsNullOrEmpty(propertyParentObjectName),
                            PropertyParentObjectName = propertyParentObjectName
                        }
                    };


                // If we don't have a dictionary key for this method, add one and add the map to it...
                if (!_modelMaps.ContainsKey(methodInfo.Name))
                    _modelMaps.Add(methodInfo.Name, new List<ModelMap>() { mm });
                else
                    // otherwise add the map to the dictionary's collection with this key...
                    _modelMaps[methodInfo.Name].Add(mm);
            }
        }

        /// <summary>
        /// Checks if a modelmap exists for the method.
        /// </summary>
        /// <param name="methodname"></param>
        /// <returns></returns>
        public bool ContainsMap(string methodname)
        {
            lock (_concurrencyLock)
            {
                return this._modelMaps.Any(a => a.Key == methodname);
            }
        }

        /// <summary>
        /// Checks if a model map exists for the method parameter.
        /// </summary>
        /// <param name="methodname"></param>
        /// <param name="parametername"></param>
        /// <returns></returns>
        public bool ContainsMap(string methodname, string parametername)
        {
            lock (_concurrencyLock)
            {
                return (this._modelMaps.Any(a =>
                    a.Key == methodname && a.Value.Any(b => b.MapInfo.MethodParameterInfo.Name == parametername)));
            }
        }

        /// <summary>
        /// Retrieve the map for the given method and parameter name
        /// </summary>
        /// <param name="methodname"></param>
        /// <param name="parametername"></param>
        /// <returns></returns>
        public ModelMap GetModelMap(string methodname, string parametername)
        {
            lock (_concurrencyLock)
            {
                var map = this._modelMaps.Where(w => w.Key == methodname).FirstOrDefault();

                return map.Value.Where(w => w.MapInfo.ModelPropertyInfo.Name == parametername).FirstOrDefault();
            }
        }

        /// <summary>
        /// Retrieves all the maps for the given method
        /// </summary>
        /// <param name="methodname"></param>
        /// <returns></returns>
        public List<ModelMap> GetModelMapCollection(string methodname)
        {
            lock (_concurrencyLock)
            {
                return _modelMaps.Where(w => w.Key == methodname).First().Value;
            }
        }
    }

    /// <summary>
    /// Container that tracks method info and mapping information for a domain model.
    /// </summary>
    public class ModelMap 
    {
        /// <summary>
        /// The <see cref="MethodInfo"/> of the associated <see cref="EIDSS.Repository.Contexts.EIDSSContextProcedures"/> method that will 
        /// be called as a result of the operation.
        /// </summary>
        public MethodInfo MethodInfo { get; set; }

        /// <summary>
        /// The <see cref="MappingInfo"/> class that contains <see cref="PropertyInfo"/> of the associated model, <see cref="ParameterInfo"/> for the associated
        /// method and <see cref="AuditColumnInfo"/> if any property are begin audited.
        /// </summary>
        public MappingInfo MapInfo { get; set; }

        public ModelMap()
        {
        }
    }

    /// <summary>
    /// Contains <see cref="PropertyInfo"/>, <see cref="ParameterInfo"/> and a <see cref="AuditColumnInfo"/> class that maps domain model properties to 
    /// <see cref="EIDSS.Repository.Contexts.EIDSSContextProcedures"/> methods.
    /// </summary>
    public class MappingInfo
    {
        /// <summary>
        /// Indicates that this property is a property of a property of the model. 
        /// </summary>
        public Boolean IsPropertyOfProperty { get; set; } = false;

        /// <summary>
        /// The <see cref="PropertyInfo"/> for the domain model who's properties maps to the <see cref="EIDSS.Repository.Contexts.EIDSSContextProcedures"/> method parameters.
        /// </summary>
        public PropertyInfo ModelPropertyInfo { get; set; }

        /// <summary>
        /// The <see cref="ParameterInfo"/> of the <see cref="EIDSS.Repository.Contexts.EIDSSContextProcedures"/> method that maps to the domain model.
        /// </summary>
        public ParameterInfo MethodParameterInfo { get; set; }

        /// <summary>
        /// When the IsPropertyOfProperty property is set to true, this property specifies the name of  its parent object.
        /// </summary>
        public string PropertyParentObjectName { get; set; }
        
        public MappingInfo()
        {

        }
    }

    public class PropertyofPropertyMeta
    {
        
    }
}
