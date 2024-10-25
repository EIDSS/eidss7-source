using EIDSS.Web.Abstracts;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels.Vector;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Web.Components.Vector.Common;
using System.Linq;
using static System.String;
using Radzen;

namespace EIDSS.Web.Components.Vector.Common
{
    public class SessionSummaryHeaderBase : VectorBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IVectorTypeClient VectorTypeClient { get; set; }
        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject]
        private ILogger<SessionSummaryHeaderBase> Logger { get; set; }

        #endregion

        #region Properties

        protected IList<BaseReferenceEditorsViewModel> VectorTypes { get; set; }
        protected IList<BaseReferenceViewModel> SessionStatuses { get; set; }


        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            try
            {
                _logger = Logger;

                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                VectorSessionStateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public void Dispose()
        {
            try
            {
                _source?.Cancel();
                _source?.Dispose();

                VectorSessionStateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
            }
            catch (Exception)
            {
                throw;
            }
        }

        #endregion Lifecycle Methods

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property is "SessionID" or "StatusID" or "FieldSessionID")
            {
                await InvokeAsync(StateHasChanged);
            }
        }

        #endregion State Container Events

        #region Load Data Methods

        protected async Task LoadStatusDropDown(LoadDataArgs args)
        {
            SessionStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Vector Surveillance Session Status", 128);
            VectorSessionStateContainer.StatusID ??= (long)ClientLibrary.Enumerations.VectorSurveillanceSessionStatusIds.InProcess;
            if (!IsNullOrEmpty(args.Filter))
            {
                List<BaseReferenceViewModel> toList = SessionStatuses.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                SessionStatuses = toList;
            }
            await InvokeAsync(StateHasChanged);
        }
        protected void VectorStatusChange()
        {
            switch (VectorSessionStateContainer.StatusID)
            {
                //Change Closed Date when Status Changes
                case (long)ClientLibrary.Enumerations.VectorSurveillanceSessionStatusIds.InProcess:
                    VectorSessionStateContainer.CloseDate = null;
                    VectorSessionStateContainer.IsReadOnly = false;
                    break;
                case (long)ClientLibrary.Enumerations.VectorSurveillanceSessionStatusIds.Closed:
                    VectorSessionStateContainer.CloseDate = DateTime.Now;
                    VectorSessionStateContainer.IsReadOnly = true;
                    break;
            }
        }

        protected async Task LoadVectorTypesDropDown()
        {
            VectorTypes = new List<BaseReferenceEditorsViewModel>();
            var request = new VectorTypesGetRequestModel();
            request.LanguageId = GetCurrentLanguage();
            request.Page = 1;
            request.PageSize = int.MaxValue - 1;
            request.SortColumn = "intOrder";
            request.SortOrder = "asc";
            VectorTypes = await VectorTypeClient.GetVectorTypeList(request);
        }

        #endregion

        #region Navigate To Surveillance Session

        protected void NavigateToSession()
        {
            var path = "Vector/VectorSurveillanceSession/Edit";
            var query = $"?sessionKey={VectorSessionStateContainer.VectorSessionKey}&isReadOnly={VectorSessionStateContainer.ReportDisabledIndicator}";
            var uri = $"{NavManager.BaseUri}{path}{query}";

            NavManager.NavigateTo(uri, true);
            
        }

        #endregion

        #endregion

   
    }
}
