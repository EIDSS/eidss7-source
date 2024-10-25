using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Laboratory
{
    public class AssignTestBase : LaboratoryBaseComponent, IDisposable
    {
        [Inject] private ILogger<AssignTestBase> Logger { get; set; }
        [Inject] private IDiseaseLabTestMatrixClient DiseaseLabTestMatrixClient { get; set; }

        [Parameter] public LaboratoryTabEnum Tab { get; set; }

        public IEnumerable<FilteredDiseaseGetListViewModel> Diseases;
        public List<TestNameTestResultsMatrixViewModel> TestResultTypes { get; set; }
        public AssignTestViewModel Model { get; set; }
        public RadzenTemplateForm<AssignTestViewModel> Form { get; set; }
        public RadzenDataGrid<TestingGetListViewModel> TestsGrid { get; set; }
        public TestingGetListViewModel TestToInsert { get; set; }

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        private const string OpeningParagraphHtmlTag = "<p>";
        private const string ClosingParagraphHtmlTag = "</p>";

        public AssignTestBase(CancellationToken token) : base(token)
        {
        }

        protected AssignTestBase() : base(CancellationToken.None)
        {
        }

        protected override async void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _logger = Logger;

            Model = new AssignTestViewModel
            {
                FilterTestNameByDisease = true,
                PendingSaveTests = new List<TestingGetListViewModel>(),
                Tests = new List<TestingGetListViewModel>(),
                TestNameTypes = new List<BaseReferenceViewModel>(),
                IsSaveDisabled = true,
                Diseases = new List<FilteredDiseaseGetListViewModel>()
            };

            switch (Tab)
            {
                case LaboratoryTabEnum.Samples:
                    foreach (var sample in LaboratoryService.SelectedSamples)
                    {
                        if (string.IsNullOrEmpty(sample.DiseaseID)) continue;
                        if (Model.Diseases?.Find(x => x.DiseaseID.ToString() == sample.DiseaseID) != null) continue;

                        if (sample.DiseaseID.Contains(","))
                        {
                            var diseaseIDsSplit = sample.DiseaseID.Split(",");
                            var diseaseNamesSplit = sample.DiseaseName.Split("|");

                            for (var index = 0; index < diseaseIDsSplit.Length; index++)
                                Model.Diseases?.Add(new FilteredDiseaseGetListViewModel
                                {
                                    DiseaseID = Convert.ToInt64(diseaseIDsSplit[index]),
                                    DiseaseName = diseaseNamesSplit[index]
                                });
                        }
                        else
                        {
                            FilteredDiseaseGetListViewModel disease = new()
                            {
                                DiseaseID = Convert.ToInt64(sample.DiseaseID),
                                DiseaseName = sample.DiseaseName
                            };
                            Model.Diseases?.Add(disease);
                        }
                    }
                    break;
                case LaboratoryTabEnum.Testing:
                    foreach (var test in LaboratoryService.SelectedTesting)
                    {
                        if (Model.Diseases.Find(x => x.DiseaseID == test.DiseaseID) != null) continue;
                        FilteredDiseaseGetListViewModel disease = new()
                        {
                            DiseaseID = Convert.ToInt64(test.DiseaseID),
                            DiseaseName = test.DiseaseName
                        };
                        Model.Diseases.Add(disease);
                    }
                    break;
                case LaboratoryTabEnum.MyFavorites:
                    foreach (var myFavorite in LaboratoryService.SelectedMyFavorites)
                    {
                        if (string.IsNullOrEmpty(myFavorite.DiseaseID)) continue;
                        if (Model.Diseases?.Find(x => x.DiseaseID.ToString() == myFavorite.DiseaseID) != null) continue;

                        if (myFavorite.DiseaseID.Contains(","))
                        {
                            var diseaseIDsSplit = myFavorite.DiseaseID.Split(",");
                            var diseaseNamesSplit = myFavorite.DiseaseName.Split("|");

                            for (var index = 0; index < diseaseIDsSplit.Length; index++)
                                Model.Diseases?.Add(new FilteredDiseaseGetListViewModel
                                {
                                    DiseaseID = Convert.ToInt64(diseaseIDsSplit[index]),
                                    DiseaseName = diseaseNamesSplit[index]
                                });
                        }
                        else
                        {
                            FilteredDiseaseGetListViewModel disease = new()
                            {
                                DiseaseID = Convert.ToInt64(myFavorite.DiseaseID),
                                DiseaseName = myFavorite.DiseaseName
                            };
                            Model.Diseases?.Add(disease);
                        }
                    }
                    break;
            }

            await GetTestNamesByDisease();

            await base.OnInitializedAsync();
        }

        protected virtual void Dispose(bool disposing)
        {
            try
            {
                if (_disposedValue) return;
                if (disposing)
                {
                    _source?.Cancel();
                    _source?.Dispose();
                }

                _disposedValue = true;
            }
            catch (ObjectDisposedException)
            {
            }
        }

        /// <summary>
        /// Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        private async Task GetTestNamesByDisease()
        {
            if (Model.Diseases.Any())
            {
                DiseaseLabTestMatrixGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    PageSize = int.MaxValue - 1,
                    SortOrder = ClientLibrary.Enumerations.EIDSSConstants.SortConstants.Ascending,
                    SortColumn = "strDisease"
                };

                var lst = await DiseaseLabTestMatrixClient.GetLabTestMatrix(request, _token);

                foreach (var baseRef in from r in lst
                                        where r?.idfsTestName != null && r.idfsDiagnosis == Model.Diseases.First().DiseaseID
                                        select new BaseReferenceViewModel
                                        {
                                            IdfsBaseReference = (long)r.idfsTestName,
                                            Name = r.strTestName
                                        })
                    Model.TestNameTypes.Add(baseRef);

                Model.TestNameTypes = Model.TestNameTypes.GroupBy(x => x.IdfsBaseReference).Select(x => x.First()).ToList();
                Model.TestNameTypes = Model.TestNameTypes.OrderBy(x => x.IntOrder).ToList();
            }
        }

        public async Task GetTestNameTypesByFilter(LoadDataArgs args)
        {
            if (!string.IsNullOrEmpty(args.Filter))
                Model.TestNameTypes = Model.TestNameTypes.Where(c =>
                    c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();

            await InvokeAsync(StateHasChanged).ConfigureAwait(false);
        }

        public async Task GetTestResultTypesByFilter(LoadDataArgs args, long? testNameTypeId)
        {
            if (!string.IsNullOrEmpty(args.Filter))
                TestResultTypes = TestResultTypes.Where(c =>
                    c.strTestResultName != null && c.strTestResultName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
            else
            {
                if (testNameTypeId is null)
                    TestResultTypes = new List<TestNameTestResultsMatrixViewModel>();
                else
                    TestResultTypes = await GetTestResultTypesByTestName(new LoadDataArgs(), testNameTypeId)
                        .ConfigureAwait(false);
            }
            await InvokeAsync(StateHasChanged).ConfigureAwait(false);
        }

        protected async void OnFilterTestNameByDiseaseChanged(bool isChecked)
        {
            try
            {
                TestResultTypes?.Clear();

                if (isChecked)
                {
                    Model.TestNameTypes.Clear();
                    await GetTestNamesByDisease();
                }
                else
                {
                    Model.TestNameTypes.Clear();
                    await GetTestNameTypes();
                    Model.TestNameTypes = LaboratoryService.TestNameTypes.ToList();
                }

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task OnTestNameTypeChange(TestingGetListViewModel test)
        {
            try
            {
                test.TestResultTypeID = null;
                test.TestResultTypeName = null;

                if (test.TestNameTypeID is null)
                    TestResultTypes = new List<TestNameTestResultsMatrixViewModel>();
                else
                    TestResultTypes = await GetTestResultTypesByTestName(new LoadDataArgs(), test.TestNameTypeID)
                        .ConfigureAwait(false);

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async void OnEditRowClick(TestingGetListViewModel item)
        {
            try
            {
                await TestsGrid.EditRow(item);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnRowUpdate(TestingGetListViewModel item)
        {
            if (item == TestToInsert) TestToInsert = null;

            string testResultName, diseaseName;
            var testName = testResultName = diseaseName = string.Empty;

            var testNameTypeName = Model.TestNameTypes.ToList().Find(x => x.IdfsBaseReference == item.TestNameTypeID);
            if (testNameTypeName != null) testName = testNameTypeName.Name;

            var disease = Model.Diseases.Find(x => x.DiseaseID == item.DiseaseID);
            if (disease != null) diseaseName = disease.DiseaseName;

            var testResultTypeName =
                LaboratoryService.TestResultTypes.Find(x => x.idfsTestResult == item.TestResultTypeID);
            if (testResultTypeName != null) testResultName = testResultTypeName.strTestResultName;

            var existingTest = Model.Tests.Find(t => t.RowNumber == item.RowNumber);

            if (existingTest == null) return;
            existingTest.TestNameTypeID = item.TestNameTypeID;
            existingTest.TestNameTypeName = testName;
            existingTest.TestResultTypeID = item.TestResultTypeID;
            existingTest.TestResultTypeName = testResultName;
            existingTest.ResultDate = item.ResultDate;
            existingTest.DiseaseID = item.DiseaseID;
            existingTest.DiseaseName = diseaseName;

            if (Model.PendingSaveTests.Any(x => x.RowNumber == existingTest.RowNumber))
            {
                var index = Model.PendingSaveTests.FindIndex(x => x.RowNumber == existingTest.RowNumber);
                Model.PendingSaveTests[index] = existingTest.ShallowCopy();
            }
            else
            {
                var pendingItem = existingTest.ShallowCopy();
                Model.PendingSaveTests.Add(pendingItem);
            }

            await InvokeAsync(StateHasChanged).ConfigureAwait(false);
        }

        protected async Task OnSaveRowClick(TestingGetListViewModel item)
        {
            if (item == TestToInsert) TestToInsert = null;

            await TestsGrid.UpdateRow(item);
        }

        protected void OnCancelEditClick(TestingGetListViewModel item)
        {
            if (item == TestToInsert) TestToInsert = null;

            TestsGrid.CancelEditRow(item);
        }

        protected async Task OnDeleteRowClick(TestingGetListViewModel item)
        {
            if (item == TestToInsert) TestToInsert = null;

            if (Model.Tests.Contains(item))
            {
                Model.Tests.Remove(item);

                if (Model.Tests.Count == 0) Model.IsSaveDisabled = true;

                await TestsGrid.Reload();
            }
            else
            {
                TestsGrid.CancelEditRow(item);
            }

            if (Model.PendingSaveTests.Any(x => x.RowNumber == item.RowNumber))
            {
                var index = Model.PendingSaveTests.FindIndex(x => x.RowNumber == item.RowNumber);
                Model.PendingSaveTests.RemoveAt(index);
            }
        }

        public async Task OnInsertRowClick()
        {
            TestToInsert = new TestingGetListViewModel();
            if (Model.Diseases.Count == 1)
                TestToInsert.DiseaseID = Model.Diseases[0].DiseaseID;

            await TestsGrid.InsertRow(TestToInsert);
        }

        protected async void OnRowCreate(TestingGetListViewModel item)
        {
            var disease = Model.Diseases.Find(x => x.DiseaseID == item.DiseaseID);
            if (disease != null) item.DiseaseName = disease.DiseaseName;

            var testNameTypeName = Model.TestNameTypes.ToList().Find(x => x.IdfsBaseReference == item.TestNameTypeID);
            if (testNameTypeName != null) item.TestNameTypeName = testNameTypeName.Name;

            if (LaboratoryService.TestResultTypes is null)
                await GetTestResultTypes();

            var testResultTypeName =
                LaboratoryService.TestResultTypes?.Find(x => x.idfsTestResult == item.TestResultTypeID);
            if (testResultTypeName != null) item.TestResultTypeName = testResultTypeName.strTestResultName;

            if (Model.Tests.Any())
            {
                _ = int.TryParse(Model.Tests.Max(t => t.RowNumber).ToString(), out var maxRowNumber);
                maxRowNumber++;
                item.RowNumber = maxRowNumber;
            }
            else
            {
                item.RowNumber = 1;
            }

            Model.Tests.Add(item);

            var pendingItem = item.ShallowCopy();
            Model.PendingSaveTests.Add(pendingItem);

            Model.IsSaveDisabled = false;
        }

        protected async Task Save()
        {
            try
            {
                var validateStatus = true;
                StringBuilder errorMessages = new();
                List<TestingGetListViewModel> tests = new();
                dynamic selectedRecords;

                foreach (var test in Model.PendingSaveTests)
                    switch (Tab)
                    {
                        case LaboratoryTabEnum.Samples:
                            selectedRecords = (List<SamplesGetListViewModel>)LaboratoryService.SelectedSamples;
                            foreach (var record in selectedRecords)
                            {
                                if (Model.PendingSaveTests.Any())
                                {
                                    if (errorMessages.ToString().Contains(test.TestNameTypeName) == false)
                                    {
                                        if (Model.PendingSaveTests.Count(x =>
                                                x.TestNameTypeID == test.TestNameTypeID &&
                                                x.DiseaseID == test.DiseaseID) > 1)
                                        {
                                            errorMessages.Append(OpeningParagraphHtmlTag + "<strong>"
                                                + string.Format(Localizer.GetString(
                                                    MessageResourceKeyConstants.DuplicateValueMessage,
                                                    test.TestNameTypeName))
                                                + "</strong>" + ClosingParagraphHtmlTag);
                                            validateStatus = false;
                                        }
                                    }
                                }

                                var newTest = test.ShallowCopy();
                                newTest.SampleID = record.SampleID;
                                newTest.TestID = DateTime.Now.Ticks * -1;
                                newTest.RowAction = (int)RowActionTypeEnum.Insert;
                                newTest.StartedDate = DateTime.Now;
                                newTest.AccessionComment = record.AccessionComment;
                                newTest.AccessionConditionOrSampleStatusTypeName =
                                    record.AccessionConditionOrSampleStatusTypeName;
                                newTest.AccessionDate = record.AccessionDate;
                                newTest.DiseaseID = test.DiseaseID;
                                newTest.DiseaseName = test.DiseaseName;
                                newTest.EIDSSAnimalID = record.EIDSSAnimalID;
                                newTest.EIDSSLaboratorySampleID = record.EIDSSLaboratorySampleID;
                                newTest.EIDSSLocalOrFieldSampleID = record.EIDSSLocalOrFieldSampleID;
                                newTest.EIDSSReportOrSessionID = record.EIDSSReportOrSessionID;
                                newTest.FavoriteIndicator = record.FavoriteIndicator;
                                newTest.FunctionalAreaName = record.FunctionalAreaName;
                                newTest.PatientOrFarmOwnerName = record.PatientOrFarmOwnerName;
                                newTest.SampleTypeName = record.SampleTypeName;
                                newTest.HumanDiseaseReportID = record.HumanDiseaseReportID;
                                newTest.VeterinaryDiseaseReportID = record.VeterinaryDiseaseReportID;
                                newTest.MonitoringSessionID = record.MonitoringSessionID;
                                newTest.VectorID = record.VectorID;

                                if (newTest.TestNameTypeID is null)
                                {
                                    newTest.TestStatusTypeID = (long)TestStatusTypeEnum.NotStarted;
                                }
                                else
                                {
                                    if (newTest.TestResultTypeID is null)
                                    {
                                        newTest.ResultDate = null;
                                        newTest.ResultEnteredByOrganizationID = null;
                                        newTest.ResultEnteredByPersonID = null;
                                        newTest.ResultEnteredByPersonName = null;
                                        newTest.TestStatusTypeID = (long)TestStatusTypeEnum.InProgress;
                                    }
                                    else
                                    {
                                        newTest.ResultDate = DateTime.Now;
                                        newTest.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                                        newTest.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                        newTest.ResultEnteredByPersonName = authenticatedUser.LastName + (string.IsNullOrEmpty(authenticatedUser.FirstName) ? "" : ", " + authenticatedUser.FirstName);
                                        newTest.TestStatusTypeID = (long)TestStatusTypeEnum.Preliminary;
                                    }
                                }

                                newTest.ActionPerformedIndicator = true;

                                tests.Add(newTest);
                            }
                            break;
                        case LaboratoryTabEnum.Testing:
                            selectedRecords = (List<TestingGetListViewModel>)LaboratoryService.SelectedTesting;
                            foreach (var record in selectedRecords)
                            {
                                if (Model.PendingSaveTests.Any())
                                {
                                    if (errorMessages.ToString().Contains(test.TestNameTypeName) == false)
                                    {
                                        if (Model.PendingSaveTests.Count(x =>
                                                x.TestNameTypeID == test.TestNameTypeID &&
                                                x.DiseaseID == test.DiseaseID) > 1)
                                        {
                                            errorMessages.Append(OpeningParagraphHtmlTag + "<strong>"
                                                + string.Format(Localizer.GetString(
                                                    MessageResourceKeyConstants.DuplicateValueMessage,
                                                    test.TestNameTypeName))
                                                + "</strong>" + ClosingParagraphHtmlTag);
                                            validateStatus = false;
                                        }
                                    }
                                }

                                var newTest = test.ShallowCopy();
                                newTest.SampleID = record.SampleID;
                                newTest.TestID = DateTime.Now.Ticks * -1;
                                newTest.RowAction = (int)RowActionTypeEnum.Insert;
                                newTest.StartedDate = DateTime.Now;
                                newTest.AccessionComment = record.AccessionComment;
                                newTest.AccessionConditionOrSampleStatusTypeName =
                                    record.AccessionConditionOrSampleStatusTypeName;
                                newTest.AccessionDate = record.AccessionDate;
                                newTest.DiseaseID = record.DiseaseID;
                                newTest.DiseaseName = record.DiseaseName;
                                newTest.EIDSSAnimalID = record.EIDSSAnimalID;
                                newTest.EIDSSLaboratorySampleID = record.EIDSSLaboratorySampleID;
                                newTest.EIDSSLocalOrFieldSampleID = record.EIDSSLocalOrFieldSampleID;
                                newTest.EIDSSReportOrSessionID = record.EIDSSReportOrSessionID;
                                newTest.FavoriteIndicator = record.FavoriteIndicator;
                                newTest.FunctionalAreaName = record.FunctionalAreaName;
                                newTest.PatientOrFarmOwnerName = record.PatientOrFarmOwnerName;
                                newTest.SampleTypeName = record.SampleTypeName;
                                newTest.ActionPerformedIndicator = true;
                                newTest.HumanDiseaseReportID = record.HumanDiseaseReportID;
                                newTest.VeterinaryDiseaseReportID = record.VeterinaryDiseaseReportID;
                                newTest.MonitoringSessionID = record.MonitoringSessionID;
                                newTest.VectorID = record.VectorID;

                                if (newTest.TestNameTypeID is null)
                                {
                                    newTest.TestStatusTypeID = (long)TestStatusTypeEnum.NotStarted;
                                }
                                else
                                {
                                    if (newTest.TestResultTypeID is null)
                                    {
                                        newTest.ResultDate = null;
                                        newTest.ResultEnteredByOrganizationID = null;
                                        newTest.ResultEnteredByPersonID = null;
                                        newTest.ResultEnteredByPersonName = null;
                                        newTest.TestStatusTypeID = (long)TestStatusTypeEnum.InProgress;
                                    }
                                    else
                                    {
                                        newTest.ResultDate = DateTime.Now;
                                        newTest.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                                        newTest.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                        newTest.ResultEnteredByPersonName = authenticatedUser.LastName + (string.IsNullOrEmpty(authenticatedUser.FirstName) ? "" : ", " + authenticatedUser.FirstName);
                                        newTest.TestStatusTypeID = (long)TestStatusTypeEnum.Preliminary;
                                    }
                                }

                                tests.Add(newTest);
                            }
                            break;
                        case LaboratoryTabEnum.MyFavorites:
                            selectedRecords = (List<MyFavoritesGetListViewModel>)LaboratoryService.SelectedMyFavorites;
                            foreach (var record in selectedRecords)
                            {
                                if (Model.PendingSaveTests.Any())
                                {
                                    if (errorMessages.ToString().Contains(test.TestNameTypeName) == false)
                                    {
                                        if (Model.PendingSaveTests.Count(x =>
                                                x.TestNameTypeID == test.TestNameTypeID &&
                                                x.DiseaseID == test.DiseaseID) > 1)
                                        {
                                            errorMessages.Append(OpeningParagraphHtmlTag + "<strong>"
                                                                 + string.Format(Localizer.GetString(
                                                                     MessageResourceKeyConstants.DuplicateValueMessage,
                                                                     test.TestNameTypeName))
                                                                 + "</strong>" + ClosingParagraphHtmlTag);
                                            validateStatus = false;
                                        }
                                    }
                                }

                                var newTest = test.ShallowCopy();
                                newTest.SampleID = record.SampleID;
                                newTest.TestID = DateTime.Now.Ticks * -1;
                                newTest.RowAction = (int)RowActionTypeEnum.Insert;
                                newTest.StartedDate = DateTime.Now;
                                newTest.AccessionComment = record.AccessionComment;
                                newTest.AccessionConditionOrSampleStatusTypeName =
                                    record.AccessionConditionOrSampleStatusTypeName;
                                newTest.AccessionDate = record.AccessionDate;
                                newTest.DiseaseID = test.DiseaseID;
                                newTest.DiseaseName = test.DiseaseName;
                                newTest.EIDSSAnimalID = record.EIDSSAnimalID;
                                newTest.EIDSSLaboratorySampleID = record.EIDSSLaboratorySampleID;
                                newTest.EIDSSLocalOrFieldSampleID = record.EIDSSLocalOrFieldSampleID;
                                newTest.EIDSSReportOrSessionID = record.EIDSSReportOrSessionID;
                                newTest.FavoriteIndicator = true;
                                newTest.FunctionalAreaName = record.FunctionalAreaName;
                                newTest.PatientOrFarmOwnerName = record.PatientOrFarmOwnerName;
                                newTest.SampleTypeName = record.SampleTypeName;
                                newTest.ActionPerformedIndicator = true;
                                newTest.HumanDiseaseReportID = record.HumanDiseaseReportID;
                                newTest.VeterinaryDiseaseReportID = record.VeterinaryDiseaseReportID;
                                newTest.MonitoringSessionID = record.MonitoringSessionID;
                                newTest.VectorID = record.VectorID;

                                if (newTest.TestNameTypeID is null)
                                {
                                    newTest.TestStatusTypeID = (long)TestStatusTypeEnum.NotStarted;
                                }
                                else
                                {
                                    if (newTest.TestResultTypeID is null)
                                    {
                                        newTest.ResultDate = null;
                                        newTest.ResultEnteredByOrganizationID = null;
                                        newTest.ResultEnteredByPersonID = null;
                                        newTest.ResultEnteredByPersonName = null;
                                        newTest.TestStatusTypeID = (long)TestStatusTypeEnum.InProgress;
                                    }
                                    else
                                    {
                                        newTest.ResultDate = DateTime.Now;
                                        newTest.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                                        newTest.ResultEnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                                        newTest.ResultEnteredByPersonName = authenticatedUser.LastName + (string.IsNullOrEmpty(authenticatedUser.FirstName) ? "" : ", " + authenticatedUser.FirstName);
                                        newTest.TestStatusTypeID = (long)TestStatusTypeEnum.Preliminary;
                                    }
                                }

                                tests.Add(newTest);
                            }
                            break;
                    }

                if (validateStatus)
                {
                    await AssignTest(tests);
                    DiagService.Close(new DialogReturnResult { ButtonResultText = ClientLibrary.Enumerations.EIDSSConstants.DialogResultConstants.AssignTest });
                }
                else
                {
                    var html = errorMessages.ToString();
                    await ShowHtmlErrorDialog(new MarkupString(html));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                var result =
                    await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null)
                        .ConfigureAwait(false);

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        DiagService.Close(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }
    }
}