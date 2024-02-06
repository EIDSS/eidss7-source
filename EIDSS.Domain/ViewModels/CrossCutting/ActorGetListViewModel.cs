using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using Newtonsoft.Json;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class ActorGetListViewModel : BaseModel
    {
        [JsonProperty("ActorID")]
        public long ActorID { get; set; }
        [JsonProperty("ActorTypeID")]
        public long ActorTypeID { get; set; }
        [JsonProperty("ActorTypeName")]
        public string ActorTypeName { get; set; }
        [JsonProperty("ActorName")]
        public string ActorName { get; set; }
        [JsonProperty("OrganizationName")]
        public string OrganizationName { get; set; }
        [JsonProperty("EmployeeUserID")]
        public long? EmployeeUserID { get; set; }
        [JsonProperty("EmployeeSiteID")]
        public long? EmployeeSiteID { get; set; }
        [JsonProperty("EmployeeSiteName")]
        public string EmployeeSiteName { get; set; }
        [JsonProperty("UserGroupSiteID")]
        public long? UserGroupSiteID { get; set; }
        [JsonProperty("UserGroupSiteName")]
        public string UserGroupSiteName { get; set; }
        [JsonProperty("UserGroupDescription")]
        public string UserGroupDescription { get; set; }
        [JsonProperty("ObjectAccessID")]
        public long? ObjectAccessID { get; set; }
        [JsonProperty("RowSelectionIndicator")]
        public bool RowSelectionIndicator { get; set; }
        public int RecordCount { get; set; }
    }
}
