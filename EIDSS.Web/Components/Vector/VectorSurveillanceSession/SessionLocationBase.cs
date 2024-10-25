using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Vector.VectorSurveillanceSession
{
    public class SessionLocationBase : VectorBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<SessionLocationBase> Logger { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies

        #region Properties

        protected RadzenTemplateForm<VectorSessionStateContainer> Form { get; set; }
        protected RadzenRadioButtonList<long?> LocationTypeSelection { get; set; }
        protected List<BaseReferenceViewModel> GroundTypes { get; set; }
        protected List<BaseReferenceViewModel> GeoTypes { get; set; }

        protected LocationView LocationComponent;


        #endregion Properties

        #region Member Variables

        private CancellationToken _token;
        private CancellationTokenSource _source;

        #endregion Member Variables

        #endregion Globals

        protected override async Task OnInitializedAsync()
        {
            _source = new();
            _token = _source.Token;

            await LoadGeoTypes(new LoadDataArgs());

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VectorSurveillanceSessionLocation.SetDotNetReference", _token, lDotNetReference);

                if (VectorSessionStateContainer.GeoLocationTypeID != null)
                {
                    await SwitchLocation(VectorSessionStateContainer.GeoLocationTypeID.Value, 
                        VectorSessionStateContainer.LocationViewModel, 
                        VectorTabs.VectorSessionTab);
                }
                else
                {
                    VectorSessionStateContainer.GeoLocationTypeID = ClientLibrary.Enumerations.EIDSSConstants.GeoLocationTypes.ExactPoint;
                    await SwitchLocation(VectorSessionStateContainer.GeoLocationTypeID.Value,
                        VectorSessionStateContainer.LocationViewModel,
                        VectorTabs.VectorSessionTab);
                }
                await ComponentRefresh();

                await InvokeAsync(StateHasChanged);

            }

        }

        public async Task ComponentRefresh()
        {
            await LocationComponent.RefreshComponent(VectorSessionStateContainer.LocationViewModel);
        }

        protected void UpdateLocationHandlerAsync(LocationViewModel locationViewModel)
        {
            VectorSessionStateContainer.LocationViewModel = locationViewModel;
        }


        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();

            }

            base.Dispose(disposing);
        }

        protected async Task OnLocationTypeChange(long? gisLocationType)
        {
            await SwitchLocation(gisLocationType,
                VectorSessionStateContainer.LocationViewModel,
                VectorTabs.VectorSessionTab);
            await ComponentRefresh();
        }

        protected async Task LoadGeoTypes(LoadDataArgs args)
        {
            try
            {
                GeoTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.GeoLocationType, null);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
            }
        }

        protected async Task LoadGroundTypes(LoadDataArgs args)
        {
            try
            {
                GroundTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.GroundType, null);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
            }
        }

        protected void ChangeLocationSettings(Object value)
        {
            VectorSessionStateContainer.LocationViewModel = (LocationViewModel)value;
        }

        #region Validation Methods

        /// <summary>
        /// Validation routine for the section.
        /// </summary>
        /// <returns>bool</returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            if (VectorSessionStateContainer.SessionLocationValidIndicator || VectorSessionStateContainer.ReportDisabledIndicator) 
                return await Task.FromResult(true);

            if (Form is null) return await Task.FromResult(true);

            var isValid = Form.EditContext.Validate();
            if (VectorSessionStateContainer.LocationViewModel.AdminLevel0Value == null)
            {
                isValid = false;
                VectorSessionStateContainer.SessionLocationValidIndicator = false;
            }

            VectorSessionStateContainer.SessionLocationModifiedIndicator = Form.EditContext.IsModified();

            VectorSessionStateContainer.SessionLocationValidIndicator = isValid;

            return await Task.FromResult(VectorSessionStateContainer.SessionLocationValidIndicator);
        }

        #endregion Validation Methods
    }
}