#region Using Statements

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.Domain.RequestModels.Administration.Security;
using System.Linq;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.FlexForm;
using Newtonsoft.Json.Linq;
using System.Text.Json;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;


#endregion
namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class ConfigurationController : BaseController
    {


        #region Global Values

        readonly ICrossCuttingClient _crossCuttingClient;
        readonly ISiteClient _siteClient;
        readonly IDiseaseClient _diseaseClient;
        readonly IOrganizationClient _organizationClient;
        readonly IFlexFormClient _flexFormClient;
        readonly IEmployeeClient _employeeClient;
        readonly IConfigurationClient _configurationClient;
        readonly AuthenticatedUser _authenticatedUser;
        #endregion

       

        /// <summary>
        /// 
        /// </summary>
        /// <param name="crossCuttingClient"></param>
        /// <param name="diseaseClient"></param>
        /// <param name="organizationClient"></param>
        /// <param name="siteClient"></param>
        /// <param name="logger"></param>
        public ConfigurationController(ICrossCuttingClient crossCuttingClient, IDiseaseClient diseaseClient, IFlexFormClient flexFormClient, IEmployeeClient employeeClient,
            IOrganizationClient organizationClient, ISiteClient siteClient,IConfigurationClient configurationClient, ILogger<ConfigurationController> logger, ITokenService tokenService) : base(logger, tokenService)
        {
            _crossCuttingClient = crossCuttingClient;
            _diseaseClient = diseaseClient;
            _organizationClient = organizationClient;
            _siteClient = siteClient;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            _flexFormClient = flexFormClient;
            _employeeClient = employeeClient;
            _configurationClient = configurationClient;
        }



      
        public async Task<JsonResult> GetDiseaseSampleTypeByDiseasePaged(int page, string data, string term)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            Pagination _pagination = new();
            DiseaseSampleTypeByDiseaseRequestModel request = new DiseaseSampleTypeByDiseaseRequestModel();
            try
            {
                var v = JsonSerializer.Deserialize<List<Select2Data>>(data);

                if (v.Count > 0)
                {


                    request.idfsDiagnosis = long.Parse(v[0].id);
                    request.LanguageId = GetCurrentLanguage();
                    request.Page = 1;
                    request.PageSize = 10;
                    request.SortColumn = "strSampleType";
                    request.SortOrder = "asc";

                    var list = await _configurationClient.GetDiseaseSampleTypeByDiseasePaged(request);

                    if (list != null)
                    {
                        foreach (var item in list)
                        {
                            select2DataItems.Add(new Select2DataItem() { id = item.idfsSampleType.ToString(), text = item.strSampleType });
                        }
                    }
                    select2DataObj.results = select2DataItems;
                    select2DataObj.pagination = _pagination;
                }
            }
            catch (Exception ex)
            {
                throw;
            }
            return Json(select2DataObj);
        }

        public class Select2Data {
            public string id { get; set; }
            public string text { get; set; }
        }
    }
}
