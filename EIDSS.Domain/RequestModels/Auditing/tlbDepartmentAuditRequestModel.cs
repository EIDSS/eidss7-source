using System.Text.Json.Serialization;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;
using EIDSS.Localization.Helpers;

namespace EIDSS.Domain.RequestModels.Auditing
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class tlbDepartmentAuditRequestModel : BaseSaveRequestModel
    {
        public string DepartmentID { get; set; }

        public string DepartmentNameDefaultValue { get; set; }

        public string DepartmentNameNationalValue { get; set; }

        public string OrderNumber { get; set; }

        public string RowStatus { get; set; }

        public string RowAction { get; set; }

        public tlbDepartmentAuditRequestModel()
        {}
    }
}