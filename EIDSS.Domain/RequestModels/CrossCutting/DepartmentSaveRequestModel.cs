using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;
using EIDSS.Localization.Helpers;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update, DataAuditObjectTypeEnum.Department)]
    public class DepartmentSaveRequestModel : BaseSaveRequestModel
    {
        public long? DepartmentID { get; set; }

        [System.Text.Json.Serialization.JsonPropertyName("DepartmentNameDefaultValue")]
        [LocalizedRequired()]
        public string DefaultName { get; set; }

        [System.Text.Json.Serialization.JsonPropertyName("DepartmentNameNationalValue")]
        public string NationalName { get; set; }

        public long? OrganizationID { get; set; }

        [System.Text.Json.Serialization.JsonPropertyName("OrderNumber")]
        public int? Order { get; set; }
        
        public long? DepartmentNameTypeID { get; set; }
        
        public string UserName { get; set; }

        [System.Text.Json.Serialization.JsonPropertyName("RowStatus")]
        public int RowStatus { get; set; }
    }
}
