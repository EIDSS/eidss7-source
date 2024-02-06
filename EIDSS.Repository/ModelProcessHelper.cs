using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;
using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace EIDSS.Repository
{
    /// <summary>
    /// Represents a state changing domain model and signals the auditing system the type of operation being performed.
    /// </summary>
    internal class DomainModelType
    {
        public string Namespace { get; init; }
        public string ModelName { get; init; }

        public string ModelFullName { get; init; }

        public bool IsUpdateObject { get; init; } = false;

        public bool IsDeleteObject { get; init; } = false;

        public DataAuditObjectTypeEnum AuditObjectType { get; init; }
    }

    /// <summary>
    /// Singleton service contract helper utility for the <see cref="ModelPropertyMapper"/> service that enumerates domain models and assists in the processing of model
    /// properties during data repository operations.
    /// </summary>
    public interface IModelProcessHelper
    {
        bool IsDomainModel(object model);
        bool IsDomainModel(string modelname);
        bool IsDeleteModel(object model);
        bool IsDeleteModel(string modelname);
        bool IsUpdateModel(object model);
        bool IsUpdateModel(string modelname);
        bool IsChangingState(object model);
        bool IsChangingState(string modelname);

        DataAuditObjectTypeEnum GetAuditObjectType(object model);
    }

    /// <summary>
    /// <see cref="ModelPropertyMapper"/> helper singleton service that enumerates domain models and assists in the processing of model
    /// properties during data repository operations.
    /// </summary>
    public class ModelProcessHelper : IModelProcessHelper
    {
        private List<DomainModelType> _domainModels;

        public DataAuditObjectTypeEnum GetAuditObjectType(object model)
        {
            return _domainModels
                .Where(a => 
                    a.ModelFullName.ToLower() == model.ToString().ToLower()).Select(s=> s.AuditObjectType).FirstOrDefault();
        }

        /// <summary>
        /// Checks to see if the model is a domain model
        /// </summary>
        /// <param name="modelname"></param>
        /// <returns></returns>
        public bool IsDomainModel(string modelname)
            => _domainModels.Any(a => 
                a.ModelFullName.ToLower() == modelname.ToLower());

        /// <summary>
        /// Checks to see if the model is a domain model
        /// </summary>
        /// <param name="modelname"></param>
        /// <returns></returns>
        public bool IsDomainModel(object model)
            => IsDomainModel(model.ToString());

        /// <summary>
        /// Checks if the model is a delete model...
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool IsDeleteModel(string modelname)
            => _domainModels.Any(a => a.ModelFullName.ToLower() == modelname.ToLower() && a.IsDeleteObject);

        /// <summary>
        /// Checks if the model is a delete model...
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool IsDeleteModel(object model)
            => IsDeleteModel(model.ToString());
        
        /// <summary>
        /// Checks if the model is an update model
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool IsUpdateModel(string modelname) 
            => _domainModels.Any(a => a.ModelFullName.ToLower() == modelname.ToLower() && a.IsUpdateObject);

        /// <summary>
        /// Checks if the model is an update model
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool IsUpdateModel(object model)
            => IsUpdateModel(model.ToString());

        /// <summary>
        /// Checks if the model is a state change (update or delete) model.
        /// </summary>
        /// <param name="modelname"></param>
        /// <returns></returns>
        public bool IsChangingState(string modelname)
            => _domainModels.Any(a=> a.ModelFullName.ToLower() == modelname.ToLower() 
                                     && (a.IsUpdateObject || a.IsDeleteObject));

        /// <summary>
        /// Checks if the model is a state change (update or delete) model.
        /// </summary>
        /// <param name="modelname"></param>
        /// <returns></returns>
        public bool IsChangingState(object model)
            => IsChangingState(model.ToString());


        /// <summary>
        /// Creates a new instance of the class and enumerates property value handlers and creates a new <see cref="DomainModelType"/> class for each.
        /// </summary>
        public ModelProcessHelper()
        {
            _domainModels = new List<DomainModelType>();

            // Enumerates all domain modes in the EIDSS.Domain project...
            var models = System.Reflection.Assembly.GetAssembly(typeof(BaseModel))
                .GetTypes()
                .Where(w => w.IsClass && !w.IsAbstract && 
                            (w.Namespace.ToLower().Contains("requestmodels") || w.Namespace.ToLower().Contains("viewmodels")));

            // Add the model to the collection...
            if (models != null)
                foreach (var c in models)
                {
                    var duatt = c.GetCustomAttributes(typeof(DataUpdateTypeAttribute),false).FirstOrDefault();
                        
                    _domainModels.Add(new DomainModelType
                    {
                        ModelName = c.Name,
                        ModelFullName = c.FullName,
                        Namespace = c.Namespace,
                        IsDeleteObject = duatt != null && 
                                         ((DataUpdateTypeAttribute)duatt).DataUpdateType == Domain.Enumerations.DataUpdateTypeEnum.Delete ? true : false,
                        IsUpdateObject = duatt != null &&
                                         ((DataUpdateTypeAttribute)duatt).DataUpdateType == Domain.Enumerations.DataUpdateTypeEnum.Update ? true : false,
                        AuditObjectType = duatt != null 
                            ? ((DataUpdateTypeAttribute)duatt).DataObjectType
                            : DataAuditObjectTypeEnum.DataAccess
                    }); 
                }

        }
    }
}
