using System;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class AggregateReportGetListViewModel
    {
        public long ReportKey { get; set; }
        public string ReportID { get; set; }
        public string ReceivedByOrganizationName { get; set; }
        public string SentByOrganizationName { get; set; }
        public string EnteredByOrganizationName { get; set; }
        public DateTime? ReceivedByDate { get; set; }
        public DateTime? SentByDate { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string AdministrativeUnitTypeName { get; set; }
        public string AdministrativeLevel1Name { get; set; }
        public string AdministrativeLevel2Name { get; set; }
        public string SettlementName { get; set; }
        public string OrganizationAdministrativeName { get; set; }
        public string TimeIntervalUnitTypeName { get; set; }
        public long SiteID { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public int RowSelectionIndicator { get; set; }
        public int? RecordCount { get; set; }
        public int? TotalCount { get; set; }
        public int? CurrentPage { get; set; }
        public int? TotalPages { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }

        public List<BaseReferenceViewModel> SearchTimeIntervalList { get; set; }

        public List<BaseReferenceViewModel> SearchAdministrativeUnitTypeList { get; set; }

        public List<GisLocationCurrentLevelModel> SearchOrganizationList { get; set; }
    }
}