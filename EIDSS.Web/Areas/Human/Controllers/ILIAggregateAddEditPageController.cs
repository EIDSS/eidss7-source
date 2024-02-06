using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using System.Web;

namespace EIDSS.Web.Areas.Human.Controllers
{
    [Area("Human")]
    [Controller]
    public class ILIAggregateAddEditPageController : BaseController
    {
        ILIAggregatePageViewModel _pageViewModel;
        private IILIAggregateFormClient _iliAggregateFormClient;
        private IOrganizationClient _organizationClient;
        private UserPermissions userPermissions;
        private IStringLocalizer _localizer;
        private string _formID;

        public List<ILIAggregateDetailViewModel> ILIAggregateDetails { get; set; }

        [Inject]
        IHttpContextAccessor HttpContext { get; set; }

        public ILIAggregateAddEditPageController(
            IILIAggregateFormClient iliAggregateFormClient,
            IOrganizationClient organizationClient,
            ITokenService tokenService,
            IStringLocalizer localizer,
            ILogger<ILIAggregateAddEditPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new ILIAggregatePageViewModel();
            _iliAggregateFormClient = iliAggregateFormClient;
            _organizationClient = organizationClient;
            _localizer = localizer;
            userPermissions = GetUserPermissions(PagePermission.CanManageBaseReferencePage);
            _pageViewModel.UserPermissions = userPermissions;
        }

        public async Task<IActionResult> Index(string queryData)
        {
            if (!string.IsNullOrEmpty(queryData))
            {
                _pageViewModel.FormID = queryData;

                // grab header data
                var request = new ILIAggregateFormSearchRequestModel();

                request.LanguageId = GetCurrentLanguage();
                request.Page = 1;
                request.PageSize = 10;
                request.SortColumn = "FormID";
                request.SortOrder = "desc";
                request.FormID = queryData;
                request.LegacyFormID = null;
                request.AggregateHeaderID = null;
                request.UserSiteID = Convert.ToInt64(authenticatedUser.SiteId);
                request.UserOrganizationID = null;
                request.ApplySiteFiltrationIndicator = false;
                request.HospitalID = null;
                request.StartDate = null;
                request.FinishDate = null;
                request.UserOrganizationID = null;
                request.UserEmployeeID = null;
                request.ApplySiteFiltrationIndicator = false;

                List<ILIAggregateViewModel> response = await _iliAggregateFormClient.GetILIAggregateList(request);
                IEnumerable<ILIAggregateViewModel> iliAggregateList = response;

                _pageViewModel.EnteredBy = iliAggregateList.ElementAt(0).UserName;
                _pageViewModel.DateEntered = iliAggregateList.ElementAt(0).DateEntered;
                _pageViewModel.DateLastSaved = iliAggregateList.ElementAt(0).DateLastSaved == iliAggregateList.ElementAt(0).DateEntered ? 
                    null : iliAggregateList.ElementAt(0).DateLastSaved;
                _pageViewModel.Week = iliAggregateList.ElementAt(0).Week;
                _pageViewModel.Year = iliAggregateList.ElementAt(0).Year;
                _pageViewModel.Site = iliAggregateList.ElementAt(0).OrganizationName;
                _pageViewModel.IdfAggregateHeader = iliAggregateList.ElementAt(0).AggregateHeaderKey;
            }
            else
            {
                _pageViewModel.DateEntered = DateTime.Now;


                var currentCulture = CultureInfo.CurrentCulture;
                var weekNo = currentCulture.Calendar.GetWeekOfYear(
                                DateTime.Now,
                                currentCulture.DateTimeFormat.CalendarWeekRule,
                                currentCulture.DateTimeFormat.FirstDayOfWeek);
                _pageViewModel.Week = weekNo;

                _pageViewModel.Year = DateTime.Now.Year;
                _pageViewModel.EnteredBy = authenticatedUser.LastName + ", " + authenticatedUser.FirstName;
                _pageViewModel.Site = authenticatedUser.Organization;
            }


            return View(_pageViewModel);
        }

    }
}
