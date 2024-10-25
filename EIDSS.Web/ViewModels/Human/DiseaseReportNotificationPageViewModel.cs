using EIDSS.Domain.ViewModels;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels.Administration;
using System;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportNotificationPageViewModel
    {
        public long? HumanID { get; set; }

        public long? HumanActualID { get; set; }

        public long? idfHumanCase { get; set; }

        public bool isEdit { get; set; }

        public bool CaseDisabled { get; set; } = false;

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationLocalIdentifierFieldLabel))]
        public string localIdentifier { get; set; }

        [IsValidDate]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfCompletionOfPaperFormFieldLabel))]
        public DateTime? dateOfCompletion { get; set; }

        public long? idfDisease { get; set; }

        public string? strDisease { get; set; }

        [LocalizedRequired]
        public Select2Configruation diseaseDD { get; set; }

        [IsValidDate]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfDiagnosisFieldLabel))]
        [LocalizedDateLessThanOrEqualToToday]
        [DateComparer(nameof(dateOfDiagnosis), "NotificationSection_dateOfDiagnosis", nameof(dateOfNotification), "NotificationSection_dateOfNotification", CompareTypeEnum.LessThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfDiagnosisFieldLabel), nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfNotificationFieldLabel))]
        public DateTime? dateOfDiagnosis { get; set; }

        [IsValidDate]
        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfNotificationFieldLabel))]
        [DateComparer(nameof(dateOfNotification), "NotificationSection_dateOfNotification", nameof(dateOfDiagnosis), "NotificationSection_dateOfDiagnosis", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfNotificationFieldLabel), nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfDiagnosisFieldLabel))]
        public DateTime? dateOfNotification { get; set; }

        [IsValidDate]
        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfNotificationFieldLabel))]
        [DateComparer(nameof(datOutbreakNotification), "NotificationSection_datOutbreakNotification", nameof(HumanCaseClinicalInformation.datFinalDiagnosisDate), "HumanCaseClinicalInformation_datFinalDiagnosisDate", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfNotificationFieldLabel), nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfDiagnosisFieldLabel))]
        public DateTime? datOutbreakNotification { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationStatusOfPatientAtTimeOfNotificationFieldLabel))]
        public Select2Configruation statusOfPatientAtNotificationDD { get; set; }

        public long? idfStatusOfPatient { get; set; }

        public string? strStatusOfPatient { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationNotificationSentbyFacilityFieldLabel))]
        public Select2Configruation notificationSentByFacilityDD { get; set; }

        [LocalizedRequired]
        public Select2Configruation notificationSentByFacilityDDValidated { get; set; }

        public long? idfNotificationSentByFacility { get; set; }

        public string? strNotificationSentByFacility { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationNotificationSentbyNameFieldLabel))]
        public Select2Configruation notificationSentByNameDD { get; set; }

        [LocalizedRequired]
        public Select2Configruation notificationSentByNameDDValidated { get; set; }


        public long? idfNotificationSentByName { get; set; }

        public string? strNotificationSentByName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationNotificationReceivedbyFacilityFieldLabel))]
        public Select2Configruation notificationReceivedByFacilityDD { get; set; }

        public long? idfNotificationReceivedByFacility { get; set; }

        public string? strNotificationReceivedByFacility { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationNotificationReceivedbyNameFieldLabel))]
        public Select2Configruation notificationReceivedByNameDD { get; set; }

        public long? idfNotificationReceivedByName { get; set; }

        public string? strNotificationReceivedByName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationCurrentLocationOfPatientFieldLabel))]
        public Select2Configruation currentLocationOfPatientDD { get; set; }

        public long? idfCurrentLocationOfPatient { get; set; }

        public string? strCurrentLocationOfPatient { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportFacilityDetailsHospitalNameFieldLabel))]
        public Select2Configruation hospitalNameDD { get; set; }

        public long? idfHospitalName { get; set; }

        public string? strHospitalName { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.DeduplicationHumanDiseaseReportNotificationOtherLocationFieldLabel))]
        public string? strOtherLocation { get; set; }

        public UserPermissions PermissionsAccessToNotification { get; set; }

        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }

        public EmployeePersonalInfoPageViewModel EmployeeDetails { get; set; }

        public bool IsReportClosed { get; set; } = false;

        public bool? blnInitialSSD { get; set; }

        public bool? blnFinalSSD { get; set; }

        public DateTime? DateOfBirth { get; set; }

        public int? ReportedAge { get; set; }

        public long? ReportedAgeUOMID { get; set; }

        public long? GenderTypeID { get; set; }

        public string GenderTypeName { get; set; }

        //Outbreak Related Information
        public bool isOutbreakCase { get; set; } = false;

        public DateTime? datOutbreakStartDate { get; set; }

        public long? ChangedDiseaseId { get; set; }

        public string? ChangedDiseaseName { get; set; }

        [IsValidDate]
        [LocalizedDateLessThanOrEqualToToday]
        public DateTime? DateOfChangedDiagnosis { get; set; }

        public long? ChangeDiagnosisReasonId { get; set; }
    }
}
