#region Usings

using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels.CrossCutting;
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
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class ActionModalBase : SurveillanceSessionBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        //[Inject]
        //protected VeterinaryActiveSurveillanceSessionStateContainerService StateContainer { get; set; }

        [Inject]
        ILogger<ActionModalBase> Logger { get; set; }

        #endregion

       
        #region Properties

        public RadzenTemplateForm<VeterinaryActiveSurveillanceSessionActionsViewModel> Form { get; set; }

        public IEnumerable<BaseReferenceViewModel> MonitoringStatusTypes;
        public IEnumerable<EmployeeLookupGetListViewModel> EnteredByPersons;
        public IEnumerable<BaseReferenceViewModel> ActionRequiredTypes;

        private VeterinaryActiveSurveillanceSessionActionsViewModel OriginalRecord { get; set; }

        #endregion

        #region Member Variables

        private AuthenticatedUser AuthenticatedUser;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// 
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            AuthenticatedUser = _tokenService.GetAuthenticatedUser();

            await GetEnteredByPersons();

            StateContainer.ActionDetail.EnteredByPersonName = EnteredByPersons.First(x => x.idfPerson == StateContainer.ActionDetail.EnteredByPersonID).FullName;

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// 
        /// </summary>
        public void Dispose()
        {
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetEnteredByPersons()
        {
            try
            {
                List<EmployeeLookupGetListViewModel> list;
                EmployeeLookupGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = null,
                    OrganizationID = AuthenticatedUser.OfficeId,
                    SortColumn = "FullName",
                    SortOrder = SortConstants.Ascending
                };

                list = await CrossCuttingClient.GetEmployeeLookupList(request);

                EnteredByPersons = list.AsODataEnumerable();

                await InvokeAsync(StateHasChanged);
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
        /// <returns></returns>
        public async Task GetMonitoringStatusTypes()
        {
            try
            {
                if (MonitoringStatusTypes == null)
                {
                    MonitoringStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ASSessionActionStatus, HACodeList.LiveStockAndAvian);
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
        /// <returns></returns>
        public async Task GetActionRequiredTypes()
        {
            try
            {
                if (ActionRequiredTypes == null)
                {
                    ActionRequiredTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ASSessionActionType, StateContainer.HACode);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Save Button Click Event

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected void OnSubmit()
        {
            if (Form.EditContext.Validate())
            {
                if (StateContainer.ActionDetail.MonitoringSessionActionID == 0 || StateContainer.ActionDetail.MonitoringSessionActionID is null)
                {
                    StateContainer.ActionDetail.MonitoringSessionActionID = StateContainer.Actions.Count + 1 * -1;
                    StateContainer.ActionDetail.RowAction = (int)RowActionTypeEnum.Insert;
                    StateContainer.ActionDetail.RowStatus = (int)RowStatusTypeEnum.Active;
                }
                else if (StateContainer.ActionDetail.MonitoringSessionActionID > 0)
                    StateContainer.ActionDetail.RowAction = (int)RowActionTypeEnum.Update;

                if (StateContainer.ActionDetail.EnteredByPersonID is not null)
                    if (EnteredByPersons.Any(x => x.idfPerson == StateContainer.ActionDetail.EnteredByPersonID))
                        StateContainer.ActionDetail.EnteredByPersonName = EnteredByPersons.First(x => x.idfPerson == StateContainer.ActionDetail.EnteredByPersonID).FullName;

                if (StateContainer.ActionDetail.MonitoringSessionActionStatusTypeID is not null)
                    StateContainer.ActionDetail.MonitoringSessionActionStatusTypeName = MonitoringStatusTypes.First(x => x.IdfsBaseReference == StateContainer.ActionDetail.MonitoringSessionActionStatusTypeID).Name;

                if (StateContainer.ActionDetail.MonitoringSessionActionTypeID is not null)
                    StateContainer.ActionDetail.MonitoringSessionActionTypeName = ActionRequiredTypes.First(x => x.IdfsBaseReference == StateContainer.ActionDetail.MonitoringSessionActionTypeID).Name;

                DiagService.Close(Form.EditContext.Model);
            }
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    dynamic result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null);

                    if (result is DialogReturnResult)
                    {
                        if (result is DialogReturnResult)
                            if ((result as DialogReturnResult).ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                            {
                                DiagService.Close(result);
                            }
                    }
                }
                else
                    DiagService.Close(null);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #endregion
    }
}
