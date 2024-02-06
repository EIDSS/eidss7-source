#region Usings

using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
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
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Web.Components.Administration;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class TestModalBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<TestModalBase> Logger { get; set; }

        [Inject]
        private ITestNameTestResultsMatrixClient TestNameTestResultsMatrix { get; set; }

        [Inject]
        private IDiseaseLabTestMatrixClient DiseaseLabTestMatrixClient { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<LaboratoryTestGetListViewModel> Form { get; set; }
        public IList<SampleGetListViewModel> Samples { get; set; }
        public IList<BaseReferenceViewModel> TestNameTypes { get; set; }
        public IList<BaseReferenceViewModel> TestCategoryTypes { get; set; }
        public IList<BaseReferenceViewModel> TestStatuses { get; set; }
        public IList<FilteredDiseaseGetListViewModel> TestDiseases { get; set; }
        public IList<TestNameTestResultsMatrixViewModel> TestResultTypes { get; set; }

        #endregion

        #region Member Variables

        protected bool Disabled;
        protected bool IsDiseaseFiltered;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        protected override async void OnInitialized()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            IsDiseaseFiltered = true;

            await GetTestStatuses();
            if (TestStatuses is not null && TestStatuses.Any())
            {
                StateContainer.LaboratoryTestDetail.TestStatusTypeID = (long)TestStatusTypeEnum.Final;
                StateContainer.LaboratoryTestDetail.TestStatusTypeName = TestStatuses.FirstOrDefault(x => x.IdfsBaseReference == StateContainer.LaboratoryTestDetail.TestStatusTypeID)?.Name;
            }

            await base.OnInitializedAsync();
        }

        #endregion

        #region Load Data Methods

        protected void GetSamples(LoadDataArgs args)
        {
            try
            {
                Samples ??= new List<SampleGetListViewModel>();

                // get the samples list from the animal samples grid
                if (StateContainer.AnimalSamples is { Count: > 0 })
                {
                    Samples = StateContainer.AnimalSamples.Where(x => x.RowStatus == (int)RowStatusTypeEnum.Active
                                                                      && !string.IsNullOrEmpty(x.EIDSSLocalOrFieldSampleID)).ToList();
                }

                // filter by filter criteria
                if (!string.IsNullOrEmpty(args.Filter))
                {
                    Samples = Samples.Where(d => d.EIDSSLocalOrFieldSampleID != null && d.EIDSSLocalOrFieldSampleID.Contains(args.Filter)).ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetDiseases(LoadDataArgs args)
        {
            try
            {
                TestDiseases ??= new List<FilteredDiseaseGetListViewModel>();

                if (string.IsNullOrEmpty(args.Filter))
                {
                    TestDiseases = new List<FilteredDiseaseGetListViewModel>();
                }

                // get the diseases list from the Disease Species Sample Grid
                if (TestDiseases.Count == 0)
                {
                    if (StateContainer.DiseaseSpeciesSamples is { Count: > 0 })
                    {
                        var distinctDiseases = StateContainer.DiseaseSpeciesSamples
                            .Where(x => x.RowStatus == (int)RowStatusTypeEnum.Active)
                            .DistinctBy(x => x.DiseaseID)
                            .Select(d => new FilteredDiseaseGetListViewModel()
                            {
                                DiseaseID = d.DiseaseID.GetValueOrDefault(),
                                DiseaseName = d.DiseaseName,
                                UsingType = d.DiseaseUsingType
                            })
                            .ToList();

                        distinctDiseases.ForEach(d => TestDiseases.Add(d));
                    }
                }

                // filter by filter criteria
                if (!string.IsNullOrEmpty(args.Filter))
                {
                    TestDiseases = TestDiseases.Where(d => d.DiseaseName != null && d.DiseaseName.Contains(args.Filter, StringComparison.OrdinalIgnoreCase)).ToList();
                }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetTestNameTypes(LoadDataArgs args)
        {
            try
            {
                if (args.Filters != null && args.Filters.Any(f => f.Property == "DiseaseID"))
                {
                    TestNameTypes = new List<BaseReferenceViewModel>();
                    var diseaseList = string.Join(",", args.Filters.Select(f => f.FilterValue).ToArray());
                    var filteredTestNameTypes = await CrossCuttingClient.GetDiseaseTestList(new DiseaseTestGetRequestModel() { DiseaseIDList = diseaseList, LanguageID = GetCurrentLanguage() });
                    if (filteredTestNameTypes is { Count: > 0 })
                    {
                        foreach (var test in filteredTestNameTypes)
                        {
                            TestNameTypes.Add(new BaseReferenceViewModel()
                            {
                                IdfsBaseReference = test.TestNameTypeID,
                                Name = test.TestNameTypeName
                            });
                        }
                    }
                }
                else
                {
                    if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                        TestNameTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.TestName, HACodeList.AvianHACode);
                    else
                    {
                        TestNameTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.TestName, HACodeList.LivestockHACode);
                    }
                }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetTestCategoryTypes(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                    TestCategoryTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.TestCategory, HACodeList.AvianHACode);
                else
                    TestCategoryTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.TestCategory, HACodeList.LivestockHACode);

                if (!string.IsNullOrEmpty(args.Filter))
                    TestCategoryTypes = TestCategoryTypes.Where(c => c.Name != null && c.Name.Contains(args.Filter)).ToList();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetTestStatuses()
        {
            try
            {
                if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                    TestStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.TestStatus, HACodeList.AvianHACode);
                else
                    TestStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.TestStatus, HACodeList.LivestockHACode);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task GetTestResultTypes(LoadDataArgs args)
        {
            try
            {
                if (StateContainer.LaboratoryTestDetail.TestNameTypeID is null)
                {
                    TestResultTypes = new List<TestNameTestResultsMatrixViewModel>();
                }
                else
                {
                    TestNameTestResultsMatrixGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = int.MaxValue - 1,
                        SortColumn = "strTestResultName",
                        SortOrder = SortConstants.Ascending,
                        idfsTestName = StateContainer.LaboratoryTestDetail.TestNameTypeID,
                        idfsTestResultRelation = (long)TestResultRelationTypeEnum.LaboratoryTest
                    };
                    TestResultTypes = await TestNameTestResultsMatrix.GetTestNameTestResultsMatrixList(request);

                    if (!string.IsNullOrEmpty(args.Filter))
                        TestResultTypes = TestResultTypes.Where(c => c.strTestResultName != null && c.strTestResultName.Contains(args.Filter)).ToList();
                }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        protected async Task OnFilterByDiseaseChange(bool value)
        {
            if (value)
            {
                // filter by the selected disease
                var filterList = new List<FilterDescriptor> {new FilterDescriptor() { Property = "DiseaseID", FilterValue = StateContainer.LaboratoryTestDetail.DiseaseID }};
                await GetTestNameTypes(new LoadDataArgs() { Filters = filterList });
            }
            else
            {
                await GetTestNameTypes(new LoadDataArgs());
            }
        }

        protected async Task OnTestDiseaseChange(object value)
        {
            if (value != null && IsDiseaseFiltered)
            {
                // filter by the selected disease
                var filterList = new List<FilterDescriptor> {new FilterDescriptor() { Property = "DiseaseID", FilterValue = StateContainer.LaboratoryTestDetail.DiseaseID }};
                await GetTestNameTypes(new LoadDataArgs() { Filters = filterList });
            }
            else
            {
                await GetTestNameTypes(new LoadDataArgs());
            }
        }

        protected async Task OnTestNameChange(object value)
        {
            await GetTestResultTypes(new LoadDataArgs());
        }

        #region Sample Drop Down Change Event

        protected async Task OnSampleChange(object value)
        {
            try
            {
                if (value == null || Samples == null || !Samples.Any())
                {
                    StateContainer.LaboratoryTestDetail.EIDSSAnimalID = null;
                    StateContainer.LaboratoryTestDetail.FarmID = null;
                    StateContainer.LaboratoryTestDetail.FarmMasterID = null;
                    StateContainer.LaboratoryTestDetail.EIDSSFarmID = null;
                    StateContainer.LaboratoryTestDetail.Species = null;
                    StateContainer.LaboratoryTestDetail.SpeciesID = null;
                    StateContainer.LaboratoryTestDetail.SpeciesTypeName = null;
                    StateContainer.LaboratoryTestDetail.ResultDate = null;
                    StateContainer.LaboratoryTestDetail.SampleTypeName = null;
                    Disabled = true;
                }
                else
                {
                    var sample = Samples.First(x => x.SampleID == (long)value);
                    if (StateContainer.ReportTypeID == ASSpeciesType.Avian)
                    {
                        StateContainer.LaboratoryTestDetail.Species = sample.SpeciesTypeName;
                    }
                    else
                    {
                        StateContainer.LaboratoryTestDetail.EIDSSAnimalID = sample.EIDSSAnimalID;
                    }
                    StateContainer.LaboratoryTestDetail.FarmID = sample.FarmMasterID;
                    StateContainer.LaboratoryTestDetail.EIDSSFarmID = sample.EIDSSFarmID;
                    StateContainer.LaboratoryTestDetail.FarmMasterID = sample.FarmMasterID;
                    StateContainer.LaboratoryTestDetail.SpeciesID = sample.SpeciesTypeID;
                    StateContainer.LaboratoryTestDetail.SpeciesTypeName = sample.SpeciesTypeName;
                    StateContainer.LaboratoryTestDetail.ResultDate = sample.SampleStatusDate;
                    StateContainer.LaboratoryTestDetail.SampleTypeName = sample.SampleTypeName;
                    Disabled = false;
                    await GetDiseases(new LoadDataArgs());
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Test Result Type

        protected async Task OnAddTestResultTypeClick()
        {
            try
            {
                Dictionary<string, object> dialogParams = new()
                {
                    { nameof(AddBaseReferenceRecord.AccessoryCode), (int)AccessoryCodeEnum.AvianAndLivestock },
                    { nameof(AddBaseReferenceRecord.BaseReferenceTypeID), (long)BaseReferenceTypeEnum.LaboratoryTestResult },
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeName),
                        FieldLabelResourceKeyConstants.SiteDetailsSiteTypeFieldLabel
                    },
                    { nameof(AddBaseReferenceRecord.Model), new BaseReferenceSaveRequestModel() }
                };

                var result = await DiagService.OpenAsync<AddBaseReferenceRecord>(
                    string.Empty,
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true,
                        Draggable = false
                    });

                if (result is BaseReferenceSaveRequestResponseModel response)
                {
                    StateContainer.LaboratoryTestDetail.TestResultTypeID = response.idfsBaseReference;
                    await GetTestResultTypes(new LoadDataArgs());
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Save Button Click Event

        protected void OnSubmit()
        {
            if (!Form.EditContext.Validate()) return;
            switch (StateContainer.LaboratoryTestDetail.TestID)
            {
                case 0:
                    StateContainer.LaboratoryTestDetail.TestID = (StateContainer.Tests != null) ? (StateContainer.Tests.Count + 1) * -1 : -1;
                    StateContainer.LaboratoryTestDetail.RowAction = (int)RowActionTypeEnum.Insert;
                    StateContainer.LaboratoryTestDetail.RowStatus = (int)RowStatusTypeEnum.Active;
                    break;

                case > 0:
                    StateContainer.LaboratoryTestDetail.RowAction = (int)RowActionTypeEnum.Update;
                    break;
            }

            StateContainer.LaboratoryTestDetail.MonitoringSessionID = StateContainer.SessionKey;

            StateContainer.LaboratoryTestDetail.DiseaseName = StateContainer.LaboratoryTestDetail.DiseaseID is null ? null : TestDiseases.First(x => x.DiseaseID == StateContainer.LaboratoryTestDetail.DiseaseID).DiseaseName;

            StateContainer.LaboratoryTestDetail.TestNameTypeName = StateContainer.LaboratoryTestDetail.TestNameTypeID is null ? null : TestNameTypes.First(x => x.IdfsBaseReference == StateContainer.LaboratoryTestDetail.TestNameTypeID).Name;

            if (StateContainer.LaboratoryTestDetail.SampleID is null)
            {
                StateContainer.LaboratoryTestDetail.EIDSSLocalOrFieldSampleID = null;
                StateContainer.LaboratoryTestDetail.SampleTypeName = null;
            }
            else
            {
                StateContainer.LaboratoryTestDetail.EIDSSLocalOrFieldSampleID = Samples.First(x => x.SampleID == StateContainer.LaboratoryTestDetail.SampleID).EIDSSLocalOrFieldSampleID;
                StateContainer.LaboratoryTestDetail.FarmMasterID = Samples
                    .First(x => x.SampleID == StateContainer.LaboratoryTestDetail.SampleID).FarmMasterID;
            }

            StateContainer.LaboratoryTestDetail.TestResultTypeName = StateContainer.LaboratoryTestDetail.TestResultTypeID is null
                ? null
                : TestResultTypes.First(x => x.idfsTestResult == StateContainer.LaboratoryTestDetail.TestResultTypeID).strTestResultName;

            StateContainer.LaboratoryTestDetail.TestCategoryTypeName = StateContainer.LaboratoryTestDetail.TestCategoryTypeID is null
                ? null
                : TestCategoryTypes.First(x => x.IdfsBaseReference == StateContainer.LaboratoryTestDetail.TestCategoryTypeID).Name;

            StateContainer.LaboratoryTestDetail.IsTestResultIndicative = TestResultTypes.First(x => x.idfsTestResult == StateContainer.LaboratoryTestDetail.TestResultTypeID).blnIndicative;

            DiagService.Close(Form.EditContext.Model);
        }

        #endregion

        #region Cancel Button Click Event

        protected async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                            DiagService.Close(result);
                }
                else
                    DiagService.Close();
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