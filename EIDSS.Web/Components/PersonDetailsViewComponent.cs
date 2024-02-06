using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Web.Areas.Human.ViewModels;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.Abstracts;
using Microsoft.Extensions.Logging;
using EIDSS.ClientLibrary.Services;
using EIDSS.Web.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using System.Linq;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using Newtonsoft.Json.Linq;
using System.Text.Json;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.ViewModels.Person;
using Microsoft.Extensions.Localization;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels.CrossCutting;
using EIDSS.Web.ViewModels.Human;
using Microsoft.Extensions.Configuration;

namespace EIDSS.Web.Components
{
    [ViewComponent(Name = "PersonDetailsView")]
    public class PersonDetailsViewComponent : ViewComponent
    {
        //DiseaseReportComponentViewModel _diseaseReportComponentViewModel;
        private readonly IPersonClient _personClient;

        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfigurationClient _configurationClient;
        private IConfiguration _configuration;
        private IStringLocalizer _localizer;
        private AuthenticatedUser _autenticatedUser;
        private UserPreferences _userPreferences;
        public string CountryId { get; set; }

        public PersonDetailsViewComponent(IPersonClient personClient, IConfiguration configuration, IConfigurationClient configurationClient, ICrossCuttingClient crossCuttingClient, IStringLocalizer localizer, ITokenService tokenService)
        {
            _personClient = personClient;
            _autenticatedUser = tokenService.GetAuthenticatedUser();
            _configurationClient = configurationClient;
            _configuration = configuration;
            _userPreferences = _autenticatedUser.Preferences;
            _crossCuttingClient = crossCuttingClient;
            _localizer = localizer;
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
        }

        // GET: PersonController
        public IViewComponentResult Invoke(DiseaseReportPersonalInformationPageViewModel diseaseReportPersonalInformationPageViewModel)
        {
            return View(diseaseReportPersonalInformationPageViewModel);
        }
    }
}