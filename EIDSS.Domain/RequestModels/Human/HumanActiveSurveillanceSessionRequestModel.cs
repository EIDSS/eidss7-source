using System;
using EIDSS.Localization.Helpers;
using EIDSS.Localization.Enumerations;

namespace EIDSS.Domain.RequestModels.Human
{
    public class ActiveSurveillanceSessionRequestModel
    {
        public string LanguageID { get; set; }
        public string SessionID { get; set; }
        public string LegacySessionID { get; set; }
        public string CampaignID { get; set; }
        public long? CampaignKey { get; set; }
        public long? SessionStatusTypeID { get; set; }
        public DateTime? DateEnteredFrom { get; set; }
        public DateTime? DateEnteredTo { get; set; }
        public long? AdministrativeLevelID { get; set; }
        public long? DiseaseID { get; set; }
        public long? UserSiteID { get; set; }
        public long? UserOrganizationID { get; set; }
        public long? UserEmployeeID { get; set; }
        public bool? ApplySiteFiltrationIndicator { get; set; }
        public string SortColumn { get; set; }
        public string SortOrder { get; set; }
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
        public bool StoredSearchIndicator { get; set; }
    }
}
