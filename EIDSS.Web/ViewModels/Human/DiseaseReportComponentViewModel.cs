using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Human
{
	public class DiseaseReportComponentViewModel
    {

        public DiseaseReportComponentViewModel()
        {
            DiseaseReportCaseInvestigationPrintViewModel = new DiseaseReportPrintViewModel();
            DiseaseReportContactPrintViewModel = new DiseaseReportPrintViewModel();
        }
        public int StartIndex { get; set; } = 1;
        public string PersonID { get; set; }

        public long? HumanID { get; set; }

        public long? HumanActualID { get; set; }

        public long? idfHumanCase { get; set; }

        public string strCaseId { get; set; }

        public bool isEdit { get; set; }

        public long idfsSite { get; set; }

        public long ReportStatusID { get; set; }

        public string ReportStatus { get; set; }

        public bool IsReportClosed { get; set; }
        public long? CaseidfGeoLocation { get; set; }
        public long? CaseidfsLocation { get; set; }
        public DiseaseReportSummaryPageViewModel ReportSummary { get; set; }

        public DiseaseReportPersonalInformationPageViewModel PersonInfoSection { get; set; }

        public DiseaseReportNotificationPageViewModel NotificationSection { get; set; }

        public DiseaseReportSymptomsPageViewModel SymptomsSection { get; set; }

        public DiseaseReportFacilityDetailsPageViewModel FacilityDetailsSection { get; set; }

        public DiseaseReportAntibioticVaccineHistoryPageViewModel AntibioticVaccineHistorySection { get; set; }

        public DiseaseReportSamplePageViewModel SamplesSection { get; set; }

        public DiseaseReportTestPageViewModel TestsSection { get; set; }

        public DiseaseReportCaseInvestigationPageViewModel CaseInvestigationSection { get; set; }

        public DiseaseReportCaseInvestigationRiskFactorsPageViewModel RiskFactorsSection { get; set; }

        public DiseaseReportContactListPageViewModel ContactListSection { get; set; }

        public DiseaseReportFinalOutcomeViewModel FinalOutcomeSection { get; set; }

        public bool IsSaveEnabled { get; set; }

        public bool isDeleteEnabled { get; set; } = false;

        public bool isPrintEnabled { get; set; } = false;

        public List<EventSaveRequestModel> PendingSaveEvents { get; set; } = new List<EventSaveRequestModel>();

        public DiseaseReportPrintViewModel DiseaseReportCaseInvestigationPrintViewModel { get; set; }

        public DiseaseReportPrintViewModel DiseaseReportContactPrintViewModel { get; set; }

        public string PrintReportNameCaseInvestigation { get; set; } = "CaseInvestigation";


        public string PrintReportNameNotification { get; set; } = "UrgentNotificationForm";

        public bool CaseDisabled { get; set; } = false;

        //Outbreak Case related properties
        public LocationViewModel HumanCaseLocation { get; set; }
        public HumanCaseClinicalInformation HumanCaseClinicalInformation { get; set; }
        public CaseGetDetailViewModel CaseDetails { get; set; }
        public DiseaseReportGetDetailViewModel DiseaseReport { get; set; }
        public List<long?> neighboringSites { get; set; } = new List<long?>();
        public bool? IsReopenClosedReport { get; set; } = false;

        //Human Active Surveillance Session related properties
        public long? idfParentMonitoringSession { get; set; }
        public long? ConnectedTestId { get; set; }
        public bool? IsFromWHOExport { get; set; } = false;
    }

    public class HumanCaseClinicalInformation
    {
        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfDiagnosisFieldLabel))]
        [DateComparer(nameof(datFinalDiagnosisDate), "HumanCaseClinicalInformation_datFinalDiagnosisDate", nameof(DiseaseReportNotificationPageViewModel.datOutbreakNotification), "NotificationSection_datOutbreakNotification", CompareTypeEnum.LessThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfDiagnosisFieldLabel), nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfNotificationFieldLabel))]
        [DateComparer(nameof(datFinalDiagnosisDate), "HumanCaseClinicalInformation_datFinalDiagnosisDate", nameof(DiseaseReportSymptomsPageViewModel.SymptomsOnsetDate), "SymptomsSection_OutBreakSymptomsOnsetDate", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfDiagnosisFieldLabel), nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel))]
        [IsValidDate]
        public DateTime? datFinalDiagnosisDate { get; set; }
    }
}
