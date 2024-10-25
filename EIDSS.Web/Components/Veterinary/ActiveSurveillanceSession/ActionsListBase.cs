using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class ActionsBase : SurveillanceSessionBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        //[Inject]
        //protected VeterinaryActiveSurveillanceSessionStateContainerService StateContainer { get; set; }

        [Inject]
        ILogger<ActionsBase> Logger { get; set; }

        #endregion

        #region Parameters

        #endregion

        #region Properties

        #endregion

        #region Member Variables

        protected int ActionsCount;
        protected int ActionsDatabaseQueryCount;
        protected int ActionsLastDatabasePage;
        protected int ActionsNewRecordCount;
        protected bool IsLoading;
        protected RadzenDataGrid<VeterinaryActiveSurveillanceSessionActionsViewModel> ActionsGrid;

        private CancellationTokenSource source;
        private CancellationToken token;

        #endregion

        #region Constants

        private const string DEFAULT_SORT_COLUMN = "ActionDate";

        #endregion

        #endregion

        #region Methods

        protected override Task OnInitializedAsync()
        {
            _logger = Logger;

            // reset the cancellation token
            source = new();
            token = source.Token;

            return base.OnInitializedAsync();
        }

        protected async Task LoadActionsGridView(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.SessionKey != null)
                {
                    int page,
                        pageSize = 10;

                    page = args.Skip == null ? 1 : ((int)args.Skip + (int)args.Top) / pageSize;

                    if (StateContainer.Actions is null)
                        IsLoading = true;

                    if (IsLoading || !string.IsNullOrEmpty(args.OrderBy))
                    {
                        string sortColumn,
                           sortOrder;

                        if (args.Sorts == null || args.Sorts.Any() == false)
                        {
                            sortColumn = DEFAULT_SORT_COLUMN;
                            sortOrder = SortConstants.Descending;
                        }
                        else
                        {
                            sortColumn = args.Sorts.FirstOrDefault().Property;
                            sortOrder = args.Sorts.FirstOrDefault().SortOrder.HasValue ? args.Sorts.FirstOrDefault().SortOrder.Value.ToString() : SortConstants.Descending;
                        }

                        var request = new VeterinaryActiveSurveillanceSessionActionsRequestModel()
                        {
                            LanguageId = GetCurrentLanguage(),
                            MonitoringSessionID = StateContainer.SessionKey.Value,
                            Page = page,
                            PageSize = pageSize,
                            SortColumn = sortColumn,
                            SortOrder = sortOrder
                        };

                        StateContainer.Actions = await VeterinaryClient.GetActiveSurveillanceSessionActionsListAsync(request, token);
                        ActionsDatabaseQueryCount = !StateContainer.Actions.Any() ? 0 : StateContainer.Actions.Count;

                        // Pagination refresh from the database, so check any pending save updates.
                        for (int index = 0; index < StateContainer.Actions.Count; index++)
                        {
                            if (StateContainer.PendingSaveActions != null && StateContainer.PendingSaveActions.Any(x => x.MonitoringSessionActionID == StateContainer.Actions[index].MonitoringSessionActionID))
                            {
                                if (StateContainer.PendingSaveActions.First(x => x.MonitoringSessionActionID == StateContainer.Actions[index].MonitoringSessionActionID).RowStatus == (int)RowStatusTypeEnum.Inactive)
                                {
                                    StateContainer.Actions.RemoveAt(index);
                                    ActionsDatabaseQueryCount--;
                                }
                                else
                                    StateContainer.Actions[index] = StateContainer.PendingSaveActions.First(x => x.MonitoringSessionActionID == StateContainer.Actions[index].MonitoringSessionActionID);
                            }
                        }
                    }
                    else
                        ActionsDatabaseQueryCount = 0; //!StateContainer.Actions.Any() ? 0 : StateContainer.Actions.Count;

                    ActionsCount = ActionsDatabaseQueryCount + ActionsNewRecordCount;

                    ActionsLastDatabasePage = Math.DivRem(ActionsDatabaseQueryCount, pageSize, out int remainderDatabaseQuery);
                    if (remainderDatabaseQuery > 0)
                        ActionsLastDatabasePage += 1;

                    for (int index = 0; index < StateContainer.Actions.Count; index++)
                    {
                        if (StateContainer.PendingSaveActions != null && StateContainer.PendingSaveActions.Any(x => x.MonitoringSessionActionID == StateContainer.Actions[index].MonitoringSessionActionID))
                        {
                            StateContainer.Actions[index] = StateContainer.PendingSaveActions.First(x => x.MonitoringSessionActionID == StateContainer.Actions[index].MonitoringSessionActionID);
                        }
                    }

                    if (page >= ActionsLastDatabasePage && StateContainer.PendingSaveActions != null && StateContainer.PendingSaveActions.Any(x => x.MonitoringSessionActionID < 0))
                    {
                        List<VeterinaryActiveSurveillanceSessionActionsViewModel> newRecordsPendingSave = StateContainer.PendingSaveActions.Where(x => x.MonitoringSessionActionID < 0).ToList();
                        int counter = 0;
                        int pendingSavePage = page - ActionsLastDatabasePage;
                        int remainderNewRecords, quotientNewRecords = Math.DivRem(ActionsCount, pageSize, out remainderNewRecords);

                        if (remainderNewRecords >= 5)
                            quotientNewRecords += 1;

                        if (pendingSavePage == 1)
                        {
                            if (remainderDatabaseQuery > newRecordsPendingSave.Count)
                                pageSize = newRecordsPendingSave.Count;
                            else
                                pageSize = remainderDatabaseQuery;
                        }
                        else if (page == quotientNewRecords)
                        {
                            pageSize = remainderNewRecords;
                            StateContainer.Actions.Clear();
                        }
                        else
                            StateContainer.Actions.Clear();

                        while (counter < pageSize)
                        {
                            if (pendingSavePage == 0)
                                StateContainer.Actions.Add(newRecordsPendingSave[counter]);
                            else
                                StateContainer.Actions.Add(newRecordsPendingSave[pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                            counter += 1;
                        }
                    }

                    ActionsLastDatabasePage = page;
                    IsLoading = false;
                }
                else
                {
                    StateContainer.Actions = new List<VeterinaryActiveSurveillanceSessionActionsViewModel>();
                    ActionsCount = 0;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveActions(VeterinaryActiveSurveillanceSessionActionsViewModel record, VeterinaryActiveSurveillanceSessionActionsViewModel originalRecord)
        {
            int index;

            if (StateContainer.PendingSaveActions == null)
                StateContainer.PendingSaveActions = new List<VeterinaryActiveSurveillanceSessionActionsViewModel>();

            if (StateContainer.PendingSaveActions.Any(x => x.MonitoringSessionActionID == record.MonitoringSessionActionID))
            {
                index = StateContainer.PendingSaveActions.IndexOf(originalRecord);
                StateContainer.PendingSaveActions[index] = record;
            }
            else
            {
                StateContainer.PendingSaveActions.Add(record);
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

      
        #endregion

        #region Add Action Button Click Event

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddActionClick()
        {
            try
            {
                var authenticatedUser = _tokenService.GetAuthenticatedUser();
                StateContainer.ActionDetail = new VeterinaryActiveSurveillanceSessionActionsViewModel()
                {
                    EnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId)
                };

                dynamic result = await DiagService.OpenAsync<ActionModal>(Localizer.GetString(HeadingResourceKeyConstants.ActionDetailsModalHeading), new Dictionary<string, object>() { },
                    options: new DialogOptions() { Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true, CloseDialogOnOverlayClick = true, ShowClose = true });

                if (result is VeterinaryActiveSurveillanceSessionActionsViewModel)
                {
                    ActionsNewRecordCount += 1;

                    StateContainer.Actions.Add(result as VeterinaryActiveSurveillanceSessionActionsViewModel);

                    TogglePendingSaveActions(result as VeterinaryActiveSurveillanceSessionActionsViewModel, null);

                    await ActionsGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Action Button Click Event

        /// <summary>
        /// 
        /// </summary>
        /// <param name="item"></param>
        protected async Task OnEditActionClick(VeterinaryActiveSurveillanceSessionActionsViewModel item)
        {
            try
            {
                StateContainer.ActionDetail = item;
                dynamic result = await DiagService.OpenAsync<ActionModal>(Localizer.GetString(HeadingResourceKeyConstants.ActionDetailsModalHeading), new Dictionary<string, object>() { },
                    options: new DialogOptions() { Style = CSSClassConstants.DefaultDialogWidth, AutoFocusFirstElement = true, CloseDialogOnOverlayClick = true, ShowClose = true });

                if (result is VeterinaryActiveSurveillanceSessionActionsViewModel)
                {
                    if (StateContainer.Actions.Any(x => x.MonitoringSessionActionID == (result as VeterinaryActiveSurveillanceSessionActionsViewModel).MonitoringSessionActionID))
                    {
                        int index = StateContainer.Actions.IndexOf(item as VeterinaryActiveSurveillanceSessionActionsViewModel);
                        StateContainer.Actions[index] = result as VeterinaryActiveSurveillanceSessionActionsViewModel;

                        TogglePendingSaveActions(result as VeterinaryActiveSurveillanceSessionActionsViewModel, item as VeterinaryActiveSurveillanceSessionActionsViewModel);
                    }

                    await ActionsGrid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Action Button Click Event

        protected async Task OnDeleteActionClick(VeterinaryActiveSurveillanceSessionActionsViewModel item)
        {
            try
            {
                dynamic result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                if (result is DialogReturnResult)
                {
                    if ((result as DialogReturnResult).ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (StateContainer.Actions.Any(x => x.MonitoringSessionActionID == item.MonitoringSessionActionID))
                        {
                            if (item.MonitoringSessionActionID <= 0)
                            {
                                StateContainer.Actions.Remove(item);
                                StateContainer.PendingSaveActions.Remove(item);
                                ActionsNewRecordCount--;
                            }
                            else
                            {
                                result = item.ShallowCopy();
                                result.RowAction = (int)RowActionTypeEnum.Delete;
                                result.RowStatus = (int)RowStatusTypeEnum.Inactive;
                                StateContainer.Actions.Remove(item);
                                ActionsCount--;

                                TogglePendingSaveActions(result, item);
                            }
                        }

                        await ActionsGrid.Reload();

                        DiagService.Close(result);
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

  
        
    }
}