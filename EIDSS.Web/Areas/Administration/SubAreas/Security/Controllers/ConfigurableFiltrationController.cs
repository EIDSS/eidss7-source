using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Administration.Security.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.Web.Administration.Security.Controllers
{
    [Area("Administration")]
    [SubArea("Security")]
    [Controller]
    public class ConfigurableFiltrationController : BaseController
    {
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfigurableFiltrationClient _configurableFiltrationClient;
        private readonly IStringLocalizer _localizer;
        private readonly UserPermissions _configurableFiltrationPermissions;

        [TempData]
        public string InformationalMessage { get; set; }

        public ConfigurableFiltrationController(IConfigurableFiltrationClient configurableFiltrationClient, ICrossCuttingClient crossCuttingClient, IStringLocalizer localizer, ITokenService tokenService,
            ILogger<ConfigurableFiltrationController> logger) : base(logger, tokenService)
        {
            _configurableFiltrationClient = configurableFiltrationClient;
            _crossCuttingClient = crossCuttingClient;
            _localizer = localizer;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _configurableFiltrationPermissions = GetUserPermissions(PagePermission.CanModifyRulesOfConfigurableFiltration);
        }

        /// <summary>
        /// Loads the list view.  This is the default view for this controller.
        /// </summary>
        /// <returns></returns>
        public IActionResult List()
        {
            ConfigurableFiltrationSearchViewModel model = new()
            {
                SearchCriteria = new AccessRuleGetRequestModel() { SortColumn = "AccessRuleID", SortOrder = EIDSSConstants.SortConstants.Ascending },
                ShowSearchResults = false,
                ConfigurableFiltrationPermissions = _configurableFiltrationPermissions
            };

            ViewBag.JavaScriptFunction = "showConfigurableFiltrationSearchCriteria();";

            return View(model);
        }

        [HttpPost()]
        public IActionResult List(ConfigurableFiltrationSearchViewModel model)
        {
            if (!ModelState.IsValid) return View(model);
            ViewBag.JavaScriptFunction = "hideConfigurableFiltrationSearchCriteria();";
            model.ShowSearchResults = true;
            model.ConfigurableFiltrationPermissions = _configurableFiltrationPermissions;

            return View(model);
        }

        [HttpPost()]
        [Route("GetAccessRuleListDataTable")]
        public async Task<JsonResult> GetAccessRuleListDataTable([FromBody] JQueryDataTablesQueryObject dataTableQueryPostObj)
        {
            try
            {
                var criteriaEnteredIndicator = false;

                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0,
                    draw = dataTableQueryPostObj.draw
                };

                if (!ModelState.IsValid) return Json(tableData);
                var postParameterDefinitions = new { SearchCriteria_AccessRuleID = "", SearchCriteria_AccessRuleName = "", SearchCriteria_BorderingAreaRuleIndicator = "", SearchCriteria_DefaultRuleIndicator = "", SearchCriteria_ReciprocalRuleIndicator = "", SearchCriteria_AccessToGenderAndAgeDataPermissionIndicator = "", SearchCriteria_AccessToPersonalDataPermissionIndicator = "", SearchCriteria_CreatePermissionIndicator = "", SearchCriteria_DeletePermissionIndicator = "", SearchCriteria_ReadPermissionIndicator = "", SearchCriteria_WritePermissionIndicator = "", SearchCriteria_GrantingActorSiteCode = "", SearchCriteria_GrantingActorSiteHASCCode = "", SearchCriteria_GrantingActorSiteName = "", SearchCriteria_ReceivingActorSiteCode = "", SearchCriteria_ReceivingActorSiteHASCCode = "", SearchCriteria_ReceivingActorSiteName = "" };
                var searchCriteria = JsonConvert.DeserializeAnonymousType(dataTableQueryPostObj.postArgs, postParameterDefinitions);

                if (!string.IsNullOrEmpty(Request.Cookies["ConfigurableFiltrationSearchPerformedIndicator"]))
                {
                    if (Request.Cookies["ConfigurableFiltrationSearchPerformedIndicator"] == "true")
                    {
                        if (!string.IsNullOrEmpty(Request.Cookies["ConfigurableFiltrationSearchCriteria"]))
                        {
                            searchCriteria = JsonConvert.DeserializeAnonymousType(Request.Cookies["ConfigurableFiltrationSearchCriteria"], postParameterDefinitions);

                            criteriaEnteredIndicator = true;
                        }

                        Response.Cookies.Append("ConfigurableFiltrationSearchPerformedIndicator", "false");
                    }
                }

                if (criteriaEnteredIndicator == false)
                {
                    if (!string.IsNullOrEmpty(searchCriteria.SearchCriteria_AccessRuleID)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_AccessRuleName)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_AccessToGenderAndAgeDataPermissionIndicator)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_AccessToPersonalDataPermissionIndicator)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_BorderingAreaRuleIndicator)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_CreatePermissionIndicator)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_DefaultRuleIndicator)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_DeletePermissionIndicator)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_GrantingActorSiteCode)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_GrantingActorSiteHASCCode)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_GrantingActorSiteName)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_ReadPermissionIndicator)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_ReceivingActorSiteCode)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_ReceivingActorSiteHASCCode)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_ReceivingActorSiteName)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_ReciprocalRuleIndicator)
                        || !string.IsNullOrEmpty(searchCriteria.SearchCriteria_WritePermissionIndicator))
                    {
                        criteriaEnteredIndicator = true;
                    }
                }

                if (!criteriaEnteredIndicator) return Json(tableData);
                var iPage = dataTableQueryPostObj.page;
                var iLength = dataTableQueryPostObj.length;

                //Get sorting values.
                dataTableQueryPostObj.ReturnSortParameter();

                var model = JsonConvert.DeserializeObject<AccessRuleGetRequestModel>(dataTableQueryPostObj.postArgs);
                model.LanguageId = GetCurrentLanguage();
                model.Page = iPage;
                model.PageSize = iLength;
                model.SortColumn = "AccessRuleID";
                model.SortOrder = EIDSSConstants.SortConstants.Ascending;
                model.AccessRuleID = string.IsNullOrEmpty(searchCriteria.SearchCriteria_AccessRuleID) ? null : Convert.ToInt64(searchCriteria.SearchCriteria_AccessRuleID);
                model.AccessRuleName = string.IsNullOrEmpty(searchCriteria.SearchCriteria_AccessRuleName) ? null : searchCriteria.SearchCriteria_AccessRuleName;
                model.AccessToGenderAndAgeDataPermissionIndicator = Convert.ToBoolean(searchCriteria.SearchCriteria_AccessToGenderAndAgeDataPermissionIndicator);
                model.AccessToPersonalDataPermissionIndicator = Convert.ToBoolean(searchCriteria.SearchCriteria_AccessToPersonalDataPermissionIndicator);
                model.BorderingAreaRuleIndicator = Convert.ToBoolean(searchCriteria.SearchCriteria_BorderingAreaRuleIndicator);
                model.CreatePermissionIndicator = Convert.ToBoolean(searchCriteria.SearchCriteria_CreatePermissionIndicator);
                model.DefaultRuleIndicator = Convert.ToBoolean(searchCriteria.SearchCriteria_DefaultRuleIndicator);
                model.DeletePermissionIndicator = Convert.ToBoolean(searchCriteria.SearchCriteria_DeletePermissionIndicator);
                model.GrantingActorSiteCode = string.IsNullOrEmpty(searchCriteria.SearchCriteria_GrantingActorSiteCode) ? null : searchCriteria.SearchCriteria_GrantingActorSiteCode;
                model.GrantingActorSiteHASCCode = string.IsNullOrEmpty(searchCriteria.SearchCriteria_GrantingActorSiteHASCCode) ? null : searchCriteria.SearchCriteria_GrantingActorSiteHASCCode;
                model.GrantingActorSiteName = string.IsNullOrEmpty(searchCriteria.SearchCriteria_GrantingActorSiteName) ? null : searchCriteria.SearchCriteria_GrantingActorSiteName;
                model.ReadPermissionIndicator = Convert.ToBoolean(searchCriteria.SearchCriteria_ReadPermissionIndicator);
                model.ReceivingActorSiteCode = string.IsNullOrEmpty(searchCriteria.SearchCriteria_ReceivingActorSiteCode) ? null : searchCriteria.SearchCriteria_ReceivingActorSiteCode;
                model.ReceivingActorSiteHASCCode = string.IsNullOrEmpty(searchCriteria.SearchCriteria_ReceivingActorSiteHASCCode) ? null : searchCriteria.SearchCriteria_ReceivingActorSiteHASCCode;
                model.ReceivingActorSiteName = string.IsNullOrEmpty(searchCriteria.SearchCriteria_ReceivingActorSiteName) ? null : searchCriteria.SearchCriteria_ReceivingActorSiteName;
                model.ReciprocalRuleIndicator = Convert.ToBoolean(searchCriteria.SearchCriteria_ReciprocalRuleIndicator);
                model.WritePermissionIndicator = Convert.ToBoolean(searchCriteria.SearchCriteria_WritePermissionIndicator);

                var list = await _configurableFiltrationClient.GetAccessRuleList(model);
                IEnumerable<AccessRuleGetListViewModel> accessRuleList = list;

                Response.Cookies.Append("ConfigurableFiltrationSearchCriteria", dataTableQueryPostObj.postArgs);

                if (list.Count <= 0) return Json(tableData);
                tableData.data.Clear();
                tableData.iTotalRecords = (int)list[0].RecordCount;
                tableData.iTotalDisplayRecords = (int)list[0].RecordCount;
                tableData.recordsTotal = (int)list[0].RecordCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        accessRuleList.ElementAt(i).AccessRuleID.ToString(),
                        accessRuleList.ElementAt(i).AccessRuleName,
                        accessRuleList.ElementAt(i).BorderingAreaRuleIndicator
                            ? _localizer.GetString(FieldLabelResourceKeyConstants.YesFieldLabel)
                            : _localizer.GetString(FieldLabelResourceKeyConstants.NoFieldLabel),
                        accessRuleList.ElementAt(i).DefaultRuleIndicator
                            ? _localizer.GetString(FieldLabelResourceKeyConstants.YesFieldLabel)
                            : _localizer.GetString(FieldLabelResourceKeyConstants.NoFieldLabel),
                        accessRuleList.ElementAt(i).ReciprocalRuleIndicator
                            ? _localizer.GetString(FieldLabelResourceKeyConstants.YesFieldLabel)
                            : _localizer.GetString(FieldLabelResourceKeyConstants.NoFieldLabel)
                    };

                    tableData.data.Add(cols);
                }

                return Json(tableData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost()]
        [Route("DuplicateActorCheck")]
        public async Task<JsonResult> DuplicateActorCheck([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

                var request = new AccessRuleGetRequestModel()
                {
                    GrantingActorSiteGroupID = string.IsNullOrEmpty(jsonObject["GrantingActorSiteGroupID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["GrantingActorSiteGroupID"]),
                    GrantingActorSiteID = string.IsNullOrEmpty(jsonObject["GrantingActorSiteID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["GrantingActorSiteID"]),
                    ReceivingActorSiteGroups = string.IsNullOrEmpty(jsonObject["SiteGroups"]?.ToString()) ? null : jsonObject["SiteGroups"].ToString(),
                    ReceivingActorSites = string.IsNullOrEmpty(jsonObject["Sites"]?.ToString()) ? null : jsonObject["Sites"].ToString(),
                    ReceivingActorUserGroups = string.IsNullOrEmpty(jsonObject["UserGroups"]?.ToString()) ? null : jsonObject["UserGroups"].ToString(),
                    ReceivingActorUsers = string.IsNullOrEmpty(jsonObject["Users"]?.ToString()) ? null : jsonObject["Users"].ToString()
                };

                {
                    request.Page = 1;
                    request.PageSize = 10;
                    request.SortColumn = "AccessRuleID";
                    request.SortOrder = EIDSSConstants.SortConstants.Ascending;

                    var list = await _configurableFiltrationClient.GetAccessRuleList(request);

                    return Json(list.Count <= 0 ? "false" : "true");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task<IActionResult> Details(long? id)
        {
            try
            {
                ConfigurableFiltrationDetailsViewModel model;

                if (id == null)
                {
                    model = new ConfigurableFiltrationDetailsViewModel
                    {
                        AccessRuleDetails = new AccessRuleGetDetailViewModel(),
                        DeleteVisibleIndicator = false,
                        SearchActorViewModel = new SearchActorViewModel()
                    };
                }
                else
                {
                    model = new ConfigurableFiltrationDetailsViewModel
                    {
                        AccessRuleDetails = await _configurableFiltrationClient.GetAccessRuleDetail(GetCurrentLanguage(), (long)id),
                        DeleteVisibleIndicator = _configurableFiltrationPermissions.Execute,
                        SearchActorViewModel = new SearchActorViewModel()
                    };

                    TempData["AccessRuleID"] = model.AccessRuleDetails.AccessRuleID.ToString();
                }

                model.SearchActorViewModel.ModalTitle = _localizer.GetString(HeadingResourceKeyConstants.SearchActorsModalHeading);
                model.SearchActorViewModel.ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Employee Type", 0).ConfigureAwait(false);
                BaseReferenceViewModel actorType = new()
                {
                    IdfsBaseReference = Convert.ToInt64(ActorTypeEnum.Site),
                    Name = _localizer.GetString(FieldLabelResourceKeyConstants.SiteFieldLabel)
                };
                model.SearchActorViewModel.ActorTypeList.Add(actorType);
                actorType = new BaseReferenceViewModel
                {
                    IdfsBaseReference = Convert.ToInt64(ActorTypeEnum.SiteGroup),
                    Name = _localizer.GetString(FieldLabelResourceKeyConstants.SiteGroupFieldLabel)
                };
                model.SearchActorViewModel.ActorTypeList.Add(actorType);

                model.SearchActorViewModel.SearchCriteria = new();

                return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost()]
        public async Task<JsonResult> GetReceivingActorList([FromBody] long? accessRuleId)
        {
            try
            {
                var model = new AccessRuleActorGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessRuleID = accessRuleId,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "ActorName",
                    SortOrder = EIDSSConstants.SortConstants.Ascending,
                };

                List<AccessRuleActorGetListViewModel> list = new();

                if (accessRuleId != null)
                    list = await _configurableFiltrationClient.GetAccessRuleActorList(model);

                TableData tableData = new()
                {
                    data = new List<List<string>>(),
                    draw = 1,
                    iTotalRecords = 0,
                    iTotalDisplayRecords = 0
                };

                if (list.Count <= 0) return Json(tableData);
                tableData.iTotalRecords = list[0].TotalRowCount;
                tableData.iTotalDisplayRecords = list[0].TotalRowCount;

                for (var i = 0; i < list.Count; i++)
                {
                    List<string> cols = new()
                    {
                        list.ElementAt(i).AccessRuleActorID.ToString(),
                        list.ElementAt(i).AccessRuleID.ToString(),
                        list.ElementAt(i).ActorTypeID.ToString(),
                        list.ElementAt(i).ActorTypeName,
                        list.ElementAt(i).ActorName,
                        list.ElementAt(i).SiteName,
                        list.ElementAt(i).ActorSiteGroupID.ToString(),
                        list.ElementAt(i).ActorSiteID.ToString(),
                        list.ElementAt(i).ActorEmployeeGroupID.ToString(),
                        list.ElementAt(i).ActorUserID.ToString(),
                        list.ElementAt(i).AccessToGenderAndAgeDataPermissionIndicator.ToString(),
                        list.ElementAt(i).AccessToPersonalDataPermissionIndicator.ToString(),
                        list.ElementAt(i).CreatePermissionIndicator.ToString(),
                        list.ElementAt(i).DeletePermissionIndicator.ToString(),
                        list.ElementAt(i).ReadPermissionIndicator.ToString(),
                        list.ElementAt(i).WritePermissionIndicator.ToString(),
                        list.ElementAt(i).RowStatus.ToString(),
                        list.ElementAt(i).RowAction.ToString(),
                        list.ElementAt(i).AccessRuleActorID.ToString()
                    };

                    tableData.data.Add(cols);
                }

                return Json(tableData);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [HttpPost()]
        [Route("SaveAccessRule")]
        public async Task<IActionResult> SaveAccessRule([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);

                ConfigurableFiltrationDetailsViewModel model = new()
                {
                    AccessRuleDetails = new AccessRuleGetDetailViewModel
                    {
                        AccessRuleID = string.IsNullOrEmpty(jsonObject["AccessRuleID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["AccessRuleID"]),
                        AccessRuleName = jsonObject["AccessRuleName"]?.ToString(),
                        AccessToGenderAndAgeDataPermissionIndicator = Convert.ToBoolean(jsonObject["AccessToGenderAndAgeDataPermissionIndicator"]?.ToString()),
                        AccessToPersonalDataPermissionIndicator = Convert.ToBoolean(jsonObject["AccessToPersonalDataPermissionIndicator"]?.ToString()),
                        BorderingAreaRuleIndicator = Convert.ToBoolean(jsonObject["BorderingAreaRuleIndicator"]?.ToString()),
                        CreatePermissionIndicator = Convert.ToBoolean(jsonObject["CreatePermissionIndicator"]?.ToString()),
                        DefaultRuleIndicator = Convert.ToBoolean(jsonObject["DefaultRuleIndicator"]?.ToString()),
                        DeletePermissionIndicator = Convert.ToBoolean(jsonObject["DeletePermissionIndicator"]?.ToString()),
                        GrantingActorSiteGroupID = string.IsNullOrEmpty(jsonObject["GrantingActorSiteGroupID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["GrantingActorSiteGroupID"]),
                        GrantingActorSiteID = string.IsNullOrEmpty(jsonObject["GrantingActorSiteID"]?.ToString()) ? null : Convert.ToInt64(jsonObject["GrantingActorSiteID"]),
                        ReadPermissionIndicator = Convert.ToBoolean(jsonObject["ReadPermissionIndicator"].ToString()),
                        ReciprocalRuleIndicator = Convert.ToBoolean(jsonObject["ReciprocalRuleIndicator"].ToString()),
                        RowStatus = (int)RowStatusTypeEnum.Active,
                        WritePermissionIndicator = Convert.ToBoolean(jsonObject["WritePermissionIndicator"].ToString())
                    },
                    DeleteVisibleIndicator = false,
                    ReceivingActors = jsonObject["ReceivingActors"].ToString(),
                };

                ModelState.ClearValidationState(nameof(AccessRuleGetDetailViewModel));
                if (!TryValidateModel(model.AccessRuleDetails, nameof(AccessRuleGetDetailViewModel)))
                {
                    model.ErrorMessage = "The record is not valid.  Please verify all data and correct any errors.";
                    return Json(model);
                }

                if (!ModelState.IsValid) return Json(model);

                AccessRuleSaveRequestModel request = new() { AccessRuleDetails = model.AccessRuleDetails, LanguageId = GetCurrentLanguage(), ReceivingActors = model.ReceivingActors, User = authenticatedUser.UserName };
                var response = await _configurableFiltrationClient.SaveAccessRule(request);

                if (response.ReturnCode != null)
                {
                    if (response.ReturnCode == 0)
                    {
                        if (model.AccessRuleDetails.AccessRuleID == null)
                        {
                            model.AccessRuleDetails.AccessRuleID = response.KeyId;

                            model.InformationalMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.AccessRuleCreatedSuccessfullyMessage) + ".", response.KeyId.ToString());
                        }
                        else
                            model.InformationalMessage = _localizer.GetString(MessageResourceKeyConstants.AccessRuleUpdatedSuccessfullyMessage);
                    }
                    else
                    {
                        throw new ApplicationException("Unable to save access rule.");
                    }
                }
                else
                {
                    throw new ApplicationException("Unable to save access rule.");
                }

                model.DeleteVisibleIndicator = _configurableFiltrationPermissions.Execute;
                model.SearchActorViewModel = new SearchActorViewModel
                {
                    ShowSearchResults = false,
                    ModalTitle = _localizer.GetString(HeadingResourceKeyConstants.SearchActorsModalHeading),
                    ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Employee Type", 0).ConfigureAwait(false)
                };
                BaseReferenceViewModel actorType = new()
                {
                    IdfsBaseReference = Convert.ToInt64(ActorTypeEnum.Site),
                    Name = _localizer.GetString(FieldLabelResourceKeyConstants.SiteFieldLabel)
                };
                model.SearchActorViewModel.ActorTypeList.Add(actorType);
                actorType = new()
                {
                    IdfsBaseReference = Convert.ToInt64(ActorTypeEnum.SiteGroup),
                    Name = _localizer.GetString(FieldLabelResourceKeyConstants.SiteGroupFieldLabel)
                };
                model.SearchActorViewModel.ActorTypeList.Add(actorType);

                model.SearchActorViewModel.SearchCriteria = new();

                return Json(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// Deletes an access rule.
        /// </summary>
        /// <param name="accessRuleId"></param>
        /// <returns></returns>
        [HttpPost()]
        public async Task<IActionResult> Delete(long accessRuleId)
        {
            try
            {
                var response = await _configurableFiltrationClient.DeleteAccessRule(accessRuleId);

                if (response.ReturnCode != null)
                {
                    switch (response.ReturnCode)
                    {
                        case 0:
                            return RedirectToAction(nameof(List), "ConfigurableFiltration");
                        case -1:
                            {
                                ConfigurableFiltrationDetailsViewModel model = new()
                                {
                                    AccessRuleDetails = await _configurableFiltrationClient.GetAccessRuleDetail(GetCurrentLanguage(), accessRuleId),
                                    DeleteVisibleIndicator = _configurableFiltrationPermissions.Execute,
                                    SearchActorViewModel = new SearchActorViewModel
                                    {
                                        ShowSearchResults = false,
                                        ModalTitle = _localizer.GetString(HeadingResourceKeyConstants.SearchActorsModalHeading),
                                        ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Employee Type", 0).ConfigureAwait(false)
                                    }
                                };
                                BaseReferenceViewModel actorType = new()
                                {
                                    IdfsBaseReference = Convert.ToInt64(ActorTypeEnum.Site),
                                    Name = _localizer.GetString(FieldLabelResourceKeyConstants.SiteFieldLabel)
                                };
                                model.SearchActorViewModel.ActorTypeList.Add(actorType);
                                actorType = new BaseReferenceViewModel
                                {
                                    IdfsBaseReference = Convert.ToInt64(ActorTypeEnum.SiteGroup),
                                    Name = _localizer.GetString(FieldLabelResourceKeyConstants.SiteGroupFieldLabel)
                                };
                                model.SearchActorViewModel.ActorTypeList.Add(actorType);
                                model.SearchActorViewModel.SearchCriteria = new ActorGetRequestModel();

                                TempData["AccessRuleID"] = model.AccessRuleDetails.AccessRuleID.ToString();

                                model.ErrorMessage = _localizer.GetString(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage);

                                ViewBag.JavaScriptFunction = "showErrorModal('" + model.ErrorMessage + "');";

                                return View("Details", model);
                            }
                        default:
                            throw new ApplicationException("Unable to delete access rule.");
                    }
                }
                else
                {
                    throw new ApplicationException("Unable to delete access rule.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// Deletes an organization.
        /// </summary>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost()]
        public JsonResult DeleteReceivingActor([FromBody] JsonElement data)
        {
            try
            {
                var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return Json(data);
        }
    }
}