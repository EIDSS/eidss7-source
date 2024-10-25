using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using EIDSS.Web.Areas.Reports.ViewModels;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels
{
    public class IntermediateReportByMonthlyFormIV03_01_27byNViewModel  :ReportBaseModel
    {
        public List<GisLocationChildLevelModel> GisRegionList { get; set; }
        public List<GisLocationChildLevelModel> GisRayonList { get; set; }

        [DisplayName("Start Date")]
        [LocalizedRequired]
        [DateComparer(nameof(StartIssueDate), "StartIssueDate", nameof(EndIssueDate), "EndIssueDate", CompareTypeEnum.LessThan, nameof(FieldLabelResourceKeyConstants.StartDateFieldLabel), nameof(FieldLabelResourceKeyConstants.EndDateFieldLabel))]
        public string StartIssueDate { get; set; }

        [DisplayName("End Date")]
        [LocalizedRequired]
        [DateComparer(nameof(EndIssueDate), "EndIssueDate", nameof(StartIssueDate), "StartIssueDate", CompareTypeEnum.GreaterThan, nameof(FieldLabelResourceKeyConstants.EndDateFieldLabel), nameof(FieldLabelResourceKeyConstants.StartDateFieldLabel))]
        public string EndIssueDate { get; set; }

        public string MinimumStartIssueDate { get; set; }
        public string MaximumStartIssueDate { get; set; }
        public string MinimumEndIssueDate { get; set; }
        public string MaximumEndIssueDate { get; set; }

        [DisplayName("Region")]
        public long? RegionId { get; set; }

        [DisplayName("Rayon")]
        public long? RayonId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class IntermediateReportByMonthlyFormIV03_01_27byNQueryModel:ReportQueryBaseModel
    {
        public string Year { get; set; }
        public string StartIssueDate { get; set; }
        public string EndIssueDate { get; set; }
        public string RegionId { get; set; }
        public string RayonId { get; set; }
    }
}

