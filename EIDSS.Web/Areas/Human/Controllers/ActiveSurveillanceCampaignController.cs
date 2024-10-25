using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.ClientLibrary.ApiClients.Admin;
using Microsoft.Extensions.Logging;
using EIDSS.Web.ViewModels;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using Newtonsoft.Json.Linq;
using EIDSS.Domain.RequestModels.CrossCutting;
using System.Text.Json;
using EIDSS.ClientLibrary.Services;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Web.ViewModels.Administration;
using System.Text;
using System.Net.Http;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Web.ViewModels.Human;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Web.Areas.Shared.ViewModels;
using EIDSS.Domain.ViewModels.Common;

namespace EIDSS.Web.Areas.Human.Controllers
{
    [Area("Human")]
    [Controller]
    public class ActiveSurveillanceCampaignController : BaseController
    {
        public ActiveSurveillanceCampaignController(ITokenService tokenService, ILogger<ActiveSurveillanceCampaignController> logger) : base(logger, tokenService)
        {
        }
        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Details(long? CampaignID, bool isReadOnly = false)
        {
            ActiveSurveillanceCampaignViewModel model = new();
            model.ActiveSurveillanceCampaignDetail = new ActiveSurveillanceCampaignDetailViewModel();
            model.CampaignID = CampaignID;
            model.IsReadonly = isReadOnly;
            return View(model);
        }

        public IActionResult Add()
        {
            ActiveSurveillanceCampaignViewModel model = new();
            model.ActiveSurveillanceCampaignDetail = new ActiveSurveillanceCampaignDetailViewModel();
            model.CampaignID = null;
            model.IsReadonly = false;
            return View("Details", model);
        }

    }
}
