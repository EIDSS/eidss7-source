using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Shared;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using static System.String;

namespace EIDSS.Web.Components.Vector.VectorAggregateCollections
{
    public class AggregateCollectionMasterBase : VectorBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private IVectorTypeClient VectorTypeClient { get; set; }

        [Inject]
        private IVectorSpeciesTypeClient VectorSpeciesTypeClient { get; set; }

        [Inject]
        private IVectorTypeCollectionMethodMatrixClient VectorTypeCollectionMethodMatrixClient { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private ISpeciesTypeClient SpeciesTypeClient { get; set; }

        [Inject]
        private ILogger<AggregateCollectionMasterBase> Logger { get; set; }

        [Inject]
        private ISiteClient SiteClient { get; set; }

        #endregion Dependencies

        #region Properties

        protected bool IsSpeciesSelected { get; set; }

        protected RadzenTemplateForm<VectorSessionStateContainer> AggregateMasterForm { get; set; }
        protected RadzenTemplateForm<VectorSessionStateContainer> AggregateLocationForm { get; set; }
        protected RadzenRadioButtonList<long?> SummaryLocationTypeSelection { get; set; }

        protected LocationView AggregateLocationViewComponent;

        #endregion Properties

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #endregion Globals

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

                await LoadGeoTypes(new LoadDataArgs());

               // wire up the state container change event
                VectorSessionStateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

                await RefreshLocationComponent();

                await base.OnInitializedAsync();
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("AggregateCollectionMaster.SetDotNetReference", _token, lDotNetReference);

                await JsRuntime.InvokeAsync<string>("initializeSidebarAggregateCollection", _token,
                 Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                 Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                 Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                 Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                 Localizer.GetString(ButtonResourceKeyConstants.DeleteButton).ToString(),
                 VectorSessionStateContainer.VectorSurveillanceSessionPermissions.Delete,
                 Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage).ToString(),
                 Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString());

                // disabled indicator
                if (VectorSessionStateContainer.IsReadOnly
                    || VectorSessionStateContainer.ReportDisabledIndicator
                    || VectorSessionStateContainer.AggregateCollectionDisabledIndicator
                    || (VectorSessionStateContainer.VectorSessionSummaryKey <= 0 &&
                        !VectorSessionStateContainer.VectorSurveillanceSessionPermissions.Create)
                    || (VectorSessionStateContainer.VectorSessionSummaryKey > 0 &&
                        !VectorSessionStateContainer.VectorSurveillanceSessionPermissions.Write))
                {
                    VectorSessionStateContainer.AggregateCollectionDisabledIndicator = true;
                }
                
