using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Web.Areas.Outbreak.ViewModels;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportSymptomsPageViewModel
    {
        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel))]
        [DateComparer(nameof(SymptomsOnsetDate), "SymptomsSection_SymptomsOnsetDate", nameof(DiseaseReportNotificationPageViewModel.dateOfDiagnosis), "NotificationSection_dateOfDiagnosis", CompareTypeEnum.LessThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel), nameof(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationDateOfDiagnosisFieldLabel))]
        [IsValidDate]
        public DateTime? SymptomsOnsetDate { get; set; }

        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel))]
        [DateComparer(nameof(OutBreakSymptomsOnsetDate), "SymptomsSection_OutBreakSymptomsOnsetDate", nameof(HumanCaseClinicalInformation.datFinalDiagnosisDate), "HumanCaseClinicalInformation_datFinalDiagnosisDate", CompareTypeEnum.LessThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel), nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfDiagnosisFieldLabel))]
        [DateComparer(nameof(OutBreakSymptomsOnsetDate), "SymptomsSection_OutBreakSymptomsOnsetDate", nameof(HumanCaseViewModel.SessionDetails.datStartDate), "sessionStartDate", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel), nameof(FieldLabelResourceKeyConstants.OutbreakSessionStartDateFieldLabel))]
        [IsValidDate]
        public DateTime? OutBreakSymptomsOnsetDate { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsInitialCaseClassificationFieldLabel))]
        public long? idfCaseClassfication { get; set; }

        public string strCaseClassification { get; set; }

        [LocalizedRequired]
        public Select2Configruation caseClassficationDD { get; set; }

        public FlexFormQuestionnaireGetRequestModel HumanDiseaseSymptoms { get; set; }

        public bool IsReportClosed { get; set; } = false;

        public bool? blnInitialSSD { get; set; }
        public bool? blnFinalSSD { get; set; }

        public long? idfHumanCase { get; set; }

        public long? idfHuman { get; set; }

        public long idfsSite { get; set; }

        public long? DiseaseID { get; set; }
    }
}