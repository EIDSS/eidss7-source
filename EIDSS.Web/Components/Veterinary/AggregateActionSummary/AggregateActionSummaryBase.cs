using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Veterinary.ViewModels.VeterinaryAggregateActionSummary;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Veterinary.AggregateDiseasesReportSummary;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.CrossCutting;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.ClientLibrary.Services;
using EIDSS.Web.ViewModels;
using Microsoft.JSInterop;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.Domain.RequestModels.Reports;
using EIDSS.Web.Areas.Shared.ViewModels;
using EIDSS.Web.Components.FlexForm;
using static System.String;

namespace EIDSS.Web.Components.Veterinary.AggregateActionSummary
{
    public class AggregateActionSummaryBase : AggregateActionSummaryBaseComponent, IDisposable
    {
        #region Dependency Injection

        [Inject]
        private IAggregateReportClient AggregateReportClient { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IVeterinaryDiagnosticInvestigationMatrixClient VeterinaryDiagnosticInvestigationMatrixClient { get; set; }

        [Inject]
        private IVeterinaryProphylacticMeasureMatrixClient VeterinaryProphylacticMeasureMatrixClient { get; set; }

        [Inject]
        private IVeterinarySanitaryActionMatrixClient VeterinarySanitaryActionMatrixClient { get; set; }

        [Inject]
        private ILogger<AggregateActionSummaryBase> Logger { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IReportCrossCuttingClient ReportingClient { get; set; }

        [Inject]
        private IApplicationContext ApplicationContext { get; set; }


        #endregion Dependency Injection

        #region Protected and Public Fields

        protected RadzenDataGrid<AggregateReportGetListViewModel> _grid;
        protected RadzenTemplateForm<AggregateReportSearchViewModel> _form;

        protected bool isLoading;
        protected bool shouldRender = true;

        protected bool showCancelButton;
        protected bool showSearchButton;

        protected bool showCancelSelectedReportsButton;
        protected bool showRemoveAllButton;
        protected bool showSummaryDataButton;

        protected bool expandSearchCriteria;
        protected bool expandAdvancedSearchCriteria;
        protected bool expandSelectedReports;

        protected bool showCriteria;
        protected bool showSelectedReports;
        protected bool showReportData;
        protected bool showSummaryData;

        protected bool disableSearchButton;
        protected bool disableAdminLevelTimeIntervalDropDowns;
        protected bool disableRemoveButton;

        protected AggregateReportSearchViewModel model;
        protected IEnumerable<BaseReferenceViewModel> timeIntervalUnits;
        protected IEnumerable<BaseReferenceViewModel> adminLevelUnits;
        public FlexFormQuestionnaireGetRequestModel modelDiagnosticInvestigations { get; set; }
        public FlexFormQuestionnaireGetRequestModel modelProphylacticMeasure { get; set; }
        public FlexFormQuestionnaireGetRequestModel modelVeterinarySanitaryMeasures { get; set; }
        public FlexFormQuestionnaireGetRequestModel modelSummaryDiagnosticInvestigations { get; set; }
        public FlexFormQuestionnaireGetRequestModel modelSummaryProphylacticMeasure { get; set; }
        public FlexFormQuestionnaireGetRequestModel modelSummaryVeterinarySanitaryMeasures { get; set; }

        protected AggregateSummaryPageViewModel DiagnosticModel { get; set; }
        protected AggregateSummaryPageViewModel ProphylacticModel { get; set; }
        protected AggregateSummaryPageViewModel SanitaryModel { get; set; }

        protected FlexFormMatrix DiagnosticFlexForm { get; set; }
        protected FlexFormMatrix ProphylacticFlexForm { get; set; }
        protected FlexFormMatrix SanitaryFlexForm { get; set; }
        protected RadzenTabs FlexFormTabs { get; set; }
        protected RadzenTabsItem DiagnosticTab { get; set; }

        public string ReportLabel { get; set; }

        #endregion Protected and Public Fields

        #region Private Fields and Properties

        private bool searchSubmitted;
        private CancellationTokenSource source;
        private CancellationToken token;

        #endregion Private Fields and Properties

        #region Parameters

        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public long? CallbackKey { get; set; }

        #endregion Parameters

        public AggregateActionSummaryTabEnum Tab { get; set; }

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            //reset the cancellation token
            source = new();
            token = source.Token;

            //wire up dialog events
            //DiagService.OnClose += DialogClose;

            //initialize model
            InitializeModelAsync();

            //set grid for not loaded
            isLoading = false;

            //set up the accordions
            showCriteria = true;
            expandSearchCriteria = true;
            showSelectedReports = false;
            showReportData = false;
            showSummaryData = false;
            SetButtonStates();

            await base.OnInitializedAsync();

            _logger = Logger;
        }

        protected void DialogClose(dynamic result)
        {
            if (result is DialogReturnResult)
            {
                var dialogResult = result as DialogReturnResult;

                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    source?.Cancel();
                    ResetSearch();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                {
                    //cancel search but user said no
                    source?.Cancel();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoPrint")
                {
                    //this is the enter parameter dialog
                    //do nothing, just let the user continue entering search criteria
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoCriteria")
                {
                    //this is the enter parameter dialog
                    //do nothing, just let the user continue entering search criteria
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NarrowSearch")
                {
                    //search timed out, narrow search criteria
                    source?.Cancel();
                    //showResults = false;
                    expandSelectedReports = false;
                    showCriteria = true;
                    expandSearchCriteria = true;
                    SetButtonStates();
                }
            }
            else
            {
                //DiagService.Close(result);

                source?.Dispose();
            }

            SetButtonStates();
        }

        protected void ResetSearch()
        {
            //initialize new model with defaults
            InitializeModelAsync();

            //set grid for not loaded
            //isLoading = false;

            //reset the cancellation token
            source = new();
            token = source.Token;

            //set up the accordions and buttons
            searchSubmitted = false;
            showCriteria = true;
            expandSearchCriteria = true;
            expandAdvancedSearchCriteria = false;
            expandSelectedReports = false;
            showSelectedReports = false;
            SetButtonStates();
        }

        public void Dispose()
        {
            source?.Cancel();
            source?.Dispose();
        }

        protected async Task CancelSearch()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var yesButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                var noButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.Yes
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                var options = new DialogOptions()
                {
                    Height = "auto"
                };

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage));
                var result = await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams, options);

                if (result is DialogReturnResult dialogResult
                    && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    DiagService.Close();

                    source?.Cancel();

                    var uri = $"{NavManager.BaseUri}Administration/Dashboard";
                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                    DiagService.Close();

                    source?.Cancel();
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, "Error closing search dialog.");
            }
        }

