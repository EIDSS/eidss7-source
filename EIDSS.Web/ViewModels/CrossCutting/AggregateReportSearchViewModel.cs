using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Laboratory;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Web.ViewModels.CrossCutting
{
    public class AggregateReportSearchViewModel
    {
        public bool HumanIndicator { get; set; }
        public bool RecordSelectionIndicator { get; set; }
        public bool ShowInModalIndicator { get; set; }
        public bool IsFirstLoadIndicator { get; set; } = true;
        public Select2Configruation TimeIntervalUnitSelect { get; set; }

        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        [LocalizedDateLessThanOrEqualToToday]
        [DateComparer(nameof(StartDate), "StartDate", nameof(EndDate), nameof(EndDate), CompareTypeEnum.LessThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.SearchHumanAggregateDiseaseReportsStartDateFieldLabel), nameof(FieldLabelResourceKeyConstants.SearchHumanAggregateDiseaseReportsEndDateFieldLabel))]
        [IsValidDate]
        public DateTime? StartDate { get; set; }

        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        [LocalizedDateLessThanOrEqualToToday]
        [DateComparer(nameof(EndDate), nameof(EndDate), nameof(StartDate), "StartDate", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.SearchHumanAggregateDiseaseReportsEndDateFieldLabel), nameof(FieldLabelResourceKeyConstants.SearchHumanAggregateDiseaseReportsStartDateFieldLabel))]
        [IsValidDate]
        public DateTime? EndDate { get; set; }

        public Select2Configruation AdministrativeLevelSelect { get; set; }
        public Select2Configruation OrganizationSelect { get; set; }
        public EIDSS.Domain.ViewModels.CrossCutting.LocationViewModel SearchLocationViewModel { get; set; }
        public AggregateReportSearchRequestModel SearchCriteria { get; set; }
        public List<AggregateReportGetListViewModel> SearchResults { get; set; }
        public EIDSSGridConfiguration AggregateDiseaseReportGridConfiguration { get; set; }
        public string InformationalMessage { get; set; }
        public UserPermissions Permissions { get; set; }

        public string ReportName { get; set; }
        public string ReportHeader { get; set; }
        public string LangId { get; set; }
        public string PrintParameters { get; set; }

        public AggregateReportSearchRequestModel aggregateReportSearchRequestModel { get; set; }
    }
}