using Microsoft.AspNetCore.Components;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using Microsoft.AspNetCore.Components.Forms;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using Microsoft.Extensions.Logging;
using Radzen;
using System;
using Radzen.Blazor;
using System.Collections.Generic;
using System.Threading.Tasks;
using EIDSS.Domain.ResponseModels.Human;
using System.Linq;
using EIDSS.ClientLibrary.Responses;

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class ActionsModalBase : ParentComponent, IDisposable
    {
        #region Globals

        [Parameter]
        public ActiveSurveillanceSessionViewModel model { get; set; }

        [Inject]
        ITokenService TokenService { get; set; }

        [Inject]
        protected DialogService DialogService { get; set; }

        public bool IsLoading { get; set; }
        public int Count;
        public RadzenTemplateForm<ActiveSurveillanceSessionViewModel> _form { get; set; }

        public EditContext EditContext { get; set; }

        #endregion

        protected override void OnInitialized()
        {
            IsLoading = true;
            EditContext = new(model);
        }

        protected async Task HandleValidEmployeeSubmit(ActiveSurveillanceSessionViewModel model)
        {
            try
            {
                if (_form.IsValid)
                {
                    ActiveSurveillanceSessionActionsResponseModel actionInformation = new ActiveSurveillanceSessionActionsResponseModel()
                    {
                        MonitoringSessionActionTypeID = long.Parse(model.ActionsInformation.ActionRequiredID.ToString()),
                        MonitoringSessionActionTypeName = Actions.Where(x => x.IdfsBaseReference == model.ActionsInformation.ActionRequiredID).First().Name,
                        MonitoringSessionActionStatusTypeID = model.ActionsInformation.StatusID,
                        MonitoringSessionActionStatusTypeName = ActionStatuses.Where(x => x.IdfsBaseReference == model.ActionsInformation.StatusID).First().Name,
                        Comments = model.ActionsInformation.Comment,
                        ActionDate = model.ActionsInformation.DateOfAction,
                        EnteredByPersonID = long.Parse(authenticatedUser.PersonId),
                        EnteredByPersonName = authenticatedUser.LastName + ", " + authenticatedUser.FirstName + " " + authenticatedUser.SecondName
                    };

                    if (model.ActionsInformation.List == null)
                    {
                        model.ActionsInformation.List = new List<ActiveSurveillanceSessionActionsResponseModel>();
                    }

                    if (model.ActionsInformation.ID == null)
                    {
                        actionInformation.MonitoringSessionActionID = actionInformation.MonitoringSessionActionID ?? model.ActionsInformation.NewRecordId--;
                        model.ActionsInformation.List.Add(actionInformation);
                        model.ActionsInformation.List = model.ActionsInformation.List.Where(x => x.RowAction != EIDSSConstants.UserAction.Delete).ToList();
                    }
                    else
                    {
                        int iIndex = model.ActionsInformation.List.FindIndex(x => x.MonitoringSessionActionID == model.ActionsInformation.ID);
                        model.ActionsInformation.List[iIndex] = actionInformation;
                    }

                    model.ActionsInformation.UnfilteredList = model.ActionsInformation.List;

                    await InvokeAsync(StateHasChanged);
                    DialogService.Close();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task HandleInvalidEmployeeSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
                string test = string.Empty;
            }
            catch (Exception)
            {
                throw;
            }
        }

        public void Dispose()
        {
        }
    }
}
