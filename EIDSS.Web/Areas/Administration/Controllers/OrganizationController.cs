using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ResponseModels;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.ViewModels.Organization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.Controllers
{
    [Area("Administration")]
    [Controller]
    public class OrganizationController : BaseController
    {
        private readonly IOrganizationClient _organizationClient;

        public OrganizationController(IOrganizationClient organizationClient, ITokenService tokenService, ILogger<OrganizationController> logger) :
            base(logger, tokenService)
        {
            _organizationClient = organizationClient;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
        }

        public IActionResult List()
        {
            return View();
        }

        public IActionResult Details(long? id)
        {
            OrganizationDetailsViewModel model = new()
            {
                OrganizationKey = id
            };

            return View(model);
        }

        /// <summary>
        /// Deletes an organization.
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost()]
        public async Task<JsonResult> DeleteOrganization([FromBody] JsonElement data)
        {
            APIPostResponseModel response = new();

            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
                if (!string.IsNullOrEmpty(jsonObject.ToString()) && jsonObject["OrganizationKey"] != null)
                {
                    response = await _organizationClient.DeleteOrganization(long.Parse(jsonObject["OrganizationKey"].ToString()), authenticatedUser.UserName, false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json(response.ReturnMessage);
        }
    }
}