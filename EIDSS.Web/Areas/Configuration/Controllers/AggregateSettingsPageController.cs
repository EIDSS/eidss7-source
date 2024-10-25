using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class AggregateSettingsPageController : BaseController
    {
        private readonly AggregateSettingsListViewModel _pageViewModel;
        private readonly IAggregateSettingsClient _configurationClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly INotificationSiteAlertService _notificationService;
        private readonly ISiteClient _siteClient;
        private readonly AuthenticatedUser _authenticatedUser;
        private SiteGetDetailViewModel _siteDetails;

        public AggregateSettingsPageController(IAggregateSettingsClient configurationClient, ICrossCuttingClient crossCuttingClient, ISiteClient siteClient,
            INotificationSiteAlertService notificationSiteAlertService, ILogger<AggregateSettingsPageController> logger, ITokenService tokenService) : base(logger, tokenService)
        {
            _pageViewModel = new AggregateSettingsListViewModel();
            _configurationClient = configurationClient;
            _crossCuttingClient = crossCuttingClient;
            _siteClient = siteClient;
            _notificationService = notificationSiteAlertService;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            var userPermissions = GetUserPermissions(PagePermission.AccessToAggregateSettings);
            _pageViewModel.AccessToAggregateSettingsRead = userPermissions.Read;
            _pageViewModel.AccessToAggregateSettingsWrite = userPermissions.Write;
            userPermissions = GetUserPermissions(PagePermission.AccessToHumanAggregateDiseaseReports);
            _pageViewModel.AccessToHumanAggregateCaseRead = userPermissions.Read;
            _pageViewModel.AccessToHumanAggregateCaseWrite = userPermissions.Write;
            userPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);
            _pageViewModel.AccessToVetAggregateCaseRead = userPermissions.Read;
            _pageViewModel.AccessToVetAggregateCaseWrite = userPermissions.Write;
            userPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateActions);
            _pageViewModel.AccessToVetAggregateActionRead = userPermissions.Read;
            _pageViewModel.AccessToVetAggregateActionWrite = userPermissions.Write;

            _pageViewModel.UserPermissions = userPermissions;
        }

        public async Task<IActionResult> Index()
        {
            _siteDetails = await _siteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(_authenticatedUser.SiteId), Convert.ToInt64(_authenticatedUser.EIDSSUserId));
            if (_siteDetails.CustomizationPackageID == null) return View(_pageViewModel);
            var loadViewModel = await LoadAggregateSettings((long)_siteDetails.CustomizationPackageID, (long)_siteDetails.SiteID);
            _pageViewModel.AggregateSettings = loadViewModel.AggregateSettings;
            _pageViewModel.PeriodType = loadViewModel.PeriodType;
            _pageViewModel.AreaType = loadViewModel.AreaType;

            return View(_pageViewModel);
        }

        private async Task<AggregateSettingsListViewModel> LoadAggregateSettings(long idfCustomizationPackage, long idfsSite)
        {
            var lstAreaType = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.StatisticalAreaType, null);
            var lstPeriodType = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.StatisticalPeriodType, null);

            var request = new AggregateSettingsGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                IdfCustomizationPackage = idfCustomizationPackage,
                idfsSite = idfsSite,
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "idfsAggrCaseType",
                SortOrder = "asc"
            };

            var lstAggregateSettings = await _configurationClient.GetAggregateSettingsList(request);

            AggregateSettingsListViewModel lstViewModel = new()
            {
                AreaType = lstAreaType,
                PeriodType = lstPeriodType,
                AggregateSettings = lstAggregateSettings
            };

            return lstViewModel;
        }

        public async Task<ActionResult> SaveAggregateSettings([FromBody] JsonElement data)
        {
            _siteDetails = await _siteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(_authenticatedUser.SiteId), Convert.ToInt64(_authenticatedUser.EIDSSUserId));
            var jsonArray = JArray.Parse(data.ToString() ?? string.Empty);
            long aggregateDiseaseReportTypeId = 0;
            AggregateSettingsSaveRequestModel request = new()
            {
                AggregateSettingRecordsList = new List<AggregateSettingRecordsSaveRequestModel>()
            };
            foreach (var item in jsonArray)
            {
                AggregateSettingRecordsSaveRequestModel record = new()
                {
                    AggregateDiseaseReportTypeId = string.IsNullOrEmpty(item["idfsAggrCaseType"]?.ToString()) ? 0 : (long)item["idfsAggrCaseType"],
                    CustomizationPackageId = _siteDetails.CustomizationPackageID,
                    SiteId = _siteDetails.SiteID,
                    StatisticalAreaTypeId = (long)item["idfsStatisticAreaType"],
                    StatisticalPeriodTypeId = (long)item["idfsStatisticPeriodType"]
                };

                if (!string.IsNullOrEmpty(item["idfsAggrCaseType"]?.ToString()))
                    aggregateDiseaseReportTypeId = (long)item["idfsAggrCaseType"];

                request.AggregateSettingRecordsList.Add(record);
            }
            request.AggregateSettingRecords = JsonConvert.SerializeObject(request.AggregateSettingRecordsList);

            var notification = await _notificationService.CreateEvent(aggregateDiseaseReportTypeId,
                    null, SystemEventLogTypes.AggregateSettingsChange, Convert.ToInt64(_authenticatedUser.SiteId), null);
            _notificationService.Events.Add(notification);
            request.Events = JsonConvert.SerializeObject(_notificationService.Events);

            request.User = _authenticatedUser.UserName;
            await _configurationClient.SaveAggregateSettings(request);

            return new EmptyResult();
        }
    }
}
