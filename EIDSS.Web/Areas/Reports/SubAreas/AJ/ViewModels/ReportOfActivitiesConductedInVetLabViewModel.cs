using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.Areas.Reports.ViewModels;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Localization.Helpers;


namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class ReportOfActivitiesConductedInVetLabViewModel : ReportBaseModel
    {
        public List<ReportYearModel> ReportYearModels { get; set; }
        public List<ReportingPeriodTypeViewModel> ReportingPeriodTypeList { get; set; }
        public List<ReportingPeriodViewModel> ReportingPeriodList { get; set; }
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }
        public List<BaseReferenceViewModel> OrganizationList { get; set; }
        public List<CurrentCountryViewModel> CurrentCountryList { get; set; }


        [DisplayName("Year")]
        [LocalizedRequired]
        public int Year { get; set; }

        [DisplayName("Reporting Period Type")]
        [LocalizedRequired]
        public string ReportingPeriodTypeId { get; set; }

        [DisplayName("Reporting Period")]
        [LocalizedRequired]
        public string ReportingPeriodId { get; set; }

        [HiddenInput]
        public bool ShowReportingPeriodId { get; set; } = false;

        [DisplayName("Country")]
        public string CountryId { get; set; }

        [DisplayName("Region")]
        public long? RegionId { get; set; }

        [DisplayName("Rayon")]
        public long? RayonId { get; set; }

        [DisplayName("Organization entered test results")]
        public long? EnterByOrganizationId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class ReportOfActivitiesConductedInVetLabQueryModel : ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string ReportingPeriodTypeId { get; set; }
        public string ReportingPeriodId { get; set; }
        public string CountryId { get; set; }
        public string RegionId { get; set; }
        public string RayonId { get; set; }
        public string EnterByOrganizationId { get; set; }

    }
}

