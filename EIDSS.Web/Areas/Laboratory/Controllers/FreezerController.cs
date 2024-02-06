#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Laboratory;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Laboratory.Freezer;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Laboratory.Freezers;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels.Laboratory;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Radzen;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Areas.Laboratory.Controllers
{
    [Area("Laboratory")]
    [Controller]
    public class FreezerController : BaseController
    {
        private readonly FreezerPageViewModel _pageViewModel;
        private readonly IFreezerClient _client;
        private readonly IAdminClient _adminClient;
        private readonly UserPermissions _userPermissions;
        private readonly IStringLocalizer _localizer;

        /// <summary>
        /// 
        /// </summary>
        /// <param name="client"></param>
        /// <param name="adminClient"></param>
        /// <param name="tokenService"></param>
        /// <param name="localizer"></param>
        /// <param name="logger"></param>
        public FreezerController(
            IFreezerClient client,
            IAdminClient adminClient,
            ITokenService tokenService,
            IStringLocalizer localizer,
            ILogger<FreezerController> logger) : base(logger, tokenService)
        {
            _pageViewModel = new FreezerPageViewModel();
            _client = client;
            _adminClient = adminClient;
            _userPermissions = GetUserPermissions(PagePermission.CanManageRepositorySchema);
            _pageViewModel.UserPermissions = _userPermissions;
            _localizer = localizer;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public async Task<IActionResult> Index()
        {
            try
            {
                await InitializeModel();
                                                
                return View(_pageViewModel);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("Laboratory/Freezer/AdvancedSearch")]
        public async Task<ActionResult> AdvancedSearch([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);

                FreezerRequestModel request = new()
                {
                    LanguageID = GetCurrentLanguage(),
                    SiteList = authenticatedUser.SiteId,
                    FreezerName = IsNullOrEmpty(jsonObject["FreezerName"]?.ToString().Trim()) ? null : jsonObject["FreezerName"].ToString().Trim(),
                    Note = IsNullOrEmpty(jsonObject["Note"]?.ToString().Trim()) ? null : jsonObject["Note"].ToString().Trim(),
                    StorageTypeID = Convert.ToInt64(jsonObject["StorageType"]?.ToString()) == 0 ? null : Convert.ToInt64(jsonObject["StorageType"]?.ToString().Trim()),
                    Building = IsNullOrEmpty(jsonObject["Building"]?.ToString().Trim()) ? null : jsonObject["Building"].ToString().Trim(),
                    Room = IsNullOrEmpty(jsonObject["Room"]?.ToString().Trim()) ? null : jsonObject["Room"].ToString().Trim(),
                    SearchString = null,
                    PaginationSet = 1,
                    PageSize = 9999,
                    MaxPagesPerFetch = 9999
                };

                var lstFreezersFiltered = await _client.GetFreezerList(request);

                HttpSessionHelper.Set(HttpContext.Session, "FreezersFiltered", lstFreezersFiltered);

                return Json("");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, data);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("Laboratory/Freezer/EditFreezer")]
        public async Task<ActionResult> EditFreezer([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);

                FreezerSubdivisionRequestModel subdivisionRequest = new()
                {
                    LanguageID = GetCurrentLanguage(),
                    SiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    FreezerID = Convert.ToInt64(jsonObject["FreezerId"]?.ToString())
                };
                var lstFreezerSubdivisions = await _client.GetFreezerSubdivisionList(subdivisionRequest);

                FreezerViewModel freezer = new();

                if (lstFreezerSubdivisions.Count > 0)
                {
                    freezer.FreezerID = lstFreezerSubdivisions[0].FreezerID;
                    freezer.FreezerName = lstFreezerSubdivisions[0].FreezerName;
                    freezer.FreezerNote = lstFreezerSubdivisions[0].FreezerNote;
                    freezer.StorageTypeID = lstFreezerSubdivisions[0].StorageTypeID;
                    freezer.Building = lstFreezerSubdivisions[0].Building;
                    freezer.Room = lstFreezerSubdivisions[0].Room;
                    freezer.EIDSSFreezerID = lstFreezerSubdivisions[0].FreezerBarCode;
                    freezer.OrganizationID = lstFreezerSubdivisions[0].OrganizationID;
                    freezer.FreezerSubdivisions = lstFreezerSubdivisions;
                }
                else
                {                    
                    var lstFreezers = await GetFreezers();                    
                    _pageViewModel.FreezerList = lstFreezers;
                    freezer = lstFreezers.First(f => f.FreezerID == subdivisionRequest.FreezerID);
                    freezer.FreezerSubdivisions = new List<FreezerSubdivisionViewModel>();                    
                }

                return Json(freezer);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, data);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("Laboratory/Freezer/DeleteFreezer")]
        public async Task<ActionResult> DeleteFreezer([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);

                FreezerSubdivisionRequestModel subdivisionRequest = new()
                {
                    LanguageID = GetCurrentLanguage(),
                    SiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    FreezerID = Convert.ToInt64(jsonObject["FreezerId"]?.ToString())
                };
                var lstFreezerSubdivisions = await _client.GetFreezerSubdivisionList(subdivisionRequest);

                var canDeleteFreezerIndicator = lstFreezerSubdivisions.All(freezerSubdivision => CanDeleteSubdivision(freezerSubdivision, lstFreezerSubdivisions));

                return Json(canDeleteFreezerIndicator ? "Warning_Confirm_Delete_Text" : "Warning_Has_Samples_Body_Text");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, data);
                throw;
            }

            //return new EmptyResult();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("Laboratory/Freezer/DeleteFreezerConfirm")]
        public async Task<ActionResult> DeleteFreezerConfirm([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);

                FreezerSaveRequestModel saveRequest = new()
                {
                    LanguageID = GetCurrentLanguage(),
                    FreezerID = Convert.ToInt64(jsonObject["FreezerId"]?.ToString()),
                    OrganizationID = Convert.ToInt64(authenticatedUser.SiteId),
                    RowStatus = (int)RowStatusTypeEnum.Inactive, //delete
                    // BUILD THIS JSON?
                    FreezerSubdivisions = null // await BuildFreezerSubdivisionParameters(saveRequest.FreezerID);
                };

                APIPostResponseModel response = await _client.SaveFreezer(saveRequest);
                //APIPostResponseModel response = new APIPostResponseModel();
                return Json(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, data);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("Laboratory/Freezer/CopyFreezer")]
        public async Task<ActionResult> CopyFreezer([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);

                FreezerSubdivisionRequestModel subdivisionRequest = new()
                {
                    LanguageID = GetCurrentLanguage(),
                    SiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    FreezerID = Convert.ToInt64(jsonObject["FreezerId"]?.ToString())
                };
                var lstFreezerSubdivisions = await _client.GetFreezerSubdivisionList(subdivisionRequest);

                foreach (var sub in lstFreezerSubdivisions)
                {
                    sub.FreezerID *= -1;
                    sub.FreezerSubdivisionID *= -1;
                    sub.ParentFreezerSubdivisionID *= -1;
                    sub.FreezerName += " (Copy)"; //TODO: change to a localized value.
                    sub.EIDSSFreezerSubdivisionID = Empty;
                    sub.RowAction = "I"; //TODO: change over to integer and use the enumeration for row action types in the domain layer.                    
                }

                FreezerViewModel freezer = new();

                if (lstFreezerSubdivisions.Count > 0)
                {
                    freezer.FreezerID = lstFreezerSubdivisions[0].FreezerID;
                    freezer.FreezerName = lstFreezerSubdivisions[0].FreezerName;
                    freezer.FreezerNote = lstFreezerSubdivisions[0].FreezerNote;
                    freezer.StorageTypeID = lstFreezerSubdivisions[0].StorageTypeID;
                    freezer.Building = lstFreezerSubdivisions[0].Building;
                    freezer.Room = lstFreezerSubdivisions[0].Room;
                    //freezer.EIDSSFreezerID = lstFreezerSubdivisions[0].FreezerBarCode;
                    freezer.OrganizationID = lstFreezerSubdivisions[0].OrganizationID;
                    freezer.FreezerSubdivisions = lstFreezerSubdivisions;                    
                }
                else
                {
                    var lstFreezers = await GetFreezers();
                    //var lstFreezers = JsonConvert.DeserializeObject<List<FreezerViewModel>>(TempData["Freezers"].ToString());
                    freezer = lstFreezers.First(f => f.FreezerID == subdivisionRequest.FreezerID);
                    freezer.FreezerSubdivisions = new List<FreezerSubdivisionViewModel>();
                }

                return Json(freezer);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, data);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("Laboratory/Freezer/GetNodeDetails")]
        public ActionResult GetNodeDetails([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? Empty);

            try
            {               
                // Retrieve
                var str = HttpContext.Session.GetString("FreezerSubdivisions");
                var lstFreezerSubdivisions = JsonConvert.DeserializeObject<List<FreezerSubdivisionViewModel>>(str);
                var subdivision = lstFreezerSubdivisions.Where(x => x.FreezerSubdivisionID == Convert.ToInt64(jsonObject["SubdivisionId"]?.ToString())).ToList();

                return Json(subdivision);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, data);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("Laboratory/Freezer/SaveFreezer")]
        public async Task<ActionResult> SaveFreezer([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? Empty);
                FreezerSaveRequestModel saveRequest = new()
                {
                    FreezerName = jsonObject["freezerName"]?.ToString(),
                    FreezerID = Convert.ToInt64(jsonObject["freezerID"]?.ToString())
                };

                var lstFreezers = await GetFreezers();                
                _pageViewModel.FreezerList = lstFreezers;
                
                foreach (var r in from freezer in lstFreezers where freezer.FreezerName == saveRequest.FreezerName && freezer.FreezerID != saveRequest.FreezerID select new FreezerSaveRequestResponseModel()
                         {
                             ReturnMessage = "DOES EXIST",
                             StrDuplicateField = Format(_localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), freezer.FreezerName)
                         })
                {
                    return Json(r);
                }

                saveRequest.LanguageID = GetCurrentLanguage();
                saveRequest.StorageTypeID = Convert.ToInt64(jsonObject["storageTypeID"]?.ToString());
                saveRequest.OrganizationID = Convert.ToInt64(authenticatedUser.SiteId);
                saveRequest.FreezerNote = jsonObject["freezerNote"]?.ToString();
                saveRequest.EIDSSFreezerID = IsNullOrEmpty(jsonObject["eidssFreezerID"]?.ToString()) ? null : jsonObject["eidssFreezerID"].ToString();
                saveRequest.Building = jsonObject["building"]?.ToString();
                saveRequest.Room = jsonObject["room"]?.ToString();
                saveRequest.RowStatus = Convert.ToInt32(jsonObject["rowStatus"]?.ToString());
                saveRequest.AuditUserName = authenticatedUser.UserName;

                var lstSubdivisions = JsonConvert.DeserializeObject<List<FreezerSubdivisionViewModel>>(jsonObject["freezerSubdivisions"]?.ToString() ?? Empty);

                // find subdivisions marked for deletion and also mark for deletion their child subdivisions
                foreach (var sub1 in lstSubdivisions)
                {
                    switch (sub1.SubdivisionTypeID)
                    {
                        // shelf
                        case (long)FreezerSubdivisionTypeEnum.Shelf when sub1.RowStatus == (int)RowStatusTypeEnum.Inactive:
                        {
                            foreach (var sub2 in lstSubdivisions.Where(sub2 => sub2.SubdivisionTypeID == (long) FreezerSubdivisionTypeEnum.Rack && sub2.ParentFreezerSubdivisionID == sub1.FreezerSubdivisionID))
                            {
                                sub2.RowStatus = (int)RowStatusTypeEnum.Inactive;

                                foreach (var sub3 in lstSubdivisions.Where(sub3 => sub3.SubdivisionTypeID == (long)FreezerSubdivisionTypeEnum.Box && sub3.ParentFreezerSubdivisionID == sub2.FreezerSubdivisionID))
                                {
                                    sub3.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                }
                            }

                            break;
                        }
                        // rack
                        case (long)FreezerSubdivisionTypeEnum.Rack when sub1.RowStatus == (int)RowStatusTypeEnum.Inactive:
                        {
                            foreach (var sub2 in lstSubdivisions.Where(sub2 => sub2.SubdivisionTypeID == (long)FreezerSubdivisionTypeEnum.Box && sub2.ParentFreezerSubdivisionID == sub1.FreezerSubdivisionID))
                            {
                                sub2.RowStatus = (int)RowStatusTypeEnum.Inactive;
                            }

                            break;
                        }
                    }
                }

                    const string letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                    var lettersArray = letters.ToCharArray();

                    foreach (var sub in lstSubdivisions.Where(sub => sub.SubdivisionTypeID == (long) FreezerSubdivisionTypeEnum.Box))
                    {
                        if (sub.NumberOfLocations != null)
                        {
                            var sqrt = Math.Sqrt((double)sub.NumberOfLocations);

                            if (sub.BoxPlaceAvailabilityList is null || !sub.BoxPlaceAvailabilityList.Any())
                            {
                                sub.BoxPlaceAvailabilityList = IsNullOrEmpty(sub.BoxPlaceAvailability) ? new List<FreezerSubdivisionBoxLocationAvailability>() : JsonConvert.DeserializeObject<List<FreezerSubdivisionBoxLocationAvailability>>(sub.BoxPlaceAvailability);
                            }

                            for (var i = 0; i < sqrt; i++)
                            {
                                for (var j = 1; j <= sqrt; j++)
                                {
                                    if (sub.BoxPlaceAvailabilityList.All(x => x.BoxLocation != lettersArray[i] + j.ToString()))
                                    {
                                        sub.BoxPlaceAvailabilityList.Add(new FreezerSubdivisionBoxLocationAvailability
                                        {
                                            AvailabilityIndicator = true,
                                            BoxLocation = lettersArray[i] + j.ToString()
                                        });
                                    }
                                }
                            }
                        }

                        sub.BoxPlaceAvailability = JsonConvert.SerializeObject(sub.BoxPlaceAvailabilityList);
                    }
                  
                saveRequest.FreezerSubdivisions = JsonConvert.SerializeObject(lstSubdivisions);

                // save freezer                
                var response = await _client.SaveFreezer(saveRequest);

                // get new list
                //lstFreezers = await GetFreezers();
                //ModelState.Clear();
                //_pageViewModel.FreezerList = lstFreezers;

                return Json(response);                
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, data);
                throw;
            }
        }


        [HttpGet]
        [Route("Laboratory/ReloadFreezerList")]
        public async Task<ActionResult> ReloadFreezerList() 
        {
            ModelState.Clear();
            var lstFreezers = await GetFreezers();            
            _pageViewModel.FreezerList = lstFreezers;

            return Json(_pageViewModel.FreezerList);

            //return View("Index", _pageViewModel.FreezerList);
        }

        [HttpPost]
        [Route("Laboratory/Freezer")]
        public async Task<ActionResult> Index(FreezerPageViewModel model) //([FromBody] JsonElement data)
        {
            ModelState.Clear();
            await InitializeModel();

            if (model.ShowBarcodeModal)
            {
                _pageViewModel.FreezerBarcodeParameters = new List<KeyValuePair<string, string>>
                {
                    new("LangID", GetCurrentLanguage()),
                    new("BarCodeLabelCode",
                        model.BarcodeLabelCode ?? model.SubdivisionBarcodeLabelCode),
                    new("BarCodeLabelTitle", model.FreezerName)
                };
                _pageViewModel.FreezerBarcodeParametersJSON = System.Text.Json.JsonSerializer.Serialize(_pageViewModel.FreezerBarcodeParameters);

            }

            if (model.ShowPrintModal)
            {
                _pageViewModel.PrintParameters = new List<KeyValuePair<string, string>>
                {
                    new("FreezerID", model.SelectedFreezerId.ToString()),
                    new("SiteID", _tokenService.GetAuthenticatedUser().SiteId),
                    new("LangID", GetCurrentLanguage()),
                    new("PersonID", _tokenService.GetAuthenticatedUser().PersonId),
                    new("PageSize", "10"),
                    new("ReportTitle", "Print")
                };

                _pageViewModel.PrintParametersJSON = System.Text.Json.JsonSerializer.Serialize(_pageViewModel.PrintParameters);                
            }
            _pageViewModel.ShowBarcodeModal = model.ShowBarcodeModal;
            _pageViewModel.ShowPrintModal = model.ShowPrintModal;
            _pageViewModel.SelectedFreezerId = model.SelectedFreezerId;
            _pageViewModel.SelectedSubdivisionId = model.SelectedSubdivisionId;

            return View("Index", _pageViewModel);
        }

        private async Task InitializeModel()
        {
            // get storage types
            var storageTypes = await _adminClient.GetBaseReferenceListAsync(
                GetCurrentLanguage(),
                (long)ReferenceTypes.Storage,
                1,
                99999,
                "intOrder",
                SortConstants.Ascending);

            var lstStorageTypes = storageTypes.ToList();
            lstStorageTypes.Insert(0, new Domain.ViewModels.Administration.BaseReferenceEditorsViewModel
            {
                StrName = Empty,
                KeyId = 0
            });

            _pageViewModel.StorageTyleList = lstStorageTypes;

            // get subdivision type (shelf, rack, box)                
            var subdivisionTypes = await _adminClient.GetBaseReferenceListAsync(
                GetCurrentLanguage(),
                (long)ReferenceTypes.Subdivision,
                1,
                99999,
                "intOrder",
                SortConstants.Ascending);

            var lstSubdivisionTypes = subdivisionTypes.ToList();
            lstSubdivisionTypes.Insert(0, new Domain.ViewModels.Administration.BaseReferenceEditorsViewModel
            {
                StrName = Empty,
                KeyId = -1
            });

            _pageViewModel.SubdivisionTypeList = lstSubdivisionTypes;

            // get box size types 
            var boxSizeTypes = await _adminClient.GetBaseReferenceListAsync(
                GetCurrentLanguage(),
                (long)ReferenceTypes.BoxSize,
                1,
                99999,
                "intOrder",
                SortConstants.Ascending);

            var lstBoxSizeTypes = boxSizeTypes.ToList();
            lstBoxSizeTypes.Insert(0, new Domain.ViewModels.Administration.BaseReferenceEditorsViewModel
            {
                StrName = Empty,
                KeyId = -1
            });

            _pageViewModel.BoxSizeTypeList = lstBoxSizeTypes;

            _pageViewModel.SiteID = authenticatedUser.SiteId;

            // check if there is a filtered list first and return it
            var lstFreezersFiltered = HttpSessionHelper.Get<List<FreezerViewModel>>(HttpContext.Session, "FreezersFiltered");

            if (lstFreezersFiltered != null)
            {
                _pageViewModel.FreezerList = lstFreezersFiltered;
                HttpSessionHelper.Set<List<FreezerViewModel>>(HttpContext.Session, "FreezersFiltered", null);
            }
            else
            {
                var lstFreezers = await GetFreezers();
                _pageViewModel.FreezerList = lstFreezers;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="freezerSubdivision"></param>
        /// <param name="lstFreezerSubdivisions"></param>
        /// <returns></returns>
        private static bool CanDeleteSubdivision(FreezerSubdivisionViewModel freezerSubdivision, List<FreezerSubdivisionViewModel> lstFreezerSubdivisions)
        {
            var boxLocationAvailability = new List<FreezerSubdivisionBoxLocationAvailability>();

            if (!IsNullOrEmpty(freezerSubdivision.BoxPlaceAvailability))
            {
                boxLocationAvailability = JsonConvert.DeserializeObject<List<FreezerSubdivisionBoxLocationAvailability>>(freezerSubdivision.BoxPlaceAvailability);
            }

            if (lstFreezerSubdivisions.Any(x => x.ParentFreezerSubdivisionID == freezerSubdivision.FreezerSubdivisionID && x.ParentFreezerSubdivisionID != null))
            {
                freezerSubdivision.RowAction = RecordConstants.Delete;
                freezerSubdivision.RowStatus = (int)RowStatusTypeEnum.Inactive;
                return true;
            }
            else
            {
                if (boxLocationAvailability.Count > 0)
                {
                    if (boxLocationAvailability.Any(x => x.AvailabilityIndicator == false))
                    {
                        return false;
                    }
                    else
                    {
                        freezerSubdivision.RowAction = RecordConstants.Delete;
                        freezerSubdivision.RowStatus = (int)RowStatusTypeEnum.Inactive;
                        return true;
                    }
                }
                else
                {
                    freezerSubdivision.RowAction = RecordConstants.Delete;
                    freezerSubdivision.RowStatus = (int)RowStatusTypeEnum.Inactive;
                    return true;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private async Task<List<FreezerViewModel>> GetFreezers()
        {

            FreezerRequestModel request = new()
            {
                LanguageID = GetCurrentLanguage(),
                SiteList = authenticatedUser.SiteId,
                FreezerName = null,
                Note = null,
                StorageTypeID = null,
                Building = null,
                Room = null,
                SearchString = null,
                PaginationSet = 1,
                PageSize = 9999,
                MaxPagesPerFetch = 9999
            };

            return await _client.GetFreezerList(request);
        }
    }
}