using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using Microsoft.Extensions.Logging;
using EIDSS.ClientLibrary.ApiClients.Admin;

namespace EIDSS.Web.Controllers.CrossCutting
{
    [Area("CrossCutting")]
    [Controller]
    public class LocationControlController : BaseController
    {
        readonly private ICrossCuttingClient _iCrossCuttingClient;
        readonly private ISettlementClient _iSettlementClient;

        public LocationControlController(ICrossCuttingClient iCrossCuttingClient, ISettlementClient iSettlementClient, ILogger<LocationControlController> logger) : base(logger)
        {
            _iCrossCuttingClient = iCrossCuttingClient;
            _iSettlementClient = iSettlementClient;
        }

        public IActionResult Index()
        {
            return View();
        }

        //[Route("GetGisLocationChildLevel")]
        //[ResponseCache(CacheProfileName = "Cache60")]
        public async Task<IActionResult> GetGisLocationChildLevel(long parentId)
        {
            var childLevelList = await _iCrossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(parentId));
            return Ok(childLevelList.OrderBy(x => x.Name));
        }

        //[Route("GetGisLocationCurrentLevel")]
        //[ResponseCache(CacheProfileName = "Cache60")]
        public async Task<IActionResult> GetGisLocationCurrentLevel(int level,bool allCountries=false)
        {
            var currentLevelList = await _iCrossCuttingClient.GetGisLocationCurrentLevel(GetCurrentLanguage(), level, allCountries);
            return Ok(currentLevelList.OrderBy(x => x.Name));
        }

        //[Route("GetGisSettlement")]
        //[ResponseCache(CacheProfileName = "Cache60")]
        public async Task<IActionResult> GetGisSettlement(long parentId, long? settlement, long settlementType)
        {
            var childLevelList = await _iCrossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(), Convert.ToString(parentId));

            var settlementList = await _iCrossCuttingClient.GetSettlementList(GetCurrentLanguage(), parentId, settlement);

            if(settlementType == 0)
                return Ok(settlementList.OrderBy(x => x.strSettlementName));
            else
                return Ok(settlementList.Where(x => x.SettlementType == settlementType).OrderBy(x => x.strSettlementName));
        }

        //[Route("GetSettlementTypeList")]
        //[ResponseCache(CacheProfileName = "Cache60")]
        public async Task<IActionResult> GetSettlementTypeList()
        {
            var settlementTypeList = await _iSettlementClient.GetSettlementTypeList(GetCurrentLanguage());
            return Ok(settlementTypeList);
        }

        //[Route("GetStreetList")]
        //[ResponseCache(CacheProfileName = "Cache60")]
        public async Task<IActionResult> GetStreetList(long settlementId)
        {
            var streetList = await _iCrossCuttingClient.GetStreetList(settlementId);
            return Ok(streetList);
        }

        //[Route("GetPostalCodeList")]
        //[ResponseCache(CacheProfileName = "Cache60")]
        public async Task<IActionResult> GetPostalCodeList(long settlementId)
        {
            var postalCodeList = await _iCrossCuttingClient.GetPostalCodeList(settlementId);
            return Ok(postalCodeList);
        }
    }
}