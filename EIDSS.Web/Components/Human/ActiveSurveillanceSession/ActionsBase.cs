using System;
using Microsoft.AspNetCore.Components;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using System.Threading;
using System.Threading.Tasks;
using Radzen;
using Radzen.Blazor;
using System.Collections.Generic;
using Microsoft.Extensions.Localization;
using EIDSS.Localization.Constants;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.ClientLibrary.ApiClients.Human;
using Microsoft.Extensions.Logging;
using System.Linq;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Web.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Web.ViewModels;
using EIDSS.ClientLibrary;
using Microsoft.JSInterop;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Web.Services;
using EIDSS.Web.Components.CrossCutting;
using System.Linq.Dynamic.Core;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class ActionsBase : ParentComponent, IDisposable
    {
        #region GRID REORDER

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }

        public CrossCutting.GridExtensionBase gridExtension { get; set; }

        #endregion GRID REORDER

        #region Globals

        [Parameter]
        public ActiveSurveillanceSessionViewModel model { get; set; }

        private ILogger<ActionsBase> Logger { get; set; }
        private CancellationTokenSource source;
        private CancellationToken token;
        protected bool isLoading;
        protected int count = 0;

        protected RadzenDataGrid<ActiveSurveillanceSessionActionsResponseModel> _actionsGrid;
        protected List<ActiveSurveillanceSessionActionsResponseModel> ActionsList { get; set; }

        [Inject]
        private DialogService DialogService { get; set; }

        [Inject]
        public IHumanActiveSurveillanceSessionClient _humanActiveSurveillanceSessionClient { get; set; }

        #endregion Globals

        protected override async Task OnInitializedAsync()
        {
            GridContainerServices.OnChange += async (property) => await StateContainerChangeAsync(property);
            authenticatedUser = TokenService.GetAuthenticatedUser();
            _logger = Logger;
            await base.OnInitializedAsync();
        }

        protected async Task LoadActionsGridView(LoadDataArgs args, bool bInitialLoad = true)
        {
            try
            {
                isLoading = true;

                if (bInitialLoad && IdfMonitoringSession != null)
                {
                    var request = new ActiveSurveillanceSessionActionsRequestModel();

                    request.LanguageId = GetCurrentLanguage();
                    request.MonitoringSessionID = IdfMonitoringSession ?? 0; //Hack to keep all actions from returning.
                    request.Page = 1;
                    request.PageSize = int.MaxValue - 1;
                    request.SortColumn = "intOrder";
                    request.SortOrder = "asc";

                    model.ActionsInformation.List = await _humanActiveSurveillanceSessionClient.GetHumanActiveSurveillanceSessionActionsListAsync(request, token);
                    model.ActionsInformation.UnfilteredList = model.ActionsInformation.List;
                }

                _actionsGrid.Reset();
                count = (model.ActionsInformation.List == null) ? 0 : model.ActionsInformation.List.Count;
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                if (source?.IsCancellationRequested == true)
                {
                }
                else
                {
                    throw;
                }
            }
            finally
            {
                isLoading = false;
                await InvokeAsync(StateHasChanged);
            }
            isLoading = false;
        }

        public async Task EditAction(object args)
        {
            try
            {
                ClearActionModal();

                ActiveSurveillanceSessionActionsResponseModel action = (ActiveSurveillanceSessionActionsResponseModel)args;

                model.ActionsInformation.ID = action.MonitoringSessionActionID;
                model.ActionsInformation.ActionRequiredID = action.MonitoringSessionActionTypeID;
                model.ActionsInformation.Comment = action.Comments;
                model.ActionsInformation.DateOfAction = action.ActionDate;
                model.ActionsInformation.EnteredBy = action.EnteredByPersonName;
                model.ActionsInformation.StatusID = action.MonitoringSessionActionStatusTypeID;

                dynamic result = await DialogService.OpenAsync<ActionsModal>(Localizer.GetString(HeadingResourceKeyConstants.ActionDetailsModalHeading),
                    new Dictionary<string, object>() { { "model", model } }, new DialogOptions() { Width = "500px", Resizable = true, Draggable = false });

                await LoadActionsGridView(null, false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task OpenActionsModal(object args)
        {
            try
            {
                ClearActionModal();

                model.ActionsInformation.EnteredBy = authenticatedUser.LastName + ", " + authenticatedUser.FirstName + " " + authenticatedUser.SecondName;

                dynamic result = await DialogService.OpenAsync<ActionsModal>(Localizer.GetString(HeadingResourceKeyConstants.ActionDetailsModalHeading),
                    new Dictionary<string, object>() { { "model", model } }, new DialogOptions() { Width = "500px", Resizable = true, Draggable = false });

                await LoadActionsGridView(null, false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task DeleteRow(object value)
        {
            try
            {
                DialogReturnResult result = await ShowDeleteConfirmation();

                if (result != null)
                {
                    if ((result as DialogReturnResult).ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        ActiveSurveillanceSessionActionsResponseModel action =
                            (ActiveSurveillanceSessionActionsResponseModel) value;

                        if (action.MonitoringSessionActionID > 0)
                        {
                            action.RowAction = EIDSSConstants.UserAction.Delete;
                            action.RowStatus = (int) RowStatusTypeEnum.Inactive;
                            model.ActionsInformation.List.Add(action);
                            model.ActionsInformation.UnfilteredList = model.ActionsInformation.List;
                            model.ActionsInformation.List = model.ActionsInformation.List
                                .Where(x => x.RowAction != EIDSSConstants.UserAction.Delete).ToList();
                        }
                        else
                        {
                            model.ActionsInformation.List.Remove(action);
                        }

                        count = model.ActionsInformation.List.Count();
                        StateContainer.SetActiveSurveillanceSessionViewModel(model);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
                await InvokeAsync(StateHasChanged);
            }
        }

        public void Dispose()
        {
            try
            {
                source?.Cancel();
                source?.Dispose();
            }
            catch (Exception)
            {
                throw;
            }
        }

        #region Grid RedOrder ColumnChooser Methods

        protected override void OnInitialized()
        {
            gridExtension = new GridExtensionBase();
            GridColumnLoad("ActiveSurveillanceSessionActions");

            base.OnInitialized();
        }

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig = gridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
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
                gridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, _actionsGrid.ColumnsCollection.ToDynamicList(), GridContainerServices);
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
                index = gridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return index;
        }

        public bool GetColumnVisibility(string columnName)
        {
            bool visible = true;
            try
            {
                visible = gridExtension.GetColumnVisibility(columnName);
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
                GridContainerServices.VisibleColumnList = gridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task StateContainerChangeAsync(string property)
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion Grid RedOrder ColumnChooser Methods
    }
}