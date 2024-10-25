using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class RecordPermissionsGetRequestModel
    { 
        [MapToParameter(new[] { "langID", "languageId", "LanguageID", "LangID" })]
        public string LanguageId { get; set; }
        public long RecordID { get; set; }
        public long? UserSiteID { get; set; }
        public long? UserOrganizationID { get; set; }
        public long? UserEmployeeID { get; set; }
    }
}