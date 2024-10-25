using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Enumerations;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportCaseInvestigationPageViewModel
    {
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportCaseInvestigationInvestigatingOrganizationFieldLabel))]
        public long? idfInvestigatedByOffice { get; set; }
        public string InvestigatedByOffice { get; set; }

        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportCaseInvestigationStartDateOfInvestigationFieldLabel))]
        [DateComparer(nameof(StartDateofInvestigation), "CaseInvestigationSection_StartDateofInvestigation", nameof(DiseaseReportNotificationPageViewModel.dateOfNotification), "NotificationSection_dateOfNotification", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportCaseInvestigationStartDateOfInvestigationFieldLabel), nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfNotificationFieldLabel))]
        [IsValidDate]
        public DateTime? StartDateofInvestigation { get; set; }

        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportCaseInvestigationStartDateOfInvestigationFieldLabel))]
        [DateComparer(nameof(OutBreakStartDateofInvestigation), "CaseInvestigationSection_OutBreakStartDateofInvestigation", nameof(DiseaseReportNotificationPageViewModel.datOutbreakNotification), "NotificationSection_datOutbreakNotification", CompareTypeEnum.GreaterThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportCaseInvestigationStartDateOfInvestigationFieldLabel), nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportNotificationDateOfNotificationFieldLabel))]
        [IsValidDate]
        public DateTime? OutBreakStartDateofInvestigation { get; set; }

        public long? idfsYNRelatedToOutbreak { get; set; }

        public long? idfOutbreak { get; set; }

        public string? comments { get; set; }

        public string strOutbreakID { get; set; }


        [LocalizedDateLessThanOrEqualToToday]
        [DateComparer(nameof(ExposureDate), "CaseInvestigationSection_ExposureDate", nameof(DiseaseReportSymptomsPageViewModel.SymptomsOnsetDate), "SymptomsSection_SymptomsOnsetDate", CompareTypeEnum.LessThanOrEqualTo, nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportCaseInvestigationDateOfPotentialExposureFieldLabel), nameof(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsDateOfSymptomsOnsetFieldLabel))]
        [IsValidDate]
        public DateTime? ExposureDate { get; set; } 
        public long? idfPointGeoLocation { get; set; } 
        public long? idfsPointGroundType { get; set; } 
        public long? idfsPointGeoLocationType { get; set; } 
        public long? idfsPointCountry { get; set; } 
        public long? idfsPointRegion { get; set; } 
        public long? idfsPointRayon { get; set; } 
        public long? idfsPointSettlement { get; set; }
        public double? dblPointDistance { get; set; } 
        public double? dblPointLatitude { get; set; } 
        public double? dblPointLongitude { get; set; } 
        public double? dblPointElevation { get; set; }
        public double? dblPointDirection { get; set; } //case investigation   //Not in SP Yet 
        public string strPointForeignAddress { get; set; } 

        public long? idfsYNExposureLocationKnown { get; set; }


        public string Region { get; set; } 
        public string Rayon { get; set; } 

        public string ExposureLocationType { get; set; } 

        public string Country { get; set; } 
        public string Settlement { get; set; } 

        public string InvestigatedByPerson { get; set; }
        public long idfInvestigatedByPerson { get; set; }
        public string ExposureLocationDescription { get; set; }

        public string strGroundType { get; set; }

        public string YNExposureLocationKnown { get; set; }

        //[LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.CreateHumanCaseInvestigatorOrganizationFieldLabel))]
        public Select2Configruation InvestigatedByOfficeDD { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.CreateHumanCaseInvestigatorNameFieldLabel))]
        public Select2Configruation OutbreakInvestigationSentByNameDD { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.CreateHumanCaseCaseClassificationFieldLabel))]
        public Select2Configruation OutbreakCaseClassificationByNameDD { get; set; }
        public bool PrimaryCase { get; set; } = false;

        public long? idfNotificationSentByName { get; set; }
        public string? strNotificationSentByName { get; set; }
        public UserPermissions PermissionsAccessToNotification { get; set; }

        public List<BaseReferenceViewModel> YNExposureLocationKnownRD { get; set; }

        public List<BaseReferenceViewModel> ExposureLocationRD { get; set; }

        public LocationViewModel ExposureLocationAddress { get; set; }

        public Select2Configruation GroundTypeDD { get; set; }

        public Select2Configruation ForeignCountryDD { get; set; }

        public DateTime CurrentDate { get; set; }

        public double? dblPointAlignment { get; set; }
        public double? dblPointAccuracy { get; set; }

        public bool IsReportClosed { get; set; } = false;
        public bool isOutbreakCase { get; set; } = false;
        public long OutbreakCaseClassificationID { get; set; }
        public string OutbreakCaseClassificationName { get; set; }
    }
}
