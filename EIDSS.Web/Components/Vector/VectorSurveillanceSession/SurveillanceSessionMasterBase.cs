using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels.Vector;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen.Blazor;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Vector.VectorSurveillanceSession
{
    public class SurveillanceSessionMasterBase : VectorBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<SurveillanceSessionMasterBase> Logger { get; set; }

        #endregion Dependencies

        #region Parameters

        [Parameter]
        public VectorSurveillancePageViewModel Model { get; set; }

        #endregion Parameters

        #region Properties

        protected RadzenTemplateForm<VectorSurveillancePageViewModel> Form { get; set; }
        protected RadzenTabs VectorSurveillanceTabs { get; set; }
        protected int SelectedTab { get; set; } = 0;

        protected SessionLocation SessionLocationComponent;
        

        #endregion Properties

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private int _previousTab = -1;
        private int _nextTab = -1;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            try
            {
                _logger = Logger;

                _source = new CancellationTokenSource();
                _token = _source.Token;

                if (Model is { idfVectorSurveillanceSession: { } })
                {
                    VectorSessionStateContainer.VectorSessionKey = Model.idfVectorSurveillanceSession ?? 0;
                    VectorSessionStateContainer.IsReadOnly = Model.IsReadOnly;
                    await GetSurveillanceSessionDetail();
                }
                // new surveillance session
                else
                {
                    // set default values
                    VectorSessionStateContainer.VectorSessionKey = 0;

                    VectorSessionStateContainer.OutbreakID = Model.OutbreakID;
                    VectorSessionStateContainer.OutbreakKey = Model.OutbreakKey;
                    VectorSessionStateContainer.AddingToOutbreakIndicator = Model.AddToOutbreakIndicator;
                    VectorSessionStateContainer.SiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                    VectorSessionStateContainer.StartDate = DateTime.Now;
                    VectorSessionStateContainer.GeoLocationTypeID = EIDSSConstants.GeoLocationTypes.ExactPoint;
                    await SwitchLocation(VectorSessionStateContainer.GeoLocationTypeID.Value,
                        VectorSessionStateContainer.LocationViewModel,
                        VectorTabs.VectorSessionTab);
                }

                // set tabs
                VectorSessionStateContainer.DetailedCollectionTabDisabled = true;
                VectorSessionStateContainer.AggregateCollectionTabDisabled = true;

                // disabled indicator
                if (VectorSessionStateContainer.IsReadOnly 
                    || (VectorSessionStateContainer.VectorSessionKey <= 0 && !VectorSessionStateContainer.VectorSurveillanceSessionPermissions.Create)
                    || (VectorSessionStateContainer.VectorSessionKey > 0 && !VectorSessionStateContainer.VectorSurveillanceSessionPermissions.Write))
                    VectorSessionStateContainer.ReportDisabledIndicator = true;

                VectorSessionStateContainer.OnChange += async property => await OnStateContainerChangeAsync(property);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                if (VectorSessionStateContainer.VectorSurveillanceSessionPermissions.Read)
                {
                    var lDotNetReference = DotNetObjectReference.Create(this);
                    await JsRuntime.InvokeVoidAsync("VectorSurveillanceSession.SetDotNetReference", _token,
                        lDotNetReference);

                    await JsRuntime.InvokeAsync<string>("initializeSidebarVectorSession", _token,
                        Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                        Localizer.GetString(ButtonResourceKeyConstants.DeleteButton).ToString(),
                        VectorSessionStateContainer.VectorSurveillanceSessionPermissions.Delete,
                        Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage)
                            .ToString(),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString());

                    if (VectorSessionStateContainer.IsReadOnly || VectorSessionStateContainer.ReportDisabledIndicator)
                    {
                        await JsRuntime.InvokeVoidAsync("reportIsDisabled", _token, true).ConfigureAwait(false);
                        await JsRuntime.InvokeVoidAsync("navigateToSurveillanceSessionReviewStep", _token)
                            .ConfigureAwait(false);
                    }
                }
                else
                    await JsRuntime.InvokeAsync<string>("insufficientPermissions", _token);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        protected override void Dispose(bool disposing)
        {
            _source?.Cancel();
            _source?.Dispose();

            if (VectorSessionStateContainer != null)
                VectorSessionStateContainer.OnChange -= async property => await OnStateContainerChangeAsync(property);

            base.Dispose(disposing);
        }

        #endregion Lifecycle Methods

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property == "SelectedVectorTab")
            {
                if (_nextTab == 0)
                {
                    await TabChange(_nextTab);
                }
                await InvokeAsync(StateHasChanged);
            }
        }

        #endregion State Container Events

        #region Tab Change

        protected void OnTabChange(int newTab)
        {
            _previousTab = VectorSurveillanceTabs.SelectedIndex;
            _nextTab = newTab;
        }

        protected async Task TabChange(int? newTab)
        {
            if (newTab is 0)
            {
                // see of there are pending changes
                if (VectorSessionStateContainer.AggregateCollectionsModifiedIndicator || VectorSessionStateContainer.DetailedCollectionsModifiedIndicator)
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null);
                    if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                    {
                        // which previous tab
                        switch (_previousTab)
                        {
                            // detailed collection tab
                            case 1:
                                if (VectorSessionStateContainer.DetailedCollectionsModifiedIndicator)
                                {
                                    _nextTab = 1;
                                    VectorSessionStateContainer.SelectedVectorTab = 1;
                                }
                                break;
                            // aggregate collection tab
                            case 2:
                                if (VectorSessionStateContainer.AggregateCollectionsModifiedIndicator)
                                {
                                    _nextTab = 2;
                                    VectorSessionStateContainer.SelectedVectorTab = 2;
                                }
                                break;
                        }
                    }
                    // cancel changes
                    else
                    {
                        VectorSessionStateContainer.DetailedCollectionTabDisabled = true;
                        VectorSessionStateContainer.DetailedCollectionsModifiedIndicator = false;
                        InitializeDetailedCollection();

                        VectorSessionStateContainer.AggregateCollectionTabDisabled = true;
                        VectorSessionStateContainer.AggregateCollectionsModifiedIndicator = false;
                        InitializeAggregateCollection();
                    }
                }

                await InvokeAsync(StateHasChanged);
            }
        }

        #endregion Tab Change

        #endregion Methods
    }
}