        protected void AccordionClick(int index)
        {
            switch (index)
            {
                //search results toggle
                case 0:

                    expandSelectedReports = !expandSelectedReports;
                    break;

                default:
                    break;
            }
            SetButtonStates();
        }

        #endregion Lifecycle Methods

        #region Protected Methods and Delegates

        protected void HandleValidSearchSubmit(AggregateReportSearchViewModel model)
        {
            if (_form.IsValid)
            {
                if (_form.EditContext.IsModified())
                {
                    searchSubmitted = true;

                    //SetButtonStates();

                    //if (_grid != null)
                    //{
                    //    await _grid.Reload();
                    //}
                }
                else
                {
                    //no search criteria entered - display the EIDSS dialog component
                    searchSubmitted = false;
                    //await ShowNoSearchCriteriaDialog();
                }
            }
        }

        protected async Task HandleInvalidSearchSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                //TODO - display the validation Errors on the dialog?
                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.FieldIsInvalidValidRangeIsMessage));
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected async Task GetTimeIntervalUnitAsync(LoadDataArgs args)
        {
            timeIntervalUnits = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.StatisticalPeriodType, EIDSSConstants.HACodeList.NoneHACode);
            if (!IsNullOrEmpty(args.Filter))
            {
                List<BaseReferenceViewModel> toList = timeIntervalUnits.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                timeIntervalUnits = toList;
            }
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetAdminLevelUnitAsync(LoadDataArgs args)
        {
            adminLevelUnits = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.StatisticalAreaType, EIDSSConstants.HACodeList.NoneHACode);
            if (!IsNullOrEmpty(args.Filter))
            {
                List<BaseReferenceViewModel> toList = adminLevelUnits.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                adminLevelUnits = toList;
            }
            await InvokeAsync(StateHasChanged);
        }

        public void EnableSearchButton()
        {
            long? adminLevelID = model.SearchCriteria.AdministrativeUnitTypeID == null ? null : (long)model.SearchCriteria.AdministrativeUnitTypeID;
            long? timeIntervalTypeID = model.SearchCriteria.TimeIntervalTypeID == null ? null : (long)model.SearchCriteria.TimeIntervalTypeID;

            if (adminLevelID == null || timeIntervalTypeID == null)
            {
                disableSearchButton = true;
                return;
            }

            if (adminLevelID != null)
            {
                if (string.IsNullOrEmpty(adminLevelID.ToString()))
                {
                    disableSearchButton = true;
                    return;
                }
            }

            if (timeIntervalTypeID != null)
            {
                if (string.IsNullOrEmpty(timeIntervalTypeID.ToString()))
                {
                    disableSearchButton = true;
                    return;
                }
            }

            disableSearchButton = false;
            return;
        }

        #endregion Protected Methods and Delegates

        #region Search modal

        protected async Task OpenSearchModal()
        {
            try
            {
                var adminLevelId = model.SearchCriteria.AdministrativeUnitTypeID;
                var timeIntervalTypeId = model.SearchCriteria.TimeIntervalTypeID;
                var selectedReportsShow = expandSelectedReports;

                var dialogParams = new Dictionary<string, object>();

                var result = await DiagService.OpenAsync<SearchAggregateDiseaseReportSummary>(Localizer.GetString(HeadingResourceKeyConstants.VeterinaryAggregateDiseaseReportSummarySearchHeading),
                    new Dictionary<string, object>() { { "ReportType", AggregateDiseaseReportTypes.VeterinaryAggregateActionReport }, { "SearchModel", model } },
                    new DialogOptions()
                    {
                        Width = CSSClassConstants.LargeDialogWidth,
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                {
                    return;
                }

                if (result is DialogReturnResult dialogResult)
                {
                    if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.SelectButton) || dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.SelectAllButton))
                    {
                        expandSelectedReports = true;
                        disableAdminLevelTimeIntervalDropDowns = true;
                        showSelectedReports = true;
                    }

                    if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (selectedReportsShow == true)
                        {
                            expandSelectedReports = true;
                            disableAdminLevelTimeIntervalDropDowns = true;
                            showSelectedReports = true;
                            model.SearchCriteria.AdministrativeUnitTypeID = adminLevelId;
                            model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeId;
                            disableSearchButton = false;
                        }
                        else
                        {
                            model.SearchCriteria.AdministrativeUnitTypeID = adminLevelId;
                            model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeId;
                            EnableSearchButton();
                            return;
                        }
                    }
                }

                SetButtonStates();
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
            //}
        }

        #endregion Search modal

        #region Selected Reports

        protected async void CancelSelectedReports()
        {
            try
            {
                long? adminLevelID = model.SearchCriteria.AdministrativeUnitTypeID == null ? null : (long)model.SearchCriteria.AdministrativeUnitTypeID;
                long? timeIntervalTypeID = model.SearchCriteria.TimeIntervalTypeID == null ? null : (long)model.SearchCriteria.TimeIntervalTypeID;

                var buttons = new List<DialogButton>();
                var yesButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                var noButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.Yes
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                var options = new DialogOptions()
                {
                    Height = "auto"
                };

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams, options);

                var dialogResult = result as DialogReturnResult;
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    AggregateActionSummaryService.SearchReports = null;
                    AggregateActionSummaryService.SelectedReports = null;

                    model.SearchCriteria.AdministrativeUnitTypeID = adminLevelID;
                    model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeID;
                    EnableSearchButton();

                    disableAdminLevelTimeIntervalDropDowns = false;
                    expandSelectedReports = false;
                    showSelectedReports = false;
                    showSummaryData = false;
                    
                    SetButtonStates();
                    
                    await InvokeAsync(StateHasChanged);
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                    source?.Cancel();
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected async Task OnRemoveAsync(long id)
        {
            try
            {
                IList<AggregateReportGetListViewModel> list = new List<AggregateReportGetListViewModel>();

                foreach (var report in AggregateActionSummaryService.SelectedReports)
                {
                    if (id != report.ReportKey)
                        list.Add(report);
                }

                AggregateActionSummaryService.SelectedReports = list;
                await _grid.Reload();

                if (AggregateActionSummaryService.SelectedReports.Count == 0)
                {
                    AggregateActionSummaryService.SearchReports = null;
                    AggregateActionSummaryService.SelectedReports = null;
                    disableAdminLevelTimeIntervalDropDowns = false;
                    showSummaryData = false;
                    showCancelButton = true;
                    showCancelSelectedReportsButton = false;
                    showRemoveAllButton = false;
                    showSummaryDataButton = false;
                    showSelectedReports = false;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task ShowReportDataLinkAsync(long? id, string reportId)
        {
            modelDiagnosticInvestigations ??= new FlexFormQuestionnaireGetRequestModel();
            modelProphylacticMeasure ??= new FlexFormQuestionnaireGetRequestModel();
            modelVeterinarySanitaryMeasures ??= new FlexFormQuestionnaireGetRequestModel();

            // reset the tab to nothing selected and refresh
            //  at the end
            var currentTab = Tab;
            Tab = AggregateActionSummaryTabEnum.None;

            if (id != null)
            {
                var result = await GetFlexFormQuestionnaireGetRequestModelAsync((long)id);

                //Diagnostic Investigation
                var matrixVersionList = await CrossCuttingClient.GetMatrixVersionsByType((long)MatrixTypes.DiagnosticInvestigations);

                if (matrixVersionList.Count > 0 && matrixVersionList.Find(v => v.BlnIsActive == true) != null)
                {
                    ReportLabel = Localizer.GetString(HeadingResourceKeyConstants.VeterinaryAggregateActionReportPageHeading) + " - " + reportId;

                    var strId = matrixVersionList.Find(v => v.BlnIsActive == true)?.IdfVersion.ToString();

                    if (result.idfDiagnosticObservation != null)
                    {
                        modelDiagnosticInvestigations.SubmitButtonID = "btnSubmit";
                        modelDiagnosticInvestigations.idfObservation = result.idfDiagnosticObservation;
                        modelDiagnosticInvestigations.idfVersion = result.idfDiagnosticVersion;
                        modelDiagnosticInvestigations.idfsFormTemplate = result.idfsDiagnosticObservationFormTemplate;
                        if (strId != null)
                            await LoadDiagnosticFlexFormsAsync(modelDiagnosticInvestigations, long.Parse(strId));
                    }
                }

                //Prophylactic Measure
                var prophylacticVersionList = await CrossCuttingClient.GetMatrixVersionsByType((long)MatrixTypes.Prophylactic);

                if (prophylacticVersionList.Count > 0 && prophylacticVersionList.Find(v => v.BlnIsActive == true) != null)
                {
                    var strId = prophylacticVersionList.Find(v => v.BlnIsActive == true)?.IdfVersion.ToString();

                    if (result.idfProphylacticObservation != null)
                    {
                        modelProphylacticMeasure.SubmitButtonID = "btnSubmit";
                        modelProphylacticMeasure.idfObservation = result.idfProphylacticObservation;
                        modelProphylacticMeasure.idfVersion = result.idfProphylacticVersion;
                        modelProphylacticMeasure.idfsFormTemplate = result.idfsProphylacticObservationFormTemplate;
                        if (strId != null)
                            await LoadProphylacticFlexFormsAsync(modelProphylacticMeasure, long.Parse(strId));
                    }
                }

                //Sanitary Action
                var sanitaryVersionList = await CrossCuttingClient.GetMatrixVersionsByType((long)MatrixTypes.VeterinarySanitaryMeasures);

                if (sanitaryVersionList.Count > 0 && sanitaryVersionList.Find(v => v.BlnIsActive == true) != null)
                {
                    var strId = sanitaryVersionList.Find(v => v.BlnIsActive == true)?.IdfVersion.ToString();

                    if (result.idfSanitaryObservation != null)
                    {
                        modelVeterinarySanitaryMeasures.SubmitButtonID = "btnSubmit";
                        modelVeterinarySanitaryMeasures.idfObservation = result.idfSanitaryObservation;
                        modelVeterinarySanitaryMeasures.idfVersion = result.idfSanitaryVersion;
                        modelVeterinarySanitaryMeasures.idfsFormTemplate = result.idfsSanitaryObservationFormTemplate;
                        if (strId != null)
                            await LoadSanitaryFlexFormsAsync(modelVeterinarySanitaryMeasures, long.Parse(strId));
                    }
                }
            }

            showReportData = true;
            showSummaryData = false;
            showSelectedReports = true;
            expandSelectedReports = false;

            // reset the tab to the first one when selecting report
            Tab = currentTab;

            SetButtonStates();
        }

        protected void OnRemoveAll()
        {
            AggregateActionSummaryService.SearchReports = null;
            AggregateActionSummaryService.SelectedReports = null;
            disableAdminLevelTimeIntervalDropDowns = false;
            showSummaryData = false;
            showCancelButton = true;
            showCancelSelectedReportsButton = false;
            showRemoveAllButton = false;
            showSummaryDataButton = false;
            showSelectedReports = false;
        }

        #endregion Selected Reports

        #region Summary

        public void OnChange(int index)
        {
            switch (index)
            {
                case 0:
                    Tab = AggregateActionSummaryTabEnum.DiagnosticInvestigation;
                    break;

                case 1:
                    Tab = AggregateActionSummaryTabEnum.ProphylacticMeasure;
                    break;

                case 2:
                    Tab = AggregateActionSummaryTabEnum.SanitaryAction;
                    break;
            }
        }

        protected void CancelSummarySearch()
        {
            expandSelectedReports = true;
            showSelectedReports = true;
            showSummaryData = false;
            showReportData = false;
            SetButtonStates();
        }

        protected async Task OnShowSummaryDataAsync()
        {
            //var observationList = string.Empty;
            //var observationListProphylactic = string.Empty;
            //var observationListSanitary = string.Empty;

            //modelSummaryDiagnosticInvestigations = new FlexFormQuestionnaireGetRequestModel();
            //modelSummaryProphylacticMeasure = new FlexFormQuestionnaireGetRequestModel();
            //modelSummaryVeterinarySanitaryMeasures = new FlexFormQuestionnaireGetRequestModel();

            // reset the tab to nothing selected and refresh
            //  at the end
            var currentTab = Tab;
            Tab = AggregateActionSummaryTabEnum.None;

            var caseList = GetSelectedReportsCaseList();

            DiagnosticModel = await GetDiagnosticModel(caseList);
            ProphylacticModel = await GetProphylacticModel(caseList);
            SanitaryModel = await GetSanitaryModel(caseList);

            //switch (currentTab)
            //{
            //    case AggregateActionSummaryTabEnum.DiagnosticInvestigation:
            //        DiagnosticModel = await GetDiagnosticModel(caseList);
            //        break;

            //    case AggregateActionSummaryTabEnum.ProphylacticMeasure:
            //        caseList = GetSelectedReportsCaseList();
            //        ProphylacticModel = await GetProphylacticModel(caseList);
            //        break;

            //    case AggregateActionSummaryTabEnum.SanitaryAction:
            //        caseList = GetSelectedReportsCaseList();
            //        SanitaryModel = await GetSanitaryModel(caseList);
            //        break;

            //    case AggregateActionSummaryTabEnum.None:
            //        break;

            //    default:
            //        throw new ArgumentOutOfRangeException();
            //}
            //Diagnostic Investigation
            //var matrixVersionList = await CrossCuttingClient.GetMatrixVersionsByType((long)MatrixTypes.DiagnosticInvestigations);

            //if (matrixVersionList.Count > 0)
            //{
            //    var strId = matrixVersionList.Find(v => v.BlnIsActive == true)?.IdfVersion.ToString();

            //    var result = new AggregateActionSummaryViewModel();

            //    foreach (var report in AggregateActionSummaryService.SelectedReports)
            //    {
            //        result = await GetFlexFormQuestionnaireGetRequestModelAsync(report.ReportKey);

            //        if (string.IsNullOrEmpty(observationList))
            //            observationList = result.idfDiagnosticObservation.ToString();
            //        else
            //            observationList += ";" + result.idfDiagnosticObservation.ToString();

            //        if (string.IsNullOrEmpty(observationListProphylactic))
            //            observationListProphylactic = result.idfProphylacticObservation.ToString();
            //        else
            //            observationListProphylactic += ";" + result.idfProphylacticObservation.ToString();

            //        if (string.IsNullOrEmpty(observationListSanitary))
            //            observationListSanitary = result.idfSanitaryObservation.ToString();
            //        else
            //            observationListSanitary += ";" + result.idfSanitaryObservation.ToString();
            //    }

            //    modelSummaryDiagnosticInvestigations.observationList = observationList;
            //    modelSummaryDiagnosticInvestigations.idfVersion = result.idfDiagnosticVersion;
            //    modelSummaryDiagnosticInvestigations.idfsFormTemplate = result.idfsDiagnosticObservationFormTemplate;
            //    if (observationList != string.Empty)
            //        await LoadDiagnosticFlexFormsAsync(modelSummaryDiagnosticInvestigations, long.Parse(strId));
            //}

            //Prophylactic Measure
            //var prophylacticVersionList = await CrossCuttingClient.GetMatrixVersionsByType((long)MatrixTypes.Prophylactic);

            //if (prophylacticVersionList.Count > 0)
            //{
            //    var strId = prophylacticVersionList.Find(v => v.BlnIsActive == true)?.IdfVersion.ToString();

            //    var result = new AggregateActionSummaryViewModel();

            //    if (observationListProphylactic == string.Empty)
            //    {
            //        foreach (var report in AggregateActionSummaryService.SelectedReports)
            //        {
            //            result = await GetFlexFormQuestionnaireGetRequestModelAsync(report.ReportKey);

            //            if (string.IsNullOrEmpty(observationList))
            //                observationList = result.idfDiagnosticObservation.ToString();
            //            else
            //                observationList += ";" + result.idfDiagnosticObservation.ToString();

            //            if (string.IsNullOrEmpty(observationListProphylactic))
            //                observationListProphylactic = result.idfProphylacticObservation.ToString();
            //            else
            //                observationListProphylactic += ";" + result.idfProphylacticObservation.ToString();

            //            if (string.IsNullOrEmpty(observationListSanitary))
            //                observationListSanitary = result.idfSanitaryObservation.ToString();
            //            else
            //                observationListSanitary += ";" + result.idfSanitaryObservation.ToString();
            //        }
            //    }

            //    modelSummaryProphylacticMeasure.observationList = observationListProphylactic;
            //    modelSummaryProphylacticMeasure.idfsFormTemplate = result.idfProphylacticVersion;
            //    modelSummaryProphylacticMeasure.idfsFormTemplate = result.idfsProphylacticObservationFormTemplate;
            //    if (observationListProphylactic != string.Empty)
            //        await LoadProphylacticFlexFormsAsync(modelSummaryProphylacticMeasure, long.Parse(strId));
            //}

            ////Sanitary Action
            //var sanitaryVersionList = await CrossCuttingClient.GetMatrixVersionsByType((long)MatrixTypes.VeterinarySanitaryMeasures);

            //if (sanitaryVersionList.Count > 0)
            //{
            //    var strId = sanitaryVersionList.Find(v => v.BlnIsActive == true)?.IdfVersion.ToString();

            //    var result = new AggregateActionSummaryViewModel();

            //    if (observationListSanitary == string.Empty)
            //    {
            //        foreach (var report in AggregateActionSummaryService.SelectedReports)
            //        {
            //            result = await GetFlexFormQuestionnaireGetRequestModelAsync(report.ReportKey);

            //            if (string.IsNullOrEmpty(observationList))
            //                observationList = result.idfDiagnosticObservation.ToString();
            //            else
            //                observationList += ";" + result.idfDiagnosticObservation.ToString();

            //            if (string.IsNullOrEmpty(observationListProphylactic))
            //                observationListProphylactic = result.idfProphylacticObservation.ToString();
            //            else
            //                observationListProphylactic += ";" + result.idfProphylacticObservation.ToString();

            //            if (string.IsNullOrEmpty(observationListSanitary))
            //                observationListSanitary = result.idfSanitaryObservation.ToString();
            //            else
            //                observationListSanitary += ";" + result.idfSanitaryObservation.ToString();
            //        }
            //    }

            //    modelSummaryVeterinarySanitaryMeasures.observationList = observationListSanitary;
            //    modelSummaryVeterinarySanitaryMeasures.idfVersion = result.idfSanitaryVersion;
            //    modelSummaryVeterinarySanitaryMeasures.idfsFormTemplate = result.idfsSanitaryObservationFormTemplate;
            //    if (observationListSanitary != string.Empty)
            //        await LoadSanitaryFlexFormsAsync(modelSummaryVeterinarySanitaryMeasures, long.Parse(strId));
            //}

            showReportData = false;
            showSummaryData = true;
            showSelectedReports = true;
            expandSelectedReports = false;

            SetButtonStates();

            // reset the tab to the first one when selecting report
            Tab = currentTab;

            await InvokeAsync(StateHasChanged);
        }

        protected string GetSelectedReportsCaseList()
        {
            var caseList = string.Empty;

            //generate the list of diseases and positive quantity for this aggregate collection
            if (AggregateActionSummaryService.SelectedReports is null) return caseList;

            var selectedReports = AggregateActionSummaryService.SelectedReports.ToList();
            var i = selectedReports.Count;
            foreach (var item in selectedReports)
            {
                var separator = i > 1 ? ";" : string.Empty;
                caseList += $"{item.ReportKey}{separator}";
                i--;
            }

            return caseList;
        }

        private async Task LoadDiagnosticFlexFormsAsync(FlexFormQuestionnaireGetRequestModel model, long idfVersion)
        {
            FlexFormMatrixData matrixData;

            model.MatrixColumns = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.InvestigationTypeColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SpeciesColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.OIECodeColumnHeading)
            };

            model.Title = String.Empty;
            model.LangID = GetCurrentLanguage();
            model.idfsFormType = (long)FlexibleFormTypes.VeterinaryDiagnostic;
            model.ObserationFieldID = "idfDiagnosticObservation";

            List<InvestigationTypeViewModel> lstInvestigationTypes = await VeterinaryDiagnosticInvestigationMatrixClient.GetInvestigationTypeMatrixListAsync(EIDSS.ClientLibrary.Enumerations.EIDSSConstants.ReferenceEditorType.InvestigationTypes, null, GetCurrentLanguage());
            List<SpeciesViewModel> lstSpecies = await CrossCuttingClient.GetSpeciesListAsync(EIDSS.ClientLibrary.Enumerations.EIDSSConstants.ReferenceEditorType.SpeciesList, HACodeList.LiveStockAndAvian, GetCurrentLanguage());
            List<VeterinaryDiseaseMatrixListViewModel> lstDiseases = await CrossCuttingClient.GetVeterinaryDiseaseMatrixListAsync(EIDSS.ClientLibrary.Enumerations.EIDSSConstants.ReferenceEditorType.Disease, HACodeList.LiveStockAndAvian, GetCurrentLanguage());

            MatrixGetRequestModel request = new MatrixGetRequestModel();
            //request.MatrixId = idfVersion;
            request.MatrixId = model.idfVersion ??= idfVersion;
            request.LanguageId = GetCurrentLanguage();
            request.Page = 1;
            request.PageSize = 1000;
            request.SortColumn = "intNumRow";
            request.SortOrder = "asc";

            List<VeterinaryDiagnosticInvestigationMatrixReportModel> lstRow = await VeterinaryDiagnosticInvestigationMatrixClient.GetVeterinaryDiagnosticInvestigationMatrixReport(request);

            model.MatrixData = new List<FlexFormMatrixData>();

            foreach (var row in lstRow)
            {
                matrixData = new FlexFormMatrixData
                {
                    MatrixData = new List<string>(),

                    idfRow = (long)row.IdfAggrDiagnosticActionMTX
                };
                matrixData.MatrixData.Add(lstInvestigationTypes.Find(v => v.IdfsBaseReference == row.IdfsDiagnosticAction).StrDefault);
                matrixData.MatrixData.Add(lstSpecies.Find(v => v.IdfsBaseReference == row.IdfsSpeciesType).StrDefault);
                matrixData.MatrixData.Add(lstDiseases.Find(v => v.IdfsBaseReference == row.IdfsDiagnosis).StrDefault);
                matrixData.MatrixData.Add(row.StrOIECode);
                model.MatrixData.Add(matrixData);
            }
        }

        private async Task<AggregateSummaryPageViewModel> GetDiagnosticModel(string caseList)
        {
            var diagnosticModel = new AggregateSummaryPageViewModel();

            var request = new AggregateSummaryRequestModel()
            {
                LangID = GetCurrentLanguage(),
                idfAggrCaseList = caseList
            };

            diagnosticModel.AggregateSummaryRecords = await ReportingClient.GetVeterinaryAggregateDiagnosticActionSummaryReportDetail(request);
            diagnosticModel.MatrixColumnHeadings = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.InvestigationTypeColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SpeciesColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.OIECodeColumnHeading)
            };
            diagnosticModel.Title = string.Empty;
            diagnosticModel.DisplayFields = new Dictionary<string, int>
            {
                { "strAction", 0 },
                { "strSpecies", 1 },
                { "strDefault", 2 },
                { "strOIECode", 3 }
            };

            return diagnosticModel;
        }

        private async Task<AggregateSummaryPageViewModel> GetProphylacticModel(string caseList)
        {
            var prophylacticModel = new AggregateSummaryPageViewModel();

            var request = new AggregateSummaryRequestModel()
            {
                LangID = GetCurrentLanguage(),
                idfAggrCaseList = caseList
            };

            prophylacticModel.AggregateSummaryRecords = await ReportingClient.GetVeterinaryAggregateProphylacticActionSummaryReportDetail(request);
            prophylacticModel.MatrixColumnHeadings = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.MeasureTypeColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.MeasureCodeColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SpeciesColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.OIECodeColumnHeading)
            };
            prophylacticModel.Title = string.Empty;
            prophylacticModel.DisplayFields = new Dictionary<string, int>
            {
                { "strAction", 0 },
                { "strActionCode", 1 },
                { "strSpecies", 2 },
                { "strDefault", 3 },
                { "strOIECode", 4 }
            };

            return prophylacticModel;
        }

        private async Task<AggregateSummaryPageViewModel> GetSanitaryModel(string caseList)
        {
            var sanitaryModel = new AggregateSummaryPageViewModel();

            var request = new AggregateSummaryRequestModel()
            {
                LangID = GetCurrentLanguage(),
                idfAggrCaseList = caseList
            };

            sanitaryModel.AggregateSummaryRecords = await ReportingClient.GetVeterinaryAggregateSanitaryActionSummaryReportDetail(request);
            sanitaryModel.MatrixColumnHeadings = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SanitaryActionColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SanitaryCodeColumnHeading)
            };
            sanitaryModel.Title = string.Empty;
            sanitaryModel.DisplayFields = new Dictionary<string, int>
            {
                { "strAction", 0 },
                { "strActionCode", 1 }
            };

            return sanitaryModel;
        }

        private async Task LoadProphylacticFlexFormsAsync(FlexFormQuestionnaireGetRequestModel model, long idfVersion)
        {
            FlexFormMatrixData matrixData;

            model.MatrixColumns = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.MeasureTypeColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.MeasureCodeColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SpeciesColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.OIECodeColumnHeading)
            };
            model.Title = String.Empty;
            model.LangID = GetCurrentLanguage();
            model.idfsFormType = (long)FlexibleFormTypes.VeterinaryProphylactic;
            model.ObserationFieldID = "idfProphylacticObservation";

            List<InvestigationTypeViewModel> lstMeasureTypes = await VeterinaryProphylacticMeasureMatrixClient.GetVeterinaryProphylacticMeasureTypes(EIDSS.ClientLibrary.Enumerations.EIDSSConstants.ReferenceEditorType.Prophylactic, HACodeList.LivestockHACode, GetCurrentLanguage());
            List<SpeciesViewModel> lstSpecies = await CrossCuttingClient.GetSpeciesListAsync(EIDSS.ClientLibrary.Enumerations.EIDSSConstants.ReferenceEditorType.SpeciesList, HACodeList.LiveStockAndAvian, GetCurrentLanguage());
            List<VeterinaryDiseaseMatrixListViewModel> lstDiseases = await CrossCuttingClient.GetVeterinaryDiseaseMatrixListAsync(EIDSS.ClientLibrary.Enumerations.EIDSSConstants.ReferenceEditorType.Disease, HACodeList.LiveStockAndAvian, GetCurrentLanguage());

            VeterinaryProphylacticMeasureMatrixGetRequestModel request = new VeterinaryProphylacticMeasureMatrixGetRequestModel();
            //request.IdfVersion = idfVersion;
            request.IdfVersion = model.idfVersion ??= idfVersion;
            request.LanguageId = GetCurrentLanguage();
            request.Page = 1;
            request.PageSize = 1000;
            request.SortColumn = "intNumRow";
            request.SortOrder = "asc";

            List<VeterinaryProphylacticMeasureMatrixViewModel> lstRow = await VeterinaryProphylacticMeasureMatrixClient.GetVeterinaryProphylacticMeasureMatrixReport(request);

            model.MatrixData = new List<FlexFormMatrixData>();

            foreach (var row in lstRow)
            {
                matrixData = new FlexFormMatrixData
                {
                    MatrixData = new List<string>(),

                    idfRow = (long)row.IdfAggrProphylacticActionMTX
                };

                matrixData.MatrixData.Add(lstMeasureTypes.Find(v => v.IdfsBaseReference == row.IdfsProphilacticAction).StrDefault);
                matrixData.MatrixData.Add(row.StrActionCode);
                matrixData.MatrixData.Add(lstSpecies.Find(v => v.IdfsBaseReference == row.IdfsSpeciesType).StrDefault);
                matrixData.MatrixData.Add(lstDiseases.Find(v => v.IdfsBaseReference == row.IdfsDiagnosis).StrDefault);
                matrixData.MatrixData.Add(row.StrOIECode);
                model.MatrixData.Add(matrixData);
            }
        }

        private async Task LoadSanitaryFlexFormsAsync(FlexFormQuestionnaireGetRequestModel model, long idfVersion)
        {
            FlexFormMatrixData matrixData;

            model.MatrixColumns = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SanitaryActionColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SanitaryCodeColumnHeading)
            };
            model.Title = String.Empty;
            model.LangID = GetCurrentLanguage();
            model.idfsFormType = (long)FlexibleFormTypes.VeterinarySanitary;
            model.ObserationFieldID = "idfSanitaryObservation";

            List<InvestigationTypeViewModel> lstSanitaryActionTypes = await VeterinarySanitaryActionMatrixClient.GetVeterinarySanitaryActionTypes(EIDSSConstants.ReferenceEditorType.Sanitary, HACodeList.LivestockHACode, GetCurrentLanguage());

            //List<VeterinarySanitaryActionMatrixViewModel> lstRow = await VeterinarySanitaryActionMatrixClient.GetVeterinarySanitaryActionMatrixReport(GetCurrentLanguage(), idfVersion);
            List<VeterinarySanitaryActionMatrixViewModel> lstRow = await VeterinarySanitaryActionMatrixClient.GetVeterinarySanitaryActionMatrixReport(GetCurrentLanguage(), model.idfVersion ??= idfVersion);

            model.MatrixData = new List<FlexFormMatrixData>();

            foreach (var row in lstRow)
            {
                matrixData = new FlexFormMatrixData
                {
                    MatrixData = new List<string>(),
                    idfRow = (long)row.IdfAggrSanitaryActionMTX
                };

                matrixData.MatrixData.Add(lstSanitaryActionTypes.Find(v => v.IdfsBaseReference == row.IdfsSanitaryAction).StrDefault);
                matrixData.MatrixData.Add(row.StrActionCode);

                model.MatrixData.Add(matrixData);
            }
        }

        private async Task<AggregateActionSummaryViewModel> GetFlexFormQuestionnaireGetRequestModelAsync(long id)
        {
            AggregateActionSummaryViewModel model = new();

            var detailRequest = new AggregateReportGetListDetailRequestModel()
            {
                LanguageID = GetCurrentLanguage(),
                idfsAggrCaseType = (long)AggregateDiseaseReportTypes.VeterinaryAggregateActionReport,
                idfAggrCase = (long)id,
                ApplyFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId)
            };
            var response = await AggregateReportClient.GetAggregateReportDetail(detailRequest, token);
            if (response.Count > 0)
            {
                model.idfsDiagnosticObservationFormTemplate = response[0].idfsDiagnosticFormTemplate;
                model.idfDiagnosticVersion = response[0].idfDiagnosticVersionID;
                model.idfDiagnosticObservation = response[0].idfDiagnosticObservation;

                model.idfsProphylacticObservationFormTemplate = response[0].idfsProphylacticFormTemplate;
                model.idfProphylacticVersion = response[0].idfProphylacticVersionID;
                model.idfProphylacticObservation = response[0].idfProphylacticObservation;

                model.idfsSanitaryObservationFormTemplate = response[0].idfsSanitaryFormTemplate;
                model.idfSanitaryVersion = response[0].idfSanitaryVersionID;
                model.idfSanitaryObservation = response[0].idfSanitaryObservation;
            }

            return model;
        }

        #endregion Summary

        #region print

        [JSInvokable("OnPrint")]
        protected async Task PrintReport()
        {
            try
            {
                if (AggregateActionSummaryService.SelectedReports is { Count: > 0 })
                {
                    var aggregateReportIds = string.Join(";",
                        AggregateActionSummaryService.SelectedReports.Select(x => x.ReportKey.ToString()));
                    //TODO: remove commented if session-User approach works//var organization = ConfigurationService.GetUserToken().Organization;
                    //TODO: consider usage of _tokenService.GetAuthenticatedUser().Organization
                    var organization = authenticatedUser.Organization;

                    var reportTitle = Localizer.GetString(HeadingResourceKeyConstants
                        .VeterinaryAggregateActionReportSummaryPageHeading);

                    ReportViewModel reportModel = new();
                    //reportModel.AddParameter("ReportTitle", "test");
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("idfsAggrCaseType", EIDSSConstants.AggregateValue.VeterinaryAction);
                    reportModel.AddParameter("idfAggrCaseList", aggregateReportIds);
                    reportModel.AddParameter("SiteID", authenticatedUser.SiteId);
                    reportModel.AddParameter("AdministrativeLevel", AggregateActionSummaryService.SelectedReports.FirstOrDefault()?.AdministrativeUnitTypeName);

                    await DiagService.OpenAsync<DisplayReport>(
                        reportTitle,
                        new Dictionary<string, object>
                        {
                            {"ReportName", "VeterinaryAggregateActionSummaryReport"},
                            {"Parameters", reportModel.Parameters}
                        },
                        new DialogOptions
                        {
                            Resizable = true,
                            Draggable = false,
                            Width = "1050px"
                        });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion print

        #region Private Methods

        private void InitializeModelAsync()
        {
            disableSearchButton = true;
            disableAdminLevelTimeIntervalDropDowns = false;

            model = new AggregateReportSearchViewModel();
            model.SearchCriteria = new();
            model.Permissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.AccessToVeterinaryAggregateActions);
            model.RecordSelectionIndicator = true;
            model.SearchCriteria.SortColumn = "ReportID";
            model.SearchCriteria.SortOrder = "desc";
            model.SearchCriteria.StartDate = null;
            model.SearchCriteria.EndDate = null;
            model.SearchLocationViewModel = new()
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = true,
                ShowAdminLevel0 = false,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = true,
                ShowAdminLevel4 = false,
                ShowAdminLevel5 = false,
                ShowAdminLevel6 = false,
                ShowSettlement = true,
                ShowSettlementType = true,
                ShowStreet = false,
                ShowBuilding = false,
                ShowApartment = false,
                ShowElevation = false,
                ShowHouse = false,
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = false,
                ShowBuildingHouseApartmentGroup = false,
                ShowPostalCode = false,
                ShowCoordinates = false,
                IsDbRequiredAdminLevel1 = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                AdminLevel0Value = Convert.ToInt64(Configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
            };
        }

        private void SetButtonStates()
        {
            if (expandSelectedReports)
            {
                showCancelButton = false;
                //showPrintButton = false;
                //showCancelSummaryButton = false;
                showCancelSelectedReportsButton = true;
                showSearchButton = true;
                showRemoveAllButton = true;
                showSummaryDataButton = true;
            }
            else if (showSummaryData)
            {
                //showPrintButton = true;
                //showCancelSummaryButton = true;
                showCancelButton = false;
                showCancelSelectedReportsButton = false;
                showSearchButton = false;
                showRemoveAllButton = false;
                showSummaryDataButton = false;
            }
            else
            {
                //showPrintButton = false;
                //showCancelSummaryButton = false;
                showCancelButton = true;
                showCancelSelectedReportsButton = false;
                showSearchButton = true;
                showRemoveAllButton = false;
                showSummaryDataButton = false;
            }

            if (!model.Permissions.Delete)
                disableRemoveButton = true;
        }

        #endregion Private Methods
    }
}