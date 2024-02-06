using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Reports;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Shared.ViewModels;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.FlexForm;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

namespace EIDSS.Web.Components.Veterinary.AggregateDiseasesReportSummary
{
    public class AggregateDiseasesReportSummaryBase : AggregateDiseaseReportSummaryBaseComponent, IDisposable
    {
        #region Dependency Injection

        [Inject]
        private IAggregateReportClient AggregateReportClient { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IVeterinaryAggregateDiseaseMatrixClient VeterinaryAggregateDiseaseMatrixClient { get; set; }

        [Inject]
        private ILogger<AggregateDiseasesReportSummaryBase> Logger { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private IReportCrossCuttingClient ReportingClient { get; set; }

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

        public DiseaseMatrixSectionViewModel FlexFormMatrixModel { get; set; }

        protected FlexFormMatrix VetAggDiseaseFlexForm { get; set; }

        protected AggregateSummaryPageViewModel DiseaseReportModel { get; set; }

        public string ReportLabel { get; set; }

        #endregion Protected and Public Fields

        #region Private Fields and Properties

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Private Fields and Properties

        #region Parameters

        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public long? CallbackKey { get; set; }

        #endregion Parameters

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

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
            var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams, options);

            var dialogResult = result as DialogReturnResult;
            if (dialogResult?.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
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

        #region Search

        protected void HandleValidSearchSubmit(AggregateReportSearchViewModel model)
        {
            if (!Form.IsValid) return;
            Form.EditContext.IsModified();
        }

        protected async Task HandleInvalidSearchSubmit(FormInvalidSubmitEventArgs args)
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton()
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
            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
        }

        #endregion Search

        #region Load Drop Down Data

        protected async Task GetTimeIntervalUnitAsync(LoadDataArgs args)
        {
            TimeIntervalUnits = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.StatisticalPeriodType, HACodeList.NoneHACode);
            if (!IsNullOrEmpty(args.Filter))
            {
                var toList = TimeIntervalUnits.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                TimeIntervalUnits = toList;
            }
            await InvokeAsync(StateHasChanged);
        }

        protected async Task GetAdminLevelUnitAsync(LoadDataArgs args)
        {
            AdminLevelUnits = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.StatisticalAreaType, HACodeList.NoneHACode);
            if (!IsNullOrEmpty(args.Filter))
            {
                var toList = AdminLevelUnits.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                AdminLevelUnits = toList;
            }
            await InvokeAsync(StateHasChanged);
        }

        #endregion Load Drop Down Data

        #region Toggle Search

        public void EnableSearchButton()
        {
            var adminLevelID = Model.SearchCriteria.AdministrativeUnitTypeID;
            var timeIntervalTypeID = Model.SearchCriteria.TimeIntervalTypeID;

            if (adminLevelID == null || timeIntervalTypeID == null)
            {
                DisableSearchButton = true;
                return;
            }

            if (IsNullOrEmpty(adminLevelID.ToString()))
            {
                DisableSearchButton = true;
                return;
            }

            if (IsNullOrEmpty(timeIntervalTypeID.ToString()))
            {
                DisableSearchButton = true;
                return;
            }

            DisableSearchButton = false;
        }

        #endregion Toggle Search

        #region Print

