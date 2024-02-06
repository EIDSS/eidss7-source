using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Localization.Helpers;
using EIDSS.Web.Abstracts;

namespace EIDSS.Web.Areas.Human.ViewModels.WeeklyReportingForm
{
    public class WeeklyReportingFormSearchViewModel
    {
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
        public long? AdminLevel1 { get; set; } = 0;
        public long? AdminLevel2 { get; set; } = 0;
        public WeeklyReportingFormGetRequestModel SearchCriteria { get; set; }
        public List<ReportFormViewModel> SearchResults { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public UserPermissions Permissions { get; set; }
        public SiteGetDetailViewModel SiteDetailViewModel { get; set; }
        public long BottomAdminLevel { get; set; }

    }

}

