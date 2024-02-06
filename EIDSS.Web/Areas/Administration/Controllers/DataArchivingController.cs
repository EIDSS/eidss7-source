using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class DataArchivingController : BaseController
    {
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly ILocalizationClient _localizationClient;
        private readonly IPreferenceClient _preferenceClient;
        private ICrossCuttingService _iCrossCuttingService;
        private readonly IStringLocalizer _localizer;
        private readonly IConfiguration _configuration;
        private IUserConfigurationService _userConfigurationService;
        private IDataArchivingClient _IDataArchivingClient;
        public DataArchivingController(ICrossCuttingClient crossCuttingClient,
            ILocalizationClient localizationClient,
            IPreferenceClient preferenceClient,
            ITokenService tokenService,
             ICrossCuttingService crossCuttingService,
             IStringLocalizer localizer,
             IConfiguration configuration,
            IUserConfigurationService configurationService,
            IDataArchivingClient dataArchivingClient,
            ILogger<DataArchivingController> logger) : base(logger)
        {
            _crossCuttingClient = crossCuttingClient;
            _localizationClient = localizationClient;
            _preferenceClient = preferenceClient;
            _iCrossCuttingService = crossCuttingService;
            _localizer = localizer;
            _configuration = configuration;
            _userConfigurationService = configurationService;
            _IDataArchivingClient = dataArchivingClient;
        }
      
        public async Task<IActionResult> Index()
        {
            try
            {
                List<DataArchivingViewModel> list = new();
                list = await _IDataArchivingClient.GetDataArchivingSettingAsync();
                var requestmodel = new DataArchivingViewModel();

                if (list.Count > 0)
                {
                    requestmodel.archiveScheduledStartTime = "Occurs every day at " + list[0].archiveScheduledStartTime;
                    requestmodel.dataAgeforArchiveInYears = list[0].dataAgeforArchiveInYears;
                }
                else
                {
                    requestmodel.archiveScheduledStartTime = _localizer.GetString(HeadingResourceKeyConstants.DataArchivingSettingsNotSet);
                    requestmodel.dataAgeforArchiveInYears = 0;
                }

                return View(requestmodel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

    }



}
