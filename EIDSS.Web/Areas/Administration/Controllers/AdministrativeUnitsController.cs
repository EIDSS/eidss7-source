using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Web.Areas.Administration.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using System.Web;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class AdministrativeUnitsController : BaseController
    {
        public AdministrativeUnitsController(
           ILogger<AdministrativeUnitsController> logger) : base(logger)
        {

        }

        public IActionResult Index()
        {
            return View();
        }


        public IActionResult Details(long adminLevelId, long? admin0Id , long? admin1Id, long? admin2Id , long? admin3Id, string nationalName, string defaultName, double? latitude, double? longitude, int? elevation,string strHasc,string strCode, long? settlementType,  bool isReadOnly = false )
        {

            AdministrativeUnitsPageDetailViewModel model = new AdministrativeUnitsPageDetailViewModel()
            {
                AdministrativeUnitsDetails = new()
                {
                    AdminLevel = adminLevelId,
                    idfsCountry = admin0Id,
                    Latitude = latitude,
                    Longitude= longitude,
                    Elevation = elevation,
                    NationalName= HttpUtility.UrlDecode(nationalName),
                    DefaultName= HttpUtility.UrlDecode(defaultName),
                    UniqueCode= HttpUtility.UrlDecode(strCode),
                    HascCode = HttpUtility.UrlDecode(strHasc),



                    EditLocationViewModel = new()
                    {
                        AdministrativeLevelId = adminLevelId,
                        AdminLevel0Value = admin0Id,
                        AdminLevel1Value= admin1Id,
                        AdminLevel2Value = admin2Id,
                        AdminLevel3Value = admin3Id,
                        Latitude= latitude,
                        Longitude= longitude,
                        Elevation =elevation,
                        SettlementType = settlementType
                    }
                    
                }
            };
            if (adminLevelId == 0)
            {
                model.AdministrativeUnitsDetails.EditLocationViewModel.OperationType = LocationViewOperationType.Add;
            }else
                model.AdministrativeUnitsDetails.EditLocationViewModel.OperationType = LocationViewOperationType.Edit;

            return View(model);

        }
    }
}
