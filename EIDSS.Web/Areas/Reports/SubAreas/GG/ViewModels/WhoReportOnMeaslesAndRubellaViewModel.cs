using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using EIDSS.Web.Areas.Reports.ViewModels;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Web.Areas.Reports.SubAreas.GG.ViewModels
{
    public class WhoReportOnMeaslesAndRubellaViewModel : ReportBaseModel
    {
        public List<WhoMeaslesRubellaDiagnosisViewModel> GetHumanWhoMeaslesRubellaDiagnosis { get; set; }



        [DisplayName("Date From")]
        [LocalizedRequired]
        [DisplayFormat(DataFormatString = "{0:d}")]
        [DateComparer(nameof(DateFrom), "DateFrom", nameof(DateTo), "DateTo", CompareTypeEnum.LessThan, nameof(FieldLabelResourceKeyConstants.DateFromFieldLabel), nameof(FieldLabelResourceKeyConstants.DateToFieldLabel))]
        public string DateFrom { get; set; }

        [DisplayName("Date To")]
        [LocalizedRequired]
        [DisplayFormat(DataFormatString = "{0:d}")]
        [DateComparer(nameof(DateTo), "DateTo", nameof(DateFrom), "DateFrom", CompareTypeEnum.GreaterThan, nameof(FieldLabelResourceKeyConstants.DateToFieldLabel), nameof(FieldLabelResourceKeyConstants.DateFromFieldLabel))]
        public string DateTo { get; set; }

        [DisplayName("Disease")]
        public long? DiseaseId { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class WhoReportOnMeaslesAndRubellaQueryModel : ReportQueryBaseModel
    {
        public string DateFrom { get; set; }
        public string DateTo { get; set; }
        public string DiseaseId { get; set; }
    }
}

