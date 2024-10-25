using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Web.ViewModels;
using Microsoft.Extensions.Logging;
using EIDSS.Web.Abstracts;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;

namespace EIDSS.Web.Controllers.CrossCutting
{
    [Route("CrossCutting/BaseReference")]
    public class ConfigurationController : BaseController
    {
        private readonly ICrossCuttingClient _crossCuttingClient;

        public ConfigurationController(ICrossCuttingClient crossCuttingClient, ILogger<ConfigurationController> logger) : base(logger)
        {
            _crossCuttingClient = crossCuttingClient;
        }

        public IActionResult Index()
        {
            return View();
        }

        [Route("BaseReferenceList")]
        public async Task<JsonResult> BaseReferenceListForSelect2DropDown(string ReferenceType, int intHACode = 510)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            Pagination _pagination = new();

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), ReferenceType, intHACode);

                if (list != null)
                {
                    foreach (var item in list)
                    {
                        select2DataItems.Add(new Select2DataItem() { id = item.IdfsBaseReference.ToString(), text = item.Name });
                    }
                }
                select2DataObj.results = select2DataItems;
                select2DataObj.pagination = _pagination;
            }
            catch (Exception)
            {
                throw;
            }
            return Json(select2DataObj);
        }

        /// <summary>
        /// Returns Base Reference Data Formatted for a Select2 DropDownList
        /// </summary>
        /// <param name="page"></param>
        /// <param name="data"></param>
        /// <returns></returns>
        public async Task<JsonResult> GetBaseReferenceTypesForSelect2DropDown(int page, string data)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            Pagination _pagination = new();

            try
            {
                _pagination.more = true;
                var baseReferenceTypeListViewModel = await _crossCuttingClient.GetReferenceTypes(GetCurrentLanguage());
                if (baseReferenceTypeListViewModel != null)
                {
                    foreach (var item in baseReferenceTypeListViewModel)
                    {
                        select2DataItems.Add(new Select2DataItem() { id = item.BaseReferenceId.ToString(), text = item.Name });
                    }
                }
                select2DataObj.results = select2DataItems;
                select2DataObj.pagination = _pagination;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { page, data });
                throw;
            }

            return Json(select2DataObj);
        }


    }
}
