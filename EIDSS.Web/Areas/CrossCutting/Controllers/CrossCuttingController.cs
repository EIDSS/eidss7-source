using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.CrossCutting.Controllers
{
    [Area("CrossCutting")]
    [Controller]
    public class CrossCuttingController : BaseController
    {
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly ISiteClient _siteClient;
        private readonly IDiseaseClient _diseaseClient;
        private readonly IOrganizationClient _organizationClient;
        private readonly IFlexFormClient _flexFormClient;
        private readonly IEmployeeClient _employeeClient;
        private readonly AuthenticatedUser _authenticatedUser;

        public CrossCuttingController(ICrossCuttingClient crossCuttingClient, IDiseaseClient diseaseClient, IFlexFormClient flexFormClient, IEmployeeClient employeeClient,
            IOrganizationClient organizationClient, ISiteClient siteClient, ILogger<CrossCuttingController> logger, ITokenService tokenService) : base(logger, tokenService)
        {
            _crossCuttingClient = crossCuttingClient;
            _diseaseClient = diseaseClient;
            _organizationClient = organizationClient;
            _siteClient = siteClient;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            _flexFormClient = flexFormClient;
            _employeeClient = employeeClient;
        }

        /// <summary>
        /// Returns Reference Type records based on  filtering and Paging from Select 2 Drop Down
        /// </summary>
        /// <param name="page">Select 2 send page</param>
        /// <param name="data"></param>
        /// <param name="term">the information entered in the select 2 text box with filter results</param>
        /// <returns></returns>
        public async Task<JsonResult> GetBaseReferenceTypesForSelect2DropDown(int page, string data, string term)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            Pagination pagination = new(); //Pagination
            ReferenceTypeRquestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.Page = page;
                request.PageSize = 10;
                request.advancedSearch = term;
                request.SortColumn = "strDefault";
                request.SortOrder = EIDSSConstants.SortConstants.Ascending;

                var baseReferenceTypeListViewModel = await _crossCuttingClient.GetReferenceTypesByName(request);
                if (baseReferenceTypeListViewModel != null)
                {
                    select2DataItems.AddRange(baseReferenceTypeListViewModel.Select(item => new Select2DataItem { id = item.BaseReferenceId.ToString(), text = item.Name }));
                }
                if (baseReferenceTypeListViewModel != null && baseReferenceTypeListViewModel.Any() && baseReferenceTypeListViewModel.First().TotalRowCount > 10)
                {
                    //Add Pagination
                    pagination.more = true;
                    select2DataObj.pagination = pagination;
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, page, data);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> GetBaseReferenceTypesForSelect2DropDownBaseReferenceEditor(int page, string data, string term)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            Pagination pagination = new(); //Pagination
            ReferenceTypeRquestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.Page = page;
                request.PageSize = 10;
                request.advancedSearch = term;
                request.SortColumn = "strDefault";
                request.SortOrder = EIDSSConstants.SortConstants.Ascending;

                var baseReferenceTypeListViewModel = await _crossCuttingClient.GetReferenceTypesByName(request);
                if (baseReferenceTypeListViewModel != null)
                {
                    select2DataItems.AddRange(from item in baseReferenceTypeListViewModel where item.BaseReferenceId != 19000090 select new Select2DataItem { id = item.BaseReferenceId.ToString(), text = item.Name });
                }
                if (baseReferenceTypeListViewModel != null && baseReferenceTypeListViewModel.Any() && baseReferenceTypeListViewModel.First().TotalRowCount > 10)
                {
                    //Add Pagination
                    pagination.more = true;
                    select2DataObj.pagination = pagination;
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, page, data);
                throw;
            }

            return Json(select2DataObj);
        }

        /// <summary>
        /// Returns Diseases  records based on  filtering and Paging from Select 2 Drop Down
        /// </summary>
        /// <param name="page">Select 2 send page</param>
        /// <param name="data"></param>
        /// <param name="term">the information entered in the select 2 text box with filter results</param>
        /// <returns></returns>
        public async Task<JsonResult> GetDiseasesForSelect2DropDownFilteredAndPaged(int page, string data, string term)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            Pagination pagination = new(); //Pagination
            DiseaseGetListPagedRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.Page = page;
                request.PageSize = 10;
                request.advancedSearch = term;
                request.SortColumn = "strDefault";
                request.SortOrder = EIDSSConstants.SortConstants.Ascending;
                request.intHACode = 2; //TODO: WHY IS THIS HARD-CODED TO HUMAN?!

                var baseReferenceTypeListViewModel = await _crossCuttingClient.GetDiseasesByIdsPaged(request);
                if (baseReferenceTypeListViewModel != null)
                {
                    select2DataItems.AddRange(baseReferenceTypeListViewModel.Select(item => new Select2DataItem { id = item.idfsBaseReference.ToString(), text = item.strName }));
                }
                if (baseReferenceTypeListViewModel != null && baseReferenceTypeListViewModel.Any() && baseReferenceTypeListViewModel.First().TotalRowCount > 10)
                {
                    //Add Pagination
                    pagination.more = true;
                    select2DataObj.pagination = pagination;
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, page, data);
                throw;
            }

            return Json(select2DataObj);
        }

        /// <summary>
        /// Returns the HA (accessory) code list
        /// </summary>
        /// <param name="mask"></param>
        /// <returns></returns>
        public async Task<JsonResult> GetHACodeListForSelect2DropDown(int? mask)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();

            try
            {
                List<HACodeListViewModel> list;
                if (mask == null)
                    list = await _crossCuttingClient.GetHACodeList(GetCurrentLanguage(), null);
                else
                    list = await _crossCuttingClient.GetHACodeList(GetCurrentLanguage(), mask.Value);

                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.intHACode.ToString(), text = item.CodeName }));
                }

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> BaseReferenceListForSelect2DropDown(string ReferenceType, int intHACode)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();

            var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), ReferenceType, intHACode);

            if (list != null)
            {
                list = list.OrderBy(o => o.IntOrder).ThenBy(n => n.Name).ToList();
                select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.IdfsBaseReference.ToString(), text = item.Name }));
            }
            select2DataObj.results = select2DataItems;
            return Json(select2DataObj);
        }

        [Route("BaseReferenceByReferenceTypeIDListForSelect2DropDown")]
        public async Task<JsonResult> BaseReferenceByReferenceTypeIDListForSelect2DropDown(int page, long referenceTypeID, string term)
        {
            Pagination pagination = new();
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            BaseReferenceEditorGetRequestModel baseReferenceGetRequestModel = new()
            {
                IdfsReferenceType = referenceTypeID,
                Page = page,
                LanguageId = GetCurrentLanguage(),
                PageSize = 10,
                AdvancedSearch = term,
                SortColumn = "intorder",
                SortOrder = EIDSSConstants.SortConstants.Ascending
            };

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceList(baseReferenceGetRequestModel);

                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.KeyId.ToString(), text = item.StrName }));

                    if (list.Any() && list.First().TotalRowCount > 10)
                    {
                        //Add Pagination
                        pagination.more = true;
                        select2DataObj.pagination = pagination;
                    }
                }

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> BaseReferenceForSelect2DropDown(string identifiers)
        {
            var referenceTypeBaseReferenceId = identifiers.Split(",");
            Pagination pagination = new();
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            BaseReferenceEditorGetRequestModel baseReferenceGetRequestModel = new()
            {
                IdfsReferenceType = Convert.ToInt64(referenceTypeBaseReferenceId[0]),
                Page = 1,
                LanguageId = GetCurrentLanguage(),
                PageSize = 10,
                AdvancedSearch = string.Empty,
                SortColumn = "strName",
                SortOrder = EIDSSConstants.SortConstants.Ascending
            };

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceList(baseReferenceGetRequestModel);

                if (list != null)
                {
                    select2DataItems.AddRange(from item in list where item.KeyId == Convert.ToInt64(referenceTypeBaseReferenceId[1]) select new Select2DataItem { id = item.KeyId.ToString(), text = item.StrName });
                }
                select2DataObj.results = select2DataItems;
                pagination.more = true; //Add Pagination
                select2DataObj.pagination = pagination;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> GetCountryList(string? term)
        {
            var list = await _crossCuttingClient.GetCountryList(GetCurrentLanguage(), term);

            return Json(new Select2DataResults
            {
                results = list.Select(item => new Select2DataItem
                { id = item.idfsCountry.ToString(), text = item.strCountryName })
                    .ToList()
            });
        }

        public async Task<JsonResult> BaseReferenceByReferenceTypeIDListForSelect2DropDownWithSorting(long referenceTypeID, string sortColumn, int page, string term, string data)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            Pagination pagination = new(); //Pagination

            BaseReferenceEditorGetRequestModel baseReferenceGetRequestModel = new()
            {
                IdfsReferenceType = referenceTypeID,
                Page = page,
                LanguageId = GetCurrentLanguage(),
                PageSize = 10,
                AdvancedSearch = term,
                SortColumn = sortColumn,
                SortOrder = EIDSSConstants.SortConstants.Ascending
            };

            // Check for filtered identifier; example test name to test result matrix page uses laboratory test or penside test.
            if (!string.IsNullOrEmpty(data))
            {
                dynamic jsonObject = JObject.Parse(data);
                if (jsonObject["text"] != null && jsonObject["text"] != "")
                    baseReferenceGetRequestModel.IdfsReferenceType = long.Parse(jsonObject["text"].ToString());
            }

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceList(baseReferenceGetRequestModel);

                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.KeyId.ToString(), text = item.StrName }));

                    if (list.Any() && list.First().TotalRowCount > 10)
                    {
                        //Add Pagination
                        pagination.more = true;
                        select2DataObj.pagination = pagination;
                    }
                }

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> GetBaseReferenceListForSelect2DropDownWithSorting(long referenceTypeID, string sortColumn, int page, string term, string data)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            Pagination pagination = new(); //Pagination

            BaseReferenceEditorGetRequestModel baseReferenceGetRequestModel = new()
            {
                IdfsReferenceType = referenceTypeID,
                Page = page,
                LanguageId = GetCurrentLanguage(),
                PageSize = 10,
                AdvancedSearch = term,
                SortColumn = sortColumn,
                SortOrder = EIDSSConstants.SortConstants.Ascending
            };

            // Check for filtered identifier; example test name to test result matrix page uses laboratory test or penside test.
            if (!string.IsNullOrEmpty(data))
            {
                dynamic jsonObject = JObject.Parse(data);
                if (jsonObject["text"] != null && jsonObject["text"] != "")
                    baseReferenceGetRequestModel.IdfsReferenceType = long.Parse(jsonObject["text"].ToString());

            }

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceLookupList(baseReferenceGetRequestModel);

                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.KeyId.ToString(), text = item.StrName }));
                    if (list.Any() && list.First().TotalRowCount > 10)
                    {
                        //Add Pagination
                        pagination.more = true;
                        select2DataObj.pagination = pagination;
                    }
                }

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> BaseReferenceList(string ReferenceType, int intHACode)
        {
            var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), ReferenceType, intHACode);

            return Json(list);
        }

        /// <summary>
        /// Gets a list of diseases filtered by accessory code, using type and optionally by the term the user is searching for.
        /// The user's employee ID is required to perform disease filtration as described in SAUC62.
        /// </summary>
        /// <param name="accessoryCode"></param>
        /// <param name="usingTypeID"></param>
        /// <param name="data"></param>
        /// <param name="term"></param>
        /// <returns></returns>
        public async Task<JsonResult> GetFilteredDiseaseForLookup(int? accessoryCode, long? usingTypeID, string data, string term)
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();

            try
            {
                if (data != null)
                {
                    JObject.Parse(data);
                }

                FilteredDiseaseRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = accessoryCode,
                    AdvancedSearchTerm = term,
                    UsingType = usingTypeID,
                    UserEmployeeID = Convert.ToInt64(_authenticatedUser.PersonId)
                };

                var list = await _crossCuttingClient.GetFilteredDiseaseList(request);
                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.DiseaseID.ToString(), text = item.DiseaseName }));
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> GetDiseaseDetails(long DiseaseID)
        {
            try
            {
                var details = await _diseaseClient.GetDiseasesDetail(GetCurrentLanguage(), DiseaseID);

                return Json(details.First().blnSyndrome == null ? false : details.First().blnSyndrome);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task<JsonResult> DiseaseList(int intHACode)
        {
            var request = new DiseasesGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = int.MaxValue - 1,
                SortColumn = "strName",
                SortOrder = EIDSSConstants.SortConstants.Ascending,
                AccessoryCode = intHACode,
                SimpleSearch = "",
                AdvancedSearch = "",
                UserEmployeeID = Convert.ToInt64(_authenticatedUser.PersonId)
            };

            var list = await _diseaseClient.GetDiseasesList(request);

            return Json(list);
        }

        public async Task<JsonResult> DiseaseListForSelect2DropDown(int intHACode, int idfsUsingType = 0)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();

            try
            {
                var request = new DiseasesGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "intOrder",
                    SortOrder = EIDSSConstants.SortConstants.Ascending,
                    AccessoryCode = intHACode,
                    SimpleSearch = null,
                    AdvancedSearch = null,
                    UserEmployeeID = Convert.ToInt64(_authenticatedUser.PersonId)
                };

                var list = await _diseaseClient.GetDiseasesList(request);

                if (list != null)
                {
                    if (idfsUsingType > 0)
                    {
                        list = list.Where(x => x.IdfsUsingType == idfsUsingType).ToList();
                    }

                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.KeyId.ToString(), text = item.StrName }));
                }

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<bool> DiseaseDetails(int disease)
        {
            try
            {
                var list = await _diseaseClient.GetDiseasesDetail(GetCurrentLanguage(), disease);
                var blnSyndrome = list.First().blnSyndrome;
                return blnSyndrome != null && (bool)blnSyndrome;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task<JsonResult> DiseaseListForSelect2DropDownAdvanced(int intHACode, int page, string data, string term, int idfsUsingType = 0)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();

            try
            {
                var request = new DiseasesGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = page,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "intOrder",
                    SortOrder = EIDSSConstants.SortConstants.Ascending,
                    AccessoryCode = intHACode,
                    SimpleSearch = term,
                    AdvancedSearch = term,
                    UserEmployeeID = Convert.ToInt64(_authenticatedUser.PersonId)
                };

                var list = await _diseaseClient.GetDiseasesList(request);

                if (list != null)
                {
                    if (idfsUsingType > 0)
                    {
                        list = list.Where(x => x.IdfsUsingType == idfsUsingType).ToList();
                    }

                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.KeyId.ToString(), text = item.StrName }));
                }

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        /// <summary>
        /// Gets a list of organizations by accessory code, organization type and optionally by the term the user is searching for.
        /// </summary>
        /// <param name="accessoryCode"></param>
        /// <param name="organizationTypeID"></param>
        /// <param name="organizationSiteAssociation"></param>
        /// <param name="data"></param>
        /// <param name="term"></param>
        /// <returns></returns>
        public async Task<JsonResult> GetOrganizationsForLookup(int? accessoryCode, long? organizationTypeID, int? organizationSiteAssociation, string data, string term)
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();

            try
            {
                if (data != null)
                {
                    var category = "";
                    dynamic jsonObject = JObject.Parse(data);
                    if (jsonObject["text"] != null && jsonObject["text"] != "")
                        category = jsonObject["text"].ToString();
                    if (category == "User")
                        organizationSiteAssociation = (int)OrganizationSiteAssociations.OrganizationWithSite;
                    else if (string.IsNullOrEmpty(category) || category == "NonUser")
                        organizationSiteAssociation = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite;
                }

                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = accessoryCode,
                    AdvancedSearch = term,
                    SiteFlag = organizationSiteAssociation,
                    OrganizationTypeID = organizationTypeID
                };

                var list = await _organizationClient.GetOrganizationAdvancedList(request);
                if (list != null)
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.idfOffice.ToString(), text = item.name }));
                select2DataObj.results = select2DataItems.GroupBy(x => x.id).Select(x => x.First()).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        [Route("GetOrganizations")]
        public async Task<JsonResult> GetOrganizations(int page, string data, string term)
        {
            Pagination pagination = new(); //Pagination
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();
            OrganizationGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.AbbreviatedName = string.IsNullOrEmpty(term) ? null : term;
                request.SortColumn = "AbbreviatedName";
                request.SortOrder = EIDSSConstants.SortConstants.Ascending;
                request.PageSize = 100;
                request.Page = page;

                var list = await _organizationClient.GetOrganizationList(request);
                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.OrganizationKey.ToString(), text = item.AbbreviatedName }));
                }
                pagination.more = true; //Add Pagination
                select2DataObj.results = select2DataItems.GroupBy(x => x.id).Select(x => x.First()).ToList();
                select2DataObj.pagination = pagination;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> GetOrganizationsAdvancedListUser(int page, string data, string term)
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();
            OrganizationAdvancedGetRequestModel request = new();

            try
            {
                request.LangID = GetCurrentLanguage();
                request.AdvancedSearch = term;

                long? category = null;
                if (data != null)
                {
                    dynamic jsonObject = JObject.Parse(data);
                    if (jsonObject["text"] != null && jsonObject["text"] != "")
                        category = Convert.ToInt32(jsonObject["text"].ToString());
                }

                request.SiteFlag = category switch
                {
                    (long)EmployeeCategory.User => (int)OrganizationSiteAssociations.OrganizationWithSite,
                    (long)EmployeeCategory.NonUser =>
                        (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    _ => request.SiteFlag
                };

                var list = await _organizationClient.GetOrganizationAdvancedList(request);
                if (list != null)
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.idfOffice.ToString(), text = item.name }));
                select2DataObj.results = select2DataItems.GroupBy(x => x.id).Select(x => x.First()).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> GetOrganizationsAdvancedListByOrganizationType(int organizationTypeID, string term)
        {
            Pagination pagination = new(); //Pagination
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();
            OrganizationAdvancedGetRequestModel request = new();

            try
            {
                request.LangID = GetCurrentLanguage();
                request.AdvancedSearch = term;
                request.SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite;
                request.OrganizationTypeID = organizationTypeID;

                var list = await _organizationClient.GetOrganizationAdvancedList(request);
                if (list != null)
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.idfOffice.ToString(), text = item.name }));
                pagination.more = true; //Add Pagination
                select2DataObj.results = select2DataItems.GroupBy(x => x.id).Select(x => x.First()).ToList();
                select2DataObj.pagination = pagination;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> GetOrganizationsByAccessoryCode(int page, int accessoryCode, string term)
        {
            Pagination pagination = new(); //Pagination
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();
            OrganizationGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.AbbreviatedName = string.IsNullOrEmpty(term) ? null : term;
                request.SortColumn = "AbbreviatedName";
                request.SortOrder = EIDSSConstants.SortConstants.Ascending;
                request.PageSize = 100;
                request.Page = page;
                request.AccessoryCode = accessoryCode;

                var list = await _organizationClient.GetOrganizationList(request);
                if (list != null)
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.OrganizationKey.ToString(), text = item.AbbreviatedName }));
                pagination.more = true; //Add Pagination
                select2DataObj.results = select2DataItems.GroupBy(x => x.id).Select(x => x.First()).ToList();
                select2DataObj.pagination = pagination;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        [Route("GetSiteList")]
        public async Task<JsonResult> GetSiteList(int page, string data)
        {
            Pagination pagination = new();
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();
            SiteGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.SortColumn = "SiteName";
                request.SortOrder = EIDSSConstants.SortConstants.Ascending;
                request.PageSize = 10;
                request.Page = page;

                var list = await _siteClient.GetSiteList(request);
                if (list != null)
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.SiteID.ToString(), text = item.SiteName }));
                pagination.more = true; //Add Pagination
                select2DataObj.results = select2DataItems;
                select2DataObj.pagination = pagination;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> BaseReferenceAdvanceListForSelect2DropDown(string ReferenceType, int page, string data, string term)
        {
            Pagination pagination = new();
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            BaseReferenceAdvancedListRequestModel request = new()
            {
                ReferenceTypeName = ReferenceType,
                Page = page,
                LanguageId = GetCurrentLanguage(),
                PageSize = 10,
                advancedSearch = term,
                SortColumn = "strName",
                SortOrder = EIDSSConstants.SortConstants.Ascending
            };

            try
            {
                var list = await _crossCuttingClient.GetBaseReferenceAdvanceList(request);

                if (list != null)
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.idfsBaseReference.ToString(), text = item.strName }));
                select2DataObj.results = select2DataItems;
                pagination.more = true; //Add Pagination
                select2DataObj.pagination = pagination;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, page, data);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> GetEmployeeListByOrganization(string data)
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();
            EmployeeGetListRequestModel request = new();

            try
            {
                using var doc = JsonDocument.Parse(data);
                var root = doc.RootElement;
                long? organizationId = long.Parse(root[0].GetProperty("id").ToString() ?? string.Empty);

                request.LanguageId = GetCurrentLanguage();
                request.OrganizationID = organizationId;
                request.SortColumn = "EmployeeFullName";
                request.SortOrder = EIDSSConstants.SortConstants.Ascending;

                var list = await _employeeClient.GetEmployeeList(request);
                if (list != null)
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.EmployeeID.ToString(), text = item.EmployeeFullName }));
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public JsonResult GetYearList()
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();

            try
            {
                //Range of years to be 1900 to current year, descending
                for (var y = DateTime.Today.Year; y >= 1900; y += -1)
                {
                    select2DataItems.Add(new Select2DataItem { id = y.ToString(), text = y.ToString() });
                }

                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> GetMatrixVersionsByType(long matrixType)
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();

            try
            {
                var list = await _crossCuttingClient.GetMatrixVersionsByType(matrixType);
                if (list != null)
                {
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.IdfVersion.ToString(), text = item.MatrixName }));
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public JsonResult GetTemplateList(long? idfsFormTemplate, long? idfsFormType)
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();
            FlexFormTemplateGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.idfsFormTemplate = idfsFormTemplate;
                request.idfsFormType = idfsFormType;

                var list = _flexFormClient.GetTemplateList(request).Result;
                if (list != null)
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.idfsFormTemplate.ToString(), text = item.DefaultName }));
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        public async Task<JsonResult> GetEmployeeLookupList(string data)
        {
            Select2DataResults select2DataObj = new();
            List<Select2DataItem> select2DataItems = new();
            EmployeeLookupGetRequestModel request = new();

            try
            {
                using var doc = JsonDocument.Parse(data);
                var root = doc.RootElement;
                long? organizationId = long.Parse(root[0].GetProperty("id").ToString() ?? string.Empty);

                request.LanguageId = GetCurrentLanguage();
                request.OrganizationID = organizationId;
                request.SortColumn = "FullName";
                request.SortOrder = EIDSSConstants.SortConstants.Ascending;

                var list = await _crossCuttingClient.GetEmployeeLookupList(request);
                if (list != null)
                    select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.idfPerson.ToString(), text = item.FullName }));
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }
    }
}