using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Vector;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using System.Linq;
using static System.String;

namespace EIDSS.Web.Components.Vector.VectorSurveillanceSession
{
    public class SessionSummaryBase : VectorBaseComponent, IDisposable
    {
        #region Globals

        #region Parameters

        //[Parameter]
        //public VectorSurveillancePageViewModel model { get; set; }

        //[Parameter]
        //public AggregateCollections AggregateCollections { get; set; }

        [Parameter]
        public string PageHeader { get; set; }

        [Parameter]
        public string SummaryHeader { get; set; }

        //[Parameter]
        //public string SessionID { get; set; }

        //[Parameter]
        //public string FieldSessionID { get; set; }

        //[Parameter]
        //public string OutbreakID { get; set; }

        [Parameter]
        public List<KeyValuePair<string, string>> Status { get; set; }

        //[Parameter]
        //public DateTime? StartDate { get; set; }

        //[Parameter]
        //public DateTime? CloseDate { get; set; }

        //[Parameter]
        //public string Description { get; set; }

        //[Parameter]
        //public long? VectorTypeID { get; set; }

        //[Parameter]
        //public long? StatusID { get; set; }

        //[Parameter]
        //public string Diseases { get; set; }

        //[Parameter]
        //public int? CollectionEffort { get; set; }

        [Parameter]
        public string ShowHideSections { get; set; }

        #endregion Parameters

        #region Properties

        protected IEnumerable<BaseReferenceEditorsViewModel> VectorTypes { get; set; }
        protected IEnumerable<BaseReferenceViewModel> SessionStatuses { get; set; }
        protected bool ReadOnly { get; set; }
        protected bool AllowClear { get; set; }

        protected RadzenTemplateForm<VectorSessionStateContainer> Form { get; set; }

        #endregion Properties

        #region Dependencies

        [Inject]
        private ILogger<SessionSummaryBase> Logger { get; set; }

        [Inject]
        private IVectorTypeClient VectorTypeClient { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        #endregion Dependencies

        #region Member Variables

        private CancellationToken _token;
        private CancellationTokenSource _source;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        #region Lifecyle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            VectorSessionStateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VectorSurveillanceSessionSummary.SetDotNetReference", _token, lDotNetReference);
            }
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();

                VectorSessionStateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
            }

            base.Dispose(disposing);
        }

        #endregion Lifecyle Methods

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property == "SessionID")
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

        #endregion Load Data Methods

        #region Vector Status Change

        protected async Task VectorStatusChange()
        {
            switch (VectorSessionStateContainer.StatusID)
            {
                // Change Closed Date when Status Changes
                case (long)ClientLibrary.Enumerations.VectorSurveillanceSessionStatusIds.InProcess:
                    // In Progress
                    VectorSessionStateContainer.CloseDate = null;
                    ReadOnly = false;
                    // Enable the clear button in date control
                    AllowClear = true;
                    break;

                case (long)ClientLibrary.Enumerations.VectorSurveillanceSessionStatusIds.Closed:
                    // Closed
                    VectorSessionStateContainer.CloseDate = DateTime.Now;
                    ReadOnly = true;
                    // Disable remove the clear button in date control
                    AllowClear = false;
                    break;
            }

            await InvokeAsync(StateHasChanged);
        }

        #endregion Vector Status Change

        #region Validation

        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            if (VectorSessionStateContainer.SessionSummaryValidIndicator || VectorSessionStateContainer.ReportDisabledIndicator)
            {
                return await Task.FromResult(true);
            }

            if (Form is null) return await Task.FromResult(true);

            if (Form.EditContext.IsModified())
            {
                VectorSessionStateContainer.SessionSummaryModifiedIndicator = true;
            }

            var isValid = Form.EditContext.Validate();
            if (VectorSessionStateContainer.StatusID == null
                || VectorSessionStateContainer.StartDate == null)
            {
                isValid = false;
                VectorSessionStateContainer.SessionSummaryValidIndicator = false;
            }

            VectorSessionStateContainer.SessionSummaryValidIndicator = isValid;

            return await Task.FromResult(isValid);
        }

        #endregion Validation

        #endregion Methods
    }
}