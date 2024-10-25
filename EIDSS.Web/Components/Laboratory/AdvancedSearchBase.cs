#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    /// <summary>
    /// </summary>
    public class AdvancedSearchBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<AdvancedSearchBase> Logger { get; set; }
        [Inject] protected ProtectedSessionStorage BrowserStorage { get; set; }
        [Inject] private ISpeciesTypeClient SpeciesTypeClient { get; set; }
        [Inject] private IOrganizationClient OrganizationClient { get; set; }
        [Inject] private IUserConfigurationService ConfigurationService { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<AdvancedSearchGetRequestModel> Form { get; set; }
        public AdvancedSearchGetRequestModel SearchCriteria { get; set; }
        public List<BaseReferenceViewModel> AccessionConditionAndSampleStatusTypes;
        public IEnumerable<BaseReferenceViewModel> SampleTypes;
        public IEnumerable<BaseReferenceViewModel> ReportOrSessionTypes;
        public IEnumerable<BaseReferenceViewModel> SurveillanceTypes;
        public IEnumerable<BaseReferenceEditorsViewModel> SpeciesTypes;
        public IEnumerable<BaseReferenceViewModel> TestNameTypes;
        public IEnumerable<BaseReferenceViewModel> TestStatusTypes;
        public IEnumerable<BaseReferenceViewModel> TestResultTypes;
        public IEnumerable<OrganizationAdvancedGetListViewModel> SentToOrganizations;
        public IEnumerable<OrganizationAdvancedGetListViewModel> TransferredToOrganizations;
        public IEnumerable<OrganizationAdvancedGetListViewModel> ResultsReceivedFromOrganizations;
        public IEnumerable<FilteredDiseaseGetListViewModel> Diseases;

        public int? AccessoryCode { get; set; }
        public bool IsSpeciesTypeDisabled { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public AdvancedSearchBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected AdvancedSearchBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            SearchCriteria ??= new AdvancedSearchGetRequestModel
            {
                DateFrom = DateTime.Now.AddDays(
                    Convert.ToInt32(ConfigurationService.SystemPreferences.NumberDaysDisplayedByDefault * -1)),
                DateTo = DateTime.Now,
                SentToOrganizationID = Convert.ToInt64(authenticatedUser
                    .OfficeId),
                SentToOrganizationSiteID =
                    Convert.ToInt64(authenticatedUser
                        .SiteId), // Must be a laboratory organization type, will be checked in on after render method on first load.
                SortColumn = "EIDSSLaboratorySampleID",
                SortOrder = SortConstants.Ascending
            };

            await GetAccessionConditionAndSampleStatusTypes(new LoadDataArgs());

            await base.OnInitializedAsync();

            _logger = Logger;
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await GetSentToOrganizations(new LoadDataArgs());

                await GetSearchCriteria();

                if (SentToOrganizations is not null)
                {
                    if (SearchCriteria.SentToOrganizationSiteID is not null &&
                        SearchCriteria.SentToOrganizationID is null)
                    {
                        if (SentToOrganizations.Any(x => x.idfsSite == SearchCriteria.SentToOrganizationSiteID))
                            SearchCriteria.SentToOrganizationID = SentToOrganizations
                                .First(x => x.idfsSite == SearchCriteria.SentToOrganizationSiteID).idfOffice;
                    }

                    if (SentToOrganizations.All(x => x.idfOffice != SearchCriteria.SentToOrganizationID))
                    {
                        // Logged on user's organization is not a laboratory organization type, so clear out the default sent to.
                        SearchCriteria.SentToOrganizationID = null;
                        SearchCriteria.SentToOrganizationSiteID = null;
                    }
                }

                await InvokeAsync(StateHasChanged);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            _disposedValue = true;
        }

        /// <summary>
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            SuppressFinalize(this);
        }

        #endregion

        #region Persistence Methods

        /// <summary>
        /// Check if a search was saved.
        /// </summary>
        /// <returns></returns>
        private async Task GetSearchCriteria()
        {
            var indicatorResult = Tab switch
            {
                LaboratoryTabEnum.Samples => await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                    .LaboratorySamplesAdvancedSearchPerformedIndicatorKey),
                LaboratoryTabEnum.Testing => await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                    .LaboratoryTestingAdvancedSearchPerformedIndicatorKey),
                LaboratoryTabEnum.Transferred => await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                    .LaboratoryTransferredAdvancedSearchPerformedIndicatorKey),
                LaboratoryTabEnum.MyFavorites => await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                    .LaboratoryMyFavoritesAdvancedSearchPerformedIndicatorKey),
                LaboratoryTabEnum.Batches => await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                    .LaboratoryBatchesAdvancedSearchPerformedIndicatorKey),
                LaboratoryTabEnum.Approvals => await BrowserStorage.GetAsync<bool>(SearchPersistenceKeys
                    .LaboratoryApprovalsAdvancedSearchPerformedIndicatorKey),
                _ => default
            };

            var searchPerformedIndicator = indicatorResult is {Success: true, Value: true};
            if (searchPerformedIndicator)
            {
                var searchModelResult = Tab switch
                {
                    LaboratoryTabEnum.Samples => await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                        SearchPersistenceKeys.LaboratorySamplesAdvancedSearchModelKey),
                    LaboratoryTabEnum.Testing => await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                        SearchPersistenceKeys.LaboratoryTestingAdvancedSearchModelKey),
                    LaboratoryTabEnum.Transferred => await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                        SearchPersistenceKeys.LaboratoryTransferredAdvancedSearchModelKey),
                    LaboratoryTabEnum.MyFavorites => await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                        SearchPersistenceKeys.LaboratoryMyFavoritesAdvancedSearchModelKey),
                    LaboratoryTabEnum.Batches => await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                        SearchPersistenceKeys.LaboratoryBatchesAdvancedSearchModelKey),
                    LaboratoryTabEnum.Approvals => await BrowserStorage.GetAsync<AdvancedSearchGetRequestModel>(
                        SearchPersistenceKeys.LaboratoryApprovalsAdvancedSearchModelKey),
                    _ => new ProtectedBrowserStorageResult<AdvancedSearchGetRequestModel>()
                };

                var searchModel = searchModelResult.Success ? searchModelResult.Value : null;
                if (searchModel != null) SearchCriteria = searchModel;
            }
        }

        #endregion

        #region Lookup Load Data Methods

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetAccessionConditionAndSampleStatusTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.AccessionCondition, HACodeList.NoneHACode);
                list.AddRange(await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.SampleStatus, HACodeList.NoneHACode));
                var item = list.Find(x => x.IdfsBaseReference == (long) SampleStatusTypeEnum.InRepository);
                if (item != null)
                    list.Remove(item);

                item = new BaseReferenceViewModel
                {
                    IdfsBaseReference = 0,
                    Name = Localizer.GetString(FieldLabelResourceKeyConstants
                        .LaboratoryAdvancedSearchModalUnaccessionedFieldLabel)
                };
                list.Add(item);

                AccessionConditionAndSampleStatusTypes = list;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSampleTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.SampleType, HACodeList.NoneHACode);

                SampleTypes = list.AsODataEnumerable();

                if (!IsNullOrEmpty(args.Filter))
                    SampleTypes = SampleTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetReportOrSessionTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.CaseType, HACodeList.NoneHACode);

                var item = list.Find(x => x.IdfsBaseReference == (long) ReportSessionTypes.Avian);
                if (item != null)
                    list.Remove(item);

                item = list.Find(x => x.IdfsBaseReference == (long) ReportSessionTypes.Livestock);
                if (item != null)
                    list.Remove(item);

                ReportOrSessionTypes = list.AsODataEnumerable();

                if (!IsNullOrEmpty(args.Filter))
                    ReportOrSessionTypes =
                        ReportOrSessionTypes.Where(c =>
                            c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSurveillanceTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.CaseReportType, HACodeList.NoneHACode);

                SurveillanceTypes = list.AsODataEnumerable();

                if (!IsNullOrEmpty(args.Filter))
                    SurveillanceTypes = SurveillanceTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSpeciesTypes(LoadDataArgs args)
        {
            try
            {
                SpeciesTypeGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = "intOrder",
                    SortOrder = SortConstants.Ascending
                };

                var list = await SpeciesTypeClient.GetSpeciesTypeList(request);

                SpeciesTypes = list.AsODataEnumerable();

                if (!IsNullOrEmpty(args.Filter))
                    SpeciesTypes = SpeciesTypes.Where(c =>
                        c.StrName != null &&
                        c.StrName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetDiseases(LoadDataArgs args)
        {
            try
            {
                FilteredDiseaseRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = AccessoryCode,
                    AdvancedSearchTerm = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    UsingType = (long) DiseaseUsingTypes.Standard,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                };

                var list = await CrossCuttingClient.GetFilteredDiseaseList(request);

                Diseases = list.AsODataEnumerable();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSentToOrganizations(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SiteFlag = (int) OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long) OrganizationTypes.Laboratory
                };

                var list = await OrganizationClient.GetOrganizationAdvancedList(request);

                SentToOrganizations = list.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList().AsODataEnumerable();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetTransferredToOrganizations(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SiteFlag = (int) OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long) OrganizationTypes.Laboratory
                };

                var list = await OrganizationClient.GetOrganizationAdvancedList(request);

                TransferredToOrganizations = list.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList().AsODataEnumerable();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetResultsReceivedFromOrganizations(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = null,
                    AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    SiteFlag = (int) OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long) OrganizationTypes.Laboratory
                };

                var list = await OrganizationClient.GetOrganizationAdvancedList(request);

                ResultsReceivedFromOrganizations = list.AsODataEnumerable();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSearchTestNameTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.TestName, HACodeList.NoneHACode);

                TestNameTypes = list.AsODataEnumerable();

                if (!IsNullOrEmpty(args.Filter))
                    TestNameTypes = TestNameTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSearchTestStatusTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.TestStatus, HACodeList.NoneHACode);

                TestStatusTypes = list.AsODataEnumerable();

                if (!IsNullOrEmpty(args.Filter))
                    TestStatusTypes = TestStatusTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public async Task GetSearchTestResultTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.TestResult, HACodeList.NoneHACode);

                TestResultTypes = list.AsODataEnumerable();

                if (!IsNullOrEmpty(args.Filter))
                    TestResultTypes = TestResultTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Sample Status Drop Down Change Event

        /// <summary>
        /// </summary>
        protected void OnSampleStatusChange()
        {
            try
            {
                SearchCriteria.SampleStatusTypeList ??= new List<long>();
                SearchCriteria.SampleStatusTypes = Join(",", SearchCriteria.SampleStatusTypeList);

                if (SearchCriteria.SampleStatusTypes == Empty)
                    SearchCriteria.SampleStatusTypes = null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Report/Session Type Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnReportOrSessionTypeChange(object value)
        {
            try
            {
                switch (value)
                {
                    case (long) ReportSessionTypes.Human:
                        IsSpeciesTypeDisabled = true;
                        AccessoryCode = (int) AccessoryCodes.HumanHACode;
                        break;
                    case (long) ReportSessionTypes.Vector:
                        IsSpeciesTypeDisabled = true;
                        AccessoryCode = (int) AccessoryCodes.VectorHACode;
                        break;
                    case (long) ReportSessionTypes.Veterinary:
                        IsSpeciesTypeDisabled = false;
                        AccessoryCode = (int) AccessoryCodes.LiveStockAndAvian;
                        break;
                    default:
                        IsSpeciesTypeDisabled = false;
                        AccessoryCode = null;
                        break;
                }

                await GetDiseases(new LoadDataArgs());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Submit Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSubmitClick()
        {
            if (!Form.EditContext.Validate()) return;

            if (SearchCriteria.SentToOrganizationID is not null)
                if (SentToOrganizations.Any(x => x.idfOffice == SearchCriteria.SentToOrganizationID))
                    if (SentToOrganizations.First(x => x.idfOffice == SearchCriteria.SentToOrganizationID)
                            .idfsSite is not null)
                    {
                        SearchCriteria.SentToOrganizationSiteID = SentToOrganizations
                            .First(x => x.idfOffice == SearchCriteria.SentToOrganizationID).idfsSite;
                    }

            // Persist search results before navigation.
            switch (Tab)
            {
                case LaboratoryTabEnum.Samples:
                    await BrowserStorage.SetAsync(
                        SearchPersistenceKeys.LaboratorySamplesAdvancedSearchPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.LaboratorySamplesAdvancedSearchModelKey,
                        SearchCriteria);

                    break;
                case LaboratoryTabEnum.Testing:
                    await BrowserStorage.SetAsync(
                        SearchPersistenceKeys.LaboratoryTestingAdvancedSearchPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.LaboratoryTestingAdvancedSearchModelKey,
                        SearchCriteria);

                    break;
                case LaboratoryTabEnum.Transferred:
                    await BrowserStorage.SetAsync(
                        SearchPersistenceKeys.LaboratoryTransferredAdvancedSearchPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.LaboratoryTransferredAdvancedSearchModelKey,
                        SearchCriteria);

                    break;
                case LaboratoryTabEnum.MyFavorites:
                    await BrowserStorage.SetAsync(
                        SearchPersistenceKeys.LaboratoryMyFavoritesAdvancedSearchPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.LaboratoryMyFavoritesAdvancedSearchModelKey,
                        SearchCriteria);

                    break;
                case LaboratoryTabEnum.Batches:
                    await BrowserStorage.SetAsync(
                        SearchPersistenceKeys.LaboratoryBatchesAdvancedSearchPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.LaboratoryBatchesAdvancedSearchModelKey,
                        SearchCriteria);

                    break;
                case LaboratoryTabEnum.Approvals:
                    await BrowserStorage.SetAsync(
                        SearchPersistenceKeys.LaboratoryApprovalsAdvancedSearchPerformedIndicatorKey, true);
                    await BrowserStorage.SetAsync(SearchPersistenceKeys.LaboratoryApprovalsAdvancedSearchModelKey,
                        SearchCriteria);

                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            if (((AdvancedSearchGetRequestModel) Form.EditContext.Model).SampleStatusTypeList != null &&
                ((AdvancedSearchGetRequestModel) Form.EditContext.Model).SampleStatusTypeList.Any(x => x == 0))
            {
                // Un-accessioned goes in the accession indicator list parameter.
                ((AdvancedSearchGetRequestModel) Form.EditContext.Model).AccessionIndicatorList =
                    ((AdvancedSearchGetRequestModel) Form.EditContext.Model).SampleStatusTypeList.First(x => x == 0)
                    .ToString();

                var sampleStatusTypes =
                    ((AdvancedSearchGetRequestModel) Form.EditContext.Model).SampleStatusTypeList.ToList();
                sampleStatusTypes.Remove(sampleStatusTypes.First(x => x == 0));
                ((AdvancedSearchGetRequestModel) Form.EditContext.Model).SampleStatusTypeList = sampleStatusTypes;

                ((AdvancedSearchGetRequestModel) Form.EditContext.Model).SampleStatusTypes =
                    sampleStatusTypes.Count == 0
                        ? null
                        : Join(",", ((AdvancedSearchGetRequestModel) Form.EditContext.Model).SampleStatusTypeList);
            }

            // Used on test requested field for transferred records.
            if (((AdvancedSearchGetRequestModel) Form.EditContext.Model).TestNameTypeID != null)
                ((AdvancedSearchGetRequestModel) Form.EditContext.Model).TestNameTypeName = TestNameTypes.First(x =>
                        x.IdfsBaseReference == ((AdvancedSearchGetRequestModel) Form.EditContext.Model).TestNameTypeID)
                    .Name;

            DiagService.Close(Form.EditContext);
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancelClick()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

                    if (result is DialogReturnResult returnResult && returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        DiagService.Close(result);
                }
                else
                {
                    DiagService.Close();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Clear Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected void OnClearClick()
        {
            try
            {
                StateHasChanged();

                SearchCriteria = new AdvancedSearchGetRequestModel
                {
                    DateFrom = DateTime.Now.AddDays(
                        Convert.ToInt32(ConfigurationService.SystemPreferences.NumberDaysDisplayedByDefault * -1)),
                    DateTo = DateTime.Now,
                    SentToOrganizationSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    SortColumn = "EIDSSLaboratorySampleID",
                    SortOrder = SortConstants.Ascending,
                    SurveillanceTypeID = (long) SurveillanceTypeEnum.Both
                };
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