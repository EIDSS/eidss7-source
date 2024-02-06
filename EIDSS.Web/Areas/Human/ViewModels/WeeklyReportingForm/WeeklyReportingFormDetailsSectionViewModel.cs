using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingForm
{
    public class WeeklyReportingFormDetailsSectionViewModel
    {
        public string ReportId { get; set; }
        [LocalizedRequired]
        public int Year  { get; set; }
        [LocalizedRequired]
        public string Week { get; set; }
        public LocationViewModel DetailsLocationViewModel { get; set; }
        [LocalizedRequired]
        public long NotificationInstitutionId  { get; set; }
        public string NotificationInstitutionName { get; set; }


        [LocalizedRequired]
        public long NotificationOfficer { get; set; }
        public string NotificationOfficerName { get; set; }

        [LocalizedRequired]
        public DateTime NotificationDate  { get; set; }
        public long EnteredInstitution { get; set; }
        public string EnteredInstitutionName { get; set; }
        public long EnteredOfficer { get; set; }
        public string EnteredOfficerName { get; set; }

        public DateTime EnteredDate { get; set; }
        public string DiseaseName { get; set; }
        public string DiseaseId { get; set; }
        public int Total { get; set; }
        public int Notified { get; set; }
        public string Comment { get; set; }

        public List<OrganizationGetListViewModel> NotificationSentByOrgList;

        public List<Select2Configruation> Select2Configurations { get; set; }

        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }





    }
}
