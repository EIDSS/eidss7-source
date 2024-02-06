using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels.Configuration;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Localization;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Areas.Configuration.Controllers
{
    [Area("Configuration")]
    [Controller]
    public class VeterinarySanitaryActionMatrixPageController : BaseController
    {
        private readonly VeterinarySanitaryActionMatrixPageViewModel _pageViewModel;
        private readonly IVeterinarySanitaryActionMatrixClient _client;
        private readonly IMeasuresClient _measuresClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IStringLocalizer _localizer;

        public VeterinarySanitaryActionMatrixPageController(
            IVeterinarySanitaryActionMatrixClient client,
            ICrossCuttingClient crossCuttingClient,
            IMeasuresClient measuresClient,
            IStringLocalizer localizer,
            ITokenService tokenService,
            ILogger<VeterinarySanitaryActionMatrixPageController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new VeterinarySanitaryActionMatrixPageViewModel();
            _client = client;
            _measuresClient = measuresClient;
            _crossCuttingClient = crossCuttingClient;
            var userPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);
            _pageViewModel.UserPermissions = userPermissions;
            _localizer = localizer;
        }

        public async Task<IActionResult> Index()
        {
            _pageViewModel.MatrixVersionList = await GetMatrixVersionsByType(MatrixTypes.VeterinarySanitaryMeasures);
            _pageViewModel.DisableNewMatrix = DoesNonActiveMatrixExist(_pageViewModel.MatrixVersionList);
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            return View(_pageViewModel);
        }

        [Route("Configuration/VeterinarySanitaryActionMatrixPage/GetMatrix")]
        public async Task<IActionResult> GetMatrix(long id)
        {
            ViewBag.SelectedVersionId = id;
            _pageViewModel.MatrixVersionList = await GetMatrixVersionsByType(MatrixTypes.VeterinarySanitaryMeasures);
            _pageViewModel.MatrixList = await LoadMatrixList(id);
            _pageViewModel.MatrixName = _pageViewModel.MatrixVersionList.Find(v => v.IdfVersion == id).MatrixName;

            // activation date of the selected matrix
            var activationDate = _pageViewModel.MatrixVersionList.Find(v => v.IdfVersion == id).DatStartDate;
            if (activationDate != null)
                _pageViewModel.ActivationDate = ((DateTime)activationDate).ToShortDateString();

            // set the "active status" of the selected matrix
            if (activationDate == null)
            {
                _pageViewModel.VersionStatus = "nonactive";
            }
            else
            {
                var blnIsActive = _pageViewModel.MatrixVersionList.Find(v => v.IdfVersion == id).BlnIsActive;
                if (blnIsActive != null && (bool)blnIsActive)
                {
                    _pageViewModel.VersionStatus = "active";
                }
                else
                {
                    var isActive = _pageViewModel.MatrixVersionList.Find(v => v.IdfVersion == id).BlnIsActive;
                    if (isActive != null && !(bool)isActive)
                    {
                        _pageViewModel.VersionStatus = "inactive";
                    }
                }
            }

            _pageViewModel.DisableNewMatrix = DoesNonActiveMatrixExist(_pageViewModel.MatrixVersionList);
            _pageViewModel.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();

            // if we are active and we have a date then disable the calendar
            if (_pageViewModel.VersionStatus != "nonactive" && _pageViewModel.ActivationDate != null)
            {
                _pageViewModel.DisableCalendar = true;
            }

            return View("Index", _pageViewModel);
            //return new EmptyResult();
        }

        [HttpPost]
        [Route("Configuration/VeterinarySanitaryActionMatrixPage/ActivateMatrixVersion")]
        public async Task<ActionResult> ActivateMatrixVersion([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            HumanAggregateCaseMatrixRequestModel headerModel = new()
            {
                MatrixName = jsonObject["MatrixName"]?.ToString(),
                StartDate = DateTime.Now,
                IsActive = true,
                IsDefault = false,
                MatrixTypeId = MatrixTypes.VeterinarySanitaryMeasures,
                VersionId = Convert.ToInt64(jsonObject["IdfVersion"]),
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            // save matrix header 
            _ = await _crossCuttingClient.SaveMatrixVersion(headerModel);

            return new EmptyResult();
        }

        [HttpPost]
        [Route("Configuration/VeterinarySanitaryActionMatrixPage/DeleteMatrixVersion")]
        public async Task<ActionResult> DeleteMatrixVersion([FromBody] JsonElement data)
        {
            try
            {
                var jObject = JObject.Parse(data.ToString() ?? Empty);
                var response = await _crossCuttingClient.DeleteMatrixVersion((long)jObject["IdfVersion"]);
                return new EmptyResult();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        [HttpPost]
        [Route("Configuration/VeterinarySanitaryActionMatrixPage/SaveMatrix")]
        public async Task<ActionResult> SaveMatrix([FromBody] JsonElement data)
        {
            var jsonArray = JArray.Parse(data.ToString() ?? Empty);
            var isEmpty = (bool)jsonArray[0]["IsEmpty"];
            var isNew = (bool)jsonArray[0]["IsNew"];
            var activeStatus = Empty;
            if (jsonArray[0]["ActiveStatus"] != null) activeStatus = jsonArray[0]["ActiveStatus"].ToString();

            var isActive = !(activeStatus is "nonactive" or "inactive" || isNew);

            HumanAggregateCaseMatrixRequestModel headerModel = new()
            {
                MatrixName = jsonArray[0]["MatrixName"]?.ToString(),
                IsActive = isActive,
                IsDefault = false,
                MatrixTypeId = MatrixTypes.VeterinarySanitaryMeasures,
                EventTypeId = null,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            if (!IsNullOrEmpty(jsonArray[0]["ActivationDate"]?.ToString()) && !isNew)
                headerModel.StartDate = (DateTime)jsonArray[0]["ActivationDate"];

            if (jsonArray[0]["IdfVersion"] != null)
                headerModel.VersionId = Convert.ToInt64(jsonArray[0]["IdfVersion"]);

            // save matrix header 
            var headerResponse = await _crossCuttingClient.SaveMatrixVersion(headerModel);

            if (headerResponse.ReturnMessage != "SUCCESS") return Json(headerResponse);
            if (isEmpty) return Json(headerResponse);
            MatrixViewModel request = new()
            {
                IdfVersion = headerResponse.KeyId, //Convert.ToInt64(jsonArray[0]["IdfVersion"]),
                InJsonString = data.ToString(),
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            // save matrix grid     
            var response = await _client.SaveVeterinarySanitaryActionMatrix(request);

            //if (isNew) return Json(headerResponse.KeyId);
            return Json(headerResponse);

            //this will also work because i'm reloading the page from javascript which will call GetMatrix to grab the new data
            //return new EmptyResult();
            //return Json(response);
        }

        [HttpPost]
        [Route("Configuration/VeterinarySanitaryActionMatrixPage/DeleteMatrixRecord")]
        public async Task<ActionResult> DeleteMatrixRecord([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            var id = (long)jsonObject["IdfAggrSanitaryActionMTX"];

            if (id <= 0) return new EmptyResult();
            MatrixViewModel request = new()
            {
                idfAggrSanitaryActionMTX = id,
                EventTypeId = (long) SystemEventLogTypes.MatrixChange,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };
            var response = await _client.DeleteVeterinarySanitaryActionMatrixRecord(request);

            return Json(response);
        }

        [HttpPost]
        [Route("Configuration/VeterinarySanitaryActionMatrixPage/AddMeasure")]
        public async Task<IActionResult> AddMeasure([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            MeasuresSaveRequestModel request = new()
            {
                Default = jsonObject["Default"]?.ToString(),
                Name = jsonObject["Name"]?.ToString(),
                StrActionCode = jsonObject["Code"]?.ToString(),
                intOrder = !IsNullOrEmpty(jsonObject["Order"]?.ToString()) ? int.Parse(jsonObject["Order"].ToString()) : 0,
                IdfsReferenceType = ReferenceEditorType.Sanitary, //19000079
                LanguageId = GetCurrentLanguage(),
                EventTypeId = (long) SystemEventLogTypes.ReferenceTableChange,
                AuditUserName = authenticatedUser.UserName,
                LocationId = authenticatedUser.RayonId,
                SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
            };

            _ = await _measuresClient.SaveMeasure(request);

            return Json("");
        }

        private async Task<List<MatrixVersionViewModel>> GetMatrixVersionsByType(long matrixType)
        {
            var versions = await _crossCuttingClient.GetMatrixVersionsByType(matrixType);

            foreach (var v in versions)
            {
                v.IsCheckmarkVisible = true;

                if (v.DatStartDate != null)
                {
                    v.ActivationDateDisplay = Convert.ToDateTime(v.DatStartDate).ToShortDateString();
                }

                if (v.BlnIsActive != null && v.DatStartDate != null && (bool)v.BlnIsActive)
                {
                    v.ActiveColor = "red";
                    ViewBag.ActiveVersionId = v.IdfVersion;
                }
                else if (v.BlnIsActive != null && v.DatStartDate != null && !(bool)v.BlnIsActive)
                {
                    v.ActiveColor = "lightgreen";
                }
                else if (v.DatStartDate == null)
                {
                    v.ActiveColor = "rgba(255, 255, 255, 0);";
                }
            }

            return versions;
        }

        private bool DoesNonActiveMatrixExist(List<MatrixVersionViewModel> versions)
        {
            // find if there is at least one nonactive matrix already 
            // prevent multiple nonactive matrix from being created (business rule)
            //_pageViewModel.DisableNewMatrix = false;
            var nonActiveMatrix = _pageViewModel.MatrixVersionList.Find(v => v.DatStartDate == null);
            return nonActiveMatrix != null;
        }

        private async Task<List<VeterinarySanitaryActionMatrixViewModel>> LoadMatrixList(long selectedMatrixVersionId)
        {
            try
            {
                var lstSanitaryActionTypes = await _client.GetVeterinarySanitaryActionTypes(ReferenceEditorType.Sanitary, HACodeList.LivestockHACode, GetCurrentLanguage());
                var lstReport = await _client.GetVeterinarySanitaryActionMatrixReport(GetCurrentLanguage(), selectedMatrixVersionId);

                if (lstReport.Count > 0)
                {
                    // if intNumRow starts with 0, increment all by 1 so that inNumRow starts at 1
                    var r = lstReport.Find(r => r.IntNumRow == 0);
                    if (r != null)
                    {
                        foreach (var report in lstReport)
                        {
                            report.IntNumRow++;
                        }
                    }
                }
                else
                {
                    var matrixDetail = new VeterinarySanitaryActionMatrixViewModel
                    {
                        IntNumRow = 1
                    };
                    lstReport.Add(matrixDetail);

                    lstSanitaryActionTypes.Insert(0, new InvestigationTypeViewModel()
                    {
                        StrDefault = _localizer.GetString(ButtonResourceKeyConstants.SelectButton),
                        StrName = _localizer.GetString(ButtonResourceKeyConstants.SelectButton),
                        IdfsBaseReference = 0
                    });
                }

                foreach (var report in lstReport)
                {
                    report.SanitaryActionList = lstSanitaryActionTypes;
                }

                return lstReport;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }
    }
}
