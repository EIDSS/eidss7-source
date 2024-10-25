using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Outbreak
{
    public class OutbreakSessionSearchRequestModel
    {
        public string LanguageID { get; set; }
        public string OutbreakID { get; set; }
        public long? OutbreakTypeID { get; set; }
        public long? SearchDiagnosesGroup { get; set; }
        [LocalizedDateLessThanOrEqualToToday]
        [DateComparer(nameof(StartDateFrom), "SearchCriteria_StartDateFrom", nameof(StartDateTo), "SearchCriteria_StartDateTo", CompareTypeEnum.LessThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.SearchOutbreaksStartDateFromFieldLabel), nameof(FieldLabelResourceKeyConstants.SearchOutbreaksStartDateToFieldLabel))]
        [IsValidDate]
        public DateTime? StartDateFrom { get; set; }
        [LocalizedDateLessThanOrEqualToToday]
        [DateComparer(nameof(StartDateTo), "SearchCriteria_StartDateTo", nameof(StartDateFrom), "SearchCriteria_StartDateFrom", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.SearchOutbreaksStartDateToFieldLabel), nameof(FieldLabelResourceKeyConstants.SearchOutbreaksStartDateFromFieldLabel))]
        [IsValidDate]
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
        public bool AdvancedSearchIndicator { get; set; }
    }
}