                if (VectorSessionStateContainer.AggregateCollectionDisabledIndicator)
                {
                    await JsRuntime.InvokeVoidAsync("navigateToAggregateCollectionReviewStep", _token).ConfigureAwait(false);
                }
            }
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();

            VectorSessionStateContainer.OnChange -= async (property) => await OnStateContainerChangeAsync(property);
        }

        #endregion Lifecycle Methods

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            switch (property)
            {
                case "SummaryVectorTypeID":
                    await SelectVector(VectorSessionStateContainer.SummaryVectorTypeID);
                    break;

                case "SummaryInfoSpeciesID" when VectorSessionStateContainer.SummaryInfoSpeciesID != null:
                    IsSpeciesSelected = true;
                    break;

                case "SelectedVectorTab":
                    if (VectorSessionStateContainer.SelectedVectorTab == (int)VectorTabs.AggregateCollectionsTab)
                    {
                        if (VectorSessionStateContainer.VectorSessionKey is > 0 && VectorSessionStateContainer.VectorSessionSummaryKey is > 0)
                        {
                            await GetAggregateCollection();
                        }
                        // new detailed collection
                        else
                        {
                            // new aggregate collection
                            if (VectorSessionStateContainer.AggregateCollectionList != null)
                            {
                                VectorSessionStateContainer.VectorSessionSummaryKey = (VectorSessionStateContainer.AggregateCollectionList.Count + 1) * -1;
                            }
                            else
                            {
                                VectorSessionStateContainer.VectorSessionSummaryKey = -1;
                            }

                            VectorSessionStateContainer.SummaryRowStatus = (int)RowStatusTypes.Active;
                            VectorSessionStateContainer.SummaryRowAction = (int)RowActionTypeEnum.Insert;
                        }

                        await RefreshLocationComponent();
                        await InvokeAsync(StateHasChanged).ConfigureAwait(false);

                    }

                    break;
                case "AggregateCollectionDisabledIndicator":
                    await InvokeAsync(StateHasChanged);
                    break;
            }
        }

        #endregion State Container Events

        #region Location User Control

        protected async Task OnLocationTypeChangeAsync(long? value)
        {
            await SwitchLocation(value,
                VectorSessionStateContainer.SummaryLocationViewModel,
                VectorTabs.AggregateCollectionsTab);

            await RefreshLocationComponent();
        }


        protected void UpdateAggregateCollectionLocationHandlerAsync(LocationViewModel locationViewModel)
        {
            VectorSessionStateContainer.SummaryLocationViewModel = locationViewModel;
        }

        public async Task RefreshLocationComponent()
        {
            await AggregateLocationViewComponent.RefreshComponent(VectorSessionStateContainer.SummaryLocationViewModel);
        }


        #endregion Location User Control

        #region Load Data

        protected async Task LoadVectorTypes(LoadDataArgs args)
        {
            try
            {
                VectorTypesGetRequestModel vectorTypesGetRequestModel = new VectorTypesGetRequestModel();
                vectorTypesGetRequestModel.LanguageId = GetCurrentLanguage();
                if (!String.IsNullOrEmpty(args.Filter))
                {
                    vectorTypesGetRequestModel.SearchVectorType = args.Filter;
                }
                vectorTypesGetRequestModel.Page = args.Skip != null & args.Skip != 0 ? args.Skip.Value : 1;
                vectorTypesGetRequestModel.PageSize = int.MaxValue - 1;
                vectorTypesGetRequestModel.SortColumn = "strName";
                vectorTypesGetRequestModel.SortOrder = "desc";
                var results = await VectorTypeClient.GetVectorTypeList(vectorTypesGetRequestModel);
                if (results != null && results.Any())
                {
                    VectorSessionStateContainer.VectorTypesList = results;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task LoadSpeciesVectorTypesList(LoadDataArgs args)
        {
            try
            {
                List<BaseReferenceEditorsViewModel> speciesVectorTypeList = new List<BaseReferenceEditorsViewModel>();
                VectorSpeciesTypesGetRequestModel vectorSpeciesTypesGetRequestModel = new VectorSpeciesTypesGetRequestModel();
                vectorSpeciesTypesGetRequestModel.LanguageId = GetCurrentLanguage();
                vectorSpeciesTypesGetRequestModel.Page = 1;
                vectorSpeciesTypesGetRequestModel.PageSize = int.MaxValue - 1;
                vectorSpeciesTypesGetRequestModel.SortColumn = "StrName";
                vectorSpeciesTypesGetRequestModel.SortOrder = "ASC";
                vectorSpeciesTypesGetRequestModel.IdfsVectorType = VectorSessionStateContainer.SummaryVectorTypeID;

                var results = await VectorSpeciesTypeClient.GetVectorSpeciesTypeList(vectorSpeciesTypesGetRequestModel);
                if (results != null && results.Any())
                {
                    if (!IsNullOrEmpty(args.Filter))
                    {
                        List<BaseReferenceEditorsViewModel> toList = results.Where(c => c.StrName != null && c.StrName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                        results = toList;
                    }

                    VectorSessionStateContainer.SpeciesList = results;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task LoadAnimalSex(LoadDataArgs args)
        {
            try
            {
                SpeciesTypeGetRequestModel requestModel = new SpeciesTypeGetRequestModel();
                requestModel.LanguageId = GetCurrentLanguage();
                requestModel.Page = args.Skip != null & args.Skip != 0 ? args.Skip.Value : 1;
                if (!String.IsNullOrEmpty(args.Filter))
                {
                    requestModel.AdvancedSearch = args.Filter;
                }
                requestModel.PageSize = 10;
                requestModel.SortColumn = "StrName";
                requestModel.SortOrder = "ASC";

                var results = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Animal Sex", 128);
                if (results.Count > 0)
                {
                    if (!IsNullOrEmpty(args.Filter))
                    {
                        List<BaseReferenceViewModel> toList = results.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                        results = toList;
                    }

                    VectorSessionStateContainer.AnimalSexList = results;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task LoadGeoTypes(LoadDataArgs args)
        {
            try
            {
                var results = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.GeoLocationType, null);
                if (results != null)
                    VectorSessionStateContainer.GeoTypes = results.Where(x => x.IdfsBaseReference != EIDSSConstants.GeoLocationTypes.National).ToList();
                else
                    VectorSessionStateContainer.GeoTypes = results.ToList();
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
                VectorSessionStateContainer.GroundTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.GroundType, null);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
            }
        }

        protected async Task SelectGroundType(object value)
        {
            try
            {
                if (value != null)
                {
                    VectorSessionStateContainer.SummaryLocationGroundTypeID = (long)value;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        #endregion Load Data

        #region Control Events

        protected async Task SelectSpecies(object data)
        {
            try
            {
                if (data != null)
                {
                    IsSpeciesSelected = true;
                    await InvokeAsync(StateHasChanged).ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        protected async Task SelectAnimalSex(object data)
        {
            try
            {
                if (data != null)
                {
                    VectorSessionStateContainer.SummaryInfoSexID = (long)data;
                    await InvokeAsync(StateHasChanged).ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        /// <summary>
        /// When selecting a Vector we load species and update the model
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task SelectVector(object data)
        {
            try
            {
                if (data != null)
                {
                    var request = new VectorSpeciesTypesGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        IdfsVectorType = (long)data,
                        Page = 1,
                        PageSize = int.MaxValue - 1,
                        SortColumn = "strDefault",
                        SortOrder = "asc"
                    };
                    var res = await VectorSpeciesTypeClient.GetVectorSpeciesTypeList(request);
                    VectorSessionStateContainer.SpeciesList = res.Count > 0 ? res : new List<BaseReferenceEditorsViewModel>();
                    await InvokeAsync(StateHasChanged).ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        #endregion Control Events

        #region Save Method

        /// <summary>
        /// Sets the flag showing save
        /// was clicked from aggregate collection
        /// and calls main save routine.
        /// </summary>
        /// <returns></returns>
        [JSInvokable()]
        public async Task OnSaveAggregateCollection()
        {
            VectorSessionStateContainer.AggregateCollectionsModifiedIndicator = true;
            await OnSave().ConfigureAwait(false);
        }

        #endregion Save Method

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateAggregateMasterSectionForSidebar()
        {
            if (VectorSessionStateContainer.AggregateCollectionsValidIndicator || VectorSessionStateContainer.AggregateCollectionDisabledIndicator)
            {
                return await Task.FromResult(true);
            }

            if (AggregateMasterForm is null) return await Task.FromResult(true);

            if (AggregateMasterForm.EditContext.IsModified())
            {
                VectorSessionStateContainer.AggregateCollectionsModifiedIndicator = true;
            }

            var isValid = AggregateMasterForm.EditContext.Validate();
            if (VectorSessionStateContainer.SummaryVectorTypeID == null
                || VectorSessionStateContainer.SummaryInfoSpeciesID == null
                || VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel1Value == null)
            {
                isValid = false;
                VectorSessionStateContainer.AggregateCollectionsValidIndicator = false;
            }

            VectorSessionStateContainer.AggregateCollectionsValidIndicator = isValid;

            return await Task.FromResult(isValid);
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateAggregateLocationSectionForSidebar()
        {
            if (VectorSessionStateContainer.AggregateCollectionLocationValidIndicator || VectorSessionStateContainer.AggregateCollectionDisabledIndicator)
            {
                return await Task.FromResult(true);
            }

            if (AggregateLocationForm is null) return await Task.FromResult(true);

            if (AggregateLocationForm.EditContext.IsModified())
            {
                VectorSessionStateContainer.AggregateCollectionLocationModifiedIndicator = true;
            }

            var isValid = AggregateLocationForm.EditContext.Validate();
            if (VectorSessionStateContainer.SummaryGeoLocationTypeID == null
                || VectorSessionStateContainer.SummaryLocationViewModel.AdminLevel1Value == null)
            {
                isValid = false;
                VectorSessionStateContainer.AggregateCollectionLocationValidIndicator = false;
            }

            VectorSessionStateContainer.AggregateCollectionLocationValidIndicator = isValid;

            return await Task.FromResult(isValid);
        }

        #endregion Validation Methods

        #endregion Methods
    }
}