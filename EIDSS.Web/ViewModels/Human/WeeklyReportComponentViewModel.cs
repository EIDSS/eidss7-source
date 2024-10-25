using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Human.WeeklyReporting;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System;   
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Web.ViewModels.Human
{
    public class WeeklyReportComponentViewModel : BaseComponent
    {
        // this controls the search
        public WeeklyReportComponentViewModel()
        {
            ReportFormPermissions = new();
            LstSentToOrganizations = new();
            EmployeeDetail = new();
        }

        [LocalizedRequired]
        public long? UserSiteID { get; set; }
        [LocalizedRequired]
        public long? UserOrganizationID { get; set; }
        [LocalizedRequired]
        public long? UserEmployeeID { get; set; }
        [LocalizedRequired]
        public long? EIDSS_UuserID { get; set; }
        public bool DefaultRegionShown { get; set; }
        public bool DefaultRayonShown { get; set; }
        
        public EmployeeDetailRequestResponseModel EmployeeDetail { get; set; }

        public string InformationalMessage { get; set; }

        public long? AdministrativeUnitTypeID { get; set; }

        public LocationViewModel ReportFormLocationModel; 

        public UserPermissions ReportFormPermissions;

        public ReportViewModel ReportModel { get; set; }
        public List<KeyValuePair<string, string>> ReportParameters { get; set; }

        public List<OrganizationAdvancedGetListViewModel> LstSentToOrganizations { get; set; }

        // add Month and Year properties 
        // then add drop down to bind to the drop downs
        // bind those these properties
        // make sure in my component that these are populated with month and year
        [LocalizedRequired]
        public int? Year { get; set; }

        [LocalizedRequired]
        public string Week { get; set; }

        [LocalizedRequired]
        public int? CurrentYear { get; set; } = Convert.ToInt32(DateTime.Now.ToString("yyyy"));
        
        [LocalizedRequired]
        public string CurrentWeek { get; set; }

        // these are the Region/Rayon/District values from the LocationChange event
        public long? idfsLocation { get; set; }
        public long? AdminLevel0Value { get; set; }
        public long? AdminLevel1Value { get; set; }
        public long? AdminLevel2Value { get; set; }
        public long? AdminLevel3Value { get; set; }
        public long? idfsSettlement { get; set; }
        public string strAdminLevel3 { get; set; }

        public long? idfReportForm { get; set; }
        public string auditUpdateUser { get; set; }

        public string strReportFormID { get; set; } = string.Empty;
        
        public long? idfsReportFormType { get; set; } = 10506188;

        [LocalizedRequired]
        [MaxLength(2000)]
        public string strComments { get; set; }
        public long? DiseaseID { get; set; } = 9842390000000;
        public string DiseaseName { get; set; } = "A80";
        public int? Total { get; set; } = 0;
        public int? AmongNotified { get; set; }
        
        // Organization/Institution
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.WeeklyReportingFormDetailsNotificationSentByInstitutionFieldLabel))]
        public long? idfSentByOffice { get; set; }

        [LocalizedRequired]
        public string strSentByOffice { get; set; }

        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.WeeklyReportingFormDetailsNotificationSentByOfficerFieldLabel))]
        public long? idfSentByPerson { get; set; }

        [LocalizedRequired]
        public string strSentByPerson { get; set; }

        [LocalizedRequired]
        public string strEnteredByOffice { get; set; } 

        [LocalizedRequired]
        public long idfEnteredByPerson { get; set; }

        [LocalizedRequired]
        public string strEnteredByPerson { get; set; }

        [LocalizedRequired]
        public DateTime? datSentByDate { get; set; }
        [LocalizedRequired]
        public DateTime? datEnteredByDate { get; set; }
        public string strDateEnteredBy { get; set; }

        public DateTime? datStartDate { get; set; }
        public DateTime? datEndDate { get; set; }

        public string strStartDate { get; set; }
        public string strEndDate { get; set; }
        
        public long? SessionKey { get; set; }
        public bool IsReadonly { get; set; }

        [LocalizedRequired]
        public long? EnteredInstitution { get; set; }
        
        [LocalizedRequired]
        public long? EnteredOfficer { get; set; }
        
        [LocalizedRequired]
        public string duplicateRecordsFound { get; set; }

    }
}
