#region Usings

using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen.Blazor;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Components.Shared;

#endregion

namespace EIDSS.Web.Components.Veterinary.Farm
{
    public class FarmAddressSectionBase : FarmBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<FarmAddressSectionBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<FarmStateContainer> Form { get; set; }
        protected LocationView LocationComponent { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Methods

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            //Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// 
        /// </summary>
        public void Dispose()
        {
            if (StateContainer != null)
                    StateContainer.OnChange -= async _ => await OnStateContainerChangeAsync().ConfigureAwait(false);

            _source?.Cancel();
            _source?.Dispose();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                StateContainer.OnChange += async _ => await OnStateContainerChangeAsync();

                var dotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("FarmAddressSection.SetDotNetReference", _token, dotNetReference);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        #endregion

        public async Task RefreshComponent()
        {
            if (LocationComponent is not null)
                await LocationComponent.RefreshComponent(StateContainer.FarmLocationModel);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private async Task OnStateContainerChangeAsync()
        {
            await InvokeAsync(StateHasChanged);
        }

        protected void UpdateAddressHandlerAsync(LocationViewModel locationViewModel)
        {
            StateContainer.FarmLocationModel = locationViewModel;
        }

        /// <summary>
        /// </summary>
        /// <param name="isReview"></param>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSection(bool isReview)
        {
            await InvokeAsync(StateHasChanged); 

            Form.EditContext.Validate();

            StateContainer.FarmAddressSectionValidIndicator = Form.IsValid;
            
            StateContainer.IsReview = isReview;

            if (StateContainer.IsReview)
            {
                StateContainer.FarmLocationModel.AlwaysDisabled = true;
                StateContainer.FarmLocationModel.EnableAdminLevel1 = false;
                StateContainer.FarmLocationModel.EnableAdminLevel2 = false;
                StateContainer.FarmLocationModel.EnableAdminLevel3 = false;
                StateContainer.FarmLocationModel.EnableApartment = false;
                StateContainer.FarmLocationModel.EnableBuilding = false;
                StateContainer.FarmLocationModel.EnableHouse = false;
                StateContainer.FarmLocationModel.EnablePostalCode = false;
                StateContainer.FarmLocationModel.EnableSettlement = false;
                StateContainer.FarmLocationModel.EnableSettlementType = false;
                StateContainer.FarmLocationModel.EnableStreet = false;
                StateContainer.FarmLocationModel.OperationType = LocationViewOperationType.ReadOnly;
            }
            else
            {
                StateContainer.FarmLocationModel.AlwaysDisabled = false;
                StateContainer.FarmLocationModel.EnableAdminLevel1 = true;
                StateContainer.FarmLocationModel.EnableApartment = StateContainer.FarmLocationModel.AdminLevel3Value != null;
                StateContainer.FarmLocationModel.EnableBuilding = StateContainer.FarmLocationModel.AdminLevel3Value != null;
                StateContainer.FarmLocationModel.EnableHouse = StateContainer.FarmLocationModel.AdminLevel3Value != null;
                StateContainer.FarmLocationModel.EnableStreet = StateContainer.FarmLocationModel.AdminLevel3Value != null;
                StateContainer.FarmLocationModel.EnablePostalCode = StateContainer.FarmLocationModel.AdminLevel3Value != null;
                StateContainer.FarmLocationModel.EnabledLatitude = true;
                StateContainer.FarmLocationModel.EnabledLongitude = true;
                StateContainer.FarmLocationModel.OperationType = null;
            }
            await RefreshComponent();

            if (StateContainer.FarmAddressSectionChangedIndicator == false)
                StateContainer.FarmAddressSectionChangedIndicator = Form.EditContext.IsModified();

            return StateContainer.FarmAddressSectionValidIndicator;
        }

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task ReloadSection()
        {
            Form.EditContext.MarkAsUnmodified();

            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #endregion

    }
}
