using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Administration;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.CrossCutting
{
    public class ReportDetailsSectionViewModel
    {
        public Select2Configruation SentByOrganizations { get; set; }
        public Select2Configruation SentByOfficers { get; set; }
        public Select2Configruation ReceivedByOrganizations { get; set; }
        public Select2Configruation ReceivedByOfficers { get; set; }
        public Select2Configruation Years { get; set; }
        public Select2Configruation Quarters { get; set; }
        public Select2Configruation Months { get; set; }
        public Select2Configruation Weeks { get; set; }
        public LocationViewModel DetailsLocationViewModel { get; set; }
        public Select2Configruation Organizations { get; set; }

        public AggregateReportGetDetailViewModel AggregateDiseaseReportDetails { get; set; }

        public string ReportID { get; set; }
        public string LegacyID { get; set; }
        [LocalizedRequired]
        public int? Year { get; set; }
        [LocalizedRequired]
        public int? Quarter { get; set; }
        [LocalizedRequired]
        public int? Month { get; set; }
        [LocalizedRequired]
        public int? Week { get; set; }
        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequired]
        public DateTime? Day { get; set; }
        public string Country { get; set; }
        [LocalizedRequired]
        public long? Organization { get; set; }
        public long? AdministrativeLevelID { get; set; }
        public long? TimeIntervalID { get; set; }
        public bool QuarterVisibleIndicator { get; set; }
        public bool MonthVisibleIndicator { get; set; }
        public bool WeekVisibleIndicator { get; set; }
        public bool DayVisibleIndicator { get; set; }
        public bool OrganizationVisibleIndicator { get; set; }
        public bool LegacyIDVisibleIndicator { get; set; }
        public bool OrganizationRequiredIndicator { get; set; }
        public bool ReportDetailsSectionValidIndicator { get; set; }

        public UserPermissions PermissionsCanAccessEmployeesList { get; set; }

        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }
        public EmployeePersonalInfoPageViewModel EmployeeDetails { get; set; }
        public long idfAggrCaseDuplicateReport { get; set; }
    }
}
