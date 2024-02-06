#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.Dashboard;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.ApiClients.Laboratory;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Dashboard;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.Dashboard;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Dashboard
{
    public class DashboardBase : BaseComponent, IDisposable
    {
        #region Grid Column Reorder Choose

        [Inject] private IConfigurationClient ConfigurationClient { get; set; }
        [Inject] protected GridContainerServices GridContainerServices { get; set; }
        public GridExtensionBase GridExtension { get; set; }


        #endregion

        #region Dependencies

        [Inject] private IUserGroupClient UserGroupClient { get; set; }
        [Inject] private IEmployeeClient EmployeeClient { get; set; }
        [Inject] private ILogger<DashboardBase> Logger { get; set; }
        [Inject] protected ILaboratoryClient LaboratoryClient { get; set; }
        [Inject] protected LaboratoryStateContainerService LaboratoryService { get; set; }
        [Inject] protected IDashboardClient DashboardClient { get; set; }
        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] private new NavigationManager NavManager { get; set; }
        [Inject] private IHumanDiseaseReportClient HumanDiseaseReportClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public int GridType { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        public int Count { get; set; }
        protected IList<DashboardUsersListViewModel> Users { get; set; }
        protected IList<SamplesGetListViewModel> UnaccessionedSamples { get; set; }
        protected IList<ApprovalsGetListViewModel> Approvals { get; set; }
        protected IList<DashboardInvestigationsListViewModel> Investigations { get; set; }
        protected IList<DashboardInvestigationsListViewModel> MyInvestigations { get; set; }
        protected IList<DashboardNotificationsListViewModel> DashNotifications { get; set; }
        protected IList<DashboardNotificationsListViewModel> MyNotifications { get; set; }
        protected IList<DashboardCollectionsListViewModel> MyCollections { get; set; }
        protected IList<UserGroupDashboardViewModel> DashboardLinks { get; set; }
        protected RadzenDataGrid<DashboardUsersListViewModel> UsersGrid { get; set; }
        protected RadzenDataGrid<SamplesGetListViewModel> UnaccessionedSamplesGrid { get; set; }
        protected RadzenDataGrid<ApprovalsGetListViewModel> ApprovalsGrid { get; set; }
        protected RadzenDataGrid<DashboardInvestigationsListViewModel> InvestigationsGrid { get; set; }
        protected RadzenDataGrid<DashboardInvestigationsListViewModel> MyInvestigationsGrid { get; set; }
        protected RadzenDataGrid<DashboardNotificationsListViewModel> NotificationsGrid { get; set; }
        protected RadzenDataGrid<DashboardNotificationsListViewModel> MyNotificationsGrid { get; set; }
        protected RadzenDataGrid<DashboardCollectionsListViewModel> MyCollectionsGrid { get; set; }
        protected bool UsersGridVisible { get; set; }
        protected bool ApprovalsGridVisible { get; set; }
        protected bool UnaccessionedSamplesGridVisible { get; set; }
        protected bool InvestigationsGridVisible { get; set; }
        protected bool MyInvestigationsGridVisible { get; set; }
        protected bool NotificationsGridVisible { get; set; }
        protected bool MyNotificationsGridVisible { get; set; }
        protected bool MyCollectionsGridVisible { get; set; }
        protected bool IsUserEditVisible { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private UserPermissions _userPermissions;
        private int _lastDatabasePage;
        private DashboardNotificationsListViewModel _selectedNotification;

        #endregion

        #region Page Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            try
            {
                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                _logger = Logger;

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                // get the user group the user belongs to
                EmployeesUserGroupAndPermissionsGetRequestModel request = new()
                {
                    idfPerson = Convert.ToInt64(authenticatedUser.PersonId),
                    LangID = GetCurrentLanguage()
                };
                var userGroupResponse = await EmployeeClient.GetEmployeeUserGroupAndPermissions(request);

                // grab the first user group if multiple
                if (userGroupResponse.Count > 0)
                {
                    // get the user group id
                    long? userGroupId = Convert.ToInt64(userGroupResponse.First().UserGroupID);

                    // get the dashboard links using the user group id
                    var requestLinks = new UserGroupDashboardGetRequestModel
                    {
                        roleId = userGroupId, // "user group id"
                        dashBoardItemType = "icon",
                        langId = GetCurrentLanguage(),
                        user = null
                    };

                    var links = await UserGroupClient.GetUserGroupDashboardList(requestLinks);

                    // generate the dashboard links
                    if (links is {Count: > 0})
                    {
                        foreach (var link in links)
                        {
                            switch (link.strBaseReferenceCode)
                            {
                                // todo: find out which link this icon is for
                                //case "":
                                //    link.IconFileName = "AdminUnits";
                                //    break;
                                case "dashBiconAnimalDiseaseReport":
                                    link.IconFileName = "AnimalReport";
                                    break;
                                case "dashBiconApprovals":
                                    link.IconFileName = "Approvals";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission.AccessToLaboratoryApprovals);

                                    break;
                                case "dashBiconAvianDiseaseRpt":
                                    link.IconFileName = "AvianReport";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission
                                            .AccessToVeterinaryDiseaseReportsData);
                                    break;
                                case "dashBiconEmployee":
                                    link.IconFileName = "Employees";
                                    var withoutAccessPerm = SetLinkReadPermissionStatus(PagePermission
                                        .CanAccessEmployeesList_WithoutManagingAccessRights);
                                    var withAccessPerm =
                                        SetLinkReadPermissionStatus(PagePermission.CanWorkWithAccessRightsManagement);
                                    link.ShowLink = withoutAccessPerm && withAccessPerm;
                                    break;
                                case "dashBiconFarm":
                                    link.IconFileName = "Farm";
                                    link.ShowLink = SetLinkReadPermissionStatus(PagePermission.AccessToFarmsData);
                                    break;
                                case "dashBiconMyFavorites":
                                    link.IconFileName = "Favorites";
                                    link.ShowLink = SetLinkReadPermissionStatus(PagePermission.AccessToFarmsData);

                                    break;
                                case "dashBiconPerson":
                                    link.IconFileName = "Human";
                                    link.ShowLink = SetLinkReadPermissionStatus(PagePermission.AccessToPersonsList);
                                    break;
                                case "dashBiconHumDiseaseRpt":
                                    link.IconFileName = "HumanReport";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission.AccessToHumanDiseaseReportData);
                                    break;

                                case "dashBiconHumAggrRpt":
                                    link.IconFileName = "HumanReport";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission
                                            .AccessToHumanAggregateDiseaseReports);

                                    break;
                                case "dashBiconLivestockDiseaseRpt":
                                    link.IconFileName = "LivestockReport";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission
                                            .AccessToVeterinaryDiseaseReportsData);

                                    break;
                                case "dashBiconOutBreak":
                                    link.IconFileName = "Outbreak";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission.AccessToOutbreakHumanCaseData);

                                    break;
                                case "dashBiconSearchSample":
                                    link.IconFileName = "SampleSearch";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission.AccessToLaboratorySamples);

                                    break;
                                case "dashBiconSampleTransfer":
                                    link.IconFileName = "SampleTransfer";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission.CanPerformSampleTransfer);

                                    break;
                                case "dashBiconOrganizations":
                                    link.IconFileName = "SiteOrgs";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission.CanAccessOrganizationsList);

                                    break;
                                case "dashBiconHumASCampaign":
                                    link.IconFileName = "Surveillance";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission
                                            .AccessToHumanActiveSurveillanceCampaign);
                                    break;

                                case "dashBiconHumASSession":
                                    link.IconFileName = "Surveillance";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission
                                            .AccessToHumanActiveSurveillanceSession);
                                    break;

                                case "dashBiconVetASSession":
                                    link.IconFileName = "Surveillance";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission
                                            .AccessToVeterinaryActiveSurveillanceSession);

                                    break;
                                case "dashBiconTesting":
                                    link.IconFileName = "Testing";
                                    break;
                                case "dashBiconUserGroups":
                                    link.IconFileName = "UserGroups";
                                    link.ShowLink = SetLinkReadPermissionStatus(PagePermission.CanManageUserGroups);

                                    break;
                                case "dashBiconVectorCollections":
                                    link.IconFileName = "Vector";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission.AccessToVectorSurveillanceSession);

                                    break;
                                case "dashBiconVetAggrRpt":
                                    link.IconFileName = "VetAggReport";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission
                                            .AccessToVeterinaryAggregateDiseaseReports);

                                    break;
                                case "dashBiconVetAggrAction":
                                    link.IconFileName = "VetAggAction";
                                    link.ShowLink =
                                        SetLinkReadPermissionStatus(PagePermission.AccessToVeterinaryAggregateActions);

                                    break;
                                case "dashBiconTrainingVideos":
                                    link.IconFileName = "Videos";

                                    break;
                                default:
                                    link.IconFileName = "reports";
                                    link.ShowLink = SetLinkReadPermissionStatus(PagePermission.AccessToReports);

                                    break;
                            }

                            link.PageLink = NavManager.BaseUri + link.PageLink[1..];
                        }

                        DashboardLinks = links.OrderBy(x => x.strName).ToList();
                    }

                    // get the dashboard type using the user group id
                    var requestGrid = new UserGroupDashboardGetRequestModel
                    {
                        roleId = userGroupId, // "user group id"
                        dashBoardItemType = "grid",
                        langId = GetCurrentLanguage(),
                        user = null
                    };

                    var dashboardGrids = await UserGroupClient.GetUserGroupDashboardList(requestGrid);

                    // display the appropriate dashboard
                    if (dashboardGrids is {Count: > 0})
                    {
                        var dashboardType = dashboardGrids.FirstOrDefault()?.strBaseReferenceCode;

                        //FOR DEBUG ONLY
                        //var dashboardType = DashboardGrids.Approvals;
                        //FOR DEBUG ONLY

                        switch (dashboardType)
                        {
                            // Users
                            case DashboardGrids.Users:
                            {
                                UsersGridVisible = true;

                                var userPermissions1 =
                                    GetUserPermissions(
                                        PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);
                                var userPermissions2 =
                                    GetUserPermissions(PagePermission.CanWorkWithAccessRightsManagement);

                                if (userPermissions1.Read && userPermissions2.Read) IsUserEditVisible = true;
                                else IsUserEditVisible = false;
                                break;
                            }
                            //Unaccessioned Samples
                            case DashboardGrids.UnaccessionedSamples:
                            {
                                _userPermissions = GetUserPermissions(PagePermission.CanPerformSampleAccessionIn);
                                if (_userPermissions.Execute) UnaccessionedSamplesGridVisible = true;
                                break;
                            }
                            // Approvals
                            case DashboardGrids.Approvals:
                                ApprovalsGridVisible = true;
                                break;
                            // Investigation
                            case DashboardGrids.Investigations:
                            {
                                _userPermissions =
                                    GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);
                                if (_userPermissions.Read) InvestigationsGridVisible = true;
                                break;
                            }
                            // My Investigation
                            case DashboardGrids.MyInvestigations:
                            {
                                _userPermissions =
                                    GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);
                                if (_userPermissions.Read) MyInvestigationsGridVisible = true;
                                break;
                            }
                            // Notifications
                            case DashboardGrids.Notifications:
                            {
                                _userPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
                                if (_userPermissions.Read) NotificationsGridVisible = true;
                                break;
                            }
                            // My Notifications
                            case DashboardGrids.MyNotifications:
                            {
                                _userPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
                                if (_userPermissions.Read) MyNotificationsGridVisible = true;
                                break;
                            }
                            // My Collections
                            case DashboardGrids.MyCollections:
                            {
                                _userPermissions = GetUserPermissions(PagePermission.AccessToVectorSurveillanceSession);
                                if (_userPermissions.Read) MyCollectionsGridVisible = true;
                                break;
                            }
                        }
                    }
                }

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion

        #region Dashboard Links Events

        /// <summary>
        /// </summary>
        /// <param name="dashboardLink"></param>
        /// <returns></returns>
        protected void OnDashboardLinkClick(DashboardLinksListViewModel dashboardLink)
        {
            try
            {
                //NAVIGATE TO EMPLOYEE EDIT

                //var result = await DiagService.OpenAsync<LaboratoryDetails>(
                //    Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleTestDetailsModalHeading),
                //    new Dictionary<string, object>
                //    {
                //        {"Tab", LaboratoryTabEnum.Testing}, {"SampleID", test.SampleID}, {"TestID", test.TestID},
                //        {"DiseaseID", test.DiseaseID}
                //    },
                //    new DialogOptions
                //    {
                //        Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                //        Height = LaboratoryModuleCSSClassConstants.DefaultDialogHeight,
                //        AutoFocusFirstElement = true,
                //        CloseDialogOnOverlayClick = false,
                //        Draggable = false,
                //        Resizable = true
                //    });

                //if (result == null)
                //    await OnReloadTesting();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Users Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadUsersData(LoadDataArgs args)
        {
            try
            {
                const int lastPage = 0;
                var pageSize = 10;

                if (UsersGrid.PageSize != 0)
                {
                    pageSize = UsersGrid.PageSize;
                    IsLoading = true;
                }

                args.Top ??= 0;

                var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                if (lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize) &&
                    page <= _lastDatabasePage)
                    IsLoading = true;

                if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                {
                    string sortColumn,
                        sortOrder;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "FamilyName";
                        sortOrder = SortConstants.Ascending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First()?.Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First()?.SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    var request = new DashboardUsersGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        SortColumn = sortColumn,
                        SortOrder = sortOrder,
                        Page = page,
                        PageSize = pageSize,
                        SiteList = authenticatedUser.SiteId
                    };

                    Users = await DashboardClient.GetDashboardUsers(request, _token);
                    Count = !Users.Any() ? 0 : Users.First().TotalRowCount;
                    IsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="employee"></param>
        /// <returns></returns>
        protected void OnEditUser(DashboardUsersListViewModel employee)
        {
            try
            {
                var uri = $"{NavManager.BaseUri}Administration/EmployeePage/Details/{employee.EmployeeID}";
                NavManager.NavigateTo(uri, true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Unaccessioned Sample Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadUnaccessionedSamplesData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn,
                    sortOrder;

                if (UnaccessionedSamplesGrid.PageSize != 0)
                    pageSize = UnaccessionedSamplesGrid.PageSize;

                args.Top ??= 0;

                var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                if (args.Sorts == null || args.Sorts.Any() == false)
                {
                    sortColumn = "Default";
                    sortOrder = SortConstants.Ascending;
                }
                else
                {
                    sortColumn = args.Sorts.First().Property;
                    sortOrder = SortConstants.Descending;
                    if (args.Sorts.First().SortOrder.HasValue)
                        if (args.Sorts.First().SortOrder?.ToString() == "Ascending")
                            sortOrder = SortConstants.Ascending;
                }

                if (UnaccessionedSamples is null)
                    IsLoading = true;

                if (IsLoading)
                {
                    var request = new SamplesGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = page,
                        PageSize = pageSize,
                        SortColumn = sortColumn,
                        SortOrder = sortOrder,
                        DaysFromAccessionDate =
                            Convert.ToInt32(ConfigurationService.SystemPreferences.NumberDaysDisplayedByDefault),
                        FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >=
                                              (long) SiteTypes.ThirdLevel,
                        TestCompletedIndicator = null,
                        TestUnassignedIndicator = null,
                        UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                        UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        UserOrganizationID = authenticatedUser.OfficeId,
                        UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                        UserSiteGroupID = string.IsNullOrEmpty(authenticatedUser.SiteGroupID)
                            ? null
                            : Convert.ToInt64(authenticatedUser.SiteGroupID)
                    };

                    LaboratoryService.Samples = await LaboratoryClient.GetSamplesList(request, _token);
                    UnaccessionedSamples = LaboratoryService.Samples
                        .Where(x => x.SampleStatusTypeID == null && x.AccessionConditionTypeID is null).ToList();
                    UnaccessionedSamples = LaboratoryService.Samples.Take(pageSize).ToList();
                    Count = !LaboratoryService.Samples.Any() ? 0 : LaboratoryService.Samples.First().UnaccessionedSampleCount;
                    IsLoading = false;
                }
                else
                {
                    ApplyDefaultListSort(sortColumn, sortOrder);

                    UnaccessionedSamples = LaboratoryService.Samples.Skip((page - 1) * pageSize).Take(pageSize)
                        .ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        private void ApplyDefaultListSort(string sortColumn, string sortOrder)
        {
            if (sortColumn is null) return;
            if (sortOrder == SortConstants.Ascending)
                LaboratoryService.Samples = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.Samples.OrderBy(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.Samples.OrderBy(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.Samples.OrderBy(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.Samples.OrderBy(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.Samples.OrderBy(x => x.DisplayDiseaseName).ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.Samples.OrderBy(x => x.EIDSSLaboratorySampleID)
                        .ToList(),
                    "AccessionDate" => LaboratoryService.Samples.OrderBy(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.Samples
                        .OrderBy(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.Samples.OrderBy(x => x.FunctionalAreaName).ToList(),
                    "EIDSSAnimalID" => LaboratoryService.Samples.OrderBy(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.Samples
                };
            else
                LaboratoryService.Samples = sortColumn switch
                {
                    "EIDSSReportOrSessionID" => LaboratoryService.Samples
                        .OrderByDescending(x => x.EIDSSReportOrSessionID)
                        .ToList(),
                    "PatientOrFarmOwnerName" => LaboratoryService.Samples
                        .OrderByDescending(x => x.PatientOrFarmOwnerName)
                        .ToList(),
                    "EIDSSLocalOrFieldSampleID" => LaboratoryService.Samples
                        .OrderByDescending(x => x.EIDSSLocalOrFieldSampleID)
                        .ToList(),
                    "SampleTypeName" => LaboratoryService.Samples.OrderByDescending(x => x.SampleTypeName)
                        .ToList(),
                    "DisplayDiseaseName" => LaboratoryService.Samples.OrderByDescending(x => x.DisplayDiseaseName)
                        .ToList(),
                    "EIDSSLaboratorySampleID" => LaboratoryService.Samples
                        .OrderByDescending(x => x.EIDSSLaboratorySampleID).ToList(),
                    "AccessionDate" => LaboratoryService.Samples.OrderByDescending(x => x.AccessionDate).ToList(),
                    "AccessionConditionOrSampleStatusTypeName" => LaboratoryService.Samples
                        .OrderByDescending(x => x.AccessionConditionOrSampleStatusTypeName).ToList(),
                    "FunctionalAreaName" => LaboratoryService.Samples.OrderByDescending(x => x.FunctionalAreaName)
                        .ToList(),
                    "EIDSSAnimalID" => LaboratoryService.Samples.OrderByDescending(x => x.EIDSSAnimalID).ToList(),
                    _ => LaboratoryService.Samples
                };
        }

        #endregion

        #region Approvals Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadApprovalsData(LoadDataArgs args)
        {
            try
            {
                var approvalsList =
                    await DashboardClient.GetDashboardApprovals(GetCurrentLanguage(), authenticatedUser.SiteId, _token);

                var userPermissionsCanDestroySamples = GetUserPermissions(PagePermission.CanDestroySamples);
                if (!userPermissionsCanDestroySamples.Execute)
                    approvalsList.Remove(
                        approvalsList.FirstOrDefault(x =>
                            x.Approval == "Samples to be destroyed")); //TODO - change to the resource

                var userPermissionsCanFinalizeLabTest = GetUserPermissions(PagePermission.CanFinalizeLaboratoryTest);
                if (!userPermissionsCanFinalizeLabTest.Execute)
                    approvalsList.Remove(
                        approvalsList.FirstOrDefault(x =>
                            x.Approval == "Test Results to be validated")); //TODO - change to the resource

                Approvals = approvalsList;
                Count = Approvals.Count;
                IsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="approval"></param>
        /// <returns></returns>
        protected void OnViewApproval(ApprovalsGetListViewModel approval)
        {
            try
            {
                var uri = $"{NavManager.BaseUri}Laboratory/Laboratory/Approvals/?f=1";
                NavManager.NavigateTo(uri, true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Investigations Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadInvestigationsData(LoadDataArgs args)
        {
            try
            {
                const int lastPage = 0;
                var pageSize = 10;

                if (InvestigationsGrid.PageSize != 0)
                {
                    pageSize = InvestigationsGrid.PageSize;
                    IsLoading = true;
                }

                args.Top ??= 0;

                var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                if (lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize) &&
                    page <= _lastDatabasePage)
                    IsLoading = true;

                if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                {
                    string sortColumn,
                        sortOrder;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "DateEntered";
                        sortOrder = SortConstants.Ascending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First()?.Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First()?.SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    var request = new DashboardInvestigationsGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        SortColumn = sortColumn,
                        SortOrder = sortOrder,
                        Page = page,
                        PageSize = pageSize,
                        SiteList = authenticatedUser.SiteId
                    };

                    Investigations = await DashboardClient.GetDashboardInvestigations(request, _token);
                    Count = !Investigations.Any() ? 0 : Investigations.First().TotalRowCount;
                    IsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="investigation"></param>
        /// <returns></returns>
        protected void OnViewInvestigation(DashboardInvestigationsListViewModel investigation)
        {
            try
            {
                switch (investigation.HACode)
                {
                    case HACodeList.AvianHACode:
                    {
                        var uri =
                            $"{NavManager.BaseUri}Veterinary/VeterinaryDiseaseReport/Details?reportTypeID={VeterinaryDiseaseReportConstants.AvianDiseaseReportCaseType}&farmID={investigation.FarmID}&diseaseReportID={investigation.VetCaseID}&isReadOnly=true";
                        NavManager.NavigateTo(uri, true);
                        break;
                    }
                    case HACodeList.LivestockHACode:
                    {
                        var uri =
                            $"{NavManager.BaseUri}Veterinary/VeterinaryDiseaseReport/Details?reportTypeID={VeterinaryDiseaseReportConstants.LivestockDiseaseReportCaseType}&farmID={investigation.FarmID}&diseaseReportID={investigation.VetCaseID}&isReadOnly=true";
                        NavManager.NavigateTo(uri, true);
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region My Investigations Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadMyInvestigationsData(LoadDataArgs args)
        {
            try
            {
                const int lastPage = 0;
                var pageSize = 10;

                if (MyInvestigationsGrid.PageSize != 0)
                {
                    pageSize = MyInvestigationsGrid.PageSize;
                    IsLoading = true;
                }

                args.Top ??= 0;

                var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                if (lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize) &&
                    page <= _lastDatabasePage)
                    IsLoading = true;

                if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                {
                    string sortColumn,
                        sortOrder;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "DateEntered";
                        sortOrder = SortConstants.Ascending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First()?.Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First()?.SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    var request = new DashboardInvestigationsGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        SortColumn = sortColumn,
                        SortOrder = sortOrder,
                        Page = page,
                        PageSize = pageSize,
                        PersonID = Convert.ToInt64(authenticatedUser.PersonId)
                    };

                    MyInvestigations = await DashboardClient.GetDashboardMyInvestigations(request, _token);
                    Count = !MyInvestigations.Any() ? 0 : MyInvestigations.First().TotalRowCount;
                    IsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="investigation"></param>
        /// <returns></returns>
        protected void OnViewMyInvestigation(DashboardInvestigationsListViewModel investigation)
        {
            try
            {
                switch (investigation.HACode)
                {
                    case HACodeList.AvianHACode:
                    {
                        var uri =
                            $"{NavManager.BaseUri}Veterinary/VeterinaryDiseaseReport/Details?reportTypeID={VeterinaryDiseaseReportConstants.AvianDiseaseReportCaseType}&farmID={investigation.FarmID}&diseaseReportID={investigation.VetCaseID}&isEdit=true";
                        NavManager.NavigateTo(uri, true);
                        break;
                    }
                    case HACodeList.LivestockHACode:
                    {
                        var uri =
                            $"{NavManager.BaseUri}Veterinary/VeterinaryDiseaseReport/Details?reportTypeID={VeterinaryDiseaseReportConstants.LivestockDiseaseReportCaseType}&farmID={investigation.FarmID}&diseaseReportID={investigation.VetCaseID}&isEdit=true";
                        NavManager.NavigateTo(uri, true);
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Notifications Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadNotificationsData(LoadDataArgs args)
        {
            try
            {
                const int lastPage = 0;
                var pageSize = 10;

                if (NotificationsGrid.PageSize != 0)
                {
                    pageSize = NotificationsGrid.PageSize;
                    IsLoading = true;
                }

                args.Top ??= 0;

                var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                if (lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize) &&
                    page <= _lastDatabasePage)
                    IsLoading = true;

                if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                {
                    string sortColumn,
                        sortOrder;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "DateEntered";
                        sortOrder = SortConstants.Ascending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First()?.Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First()?.SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    var request = new DashboardNotificationsGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        SortColumn = sortColumn,
                        SortOrder = sortOrder,
                        Page = page,
                        PageSize = pageSize,
                        SiteList = authenticatedUser.SiteId
                    };

                    DashNotifications = await DashboardClient.GetDashboardNotifications(request, _token);

                    foreach (var n in DashNotifications)
                        if (!string.IsNullOrEmpty(n.PersonName))
                            n.PersonName = n.PersonName.ToUpper();

                    Count = !DashNotifications.Any() ? 0 : DashNotifications.First().TotalRowCount;
                    IsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="notification"></param>
        /// <param name="action"></param>
        /// <returns></returns>
        protected async Task OnViewNotification(DashboardNotificationsListViewModel notification, string action)
        {
            try
            {
                switch (action)
                {
                    case "view":
                    {
                        // start index should be anything greater than 1 to be taken to "Review" section of human disease report
                        var uri =
                            $"{NavManager.BaseUri}Human/HumanDiseaseReport/LoadDiseaseReport?humanId={notification.HumanID}&caseId={notification.HumanCaseID}&isEdit=False&readOnly=True&StartIndex=3";
                        NavManager.NavigateTo(uri, true);
                        break;
                    }
                    case "add":
                        DiagService.OnClose -= HandleAssignInvestigatorResponse;
                        DiagService.OnClose += HandleAssignInvestigatorResponse;
                        _selectedNotification = notification;
                        await ShowConfirmAssignInvestigator();
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task ShowConfirmAssignInvestigator()
        {
            var buttons = new List<DialogButton>();

            var yesButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                ButtonType = DialogButtonType.Yes
            };
            buttons.Add(yesButton);

            var noButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                ButtonType = DialogButtonType.No
            };
            buttons.Add(noButton);

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.LocalizedMessage), "Do you want to assign yourself as investigator?"
                } //TODO - needs to be a resource!
            };

            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading),
                dialogParams);
        }

        /// <summary>
        /// </summary>
        /// <param name="result"></param>
        protected async void HandleAssignInvestigatorResponse(dynamic result)
        {
            result = (DialogReturnResult) result;
            if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                try
                {
                    var saveRequest = new HumanSetDiseaseReportRequestModel
                    {
                        idfHumanCase = _selectedNotification.HumanCaseID,
                        idfInvestigatedByPerson = Convert.ToInt64(authenticatedUser.PersonId),
                        strEpidemiologistsName = authenticatedUser.LastName + " " + authenticatedUser.FirstName
                    };
                    var response =
                        await HumanDiseaseReportClient.UpdateHumanDiseaseInvestigatedByAsync(saveRequest, _token);
                    await NotificationsGrid.Reload();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex.Message, null);
                    throw;
                }
            else if (result.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                DiagService.OnClose -= HandleAssignInvestigatorResponse;
        }

        #endregion

        #region My Notifications Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadMyNotificationsData(LoadDataArgs args)
        {
            try
            {
                const int lastPage = 0;
                var pageSize = 10;

                if (MyNotificationsGrid.PageSize != 0)
                {
                    pageSize = MyNotificationsGrid.PageSize;
                    IsLoading = true;
                }

                args.Top ??= 0;

                var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                if (lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize) &&
                    page <= _lastDatabasePage)
                    IsLoading = true;

                if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                {
                    string sortColumn,
                        sortOrder;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "DateEntered";
                        sortOrder = SortConstants.Ascending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First()?.Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First()?.SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    var request = new DashboardNotificationsGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        SortColumn = sortColumn,
                        SortOrder = sortOrder,
                        Page = page,
                        PageSize = pageSize,
                        PersonID = Convert.ToInt64(authenticatedUser.PersonId)
                    };

                    MyNotifications = await DashboardClient.GetDashboardMyNotifications(request, _token);

                    foreach (var n in MyNotifications)
                        if (!string.IsNullOrEmpty(n.PersonName))
                            n.PersonName = n.PersonName.ToUpper();

                    Count = !MyNotifications.Any() ? 0 : MyNotifications.First().TotalRowCount;
                    IsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="notification"></param>
        /// <returns></returns>
        protected void OnViewMyNotification(DashboardNotificationsListViewModel notification)
        {
            try
            {
                var uri =
                    $"{NavManager.BaseUri}Human/HumanDiseaseReport/LoadDiseaseReport?humanId={notification.HumanID}&caseId={notification.HumanCaseID}&isEdit=False&readOnly=True&StartIndex=3";
                NavManager.NavigateTo(uri, true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region My Collections Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadMyCollectionsData(LoadDataArgs args)
        {
            try
            {
                const int lastPage = 0;
                var pageSize = 10;

                if (MyCollectionsGrid.PageSize != 0)
                {
                    pageSize = MyCollectionsGrid.PageSize;
                    IsLoading = true;
                }

                args.Top ??= 0;

                var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                if (lastPage != (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize) &&
                    page <= _lastDatabasePage)
                    IsLoading = true;

                if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                {
                    string sortColumn,
                        sortOrder;

                    if (args.Sorts == null || args.Sorts.Any() == false)
                    {
                        sortColumn = "DateEntered";
                        sortOrder = SortConstants.Descending;
                    }
                    else
                    {
                        sortColumn = args.Sorts.First()?.Property;
                        sortOrder = SortConstants.Descending;
                        if (args.Sorts.First().SortOrder.HasValue)
                            if (args.Sorts.First()?.SortOrder?.ToString() == "Ascending")
                                sortOrder = SortConstants.Ascending;
                    }

                    var request = new DashboardCollectionsGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        SortColumn = sortColumn,
                        SortOrder = sortOrder,
                        Page = page,
                        PageSize = pageSize,
                        PersonID = Convert.ToInt64(authenticatedUser.PersonId)
                    };

                    MyCollections = await DashboardClient.GetDashboardMyCollections(request, _token);
                    Count = !MyCollections.Any() ? 0 : MyCollections.First().TotalRowCount;
                    IsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="collection"></param>
        /// <param name="action"></param>
        /// <returns></returns>
        protected void OnViewMyCollection(DashboardCollectionsListViewModel collection, string action)
        {
            try
            {
                switch (action)
                {
                    case "view":
                    {
                        var uri =
                            $"{NavManager.BaseUri}Vector/VectorSurveillanceSession/SavedVectorSurveillanceSession?vectorSurveillanceSession={collection.VectorSurveillanceSessionID}";
                        NavManager.NavigateTo(uri, true);
                        break;
                    }
                    case "edit":
                    {
                        var uri =
                            $"{NavManager.BaseUri}Vector/VectorSurveillanceSession/SavedVectorSurveillanceSession?vectorSurveillanceSession={collection.VectorSurveillanceSessionID}";
                        NavManager.NavigateTo(uri, true);
                        break;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Grid Column Reorder Chooser

        protected override void OnInitialized()
        {
            GridExtension = new GridExtensionBase();
            GridColumnLoad("DashBoard");

            //Task.Run(async () => await GridColumnLoad("DashBoard")).Wait(500);
            base.OnInitialized();
        }

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig =
                    GridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public void GridColumnSave(string columnNameId)
        {
            try
            {
                GridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient,
                    UsersGrid.ColumnsCollection.ToDynamicList(), GridContainerServices);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public int FindColumnOrder(string columnName)
        {
            var index = 0;
            try
            {
                index = GridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return index;
        }

        public bool GetColumnVisibility(string columnName)
        {
            var visible = true;
            try
            {
                visible = GridExtension.GetColumnVisibility(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return visible;
        }

        public void HeaderCellRender(string propertyName)
        {
            try
            {
                GridContainerServices.VisibleColumnList =
                    GridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private bool SetLinkReadPermissionStatus(PagePermission pagePermission)
        {
            var perm = GetUserPermissions(pagePermission);
            return perm.Read;
        }

        #endregion
    }
}