using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Components.Human.HumanAggregateDiseaseReportSummary
{
    public class HumanAggregateDiseaseReportSummaryBase : HumanAggregateDiseaseReportSummaryBaseComponent, IDisposable
    {
        public FlexForm.FlexForm Ff { get; set; }
        public DiseaseMatrixSectionViewModel FlexFormMatrixModel { get; set; }

        #region Dependency Injection

        [Inject] private IAggregateReportClient AggregateDiseaseReportClient { get; set; }

        [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject] private IHumanAggregateDiseaseMatrixClient HumanAggregateDiseaseMatrixClient { get; set; }

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }

        [Inject] private ILogger<HumanAggregateDiseaseReportSummaryBase> Logger { get; set; }

        [Inject]
        private IApplicationContext ApplicationContext { get; set; }

        #endregion Dependency Injection

        #region Protected and Public Fields

        protected RadzenDataGrid<AggregateReportGetListViewModel> Grid;
        protected RadzenTemplateForm<AggregateReportSearchViewModel> Form;

        protected bool IsLoading;
        protected bool shouldRender = true;

        protected bool ShowCancelButton;
        protected bool ShowSearchButton;

        protected bool ShowCancelSelectedReportsButton;
        protected bool ShowRemoveAllButton;
        protected bool ShowSummaryDataButton;

        //protected bool showPrintButton;
        //protected bool showCancelSummaryButton;

        protected bool ExpandSearchCriteria;
        protected bool ExpandAdvancedSearchCriteria;
        protected bool ExpandSelectedReports;

        protected bool ShowCriteria;
        protected bool ShowSelectedReports;
        protected bool ShowReportData;
        protected bool ShowSummaryData;

        protected bool DisableSearchButton;
        protected bool DisableAdminLevelTimeIntervalDropDowns;
        protected bool DisableRemoveButton;

        protected AggregateReportSearchViewModel Model;
        protected IEnumerable<BaseReferenceViewModel> TimeIntervalUnits;
        protected IEnumerable<BaseReferenceViewModel> AdminLevelUnits;

        #endregion Protected and Public Fields

        #region Private Fields and Properties

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Private Fields and Properties

        #region Parameters

        [Parameter] public SearchModeEnum Mode { get; set; }

        [Parameter] public string CallbackUrl { get; set; }

        [Parameter] public long? CallbackKey { get; set; }

        #endregion Parameters

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            //wire up dialog events
            //DiagService.OnClose += DialogClose;

            //initialize model
            InitializeModelAsync();

            //set grid for not loaded
            IsLoading = false;

            //set up the accordions
            ShowCriteria = true;
            ExpandSearchCriteria = true;
            ShowSelectedReports = false;
            ShowReportData = false;
            ShowSummaryData = false;
            SetButtonStates();

            await base.OnInitializedAsync();

            _logger = Logger;
        }

        //protected void DialogClose(dynamic result)
        //{
        //    if (result is DialogReturnResult)
        //    {
        //        var dialogResult = result as DialogReturnResult;

        //        if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
        //        {
        //            //cancel search and user said yes
        //            source?.Cancel();
        //            ResetSearch();
        //        }
        //        if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
        //        {
        //            //cancel search but user said no
        //            source?.Cancel();
        //        }
        //        if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoPrint")
        //        {
        //            //this is the enter parameter dialog
        //            //do nothing, just let the user continue entering search criteria
        //        }
        //        if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoCriteria")
        //        {
        //            //this is the enter parameter dialog
        //            //do nothing, just let the user continue entering search criteria
        //        }
        //        if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NarrowSearch")
        //        {
        //            //search timed out, narrow search criteria
        //            source?.Cancel();
        //            //showResults = false;
        //            expandSelectedReports = false;
        //            showCriteria = true;
        //            expandSearchCriteria = true;
        //            SetButtonStates();
        //        }
        //    }
        //    else
        //    {
        //        //DiagService.Close(result);

        //        source?.Dispose();
        //    }

        //    SetButtonStates();
        //}

        protected void ResetSearch()
        {
            //initialize new model with defaults
            InitializeModelAsync();

            //set grid for not loaded
            //isLoading = false;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            //set up the accordions and buttons
            ShowCriteria = true;
            ExpandSearchCriteria = true;
            ExpandAdvancedSearchCriteria = false;
            ExpandSelectedReports = false;
            ShowSelectedReports = false;
            SetButtonStates();
        }

        public void Dispose()
        {
        }

        protected async Task CancelSearch()
        {
            var buttons = new List<DialogButton>();
            var yesButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                ButtonType = DialogButtonType.Yes
            };
            var noButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                ButtonType = DialogButtonType.Yes
            };
            buttons.Add(yesButton);
            buttons.Add(noButton);

            var options = new DialogOptions
            {
                Height = "auto;"
            };

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                }
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(
                Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams, options);

            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText ==
                Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                //cancel search and user said yes
                _source?.Cancel();
                shouldRender = false;
                var uri = $"{NavManager.BaseUri}Administration/Dashboard";
                NavManager.NavigateTo(uri, true);
            }
            else
            {
                //cancel search but user said no so leave everything alone and cancel thread
                _source?.Cancel();
            }
        }

        protected void AccordionClick(int index)
        {
            ExpandSelectedReports = index switch
            {
                //search results toggle
                0 => !ExpandSelectedReports,
                _ => ExpandSelectedReports
            };
            SetButtonStates();
        }

        #endregion Lifecycle Methods

        #region Protected Methods and Delegates

        protected void HandleValidSearchSubmit(AggregateReportSearchViewModel model)
        {
            if (Form.IsValid) Form.EditContext.IsModified();
            //SetButtonStates();
            //if (_grid != null)
            //{
            //    await _grid.Reload();
            //}
            //no search criteria entered - display the EIDSS dialog component
            //await ShowNoSearchCriteriaDialog();
        }

        protected async Task HandleInvalidSearchSubmit(FormInvalidSubmitEventArgs args)
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            //TODO - display the validation Errors on the dialog?
            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.FieldIsInvalidValidRangeIsMessage)
                }
            };
            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading),
                dialogParams);
        }

        protected async Task GetTimeIntervalUnitAsync(LoadDataArgs args)
        {
            TimeIntervalUnits = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.StatisticalPeriodType, HACodeList.NoneHACode);
            if (!IsNullOrEmpty(args.Filter))
            {
                var toList = TimeIntervalUnits.Where(c =>
                    c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                TimeIntervalUnits = toList;
            }

            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetAdminLevelUnitAsync(LoadDataArgs args)
        {
            AdminLevelUnits = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.StatisticalAreaType, HACodeList.NoneHACode);
            if (!IsNullOrEmpty(args.Filter))
            {
                var toList = AdminLevelUnits.Where(c =>
                    c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                AdminLevelUnits = toList;
            }

            await InvokeAsync(StateHasChanged);
        }

        public void EnableSearchButton()
        {
            var adminLevelId = Model.SearchCriteria.AdministrativeUnitTypeID;
            var timeIntervalTypeId = Model.SearchCriteria.TimeIntervalTypeID;

            if (adminLevelId == null || timeIntervalTypeId == null)
            {
                DisableSearchButton = true;
                return;
            }

            if (IsNullOrEmpty(adminLevelId.ToString()))
            {
                DisableSearchButton = true;
                return;
            }

            if (IsNullOrEmpty(timeIntervalTypeId.ToString()))
            {
                DisableSearchButton = true;
                return;
            }

            DisableSearchButton = false;
        }

        #endregion Protected Methods and Delegates

        #region Search modal

        protected async Task OpenSearchModal()
        {
            //if (searchSubmitted)
            //{
            try
            {
                var adminLevelId = Model.SearchCriteria.AdministrativeUnitTypeID;
                var timeIntervalTypeId = Model.SearchCriteria.TimeIntervalTypeID;
                var selectedReportsShow = ExpandSelectedReports;

                //var dialogParams = new Dictionary<string, object>();

                var result = await DiagService.OpenAsync<SearchHumanAggregateDiseaseReportSummary>(
                    Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportDiseaseReportSummaryHeading),
                    new Dictionary<string, object>
                    {
                        {"ReportType", AggregateDiseaseReportTypes.HumanAggregateDiseaseReport}, {"SearchModel", Model}
                    },
                    new DialogOptions {Width = "1000px", Resizable = true, Draggable = false});

                if (result == null) return;

                if (result is DialogReturnResult dialogResult)
                {
                    if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.SelectButton) ||
                        dialogResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.SelectAllButton))
                    {
                        ExpandSelectedReports = true;
                        DisableAdminLevelTimeIntervalDropDowns = true;
                        ShowSelectedReports = true;
                    }

                    if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (selectedReportsShow)
                        {
                            ExpandSelectedReports = true;
                            DisableAdminLevelTimeIntervalDropDowns = true;
                            ShowSelectedReports = true;
                            Model.SearchCriteria.AdministrativeUnitTypeID = adminLevelId;
                            Model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeId;
                            DisableSearchButton = false;
                        }
                        else
                        {
                            Model.SearchCriteria.AdministrativeUnitTypeID = adminLevelId;
                            Model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeId;
                            EnableSearchButton();
                            return;
                        }
                    }
                }

                SetButtonStates();

                //await InvokeAsync(StateHasChanged);
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
            var adminLevelId = Model.SearchCriteria.AdministrativeUnitTypeID;
            var timeIntervalTypeId = Model.SearchCriteria.TimeIntervalTypeID;

            var buttons = new List<DialogButton>();
            var yesButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                ButtonType = DialogButtonType.Yes
            };
            var noButton = new DialogButton
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                ButtonType = DialogButtonType.Yes
            };
            buttons.Add(yesButton);
            buttons.Add(noButton);

            var options = new DialogOptions
            {
                Height = "auto;"
            };

            var dialogParams = new Dictionary<string, object>
            {
                {nameof(EIDSSDialog.DialogButtons), buttons},
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                }
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(
                Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams, options);

            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText ==
                Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                AggregateDiseaseReportSummaryService.SearchReports = null;
                AggregateDiseaseReportSummaryService.SelectedReports = null;

                Model.SearchCriteria.AdministrativeUnitTypeID = adminLevelId;
                Model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeId;
                EnableSearchButton();

                DisableAdminLevelTimeIntervalDropDowns = false;
                ExpandSelectedReports = false;
                ShowSelectedReports = false;
                ShowSummaryData = false;

                ResetSearch();

                await InvokeAsync(StateHasChanged);
            }
            else
            {
                //cancel search but user said no so leave everything alone and cancel thread
                _source?.Cancel();
            }
        }

        protected async Task OnRemoveAsync(long id)
        {
            try
            {
                IList<AggregateReportGetListViewModel> list = AggregateDiseaseReportSummaryService.SelectedReports
                    .Where(report => id != report.ReportKey).ToList();

                AggregateDiseaseReportSummaryService.SelectedReports = list;
                await Grid.Reload();

                if (AggregateDiseaseReportSummaryService.SelectedReports.Count == 0)
                {
                    AggregateDiseaseReportSummaryService.SearchReports = null;
                    AggregateDiseaseReportSummaryService.SelectedReports = null;

                    DisableAdminLevelTimeIntervalDropDowns = false;
                    ShowSummaryData = false;
                    ShowCancelButton = true;
                    ShowCancelSelectedReportsButton = false;
                    ShowRemoveAllButton = false;
                    ShowSummaryDataButton = false;
                    ShowSelectedReports = false;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected void ShowReportDataLinkAsync(long? id)
        {
            var uri = $"{NavManager.BaseUri}Human/AggregateDiseaseReport/DetailsReviewPage?id=" + id;
            NavManager.NavigateTo(uri, true);
        }

        private async Task LoadFlexFormsAsync(DiseaseMatrixSectionViewModel model)
        {
            model.AggregateCase.MatrixColumns = new List<string>
            {
                Localizer.GetString(FieldLabelResourceKeyConstants.HumanAggregateDiseaseReportSummaryDiseaseFieldLabel),
                Localizer.GetString(
                    FieldLabelResourceKeyConstants.HumanAggregateDiseaseReportSummaryICD10CodeFieldLabel)
            };
            model.AggregateCase.Title =
                Empty; // Localizer.GetString(HeadingResourceKeyConstants.SummaryAggregateSettingsHeading);
            model.AggregateCase.LangID = GetCurrentLanguage();
            model.AggregateCase.idfsFormType = (long) FlexibleFormTypes.HumanAggregate;

            HumanAggregateCaseMatrixGetRequestModel request = new()
            {
                IdfVersion = (long) model.idfVersion,
                PageSize = 1000,
                Page = 1,
                SortOrder = "asc",
                SortColumn = "intNumRow",
                LanguageId = GetCurrentLanguage()
            };

            var lstRow = await HumanAggregateDiseaseMatrixClient.GetHumanAggregateDiseaseMatrixList(request);

            model.AggregateCase.MatrixData = new List<FlexFormMatrixData>();

            foreach (var row in lstRow)
            {
                var matrixData = new FlexFormMatrixData
                {
                    MatrixData = new List<string>(),

                    idfRow = row.IdfHumanCaseMTX
                };
                matrixData.MatrixData.Add(row.StrDefault);
                matrixData.MatrixData.Add(row.StrIDC10);
                model.AggregateCase.MatrixData.Add(matrixData);
            }

            FlexFormMatrixModel = model;
        }

        protected void OnRemoveAll()
        {
            AggregateDiseaseReportSummaryService.SearchReports = null;
            AggregateDiseaseReportSummaryService.SelectedReports = null;
            DisableAdminLevelTimeIntervalDropDowns = false;
            ShowSummaryData = false;
            ShowCancelButton = true;
            ShowCancelSelectedReportsButton = false;
            ShowRemoveAllButton = false;
            ShowSummaryDataButton = false;
            ShowSelectedReports = false;
        }

        #endregion Selected Reports

        #region Summary

        protected void CancelSummarySearch()
        {
            ExpandSelectedReports = true;
            ShowSelectedReports = true;
            ShowSummaryData = false;
            SetButtonStates();
        }

        protected async Task PrintReport()
        {
            try
            {
                if (AggregateDiseaseReportSummaryService.SelectedReports is {Count: > 0})
                {
                    var aggregateReportIds = Join(";",
                        AggregateDiseaseReportSummaryService.SelectedReports.Select(x => x.ReportKey.ToString()));
                    _ = authenticatedUser//TODO: remove commented if session-User approach works//ConfigurationService.GetUserToken()
                        .Organization;

                    var reportTitle = Localizer.GetString(HeadingResourceKeyConstants
                        .HumanAggregateDiseaseReportSummaryHumanAggregateDiseaseReportsSummaryHeading);

                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("idfsAggrCaseType", ((long) FlexibleFormTypes.HumanAggregate).ToString());
                    reportModel.AddParameter("idfAggrCaseList", aggregateReportIds);
                    reportModel.AddParameter("SiteID", authenticatedUser.SiteId);
                    reportModel.AddParameter("AdministrativeLevel",
                        AggregateDiseaseReportSummaryService.SelectedReports.FirstOrDefault()
                            ?.AdministrativeUnitTypeName);

                    await DiagService.OpenAsync<DisplayReport>(
                        reportTitle,
                        new Dictionary<string, object>
                        {
                            {"ReportName", "HumanAggregateDiseaseSummaryReport"},
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

        protected async Task OnShowSummaryDataAsync()
        {
            var observationList = Empty;
            DiseaseMatrixSectionViewModel diseaseMatrixSectionViewModel = new();
            var matrixVersionList = await CrossCuttingClient.GetMatrixVersionsByType(MatrixTypes.HumanAggregateCase);
            var version = matrixVersionList.Find(v => v.BlnIsActive == true)?.IdfVersion.ToString();
            if (version != null) diseaseMatrixSectionViewModel.idfVersion = long.Parse(version);

            foreach (var report in AggregateDiseaseReportSummaryService.SelectedReports)
            {
                diseaseMatrixSectionViewModel.AggregateCase =
                    await GetFlexFormQuestionnaireGetRequestModelAsync(report.ReportKey);
                if (IsNullOrEmpty(observationList))
                    observationList = diseaseMatrixSectionViewModel.AggregateCase.idfObservation.ToString();
                else
                    observationList += ";" + diseaseMatrixSectionViewModel.AggregateCase.idfObservation;
            }

            if (AggregateDiseaseReportSummaryService.SelectedReports is {Count: > 0})
            {
                diseaseMatrixSectionViewModel.AggregateCase.observationList = observationList;

                ShowReportData = false;
                ShowSummaryData = true;
                ShowSelectedReports = true;
                ExpandSelectedReports = false;

                SetButtonStates();

                await LoadFlexFormsAsync(diseaseMatrixSectionViewModel);
            }
        }

        private async Task<FlexFormQuestionnaireGetRequestModel> GetFlexFormQuestionnaireGetRequestModelAsync(long id)
        {
            FlexFormQuestionnaireGetRequestModel model = new();

            var detailRequest = new AggregateReportGetListDetailRequestModel
            {
                LanguageID = GetCurrentLanguage(),
                idfsAggrCaseType = (long) AggregateDiseaseReportTypes.HumanAggregateDiseaseReport,
                idfAggrCase = id,
                ApplyFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId)
            };
            var response = await AggregateDiseaseReportClient.GetAggregateReportDetail(detailRequest, _token);
            if (response.Count <= 0) return model;
            model.idfsFormTemplate = response[0].idfsCaseFormTemplate;
            model.idfObservation = response[0].idfCaseObservation;

            return model;
        }

        #endregion Summary

        #region Private Methods

        private void InitializeModelAsync()
        {
            DisableSearchButton = true;
            DisableAdminLevelTimeIntervalDropDowns = false;

            Model = new AggregateReportSearchViewModel
            {
                SearchCriteria = new AggregateReportSearchRequestModel(),
                Permissions = GetUserPermissions(PagePermission.AccessToHumanAggregateDiseaseReports),
                RecordSelectionIndicator = true
            };
            Model.SearchCriteria.SortColumn = "ReportID";
            Model.SearchCriteria.SortOrder = SortConstants.Descending;
            Model.SearchCriteria.StartDate = null;
            Model.SearchCriteria.EndDate = null;
            Model.SearchLocationViewModel = new LocationViewModel
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
            if (ExpandSelectedReports)
            {
                ShowCancelButton = false;
                ShowCancelSelectedReportsButton = true;
                ShowSearchButton = true;
                ShowRemoveAllButton = true;
                ShowSummaryDataButton = true;
            }
            else if (ShowSummaryData)
            {
                ShowCancelButton = false;
                ShowCancelSelectedReportsButton = false;
                ShowSearchButton = false;
                ShowRemoveAllButton = false;
                ShowSummaryDataButton = false;
            }
            else
            {
                ShowCancelButton = true;
                ShowCancelSelectedReportsButton = false;
                ShowSearchButton = true;
                ShowRemoveAllButton = false;
                ShowSummaryDataButton = false;
            }

            if (!Model.Permissions.Delete)
                DisableRemoveButton = true;
        }

        #endregion Private Methods
    }
}