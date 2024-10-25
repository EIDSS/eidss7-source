using EIDSS.Domain.Abstracts;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using System;

namespace EIDSS.Domain.RequestModels.Human
{
    public class WeeklyReportingFormGetRequestModel : BaseGetRequestModel
    {
        public long SiteId { get; set; }
        public long? ReportFormTypeId { get; set; }
        public string EIDSSReportID { get; set; }
        public long? AdministrativeUnitTypeId { get; set; }
        public long? TimeIntervalTypeId { get; set; }
        [DateComparer(nameof(StartDate), "SearchCriteria_StartDate", nameof(EndDate), "SearchCriteria_EndDate", CompareTypeEnum.LessThanOrEqualTo, nameof(StartDate), nameof(EndDate))]
        [LocalizedDateLessThanOrEqualToToday]
        [IsValidDate]
        public DateTime? StartDate { get; set; }
        [DateComparer("EndDate", "SearchCriteria_EndDate", "StartDate", "SearchCriteria_StartDate", CompareTypeEnum.GreaterThanOrEqualTo, nameof(EndDate), nameof(StartDate))]
        [LocalizedDateLessThanOrEqualToToday]
        public DateTime? EndDate { get; set; }
        public long? OrganizationId  { get; set; }
        public string  SiteList { get; set; }
        public long? AdministrativeLevelId  { get; set; }
        public bool SelectAllIndicator { get; set; } = false;
        public long UserSiteID { get; set; }        
        public long? UserOrganizationID { get; set; }        
        public long? UserEmployeeID { get; set; }
        public bool ApplySiteFiltrationIndicator { get; set; } = false;
    }

    public class WeeklyReportingFormGetDetailRequestModel 
    {
        public string LangID { get; set; }
        public long? idfsReportFormType { get; set; }
        public long? idfReportForm { get; set; }
    }
}