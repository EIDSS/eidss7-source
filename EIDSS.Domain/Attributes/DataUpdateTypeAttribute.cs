using EIDSS.Domain.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.Attributes
{
    /// <summary>
    /// Used to decorate state change models and signals the auditing infrastructure what type
    /// of operation is being performed.
    /// </summary>
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = false)]
    public class DataUpdateTypeAttribute : Attribute
    {
        public DataAuditObjectTypeEnum DataObjectType { get; private set; }
        public DataUpdateTypeEnum DataUpdateType { get; private set; }
        public DataUpdateTypeAttribute( DataUpdateTypeEnum updatetype, DataAuditObjectTypeEnum objecttype = DataAuditObjectTypeEnum.DataAccess)
        {
            DataObjectType = objecttype;
            DataUpdateType = updatetype;

        }
    }
}
