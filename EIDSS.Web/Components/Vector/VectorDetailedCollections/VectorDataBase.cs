using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Components.Vector.SearchVectorSurveillanceSession;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Web.Services;
using Radzen.Blazor;
using static System.String;

namespace EIDSS.Web.Components.Vector.VectorDetailedCollections
{
    public class VectorDataBase : VectorBaseComponent
    {
        #region Dependencies

        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IVectorSpeciesTypeClient VectorSpeciesTypeClient { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        protected IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        protected IEmployeeClient EmployeeClient { get; set; }

        [Inject]
        private ILogger<SearchVectorSurveillanceSessionBase> Logger { get; set; }

        #endregion Dependencies

        protected RadzenTemplateForm<VectorSessionStateContainer> VectorDataForm { get; set; }
        protected IEnumerable<BaseReferenceEditorsViewModel> SpeciesList { get; set; }
        protected IEnumerable<BaseReferenceViewModel> AnimalSexList { get; set; }
        protected int IdentifiedByInstitutionListCount { get; set; }
        protected IEnumerable<OrganizationAdvancedGetListViewModel> IdentifiedByInstitutionList { get; set; }
        protected IEnumerable<EmployeeLookupGetListViewModel> IdentifiedByPersonList { get; set; }
        protected int IdentifiedByPersonListCount { get; set; }
        protected int AnimalSexListCount { get; set; }
        protected IEnumerable<BaseReferenceViewModel> IdentifyingMethodList { get; set; }
        protected int IdentifyingmethodCount { get; set; }

        private CancellationTokenSource _source;
        private CancellationToken _token;

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            // wire up the state container change event
            VectorSessionStateContainer.OnChange += async (property) => await OnStateContainerChangeAsync(property);

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("DetailedCollectionVectorData.SetDotNetReference", _token, lDotNetReference);
            }
            //await LoadIdentifiedByPerson(new LoadDataArgs());
            await base.OnAfterRenderAsync(firstRender);
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

        #region State Container Events

        private async Task OnStateContainerChangeAsync(string property)
        {
            if (property == "DetailVectorTypeID")
            {
                await LoadSpeciesVectorTypesList(new LoadDataArgs());
            }

            if (property == "SelectedVectorTab")
            {
                await InvokeAsync(StateHasChanged);
            }
        }

        #endregion State Container Events

        public async Task LoadSpeciesVectorTypesList(LoadDataArgs args)
        {
            try
            {
                var vectorSpeciesTypesGetRequestModel = new VectorSpeciesTypesGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    IdfsVectorType = VectorSessionStateContainer.DetailVectorTypeID,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "StrName",
                    SortOrder = "ASC",
                    AdvancedSearch = string.IsNullOrEmpty(args.Filter) ? null : args.Filter
                };

                SpeciesList = await VectorSpeciesTypeClient.GetVectorSpeciesTypeList(vectorSpeciesTypesGetRequestModel);
                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task LoadAnimalSex(LoadDataArgs args)
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
                    AnimalSexList = results;
                    AnimalSexListCount = results.Count;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task LoadIdentifyingMethod(LoadDataArgs args)
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

                var results = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), "Identification method", EIDSSConstants.HACodeList.VectorHACode);
                if (results.Count > 0)
                {
                    if (!IsNullOrEmpty(args.Filter))
                    {
                        List<BaseReferenceViewModel> toList = results.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                        results = toList;
                    }
                    IdentifyingMethodList = results;
                    IdentifyingmethodCount = results.Count;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task LoadIdentifiedByInstitution(LoadDataArgs args)
        {
            try
            {
                if (VectorSessionStateContainer.Organizations is null) await VectorSessionStateContainer.LoadOrganizations();

                var query = VectorSessionStateContainer.Organizations.AsQueryable();
                if (!string.IsNullOrEmpty(args.Filter))
                {
                    query = query.Where(x => x.name.ToLowerInvariant().StartsWith(args.Filter.ToLowerInvariant()));
                }

                IdentifiedByInstitutionList = query.ToList();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task IdentifiedByInstitutionChange(object data)
        {
            if (data != null)
            {
                await LoadIdentifiedByPerson(new LoadDataArgs());
            }
            else
            {
                IdentifiedByPersonList = new List<EmployeeLookupGetListViewModel>();
            }
            await InvokeAsync(StateHasChanged);
        }

        public async Task LoadIdentifiedByPerson(LoadDataArgs args)
        {
            try
            {
                //if (VectorSessionStateContainer.DetailCollectedByInstitutionID != null)
                //{
                    EmployeeLookupGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        AccessoryCode = null,
                        AdvancedSearch = null,
                        //OrganizationID = VectorSessionStateContainer.DetailIdentifiedByInstitutionID,
                        SortColumn = "FullName",
                        SortOrder = EIDSSConstants.SortConstants.Ascending
                    };

                    IdentifiedByPersonList = await CrossCuttingClient.GetEmployeeLookupList(request);
                if (!IsNullOrEmpty(args.Filter))
                {
                    List<EmployeeLookupGetListViewModel> toList = IdentifiedByPersonList.Where(c => c.FullName != null && c.FullName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                    IdentifiedByPersonList = toList;
                }

                await InvokeAsync(StateHasChanged);
                //}
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            return await Task.FromResult(VectorSessionStateContainer.DetailCollectionsVectorDataValidIndicator = VectorDataForm.EditContext.Validate());
        }

        #endregion Validation Methods
    }
}