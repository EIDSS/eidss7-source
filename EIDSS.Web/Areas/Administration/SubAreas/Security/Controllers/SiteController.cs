#region Usings

using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.Administration;
using static System.Int32;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.Controllers
{
    [Area("Administration")]
    [SubArea("Security")]
    public class SiteController : BaseController
    {
        #region Global Values

        private readonly ISiteClient _siteClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IUserGroupClient _userGroupClient;
        private readonly IStringLocalizer _localizer;
        private readonly IHttpContextAccessor _httpContext;

        private readonly UserPermissions _sitePermissions;

        #endregion

        #region Constructors

        public SiteController(ISiteClient siteClient, ICrossCuttingClient crossCuttingClient, IUserGroupClient userGroupClient, IStringLocalizer localizer, IHttpContextAccessor httpContext, ITokenService tokenService, ILogger<SiteController> logger) :
            base(logger, tokenService)
        {
            _siteClient = siteClient;
            _crossCuttingClient = crossCuttingClient;
            _userGroupClient = userGroupClient;
            _localizer = localizer;
            _httpContext = httpContext;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _sitePermissions = GetUserPermissions(PagePermission.AccessToEIDSSSitesList_ManagingDataAccessFromOtherSites);
        }

        #endregion

        #region Search Sites

        public IActionResult List()
        {
            return View();
        }

        #endregion

        #region Site Details

        /// <summary>
        /// Sets up a new site or gets the details for an existing site.
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        public async Task<IActionResult> Details(long? id)
        {
            try
            {
                SiteDetailsViewModel model;

                if (id == null)
                {
                    model = new SiteDetailsViewModel
                    {
                        WritePermissionIndicator = _sitePermissions.Write,
                        SiteInformationSection = new SiteInformationSectionViewModel
                        {
                            SiteDetails = new SiteGetDetailViewModel(),
                            LoggedInUserPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations)
                        },
                        PermissionsSection = new PermissionsSectionViewModel
                        {
                            SiteAccessRightsUserPermissions = _sitePermissions
                        },
                        OrganizationsSection = new OrganizationsSectionViewModel
                        {
                            OrganizationPermissions = _sitePermissions
                        },
                        SearchActorViewModel = new SearchActorViewModel
                        {
                            ModalTitle = _localizer.GetString(HeadingResourceKeyConstants.UsersAndGroupsListModalHeading),
                            ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Employee Type", 0).ConfigureAwait(false),
                            SearchCriteria = new ActorGetRequestModel(),
                            SiteID = long.Parse(authenticatedUser.SiteId)
                        }
                    };

                    model.SiteInformationSection.SiteDetails.ActiveStatusIndicator = true;

                    UserGroupGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = "idfEmployeeGroup",
                        SortOrder = SortConstants.Ascending
                    };
                    var list = await _userGroupClient.GetUserGroupList(request);
                    if (list.All(x => x.idfEmployeeGroup != (long) RoleEnum.DefaultRole)) return View(model);
                    {
                        model.PermissionsSection.PendingSaveActors = new List<SiteActorGetListViewModel>();
                        SiteActorGetListViewModel defaultActor = new()
                        {
                            ActorID = -1,
                            ActorTypeName = "Employee Group",
                            ActorName = list.First(x => x.idfEmployeeGroup == (long)RoleEnum.DefaultRole).strName,
                            DefaultEmployeeGroupIndicator = true,
                            ExternalActorIndicator = false,
                            RowAction = (int)RowActionTypeEnum.Insert,
                            RowStatus = (int)RowStatusTypeEnum.Active
                        };
                        model.PermissionsSection.PendingSaveActors.Add(defaultActor);

                        var objectOperationTypes = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.SystemFunctionOperation, HACodeList.NoneHACode).ConfigureAwait(false);

                        var executePermission = objectOperationTypes.First(x => x.IdfsBaseReference == (long)ClientLibrary.Enumerations.PermissionLevelEnum.Execute);
                        var newRecordCount = 1;
                        objectOperationTypes.Remove(executePermission);
                        model.PermissionsSection.PendingSaveActors.First().Permissions =
                            new List<ObjectAccessGetListViewModel>();
                        model.PermissionsSection.PendingSaveActorPermissions =
                            new List<ObjectAccessGetListViewModel>();
                        foreach (var permission in objectOperationTypes.Select(item => new ObjectAccessGetListViewModel()
                                 {
                                     ObjectAccessID = newRecordCount * -1,
                                     ObjectOperationTypeID = item.IdfsBaseReference,
                                     ObjectOperationTypeName = item.Name,
                                     ObjectTypeID = (long) ObjectTypeEnum.Site,
                                     ObjectID = -1,
                                     ActorID = defaultActor.ActorID,
                                     DefaultEmployeeGroupIndicator = true,
                                     SiteID = -1,
                                     PermissionTypeID = item.IdfsBaseReference == (long)Domain.Enumerations.PermissionLevelEnum.Read ? (int) PermissionValueTypeEnum.Allow : (int) PermissionValueTypeEnum.Deny,
                                     PermissionIndicator = item.IdfsBaseReference == (long)Domain.Enumerations.PermissionLevelEnum.Read,
                                     RowStatus = (int) RowStatusTypeEnum.Active,
                                     RowAction = RecordConstants.Insert
                                 }))
                        {
                            model.PermissionsSection.PendingSaveActors.First().Permissions
                                .Add(permission);
                            model.PermissionsSection.PendingSaveActorPermissions.Add(permission);

                            newRecordCount += 1;
                        }
                    }
                }
                else
                {
                    model = new SiteDetailsViewModel
                    {
                        WritePermissionIndicator = _sitePermissions.Write,
                        SiteInformationSection = new SiteInformationSectionViewModel
                        {
                            SiteDetails = await _siteClient.GetSiteDetails(GetCurrentLanguage(), (long)id, Convert.ToInt64(authenticatedUser.EIDSSUserId)),
                            LoggedInUserPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations)
                        },
                        PermissionsSection = new PermissionsSectionViewModel
                        {
                            SiteAccessRightsUserPermissions = _sitePermissions
                        },
                        OrganizationsSection = new OrganizationsSectionViewModel
                        {
                            OrganizationPermissions = _sitePermissions
                        },
                        SiteID = id,
                        SearchActorViewModel = new SearchActorViewModel
                        {
                            ModalTitle = _localizer.GetString(HeadingResourceKeyConstants.UsersAndGroupsListModalHeading),
                            ActorTypeList = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.EmployeeType, 0).ConfigureAwait(false),
                            SearchCriteria = new ActorGetRequestModel(),
                            SiteID = long.Parse(authenticatedUser.SiteId)
                        }
                    };

                    _httpContext.HttpContext?.Response.Cookies.Append("SiteSearchPerformedIndicator", "true");
                }

                return View(model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion
    }
}