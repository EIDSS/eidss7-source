using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportFacilityDetailsPageViewModel
    {
        public DiseaseReportFacilityDetailsPageViewModel()
        {
            BaseReferencePermissions = new();
        }

        public long? PatientPreviouslySoughtCare { get; set; }
        public long? SoughtCareFacilityID { get; set; }


        [IsValidDate]
        [LocalizedDateLessThanOrEqualToToday]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        [DatePatientFirstSoughtCare(
            nameof(SoughtCareFirstDate), "FacilityDetailsSection_SoughtCareFirstDate",
            nameof(DiseaseReportNotificationPageViewModel.dateOfDiagnosis), "NotificationSection_dateOfDiagnosis",
            nameof(DiseaseReportSymptomsPageViewModel.SymptomsOnsetDate), "SymptomsSection_SymptomsOnsetDate"
        )]
        public DateTime? SoughtCareFirstDate { get; set; }
        public long? NonNotifiableDiseaseID { get; set; }
        public long? Hospitalized { get; set; }
        public long? HospitalID { get; set; }

        [IsValidDate]
        [LocalizedDateLessThanOrEqualToToday]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportFacilityDetailsDateOfHospitalizationFieldLabel))]
        [DateComparer(nameof(HospitalizationDate), "FacilityDetailsSection_HospitalizationDate",
            nameof(DiseaseReportSymptomsPageViewModel.SymptomsOnsetDate), "SymptomsSection_SymptomsOnsetDate",
            CompareTypeEnum.GreaterThanOrEqualTo,
            nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportFacilityDetailsDateOfHospitalizationFieldLabel),
            nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel)
            )]
        public DateTime? HospitalizationDate { get; set; }

        [IsValidDate]
        [LocalizedDateLessThanOrEqualToToday]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportFacilityDetailsDateOfHospitalizationFieldLabel))]
        [DateComparer(nameof(HospitalizationDate), "FacilityDetailsSection_OutbreakHospitalizationDate",
            nameof(DiseaseReportSymptomsPageViewModel.SymptomsOnsetDate), "SymptomsSection_OutBreakSymptomsOnsetDate",
            CompareTypeEnum.GreaterThanOrEqualTo,
            nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportFacilityDetailsDateOfHospitalizationFieldLabel),
            nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel)
            )]
        public DateTime? OutbreakHospitalizationDate { get; set; }

        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportFacilityDetailsDateOfDischargeFieldLabel))]
        [DateComparer(nameof(DateOfDischarge), "FacilityDetailsSection_DateOfDischarge",
            nameof(HospitalizationDate), "FacilityDetailsSection_HospitalizationDate",
            CompareTypeEnum.GreaterThanOrEqualTo,
            nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportFacilityDetailsDateOfDischargeFieldLabel),
            nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportFacilityDetailsDateOfHospitalizationFieldLabel))]
        [IsValidDate]
        [DisplayFormat(DataFormatString = "{0:dd/MM/yyyy}")]
        public DateTime? DateOfDischarge { get; set; }

        //Drop downs
        public List<BaseReferenceViewModel> YesNoChoices { get; set; }
        public Select2Configruation FacilitySelect { get; set; }
        public Select2Configruation DiagnosisSelect { get; set; }
        public Select2Configruation HospitalSelect { get; set; }
        public UserPermissions BaseReferencePermissions { get; set; }
        public bool IsReportClosed { get; set; } = false;
        public bool IsOutbreak { get; set; } = false;
    }
}
