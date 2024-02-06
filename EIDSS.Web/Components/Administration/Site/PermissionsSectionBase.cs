#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.Site;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Administration.Site
{
    /// <summary>
    /// </summary>
    public class PermissionsSectionBase : BaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<PermissionsSectionBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private ISiteClient SiteClient { get; set; }
        [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] private IUserGroupClient UserGroupClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public SiteDetailsViewModel Model { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }

        #endregion

        #region Properties

        public bool IsLoading { get; set; }
        protected RadzenDataGrid<SiteActorGetListViewModel> ActorsGrid { get; set; }
        public List<EmployeesForUserGroupViewModel> Actors { get; set; }
        public IList<SiteActorGetListViewModel> SelectedActor { get; set; }
        public long? ActorId { get; set; }
        public int Count { get; set; }
        private int PreviousPageSize { get; set; }

        private List<BaseReferenceViewModel> ObjectOperationTypes { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private int _databaseQueryCount;
        private int _newActorRecordCount;
        private int _newPermissionRecordCount;
        private int _lastDatabasePage;
        private int _lastPage = 1;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "ActorTypeName";

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            await GetObjectOperationTypes();

            await base.OnInitializedAsync();
        }

        /// <summary>
        ///     Cancel any background tasks and remove event handlers.
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                IsLoading = true;

                ActorId = null;

                //if (Model.SiteInformationSection.SiteDetails.SiteID != null)
                //Actors = await GetActors((long) Model.SiteInformationSection.SiteDetails.SiteID, false, 1,
                //    MaxValue - 1, DefaultSortColumn,
                //    SortConstants.Ascending);

                if (Model.PermissionsSection.PendingSaveActorPermissions is not null &&
                    Model.PermissionsSection.PendingSaveActorPermissions.Any())
                    _newPermissionRecordCount = Model.PermissionsSection.PendingSaveActorPermissions.Count;

                await JsRuntime.InvokeVoidAsync("PermissionsSection.SetDotNetReference", _token,
                    DotNetObjectReference.Create(this));
            }
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// </summary>
        /// <param name="siteId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<SiteActorGetListViewModel>> GetActors(long siteId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new SiteActorGetRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder,
                SiteID = siteId
            };

            return await SiteClient.GetSiteActorList(request);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task GetObjectOperationTypes()
        {
            try
            {
                ObjectOperationTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.SystemFunctionOperation, HACodeList.NoneHACode).ConfigureAwait(false);

                var executePermission =
                    ObjectOperationTypes.First(x => x.IdfsBaseReference == (long)PermissionLevelEnum.Execute);

                ObjectOperationTypes.Remove(executePermission);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadActorData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (ActorsGrid.PageSize != 0)
                    pageSize = ActorsGrid.PageSize;

                if (PreviousPageSize != pageSize)
                    IsLoading = true;

                PreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (Model.PermissionsSection.Actors is null ||
                        _lastPage != (args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize))
                        IsLoading = true;

                    if (IsLoading || !IsNullOrEmpty(args.OrderBy))
                    {
                        if (args.Sorts != null && args.Sorts.Any())
                        {
                            sortColumn = args.Sorts.First().Property;
                            sortOrder = SortConstants.Descending;
                            if (args.Sorts.First().SortOrder.HasValue)
                            {
                                var order = args.Sorts.First().SortOrder;
                                if (order != null && order.Value.ToString() == "Ascending")
                                    sortOrder = SortConstants.Ascending;
                            }
                        }

                        if (Model.SiteInformationSection.SiteDetails.SiteID is null)
                        {
                            Model.PermissionsSection.Actors = new List<SiteActorGetListViewModel>();
                            if (Model.PermissionsSection.PendingSaveActors is not null)
                                _newActorRecordCount = Model.PermissionsSection.PendingSaveActors.Count;
                        }
                        else
                        {
                            Model.PermissionsSection.Actors =
                                await GetActors((long)Model.SiteInformationSection.SiteDetails.SiteID, page,
                                        pageSize,
                                        sortColumn, sortOrder)
                                    .ConfigureAwait(false);

                            if (Model.PermissionsSection.Actors.All(x => x.DefaultEmployeeGroupIndicator == false))
                            {
                                UserGroupGetRequestModel request = new()
                                {
                                    LanguageId = GetCurrentLanguage(),
                                    Page = 1,
                                    PageSize = MaxValue - 1,
                                    SortColumn = "idfEmployeeGroup",
                                    SortOrder = SortConstants.Ascending
                                };
                                var list = await UserGroupClient.GetUserGroupList(request);
                                if (list.Any(x => x.idfEmployeeGroup == (long)RoleEnum.DefaultRole))
                                {
                                    Model.PermissionsSection.PendingSaveActors = new List<SiteActorGetListViewModel>();
                                    SiteActorGetListViewModel defaultActor = new()
                                    {
                                        ActorID = -1,
                                        ActorTypeName = "Employee Group",
                                        ActorName = list.First(x => x.idfEmployeeGroup == (long)RoleEnum.DefaultRole)
                                            .strName,
                                        DefaultEmployeeGroupIndicator = true,
                                        ExternalActorIndicator = false,
                                        RowAction = (int)RowActionTypeEnum.Insert,
                                        RowStatus = (int)RowStatusTypeEnum.Active
                                    };
                                    Model.PermissionsSection.PendingSaveActors.Add(defaultActor);
                                    _newActorRecordCount += 1;

                                    var objectOperationTypes = await CrossCuttingClient.GetBaseReferenceList(
                                            GetCurrentLanguage(),
                                            BaseReferenceConstants.SystemFunctionOperation, HACodeList.NoneHACode)
                                        .ConfigureAwait(false);

                                    var executePermission = objectOperationTypes.First(x =>
                                        x.IdfsBaseReference ==
                                        (long)ClientLibrary.Enumerations.PermissionLevelEnum.Execute);
                                    var newRecordCount = 1;
                                    objectOperationTypes.Remove(executePermission);
                                    Model.PermissionsSection.PendingSaveActors.First().Permissions =
                                        new List<ObjectAccessGetListViewModel>();
                                    Model.PermissionsSection.PendingSaveActorPermissions =
                                        new List<ObjectAccessGetListViewModel>();
                                    foreach (var permission in objectOperationTypes.Select(item =>
                                                 new ObjectAccessGetListViewModel
                                                 {
                                                     ObjectAccessID = newRecordCount * -1,
                                                     ObjectOperationTypeID = item.IdfsBaseReference,
                                                     ObjectOperationTypeName = item.Name,
                                                     ObjectTypeID = (long)ObjectTypeEnum.Site,
                                                     ObjectID = -1,
                                                     ActorID = defaultActor.ActorID,
                                                     DefaultEmployeeGroupIndicator = true,
                                                     SiteID = -1,
                                                     PermissionTypeID =
                                                         item.IdfsBaseReference ==
                                                         (long)PermissionLevelEnum.Read
                                                             ? (int)PermissionValueTypeEnum.Allow
                                                             : (int)PermissionValueTypeEnum.Deny,
                                                     PermissionIndicator = item.IdfsBaseReference ==
                                                                           (long)PermissionLevelEnum.Read,
                                                     RowStatus = (int)RowStatusTypeEnum.Active,
                                                     RowAction = RecordConstants.Insert
                                                 }))
                                    {
                                        Model.PermissionsSection.PendingSaveActors.First().Permissions
                                            .Add(permission);
                                        Model.PermissionsSection.PendingSaveActorPermissions.Add(permission);

                                        newRecordCount += 1;
                                    }
                                }
                            }
                        }

                        _databaseQueryCount = !Model.PermissionsSection.Actors.Any()
                            ? 0
                            : Model.PermissionsSection.Actors.First().TotalRowCount;
                    }
                    else if (Model.PermissionsSection.Actors != null)
                    {
                        var deletedCount =
                            _databaseQueryCount = Model.PermissionsSection.Actors.Count(x =>
                                x.RowStatus == (int)RowStatusTypeEnum.Inactive);
                        var databaseCount =
                            Model.PermissionsSection.Actors.All(x => x.RowAction == (int)RowActionTypeEnum.Insert)
                                ? 0
                                : Model.PermissionsSection.Actors
                                    .First(x => x.RowAction != (int)RowActionTypeEnum.Insert).TotalRowCount;
                        _databaseQueryCount = Model.PermissionsSection.Actors.All(x =>
                            x.RowStatus == (int)RowStatusTypeEnum.Inactive ||
                            (x.ActorID < 0 && x.RowAction == (int)RowActionTypeEnum.Insert))
                            ? 0
                            : databaseCount - deletedCount;
                    }

                    if (Model.PermissionsSection.Actors != null)
                        for (var index = 0; index < Model.PermissionsSection.Actors.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.PermissionsSection.Actors[index].RowAction == (int)RowActionTypeEnum.Insert)
                            {
                                Model.PermissionsSection.Actors.RemoveAt(index);
                                index--;
                            }

                            if (Model.PermissionsSection.PendingSaveActors == null || index < 0 ||
                                Model.PermissionsSection.Actors.Count == 0 ||
                                Model.PermissionsSection.PendingSaveActors.All(x =>
                                    x.ActorID != Model.PermissionsSection.Actors[index].ActorID))
                                continue;
                            {
                                if (Model.PermissionsSection.PendingSaveActors
                                        .First(x => x.ActorID ==
                                                    Model.PermissionsSection.Actors[index].ActorID)
                                        .RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    Model.PermissionsSection.Actors.RemoveAt(index);
                                    _databaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.PermissionsSection.Actors[index] =
                                        Model.PermissionsSection.PendingSaveActors.First(x =>
                                            x.ActorID ==
                                            Model.PermissionsSection.Actors[index].ActorID);
                                }
                            }
                        }

                    Count = _databaseQueryCount + _newActorRecordCount;

                    if (_newActorRecordCount > 0)
                    {
                        _lastDatabasePage = Math.DivRem(_databaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _lastDatabasePage == 0)
                            _lastDatabasePage += 1;

                        if (page >= _lastDatabasePage && Model.PermissionsSection.PendingSaveActors != null &&
                            Model.PermissionsSection.PendingSaveActors.Any(x =>
                                x.RowAction == (int)RowActionTypeEnum.Insert))
                        {
                            var newRecordsPendingSave =
                                Model.PermissionsSection.PendingSaveActors
                                    .Where(x => x.RowAction == (int)RowActionTypeEnum.Insert).ToList();
                            var counter = 0;
                            var pendingSavePage = page - _lastDatabasePage;
                            var quotientNewRecords = Math.DivRem(Count, pageSize, out var remainderNewRecords);

                            if (remainderNewRecords >= pageSize / 2)
                                quotientNewRecords += 1;

                            if (pendingSavePage == 0)
                            {
                                pageSize = pageSize - remainderDatabaseQuery > newRecordsPendingSave.Count
                                    ? newRecordsPendingSave.Count
                                    : pageSize - remainderDatabaseQuery;
                            }
                            else if (page - 1 == quotientNewRecords)
                            {
                                remainderDatabaseQuery = 1;
                                pageSize = remainderNewRecords;
                                Model.PermissionsSection.Actors?.Clear();
                            }
                            else
                            {
                                Model.PermissionsSection.Actors?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.PermissionsSection.Actors?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.PermissionsSection.Actors != null)
                            Model.PermissionsSection.Actors = Model.PermissionsSection.Actors.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _lastPage = page;
                }

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
        /// <param name="args"></param>
        protected async Task OnRowRender(RowRenderEventArgs<SiteActorGetListViewModel> args)
        {
            try
            {
                args.Expandable = args.Data.ActorTypeID == (long)ActorTypeEnum.EmployeeGroup;

                if (Model.SiteInformationSection.SiteDetails.SiteID != null)
                {
                    Model.PermissionsSection.PendingSaveActorPermissions ??= new List<ObjectAccessGetListViewModel>();

                    var model = new ObjectAccessGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        ActorID = args.Data.ActorID,
                        ObjectID = (long)Model.SiteInformationSection.SiteDetails.SiteID,
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = "ActorName",
                        SortOrder = SortConstants.Ascending
                    };
                    var permissions = await CrossCuttingClient.GetObjectAccessList(model);

                    if (Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID)
                            .Permissions is null ||
                        !Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID).Permissions.Any())
                    {
                        Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID).Permissions =
                            new List<ObjectAccessGetListViewModel>();

                        foreach (var permission in ObjectOperationTypes.Select(item => new ObjectAccessGetListViewModel
                        {
                            ObjectAccessID = _newPermissionRecordCount + 1 * -1,
                            ObjectOperationTypeID = item.IdfsBaseReference,
                            ObjectOperationTypeName = item.Name,
                            ObjectTypeID = (long)ObjectTypeEnum.Site,
                            ObjectID = Model.SiteID,
                            ActorID = args.Data.ActorID,
                            DefaultEmployeeGroupIndicator = args.Data.DefaultEmployeeGroupIndicator,
                            SiteID = Model.SiteID,
                            PermissionTypeID = (int)PermissionValueTypeEnum.Deny,
                            PermissionIndicator = false,
                            RowStatus = (int)RowStatusTypeEnum.Active,
                            RowAction = RecordConstants.Read
                        }))
                            Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID).Permissions
                                .Add(permission);
                    }

                    if (permissions.Any())
                        foreach (var permission in permissions.Where(permission =>
                                     Model.PermissionsSection.PendingSaveActorPermissions.All(x =>
                                         x.ObjectAccessID != permission.ObjectAccessID)))
                        {
                            Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID).Permissions
                                .First(y => y.ObjectOperationTypeID == permission.ObjectOperationTypeID)
                                .ObjectAccessID = permission.ObjectAccessID;

                            Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID).Permissions
                                    .First(y => y.ObjectOperationTypeID == permission.ObjectOperationTypeID)
                                    .PermissionTypeID =
                                permission.PermissionTypeID;

                            Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID).Permissions
                                .First(y => y.ObjectOperationTypeID == permission.ObjectOperationTypeID)
                                .PermissionIndicator = Model.PermissionsSection.Actors
                                .First(x => x.ActorID == args.Data.ActorID).Permissions
                                .First(y => y.ObjectOperationTypeID == permission.ObjectOperationTypeID)
                                .PermissionTypeID == (int)PermissionValueTypeEnum.Allow;
                        }
                }

                if ((args.Data.ActorTypeID == (long)ActorTypeEnum.EmployeeGroup && Model.PermissionsSection.Actors
                        .First(x => x.ActorID == args.Data.ActorID).Employees is null) ||
                    !Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID).Employees.Any())
                {
                    if (Actors is not null)
                    {
                        Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID).Employees =
                            Actors.Where(x => x.idfEmployeeGroup == args.Data.ActorID).ToList();
                    }
                    else
                    {
                        var request = new EmployeesForUserGroupGetRequestModel
                        {
                            idfEmployeeGroup = args.Data.ActorID,
                            langId = GetCurrentLanguage(),
                            pageNo = 1,
                            pageSize = 10,
                            SortColumn = "Name",
                            SortOrder = "ASC",
                            idfsSite = Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID).SiteID
                        };
                        Model.PermissionsSection.Actors.First(x => x.ActorID == args.Data.ActorID).Employees =
                            await UserGroupClient.GetEmployeesForUserGroupList(request);
                    }
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
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveActors(SiteActorGetListViewModel record,
            SiteActorGetListViewModel originalRecord)
        {
            Model.PermissionsSection.PendingSaveActors ??= new List<SiteActorGetListViewModel>();

            if (Model.PermissionsSection.PendingSaveActors.Any(x => x.ActorID == record.ActorID))
            {
                if (originalRecord is not null)
                {
                    var index = Model.PermissionsSection.PendingSaveActors.FindIndex(x =>
                        x.ActorID == originalRecord.ActorID);
                    Model.PermissionsSection.PendingSaveActors[index] = record;
                }
                else
                {
                    Model.PermissionsSection.PendingSaveActors.Add(record);
                }
            }
            else
            {
                Model.PermissionsSection.PendingSaveActors.Add(record);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveActorPermissions(ObjectAccessGetListViewModel record,
            ObjectAccessGetListViewModel originalRecord)
        {
            Model.PermissionsSection.PendingSaveActorPermissions ??= new List<ObjectAccessGetListViewModel>();

            if (Model.PermissionsSection.PendingSaveActorPermissions.Any(x =>
                    x.ObjectAccessID == record.ObjectAccessID))
            {
                if (originalRecord is not null)
                {
                    var index = Model.PermissionsSection.PendingSaveActorPermissions.FindIndex(x =>
                        x.ObjectAccessID == originalRecord.ObjectAccessID);
                    Model.PermissionsSection.PendingSaveActorPermissions[index] = record;
                }
                else
                {
                    Model.PermissionsSection.PendingSaveActorPermissions.Add(record);
                }
            }
            else
            {
                Model.PermissionsSection.PendingSaveActorPermissions.Add(record);
            }
        }

        #endregion

        #region Add Actor Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddActorClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<SearchActor>(
                    Localizer.GetString(HeadingResourceKeyConstants.UsersAndGroupsListModalHeading),
                    new Dictionary<string, object>(),
                    new DialogOptions
                    {
                        Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true,
                        ShowClose = true
                    });

                if (result is List<ActorGetListViewModel> list)
                {
                    if (list.Any())
                        foreach (var item in list)
                        {
                            var siteIdentifier = item.EmployeeUserID is not null
                                ? item.EmployeeSiteID
                                : item.UserGroupSiteID;
                            _newPermissionRecordCount += 1;

                            SiteActorGetListViewModel actor = new()
                            {
                                ActorID = item.ActorID,
                                ActorTypeName = item.ActorTypeName,
                                ActorName = item.ActorName,
                                ExternalActorIndicator =
                                    siteIdentifier != Model.SiteInformationSection.SiteDetails.SiteID,
                                RowAction = (int)RowActionTypeEnum.Insert,
                                RowStatus = (int)RowStatusTypeEnum.Active
                            };

                            TogglePendingSaveActors(actor, null);

                            _newActorRecordCount += 1;

                            ActorId = item.ActorID;

                            Model.PermissionsSection.PendingSaveActors.First(x => x.ActorID == actor.ActorID)
                                    .Permissions =
                                new List<ObjectAccessGetListViewModel>();

                            foreach (var permission in ObjectOperationTypes.Select(baseReferenceViewModel =>
                                         new ObjectAccessGetListViewModel
                                         {
                                             ObjectAccessID = _newPermissionRecordCount * -1,
                                             ObjectOperationTypeID = baseReferenceViewModel.IdfsBaseReference,
                                             ObjectOperationTypeName = baseReferenceViewModel.Name,
                                             ObjectTypeID = (long)ObjectTypeEnum.Site,
                                             ObjectID = Model.SiteID,
                                             ActorID = actor.ActorID,
                                             DefaultEmployeeGroupIndicator = false,
                                             SiteID = Model.SiteID,
                                             PermissionTypeID = (int)PermissionValueTypeEnum.Deny,
                                             PermissionIndicator = false,
                                             RowStatus = (int)RowStatusTypeEnum.Active,
                                             RowAction = RecordConstants.Read
                                         }))
                            {
                                Model.PermissionsSection.PendingSaveActors.First(x => x.ActorID == actor.ActorID)
                                    .Permissions
                                    .Add(permission);

                                TogglePendingSaveActorPermissions(permission, null);

                                _newPermissionRecordCount += 1;
                            }
                        }

                    await ActorsGrid.Reload().ConfigureAwait(false);
                }
                else
                {
                    IsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Change Permission Event

        /// <summary>
        /// </summary>
        /// <param name="item"></param>
        protected void ChangePermission(ObjectAccessGetListViewModel item)
        {
            try
            {
                ObjectAccessGetListViewModel originalRecord = null;
                if (Model.PermissionsSection.Actors.Any(x => x.ActorID == item.ActorID))
                {
                    originalRecord =
                        Model.PermissionsSection.Actors.First(x => x.ActorID == item.ActorID).Permissions
                            .First(x => x.ObjectAccessID == item.ObjectAccessID);

                    Model.PermissionsSection.Actors.First(x => x.ActorID == item.ActorID).Permissions
                        .First(x => x.ObjectAccessID == item.ObjectAccessID).PermissionTypeID = item.PermissionIndicator
                        ? (int)PermissionValueTypeEnum.Allow
                        : (int)PermissionValueTypeEnum.Deny;

                    Model.PermissionsSection.Actors.First(x => x.ActorID == item.ActorID).Permissions
                            .First(x => x.ObjectAccessID == item.ObjectAccessID).PermissionIndicator =
                        item.PermissionIndicator;

                    Model.PermissionsSection.Actors.First(x => x.ActorID == item.ActorID).Permissions
                        .First(x => x.ObjectAccessID == item.ObjectAccessID).RowAction = RecordConstants.Update;
                }

                item.PermissionTypeID = item.PermissionIndicator
                    ? (int)PermissionValueTypeEnum.Allow
                    : (int)PermissionValueTypeEnum.Deny;
                item.RowAction = RecordConstants.Update;

                TogglePendingSaveActorPermissions(item, originalRecord);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Actor Row Selection Click Event

        /// <summary>
        /// </summary>
        /// <param name="actor"></param>
        protected void OnRowSelect(SiteActorGetListViewModel actor)
        {
            try
            {
                SelectedActor ??= new List<SiteActorGetListViewModel>();
                SelectedActor.Clear();
                ActorId = actor.ActorID;
                SelectedActor.Add(actor);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Actor Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="actor"></param>
        protected async Task OnDeleteActorClick(object actor)
        {
            try
            {
                var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage,
                    null);

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (Model.PermissionsSection.Actors.Any(x =>
                                x.ActorID == ((SiteActorGetListViewModel)actor).ActorID))
                        {
                            if (((SiteActorGetListViewModel)actor).ActorID <= 0 &&
                                ((SiteActorGetListViewModel)actor).RowAction == (int)RowActionTypeEnum.Insert)
                            {
                                Model.PermissionsSection.Actors.Remove((SiteActorGetListViewModel)actor);
                                Model.PermissionsSection.PendingSaveActors.Remove(
                                    (SiteActorGetListViewModel)actor);

                                if (Model.PermissionsSection.PendingSaveActorPermissions is not null &&
                                    Model.PermissionsSection.PendingSaveActorPermissions.Any(x =>
                                        x.ActorID == ((SiteActorGetListViewModel)actor).ActorID))
                                    Model.PermissionsSection.PendingSaveActorPermissions.RemoveAll(x =>
                                        x.ActorID == ((SiteActorGetListViewModel)actor).ActorID);

                                _newActorRecordCount--;
                            }
                            else
                            {
                                result = ((SiteActorGetListViewModel)actor).ShallowCopy();
                                result.RowAction = (int)RowActionTypeEnum.Delete;
                                result.RowStatus = (int)RowStatusTypeEnum.Inactive;

                                var permissions = Model.PermissionsSection.Actors
                                    .First(x => x.ActorID == ((SiteActorGetListViewModel)actor).ActorID).Permissions;

                                Model.PermissionsSection.Actors.RemoveAll(x =>
                                    x.ActorID == ((SiteActorGetListViewModel)actor).ActorID);
                                Count--;

                                if (permissions is not null)
                                    foreach (var permission in permissions)
                                    {
                                        var permissionResult = permission.ShallowCopy();

                                        permission.RowAction = RecordConstants.Delete;
                                        permission.RowStatus = (int)RowStatusTypeEnum.Inactive;

                                        TogglePendingSaveActorPermissions(permission, permissionResult);
                                    }

                                TogglePendingSaveActors(result, (SiteActorGetListViewModel)actor);
                            }
                        }

                        await ActorsGrid.Reload().ConfigureAwait(false);

                        DiagService.Close(result);
                    }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSubmit()
        {
            Model.PermissionsSectionValidIndicator = true;

            return Model.PermissionsSectionValidIndicator;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public bool ValidateSectionForSidebar()
        {
            Model.PermissionsSectionValidIndicator = true;

            return Model.PermissionsSectionValidIndicator;
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public void ReloadSection()
        {
            Model.PermissionsSection.Actors = null;
            ActorsGrid.Reload();
        }

        #endregion

        #endregion
    }
}