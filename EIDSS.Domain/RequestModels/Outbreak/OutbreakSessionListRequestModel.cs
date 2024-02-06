using System;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    public class OutbreakSessionListRequestModel
    {
        public string LanguageID { get; set; }
        public string OutbreakID { get; set; }
        public long? OutbreakTypeID { get; set; }
        public long? SearchDiagnosesGroup { get; set; }
        public DateTime? StartDateFrom { get; set; }
        public DateTime? StartDateTo { get; set; }
        public long? OutbreakStatusTypeID { get; set; }
        public long? AdministrativeLevelID { get; set; }
        public string QuickSearch { get; set; }
        public long? UserSiteID { get; set; }
        public long? UserOrganizationID { get; set; }
        public long? UserEmployeeID { get; set; }
        public bool? ApplySiteFiltrationIndicator { get; set; }
        public string SortColumn { get; set; }
        public string SortOrder { get; set; }
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
    }
}