        [JSInvokable("OnPrint")]
        protected async Task PrintReport()
        {
            try
            {
                if (AggregateDiseaseReportSummaryService.SelectedReports is { Count: > 0 })
                {
                    var aggregateReportIds = Join(";",
                        AggregateDiseaseReportSummaryService.SelectedReports.Select(x => x.ReportKey.ToString()));
                    //TODO: remove commented if session-User approach works//var organization = ConfigurationService.GetUserToken().Organization;
                    //TODO: consider usage of _tokenService.GetAuthenticatedUser().Organization
                    var organization = authenticatedUser.Organization;

                    var reportTitle = Localizer.GetString(HeadingResourceKeyConstants
                        .VeterinaryAggregateDiseaseReportSummaryPageHeading);

                    ReportViewModel reportModel = new();
                    reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                    reportModel.AddParameter("LangID", GetCurrentLanguage());
                    reportModel.AddParameter("idfsAggrCaseType", ((long)FlexibleFormTypes.VeterinaryAggregate).ToString());
                    reportModel.AddParameter("idfAggrCaseList", aggregateReportIds);
                    reportModel.AddParameter("SiteID", authenticatedUser.SiteId);
                    reportModel.AddParameter("AdministrativeLevel", AggregateDiseaseReportSummaryService.SelectedReports.FirstOrDefault()?.AdministrativeUnitTypeName);

                    await DiagService.OpenAsync<DisplayReport>(
                        reportTitle,
                        new Dictionary<string, object>
                        {
                            {"ReportName", "VeterinaryAggregateDiseaseSummaryReport"},
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

        #endregion Print

        #region Search modal

        protected async Task OpenSearchModal()
        {
            try
            {
                var adminLevelID = Model.SearchCriteria.AdministrativeUnitTypeID;
                var timeIntervalTypeID = Model.SearchCriteria.TimeIntervalTypeID;
                var SelectedReportsShow = ExpandSelectedReports;

                var result = await DiagService.OpenAsync<SearchAggregateDiseaseReportSummary>(Localizer.GetString(HeadingResourceKeyConstants.VeterinaryAggregateDiseaseReportSummarySearchHeading),
                    new Dictionary<string, object> { { "ReportType", AggregateDiseaseReportTypes.VeterinaryAggregateDiseaseReport }, { "SearchModel", Model } },
                    new DialogOptions
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
                        ExpandSelectedReports = true;
                        DisableAdminLevelTimeIntervalDropDowns = true;
                        ShowSelectedReports = true;
                    }

                    if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (SelectedReportsShow)
                        {
                            ExpandSelectedReports = true;
                            DisableAdminLevelTimeIntervalDropDowns = true;
                            ShowSelectedReports = true;
                            Model.SearchCriteria.AdministrativeUnitTypeID = adminLevelID;
                            Model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeID;
                            DisableSearchButton = false;
                        }
                        else
                        {
                            Model.SearchCriteria.AdministrativeUnitTypeID = adminLevelID;
                            Model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeID;
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
        }

        #endregion Search modal

        #region Selected Reports

        protected async void CancelSelectedReports()
        {
            var adminLevelID = Model.SearchCriteria.AdministrativeUnitTypeID;
            var timeIntervalTypeID = Model.SearchCriteria.TimeIntervalTypeID;

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
                { nameof(EIDSSDialog.DialogButtons), buttons },
                {
                    nameof(EIDSSDialog.Message),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                }
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams, options);

            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
            {
                AggregateDiseaseReportSummaryService.SearchReports = null;
                AggregateDiseaseReportSummaryService.SelectedReports = null;

                Model.SearchCriteria.AdministrativeUnitTypeID = adminLevelID;
                Model.SearchCriteria.TimeIntervalTypeID = timeIntervalTypeID;
                EnableSearchButton();

                DisableAdminLevelTimeIntervalDropDowns = false;
                ExpandSelectedReports = false;
                ShowSelectedReports = false;
                ShowSummaryData = false;
                ShowReportData = false;

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
                IList<AggregateReportGetListViewModel> list = new List<AggregateReportGetListViewModel>();

                foreach (var report in AggregateDiseaseReportSummaryService.SelectedReports)
                {
                    if (id != report.ReportKey)
                        list.Add(report);
                }

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

        protected async Task ShowReportDataLinkAsync(long? id, string reportId)
        {
            ShowReportData = false;
            StateHasChanged();

            await LoadAggregateReport(id, reportId);
        }

        protected async Task LoadAggregateReport(long? id, string reportId)
        {
            DiseaseMatrixSectionViewModel matrixSectionViewModel = new();

            var matrixVersionList = await CrossCuttingClient.GetMatrixVersionsByType(MatrixTypes.VetAggregateCase);
            if (matrixVersionList.Count > 0 && matrixVersionList.Find(v => v.BlnIsActive == true) != null)
            {
                var strId = matrixVersionList.Find(v => v.BlnIsActive == true)?.IdfVersion.ToString();

                if (id != null)
                    matrixSectionViewModel.AggregateCase = await GetFlexFormQuestionnaireGetRequestModelAsync((long)id);
                if (strId != null)
                    matrixSectionViewModel.idfVersion =
                        matrixSectionViewModel.AggregateCase.idfVersion ?? long.Parse(strId);

                if (matrixSectionViewModel.AggregateCase.idfObservation != null)
                {
                    ReportLabel = Localizer.GetString(HeadingResourceKeyConstants.VeterinaryAggregateDiseaseReportPageHeading) + " - " + reportId;

                    matrixSectionViewModel.AggregateCase.SubmitButtonID = "btnSubmit";
                    matrixSectionViewModel.AggregateCase.ObserationFieldID = "idfCaseObservation";
                    await LoadFlexFormsAsync(matrixSectionViewModel);
                }
            }

            ShowReportData = true;
            ShowSummaryData = false;
            ShowSelectedReports = true;
            ExpandSelectedReports = false;

            SetButtonStates();

            await InvokeAsync(StateHasChanged);
        }

        protected void OnRemoveAll()
        {
            AggregateDiseaseReportSummaryService.SearchReports = null;
            AggregateDiseaseReportSummaryService.SelectedReports = null;
            //IList<AggregateDiseaseReportGetListViewModel> list = new List<AggregateDiseaseReportGetListViewModel>();
            //AggregateDiseaseReportSummaryService.SelectedReports = list;
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
            ShowReportData = false;
            SetButtonStates();
        }

        protected async Task OnShowSummaryDataAsync()
        {
            var caseList = GetSelectedReportsCaseList();
            DiseaseReportModel = await GetDiseaseReportModel(caseList);

            ShowReportData = false;
            ShowSummaryData = true;
            ShowSelectedReports = true;
            ExpandSelectedReports = false;

            SetButtonStates();

            await InvokeAsync(StateHasChanged);
        }

        private async Task<FlexFormQuestionnaireGetRequestModel> GetFlexFormQuestionnaireGetRequestModelAsync(long id)
        {
            FlexFormQuestionnaireGetRequestModel getRequestModel = new();

            var detailRequest = new AggregateReportGetListDetailRequestModel
            {
                LanguageID = GetCurrentLanguage(),
                idfAggrCase = id,
                idfsAggrCaseType = (long)AggregateDiseaseReportTypes.VeterinaryAggregateDiseaseReport,
                ApplyFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId)
            };
            var response = await AggregateReportClient.GetAggregateReportDetail(detailRequest, _token);
            if (response.Count <= 0) return getRequestModel;
            getRequestModel.idfsFormTemplate = response[0].idfsCaseFormTemplate;
            getRequestModel.idfObservation = response[0].idfCaseObservation;
            getRequestModel.idfVersion = response[0].idfVersion;

            return getRequestModel;
        }

        private async Task<AggregateSummaryPageViewModel> GetDiseaseReportModel(string caseList)
        {
            var diseaseReportModel = new AggregateSummaryPageViewModel();

            var request = new AggregateSummaryRequestModel
            {
                LangID = GetCurrentLanguage(),
                idfAggrCaseList = caseList
            };

            diseaseReportModel.AggregateSummaryRecords = await ReportingClient.GetVeterinaryAggregateReportDetail(request, _token);
            diseaseReportModel.MatrixColumnHeadings = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SpeciesColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.OIECodeColumnHeading)
            };
            diseaseReportModel.Title = Empty;
            diseaseReportModel.DisplayFields = new Dictionary<string, int>
            {
                { "strDefault", 0 },
                { "strSpecies", 1 },
                { "strOIECode", 2 }
            };

            return diseaseReportModel;
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
                Permissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateDiseaseReports),
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

        private async Task LoadFlexFormsAsync(DiseaseMatrixSectionViewModel model)
        {
            model.AggregateCase.MatrixColumns = new List<string>
            {
                Localizer.GetString(ColumnHeadingResourceKeyConstants.ConfigureVeterinaryAggregateReportMatrixDiseaseColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.SpeciesColumnHeading),
                Localizer.GetString(ColumnHeadingResourceKeyConstants.OIECodeColumnHeading)
            };

            model.AggregateCase.Title = Empty;
            model.AggregateCase.LangID = GetCurrentLanguage();
            model.AggregateCase.idfsFormType = (long)FlexibleFormTypes.VeterinaryAggregate;

            var lstDiseases = await CrossCuttingClient.GetVeterinaryDiseaseMatrixListAsync(EIDSSConstants.ReferenceEditorType.Disease, HACodeList.LiveStockAndAvian, GetCurrentLanguage());
            var lstSpecies = await CrossCuttingClient.GetSpeciesListAsync(EIDSSConstants.ReferenceEditorType.SpeciesList, HACodeList.LiveStockAndAvian, GetCurrentLanguage());

            var lstRow = await VeterinaryAggregateDiseaseMatrixClient.GetVeterinaryAggregateDiseaseMatrixListAsync(model.AggregateCase.idfVersion.ToString(), GetCurrentLanguage());

            model.AggregateCase.MatrixData = new List<FlexFormMatrixData>();

            foreach (var row in lstRow)
            {
                if (row.IdfAggrVetCaseMTX == null) continue;
                var matrixData = new FlexFormMatrixData
                {
                    MatrixData = new List<string>(),
                    idfRow = (long)row.IdfAggrVetCaseMTX
                };

                //matrixData.MatrixData.Add(row.StrDefault);  // for Disease
                matrixData.MatrixData.Add(lstDiseases.Find(v => v.IdfsBaseReference == row.IdfsDiagnosis)?.StrDefault);
                matrixData.MatrixData.Add(lstSpecies.Find(v => v.IdfsBaseReference == row.IdfsSpeciesType)?.StrDefault);
                matrixData.MatrixData.Add(row.StrOIECode);
                model.AggregateCase.MatrixData.Add(matrixData);
            }

            FlexFormMatrixModel = model;
        }

        protected string GetSelectedReportsCaseList()
        {
            var caseList = Empty;

            //generate the list of diseases and positive quantity for this aggregate collection
            if (AggregateDiseaseReportSummaryService.SelectedReports is null) return caseList;

            var selectedReports = AggregateDiseaseReportSummaryService.SelectedReports.ToList();
            var i = selectedReports.Count;
            foreach (var item in selectedReports)
            {
                var separator = i > 1 ? ";" : Empty;
                caseList += $"{item.ReportKey}{separator}";
                i--;
            }

            return caseList;
        }

        #endregion Private Methods
    }
}