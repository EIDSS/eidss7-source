using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Areas.Human.ViewModels.ActiveSurveillanceSession;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Human.ActiveSurveillanceSession
{
    public class TestsBase : ParentComponent, IDisposable
    {
        #region Grid

        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }

        public CrossCutting.GridExtensionBase GridExtension { get; set; }

        #endregion Grid

        #region Globals

        [Parameter]
        public ActiveSurveillanceSessionViewModel model { get; set; }

        private CancellationTokenSource source;
        private CancellationToken token;
        protected bool isLoading;
        protected int count;

        protected RadzenDataGrid<ActiveSurveillanceSessionTestsResponseModel> _testsGrid;

        #region Dependencies

        [Inject]
        private ILogger<TestsBase> Logger { get; set; }

        [Inject]
        private DialogService DialogService { get; set; }

        [Inject]
        private IHumanActiveSurveillanceSessionClient _humanActiveSurveillanceSessionClient { get; set; }

        [Inject]
        private ITestNameTestResultsMatrixClient TestNameTestResultsMatrixClient { get; set; }

        #endregion Dependencies

        #endregion Globals

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            GridContainerServices.OnChange += async (property) => await StateContainerChangeAsync(property);

            await base.OnInitializedAsync();
        }

        protected async Task LoadTestsGridView(LoadDataArgs args, bool bInitialLoad = true)
        {
            try
            {
                isLoading = true;

                if (bInitialLoad)
                {
                    var request = new ActiveSurveillanceSessionTestsRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        idfMonitoringSession = IdfMonitoringSession,
                        Page = 1,
                        PageSize = 10,
                        SortColumn = "ResultDate",
                        SortOrder = "asc"
                    };

                    model.TestsInformation.List = await _humanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionTests(request, token);

                    foreach (var test in model.TestsInformation.List)
                    {
                        test.OriginalTestResultTypeID = test.TestResultID;
                    }

                    model.TestsInformation.UnfilteredList = model.TestsInformation.List;
                }

                _testsGrid.Reset();
                count = model.TestsInformation.List?.Count ?? 0;
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                //catch cancellation or timeout exception
                if (source?.IsCancellationRequested == true)
                {
                }
                else
                {
                    throw;
                }
            }
            finally
            {
                isLoading = false;
                await InvokeAsync(StateHasChanged);
            }
            //initialize the grid so that it displays 'No records message'
            isLoading = false;
        }

        public async Task EditTest(object args)
        {
            try
            {
                await ClearTestModal(false);

                var test = (ActiveSurveillanceSessionTestsResponseModel)args;

                model.TestsInformation.ID = long.Parse(test.ID.ToString());
                model.TestsInformation.FieldSampleID = test.FieldSampleID;
                model.TestsInformation.TestStatus = test.TestStatus;
                model.TestsInformation.TestStatusID = long.Parse(test.TestStatusID.ToString());
                model.TestsInformation.LabSampleID = test.LabSampleID;
                model.TestsInformation.TestCategoryID = test.TestCategoryID;
                model.TestsInformation.ResultDate = test.ResultDate;
                model.TestsInformation.TestNames = new List<ActiveSurveillanceSessionTestNamesResponseModel>();
                model.TestsInformation.TestNameID = test.TestNameID;
                model.TestsInformation.TestResults = new List<TestNameTestResultsMatrixViewModel>();
                model.TestsInformation.TestResultID = test.TestResultID;
                model.TestsInformation.SampleType = test.SampleType;
                model.TestsInformation.PersonID = long.Parse(test.PersonID.ToString());
                model.TestsInformation.EIDSSPersonID = test.EIDSSPersonID;

                model.TestsInformation.TestDiseaseID = long.Parse(test.DiseaseID.ToString());

                var testNamesRequest = new ActiveSurveillanceSessionTestNameRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    DiseaseIDList = test.DiseaseID.ToString(),
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "TestNameTypeName",
                    SortOrder = SortConstants.Descending
                };

                var response = await _humanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionTestNames(testNamesRequest, token);

                if (response.FirstOrDefault(r => r.TestNameTypeID == model.TestsInformation.TestNameID) == null)
                {
                    testNamesRequest.DiseaseIDList = null;
                    response = await _humanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionTestNames(testNamesRequest, token);
                    model.TestsInformation.FilterByDisease = false;
                }

                model.TestsInformation.TestNames = response.AsEnumerable();

                var testResultsRequest = new TestNameTestResultsMatrixGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsTestName = test.TestNameID,
                    idfsTestResultRelation = BaseReferenceTypeIds.LabTest,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "strTestResultDefault",
                    SortOrder = SortConstants.Ascending,
                };

                model.TestsInformation.TestResults = await TestNameTestResultsMatrixClient.GetTestNameTestResultsMatrixList(testResultsRequest);

                dynamic result = await DialogService.OpenAsync<TestDetailsModal>(Localizer.GetString(HeadingResourceKeyConstants.TestDetailsModalHeading),
                        new Dictionary<string, object>()
                        {
                            { "model", model }
                        },
                        new DialogOptions()
                        {
                            Width = CSSClassConstants.DefaultDialogWidth,
                            AutoFocusFirstElement = true,
                            CloseDialogOnOverlayClick = true,
                            ShowClose = true,
                            Resizable = true,
                            Draggable = false
                        });

                await LoadTestsGridView(null, false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task OpenTestModal(object args)
        {
            try
            {
                await ClearTestModal(true);

                if (model.DetailedInformation.List.Count == 1)
                {
                    model.TestsInformation.FieldSampleID = model.DetailedInformation.List[0].FieldSampleID;
                }

                var result = await DialogService.OpenAsync<TestDetailsModal>(Localizer.GetString(HeadingResourceKeyConstants.TestDetailsModalHeading),
                    new Dictionary<string, object>()
                    {
                        { "model", model }
                    },
                    new DialogOptions()
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = true,
                        ShowClose = true,
                        Resizable = true,
                        Draggable = false,
                    });

                await LoadTestsGridView(null, false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task OnPrintTestsButtonClick()
        {
            try
            {
                // Reset the cancellation token
                source = new CancellationTokenSource();
                token = source.Token;

                string fullName =
                    $"{authenticatedUser.FirstName} {authenticatedUser.SecondName} {authenticatedUser.LastName}";

                ReportViewModel reportModel = new();
                // required parameters N.B.(Every report needs these three)
                reportModel.AddParameter("LangID", GetCurrentLanguage());
                reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                reportModel.AddParameter("SiteID", authenticatedUser.SiteId);

                //reportModel.AddParameter("IncludeSignature", null);
                reportModel.AddParameter("UserFullName", fullName);
                reportModel.AddParameter("UserOrganization", authenticatedUser.Organization);
                reportModel.AddParameter("ObjID", IdfMonitoringSession.ToString());

                //reportModel.AddParameter("ReportTitle",Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTestResultReportHeading));

                // generate Avian report
                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportTestsDetailHeading),
                    new Dictionary<string, object>
                        {{"ReportName", "HumanActiveSurveillanceSessionLabTests"}, {"Parameters", reportModel.Parameters}},
                    new DialogOptions
                    {
                        Style = EIDSSConstants.LaboratoryModuleTabConstants.Testing,
                        Left = "150",
                        Resizable = true,
                        Draggable = false,
                        Width = "1150px"
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task DeleteRow(object value)
        {
            try
            {
                var result = await ShowDeleteConfirmation();

                if (result is not null)
                {
                    if (((DialogReturnResult) result).ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        var test = (ActiveSurveillanceSessionTestsResponseModel) value;

                        if (test.ID > 0)
                        {
                            //model.TestsInformation.List.Remove(test);
                            test = model.TestsInformation.UnfilteredList.First(x => x.ID == test.ID);
                            test.RowAction = EIDSSConstants.UserAction.Delete;
                            test.intRowStatus = 1;

                            model.TestsInformation.List = model.TestsInformation.UnfilteredList
                                .Where(x => x.RowAction != EIDSSConstants.UserAction.Delete).ToList();
                        }
                        else
                        {
                            model.TestsInformation.List.Remove(test);
                        }

                        count = model.TestsInformation.List.Count();
                        StateContainer.SetActiveSurveillanceSessionViewModel(model);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
                await InvokeAsync(StateHasChanged);
            }
        }

        protected void OnLinkDiseaseReportClick(object args)
        {
            try
            {
                var uri = $"{NavManager.BaseUri}Human/HumanDiseaseReport/LoadDiseaseReport?humanId={((ActiveSurveillanceSessionTestsResponseModel)args).HumanMasterID}&idfMonitoringSession={IdfMonitoringSession}&idfTesting={((ActiveSurveillanceSessionTestsResponseModel)args).ID}&isEdit=False&readOnly=false&StartIndex=3";

                NavManager.NavigateTo(uri, true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public void Dispose()
        {
            try
            {
                source?.Cancel();
                source?.Dispose();
            }
            catch (Exception)
            {
                throw;
            }
        }

        #region Grid Reorder

        protected override void OnInitialized()
        {
            GridExtension = new GridExtensionBase();
            GridColumnLoad("ActiveSurveillanceSessionTests");

            base.OnInitialized();
        }

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig = GridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public void GridColumnSave(string columnNameId)
        {
            try
            {
                GridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, _testsGrid.ColumnsCollection.ToDynamicList(), GridContainerServices);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public int FindColumnOrder(string columnName)
        {
            var index = 0;
            try
            {
                index = GridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return index;
        }

        public bool GetColumnVisibility(string columnName)
        {
            bool visible = true;
            try
            {
                visible = GridExtension.GetColumnVisibility(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return visible;
        }

        public void HeaderCellRender(string propertyName)
        {
            try
            {
                GridContainerServices.VisibleColumnList = GridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task StateContainerChangeAsync(string property)
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion Grid Reorder
    }
}