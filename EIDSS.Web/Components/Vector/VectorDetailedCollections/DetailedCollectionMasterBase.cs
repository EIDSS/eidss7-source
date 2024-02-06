using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Vector;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
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
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Components.Vector.VectorDetailedCollections
{
    public class DetailedCollectionMasterBase : VectorBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<DetailedCollectionMasterBase> Logger { get; set; }

        [Inject]
        protected IVectorTypeCollectionMethodMatrixClient VectorTypeCollectionMethodMatrixClient { get; set; }

        [Inject]
        protected IVectorTypeClient VectorTypeClient { get; set; }

        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        protected IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        protected IEmployeeClient EmployeeClient { get; set; }

        #endregion Dependencies

        #region Parameters

        [Parameter]
        public int vectorTypesListCount { get; set; }

        #endregion Parameters

        #region Properties

        protected RadzenTemplateForm<VectorSessionStateContainer> Form { get; set; }
        protected RadzenRadioButtonList<long?> DetailLocationTypeSelection { get; set; }
        public bool IsVectorTypeBlank { get; set; }
        protected List<BaseReferenceEditorsViewModel> VectorTypesList { get; set; }
        protected List<BaseReferenceViewModel> BasisOfRecordList { get; set; }
        protected List<BaseReferenceViewModel> TimePeriodList { get; set; }
        protected List<BaseReferenceViewModel> YesNoList { get; set; }
        protected IEnumerable<EmployeeLookupGetListViewModel> CollectorsList { get; set; }
        protected List<VectorTypeCollectionMethodMatrixViewModel> VectorMethodMatrixList { get; set; }
        protected List<OrganizationAdvancedGetListViewModel> CollectedByOrgList { get; set; }
        public IEnumerable<USP_VCTS_VECT_GetDetailResponseModel> HostVectorRecords { get; set; }
        protected List<BaseReferenceViewModel> GroundTypes { get; set; }
        protected List<BaseReferenceViewModel> Surroundings { get; set; }
        protected List<BaseReferenceViewModel> GeoTypes { get; set; }
        protected bool IsHostReferenceDisabled { get; set; }

        protected LocationView DetailLocationViewComponent;

        #endregion Properties

        #region Member Variables

        protected RadzenDropDown<long?> collectedByEmployeeDD;
        protected RadzenDropDown<long?> collectedByInstitutionDD;
        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            try
            {
                await LoadGeoTypes(new LoadDataArgs());

                // wire up the state container change event
                VectorSessionStateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

                //await RefreshComponent();

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("DetailedCollectionMaster.SetDotNetReference", _token, lDotNetReference);

                await JsRuntime.InvokeAsync<string>("initializeSidebarDetailedCollection", _token,
                                Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                                Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                                Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                                Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                                Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage).ToString(),
                                Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString());

                // disabled indicator
                if (VectorSessionStateContainer.IsReadOnly
                    || VectorSessionStateContainer.ReportDisabledIndicator
                    || VectorSessionStateContainer.DetailCollectionDisabledIndicator
                    || (VectorSessionStateContainer.VectorDetailedCollectionKey <= 0 &&
                        !VectorSessionStateContainer.VectorSurveillanceSessionPermissions.Create)
                    || (VectorSessionStateContainer.VectorDetailedCollectionKey > 0 &&
                        !VectorSessionStateContainer.VectorSurveillanceSessionPermissions.Write))
                {
                    VectorSessionStateContainer.DetailCollectionDisabledIndicator = true;
                }

                if (VectorSessionStateContainer.DetailCollectionDisabledIndicator)
                {
                    await JsRuntime.InvokeVoidAsync("navigateToDetailCollectionReviewStep", _token).ConfigureAwait(false);
                }

                if (IsHostReferenceDisabled == false)
                {
                    await LoadHostVectorTypes();
                    await InvokeAsync(StateHasChanged);
                }
            }

            if (VectorSessionStateContainer.DetailVectorTypeID is null)
            {
                IsVectorTypeBlank = true;
            }
            else
            {
                IsVectorTypeBlank = false;
                if (VectorMethodMatrixList.Count() == 0)
                    await LoadCollectionMethodMatrixRecord(new LoadDataArgs());
            }

            if (VectorSessionStateContainer.DetailCollectedByInstitutionID != null && CollectorsList == null)
            {
                await LoadCollectors(new LoadDataArgs());
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


        protected void UpdateDetailCollectionLocationHandlerAsync(LocationViewModel locationViewModel)
        {
            VectorSessionStateContainer.DetailLocationViewModel = locationViewModel;
        }

        public async Task RefreshComponent()
        {
            await DetailLocationViewComponent.RefreshComponent(VectorSessionStateContainer.DetailLocationViewModel);
        }


        #endregion Lifecycle Methods

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            switch (property)
            {
                case "SelectedVectorTab":
                    if (VectorSessionStateContainer.SelectedVectorTab == (int)VectorTabs.DetailedCollectionsTab)
                    {
                        if (VectorSessionStateContainer.VectorSessionKey is > 0 && VectorSessionStateContainer.VectorDetailedCollectionKey is > 0)
                        {
                            await GetDetailCollection();
                            await SwitchLocation(VectorSessionStateContainer.DetailGeoLocationTypeID,
                                VectorSessionStateContainer.DetailLocationViewModel,
                                VectorTabs.DetailedCollectionsTab);
                            await RefreshComponent();
                            await InvokeAsync(StateHasChanged);
                        }
                        // new detailed collection
                        else
                        {
                            VectorSessionStateContainer.VectorDetailedCollectionKey = 0;
                            VectorSessionStateContainer.DetailGeoLocationTypeID = EIDSSConstants.GeoLocationTypes.ExactPoint;
                            await SwitchLocation(VectorSessionStateContainer.DetailGeoLocationTypeID,
                                VectorSessionStateContainer.DetailLocationViewModel,
                                VectorTabs.DetailedCollectionsTab);
                            await RefreshComponent();
                            await InvokeAsync(StateHasChanged);
                        }

                    }
                    break;
                case "DetailCollectionDisabledIndicator":
                    await SwitchLocation(VectorSessionStateContainer.DetailGeoLocationTypeID,
                        VectorSessionStateContainer.DetailLocationViewModel,
                        VectorTabs.DetailedCollectionsTab);
                    await RefreshComponent();
                    await InvokeAsync(StateHasChanged);
                    break;
            }

            
        }

        #endregion State Container Events

        #region Vector Type Change Event



        protected async Task OnVectorTypeChange()
        {
            IsVectorTypeBlank = false;
            await LoadCollectionMethodMatrixRecord(new LoadDataArgs());
            await InvokeAsync(StateHasChanged);
        }

        #endregion Vector Type Change Event

        #region Save Method

        /// <summary>
        /// Sets the flag showing save
        /// was clicked from detailed collection
        /// and calls main save routine.
        /// </summary>
        /// <returns></returns>
        [JSInvokable()]
        public async Task OnSaveDetailedCollection()
        {
            VectorSessionStateContainer.DetailedCollectionsModifiedIndicator = true;
            await OnSave().ConfigureAwait(false);
        }

        #endregion Save Method

        #region Load Data Methods

        public async Task LoadVectorTypes(LoadDataArgs args)
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
                vectorTypesGetRequestModel.SortOrder = "asc";

                var results = await VectorTypeClient.GetVectorTypeList(vectorTypesGetRequestModel);
                if (results.Count > 0)
                {
                    vectorTypesListCount = results[0].TotalRowCount;
                    VectorTypesList = results;

                    string sortColumn = "strDefault";
                    string sortOrder = "asc";
                    var request = new VectorTypeCollectionMethodMatrixGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        idfsVectorType = VectorSessionStateContainer.DetailVectorTypeID,
                        Page = 1,
                        PageSize = int.MaxValue - 1,
                        SortColumn = sortColumn,
                        SortOrder = sortOrder,
                    };
                    VectorMethodMatrixList = await VectorTypeCollectionMethodMatrixClient.GetVectorTypeCollectionMethodMatrixList(request);
                    if (VectorSessionStateContainer.DetailVectorTypeID != null && results.Where(x => x.IdfsVectorType == VectorSessionStateContainer.DetailVectorTypeID).ToList().FirstOrDefault() != null)
                        IsHostReferenceDisabled = !results.Where(x => x.IdfsVectorType == VectorSessionStateContainer.DetailVectorTypeID).ToList().FirstOrDefault().BitCollectionByPool;

                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task LoadHostVectorTypes()
        {
            List<USP_VCTS_VECT_GetDetailResponseModel> vectorDetailsList = new List<USP_VCTS_VECT_GetDetailResponseModel>();
            USP_VCTS_VECT_GetDetailRequestModel request = new USP_VCTS_VECT_GetDetailRequestModel();
            try
            {
                request.LangID = GetCurrentLanguage();
                request.idfVectorSurveillanceSession = VectorSessionStateContainer.VectorSessionKey;
                request.PageNumber = 1;
                request.PageSize = 10;
                request.SortColumn = "idfVector";
                request.SortOrder = "asc";
                var res = await VectorClient.GetVectorDetails(request, _token);
                if (res.Count > 0)
                {
                    HostVectorRecords = res;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            finally
            {
                await InvokeAsync(StateHasChanged);
            }
        }

        public async Task LoadBasisOfRecord(LoadDataArgs args)
        {
            try
            {
                var res = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Basisofrecord, HACodeList.VectorHACode);
                if (res.Count > 0)
                {
                    if (!IsNullOrEmpty(args.Filter))
                    {
                        List<BaseReferenceViewModel> toList = res.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                        res = toList;
                    }

                    BasisOfRecordList = res;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public async Task LoadCollectionTimes(LoadDataArgs args)
        {
            try
            {
                var res = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Collection time period", 128);
                if (res.Count > 0)
                {
                    if (!IsNullOrEmpty(args.Filter))
                    {
                        List<BaseReferenceViewModel> toList = res.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                        res = toList;
                    }

                    TimePeriodList = res;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task LoadYesNoList(LoadDataArgs args)
        {
            try
            {
                var res = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Yes/No Value List", 128);
                if (res.Count > 0)
                {
                    if (!IsNullOrEmpty(args.Filter))
                    {
                        List<BaseReferenceViewModel> toList = res.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                        res = toList;
                    }

                    YesNoList = res;
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
                    GeoTypes = results.Where(x => x.IdfsBaseReference != EIDSSConstants.GeoLocationTypes.National).ToList();
                else
                    GeoTypes = results.ToList();
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

        protected async Task LoadSurroundings(LoadDataArgs args)
        {
            try
            {
                Surroundings = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.Surrounding, null);
                if (!IsNullOrEmpty(args.Filter))
                {
                    List<BaseReferenceViewModel> toList = Surroundings.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                    Surroundings = toList;
                }
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
            }
        }

        protected async Task LoadCollectors(LoadDataArgs args)
        {
            try
            {
                if (VectorSessionStateContainer.DetailCollectedByInstitutionID != null)
                {
                    EmployeeLookupGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        AccessoryCode = null,
                        AdvancedSearch = null,
                        OrganizationID = VectorSessionStateContainer.DetailCollectedByInstitutionID,
                        SortColumn = "FullName",
                        SortOrder = SortConstants.Ascending
                    };

                    CollectorsList = await CrossCuttingClient.GetEmployeeLookupList(request);
                    if (!IsNullOrEmpty(args.Filter))
                    {
                        List<EmployeeLookupGetListViewModel> toList = CollectorsList.Where(c => c.FullName != null && c.FullName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                        CollectorsList = toList;
                    }
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task LoadCollectionMethodMatrixRecord(LoadDataArgs args)
        {
            if (VectorSessionStateContainer.DetailVectorTypeID is null)
            {
                IsVectorTypeBlank = true;
            }
            try
            {
                string sortColumn = "strDefault";
                string sortOrder = "desc";
                var request = new VectorTypeCollectionMethodMatrixGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsVectorType = VectorSessionStateContainer.DetailVectorTypeID,
                    Page = 1,
                    PageSize = 50,
                    SortColumn = sortColumn,
                    SortOrder = sortOrder,
                };
                var res = await VectorTypeCollectionMethodMatrixClient.GetVectorTypeCollectionMethodMatrixList(request);
                if (res.Count > 0)
                {
                    if (args != null && !IsNullOrEmpty(args.Filter))
                    {
                        List<VectorTypeCollectionMethodMatrixViewModel> toList = res.Where(c => c.strName != null && c.strName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                        res = toList;
                    }

                    VectorMethodMatrixList = res;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                Logger.LogInformation(ex.Message);
            }
        }

        #endregion Load Data Methods

        #region Location

        public async Task ChangeLocationSettings(object value)
        {
            await InvokeAsync(StateHasChanged);
        }

        protected async Task OnLocationTypeChange(long? gisLocationType)
        {
            await SwitchLocation(gisLocationType,
                VectorSessionStateContainer.DetailLocationViewModel,
                VectorTabs.DetailedCollectionsTab);

            await RefreshComponent();
        }

        #endregion Location

        #region Organization

        public async Task LoadOrganizations(LoadDataArgs args)
        {
            try
            {
                if (VectorSessionStateContainer.Organizations is null) await VectorSessionStateContainer.LoadOrganizations();

                var query = VectorSessionStateContainer.Organizations;
                if (!IsNullOrEmpty(args.Filter))
                {
                    query = query.Where(c => c.name != null && c.name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                }

                //CollectedByOrgList = query.Count();
                CollectedByOrgList = query.ToList();

                await InvokeAsync(StateHasChanged);

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnCollectedByInstitutionChange(object data)
        {
            if (data != null)
            {
                await LoadCollectors(new LoadDataArgs());
            }
        }

        #endregion Organization

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            if (VectorSessionStateContainer.DetailCollectionsValidIndicator || VectorSessionStateContainer.DetailCollectionDisabledIndicator)
            {
                return await Task.FromResult(true);
            }

            if (Form is null) return await Task.FromResult(true);

            if (Form.EditContext.IsModified())
            {
                VectorSessionStateContainer.DetailedCollectionsModifiedIndicator = true;
            }

            var isValid = Form.EditContext.Validate();
            if (VectorSessionStateContainer.DetailVectorTypeID == null
                || VectorSessionStateContainer.DetailCollectedByInstitutionID == null
                || VectorSessionStateContainer.DetailCollectionDate == null
                || VectorSessionStateContainer.DetailLocationViewModel.AdminLevel1Value == null)
            {
                isValid = false;
                VectorSessionStateContainer.DetailCollectionsValidIndicator = false;
            }

            VectorSessionStateContainer.DetailCollectionsValidIndicator = isValid;

            return await Task.FromResult(isValid);
        }

        #endregion Validation Methods

        #endregion Methods
    }
}