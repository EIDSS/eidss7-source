#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static System.Int32;
using static System.String;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class LaboratoryTestBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<LaboratoryTestBase> Logger { get; set; }
        [Inject] private ITestNameTestResultsMatrixClient TestNameTestResultsMatrix { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel DiseaseReport { get; set; }
        [Parameter] public LaboratoryTestGetListViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<LaboratoryTestGetListViewModel> Form { get; set; }
        public IEnumerable<FilteredDiseaseGetListViewModel> Diseases { get; set; }
        public IEnumerable<BaseReferenceViewModel> TestNameTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> TestCategoryTypes { get; set; }
        public IEnumerable<TestNameTestResultsMatrixViewModel> TestResultTypes { get; set; }
        public IEnumerable<BaseReferenceViewModel> TestStatusTypes { get; set; }
        public string FieldSampleIdFieldLabelResourceKey { get; set; }
        public string LabSampleIdFieldLabelResourceKey { get; set; }
        public string SampleTypeFieldLabelResourceKey { get; set; }
        public string SpeciesFieldLabelResourceKey { get; set; }
        public string AnimalIdFieldLabelResourceKey { get; set; }
        public string TestDiseaseFieldLabelResourceKey { get; set; }
        public string TestNameFieldLabelResourceKey { get; set; }
        public string TestStatusFieldLabelResourceKey { get; set; }
        public string TestCategoryFieldLabelResourceKey { get; set; }
        public string ResultDateFieldLabelResourceKey { get; set; }
        public string ResultObservationFieldLabelResourceKey { get; set; }

        #endregion

        #region Member Variables

        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public LaboratoryTestBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected LaboratoryTestBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
            {
                FieldSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportLabTestDetailsModalFieldSampleIDFieldLabel;
                LabSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportLabTestDetailsModalLabSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportLabTestDetailsModalSampleTypeFieldLabel;
                SpeciesFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportLabTestDetailsModalSpeciesFieldLabel;
                TestDiseaseFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportLabTestDetailsModalTestDiseaseFieldLabel;
                TestNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportLabTestDetailsModalTestNameFieldLabel;
                TestCategoryFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportLabTestDetailsModalTestCategoryFieldLabel;
                TestStatusFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportLabTestDetailsModalTestStatusFieldLabel;
                ResultDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportLabTestDetailsModalResultDateFieldLabel;
                ResultObservationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportLabTestDetailsModalResultObservationFieldLabel;
            }
            else
            {
                FieldSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestDetailsModalFieldSampleIDFieldLabel;
                LabSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestDetailsModalLabSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestDetailsModalSampleTypeFieldLabel;
                AnimalIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestDetailsModalAnimalIDFieldLabel;
                TestDiseaseFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestDetailsModalTestDiseaseFieldLabel;
                TestNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestDetailsModalTestNameFieldLabel;
                TestCategoryFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestDetailsModalTestCategoryFieldLabel;
                TestStatusFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestDetailsModalTestStatusFieldLabel;
                ResultDateFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestDetailsModalResultDateFieldLabel;
                ResultObservationFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestDetailsModalResultObservationFieldLabel;
            }

            await GetDiseases(new LoadDataArgs());

            Model.TestStatusTypeID = (long) TestStatusTypeEnum.Final;

            await base.OnInitializedAsync();
        }

        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
            }

            // TODO: free unmanaged resources (unmanaged objects) and override finalizer
            // TODO: set large fields to null
            _disposedValue = true;
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~AnimalBase()
        // {
        //     // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        //     Dispose(disposing: false);
        // }
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion

        #region Load Data Methods

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
                    AccessoryCode = DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                        ? HACodeList.AvianHACode
                        : HACodeList.LivestockHACode,
                    AdvancedSearchTerm = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                    UsingType = (long) DiseaseUsingTypes.Standard,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                };

                Diseases = await CrossCuttingClient.GetFilteredDiseaseList(request).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetTestNameTypes(LoadDataArgs args)
        {
            try
            {
                if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                    TestNameTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.TestName, HACodeList.AvianHACode).ConfigureAwait(false);
                else
                    TestNameTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.TestName, HACodeList.LivestockHACode).ConfigureAwait(false);

                if (!IsNullOrEmpty(args.Filter))
                    TestNameTypes = TestNameTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetTestCategoryTypes(LoadDataArgs args)
        {
            try
            {
                if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                    TestCategoryTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.TestCategory, HACodeList.AvianHACode).ConfigureAwait(false);
                else
                    TestCategoryTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                        BaseReferenceConstants.TestCategory, HACodeList.LivestockHACode).ConfigureAwait(false);

                if (!IsNullOrEmpty(args.Filter))
                    TestCategoryTypes = TestCategoryTypes.Where(c =>
                        c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetTestResultTypes(LoadDataArgs args)
        {
            try
            {
                if (Model.TestNameTypeID is null)
                {
                    TestResultTypes = new List<TestNameTestResultsMatrixViewModel>();
                }
                else
                {
                    TestNameTestResultsMatrixGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = "strTestResultName",
                        SortOrder = SortConstants.Ascending,
                        idfsTestName = Model.TestNameTypeID,
                        idfsTestResultRelation = (long) TestResultRelationTypeEnum.LaboratoryTest
                    };
                    TestResultTypes = await TestNameTestResultsMatrix.GetTestNameTestResultsMatrixList(request)
                        .ConfigureAwait(false);

                    if (!IsNullOrEmpty(args.Filter))
                        TestResultTypes = TestResultTypes.Where(c =>
                            c.strTestResultName != null && c.strTestResultName.Contains(args.Filter,
                                StringComparison.CurrentCultureIgnoreCase));
                }

                await InvokeAsync(StateHasChanged).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task GetTestStatusTypes()
        {
            try
            {
                if (TestStatusTypes == null)
                {
                    if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                        TestStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.TestStatus, HACodeList.AvianHACode).ConfigureAwait(false);
                    else
                        TestStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.TestStatus, HACodeList.LivestockHACode).ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Sample Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnSampleChange(object value)
        {
            try
            {
                if (value == null)
                {
                    Model.EIDSSAnimalID = null;
                    Model.EIDSSLaboratorySampleID = null;
                    Model.Species = null;
                    Model.SpeciesID = null;
                    Model.SpeciesTypeName = null;
                    Model.SampleTypeName = null;
                }
                else
                {
                    if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                        Model.Species = DiseaseReport.Samples.First(x => x.SampleID == (long) value).Species;
                    else
                        Model.EIDSSAnimalID =
                            DiseaseReport.Samples.First(x => x.SampleID == (long) value).EIDSSAnimalID;

                    Model.EIDSSLaboratorySampleID =
                        DiseaseReport.Samples.First(x => x.SampleID == (long) value).EIDSSLaboratorySampleID;
                    Model.SampleTypeName = DiseaseReport.Samples.First(x => x.SampleID == (long) value).SampleTypeName;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Test Name Type Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async void OnTestNameTypeChange()
        {
            try
            {
                await GetTestResultTypes(new LoadDataArgs()).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Test Name Type Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddTestNameTypeClick()
        {
            try
            {
                Dictionary<string, object> dialogParams = new()
                {
                    {
                        nameof(AddBaseReferenceRecord.AccessoryCode),
                        DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                            ? (int) AccessoryCodeEnum.Avian
                            : (int) AccessoryCodeEnum.Livestock
                    },
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeID),
                        (long) BaseReferenceTypeEnum.LaboratoryTestName
                    },
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeName),
                        FieldLabelResourceKeyConstants.TestDetailsModalTestNameFieldLabel
                    },
                    {nameof(AddBaseReferenceRecord.Model), new BaseReferenceSaveRequestModel()}
                };
                var result = await DiagService.OpenAsync<AddBaseReferenceRecord>(
                    Localizer.GetString(HeadingResourceKeyConstants.BaseReferenceDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true, Draggable = false
                    }).ConfigureAwait(false);

                if (result is BaseReferenceSaveRequestResponseModel)
                    await GetTestNameTypes(new LoadDataArgs()).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Add Test Category Type Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddTestCategoryTypeClick()
        {
            try
            {
                Dictionary<string, object> dialogParams = new()
                {
                    {
                        nameof(AddBaseReferenceRecord.AccessoryCode),
                        DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                            ? (int) AccessoryCodeEnum.Avian
                            : (int) AccessoryCodeEnum.Livestock
                    },
                    {nameof(AddBaseReferenceRecord.BaseReferenceTypeID), (long) BaseReferenceTypeEnum.TestCategory},
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeName),
                        FieldLabelResourceKeyConstants.TestDetailsModalTestCategoryFieldLabel
                    },
                    {nameof(AddBaseReferenceRecord.Model), new BaseReferenceSaveRequestModel()}
                };
                var result = await DiagService.OpenAsync<AddBaseReferenceRecord>(
                    Localizer.GetString(HeadingResourceKeyConstants.BaseReferenceDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true, Draggable = false
                    }).ConfigureAwait(false);

                if (result is BaseReferenceSaveRequestResponseModel)
                    await GetTestCategoryTypes(new LoadDataArgs()).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Add Test Result Type Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task AddTestResultTypeClick()
        {
            try
            {
                Dictionary<string, object> dialogParams = new()
                {
                    {
                        nameof(AddBaseReferenceRecord.AccessoryCode),
                        DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                            ? (int) AccessoryCodeEnum.Avian
                            : (int) AccessoryCodeEnum.Livestock
                    },
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeID),
                        (long) BaseReferenceTypeEnum.LaboratoryTestResult
                    },
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeName),
                        FieldLabelResourceKeyConstants.TestDetailsModalTestResultFieldLabel
                    },
                    {nameof(AddBaseReferenceRecord.Model), new BaseReferenceSaveRequestModel()}
                };
                var result = await DiagService.OpenAsync<AddBaseReferenceRecord>(
                    Localizer.GetString(HeadingResourceKeyConstants.BaseReferenceDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true, Draggable = false
                    }).ConfigureAwait(false);

                if (result is BaseReferenceSaveRequestResponseModel)
                    await GetTestResultTypes(new LoadDataArgs()).ConfigureAwait(false);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Save Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public void OnSubmit()
        {
            if (!Form.EditContext.Validate()) return;
            switch (Model.TestID)
            {
                case 0:
                    Model.TestID = (DiseaseReport.LaboratoryTests.Count + 1) * -1;
                    Model.NonLaboratoryTestIndicator = true;
                    Model.RowAction = (int) RowActionTypeEnum.Insert;
                    Model.RowStatus = (int) RowStatusTypeEnum.Active;
                    break;
                case > 0:
                    Model.RowAction = (int) RowActionTypeEnum.Update;
                    break;
            }

            Model.DiseaseName = Model.DiseaseID is null
                ? null
                : Diseases.First(x => x.DiseaseID == Model.DiseaseID).DiseaseName;

            if (Model.SampleID is null)
            {
                Model.AnimalID = null;
                Model.EIDSSAnimalID = null;
                Model.EIDSSLaboratorySampleID = null;
                Model.EIDSSLocalOrFieldSampleID = null;
                Model.SampleTypeName = null;
                Model.Species = null;
                Model.SpeciesID = null;
                Model.SpeciesTypeName = null;
            }
            else
            {
                Model.AnimalID = DiseaseReport.Samples.First(x => x.SampleID == Model.SampleID).AnimalID;
                Model.EIDSSAnimalID = DiseaseReport.Samples.First(x => x.SampleID == Model.SampleID).EIDSSAnimalID;
                Model.EIDSSLaboratorySampleID =
                    DiseaseReport.Samples.First(x => x.SampleID == Model.SampleID).EIDSSLaboratorySampleID;
                Model.EIDSSLocalOrFieldSampleID =
                    DiseaseReport.Samples.First(x => x.SampleID == Model.SampleID).EIDSSLocalOrFieldSampleID;
                Model.SampleTypeName = DiseaseReport.Samples.First(x => x.SampleID == Model.SampleID).SampleTypeName;
                Model.Species = DiseaseReport.Samples.First(x => x.SampleID == Model.SampleID).Species;
                Model.SpeciesID = DiseaseReport.Samples.First(x => x.SampleID == Model.SampleID).SpeciesID;
                Model.SpeciesTypeName = DiseaseReport.Samples.First(x => x.SampleID == Model.SampleID).SpeciesTypeName;
            }

            Model.TestNameTypeName = Model.TestNameTypeID is null
                ? null
                : TestNameTypes.First(x => x.IdfsBaseReference == Model.TestNameTypeID).Name;

            Model.TestCategoryTypeName = Model.TestCategoryTypeID is null
                ? null
                : TestCategoryTypes.First(x => x.IdfsBaseReference == Model.TestCategoryTypeID).Name;

            if (Model.TestResultTypeID is null)
            {
                Model.TestResultTypeName = null;
                Model.IsTestResultIndicative = false;
            }
            else
            {
                if (Model.TestResultTypeID != null &&
                    TestResultTypes.Any(x => x.idfsTestResult == (long)Model.TestResultTypeID))
                {
                    Model.TestResultTypeName = TestResultTypes.First(x => x.idfsTestResult == Model.TestResultTypeID)
                        .strTestResultName;
                    Model.IsTestResultIndicative = TestResultTypes
                        .First(x => x.idfsTestResult == Model.TestResultTypeID)
                        .blnIndicative;
                }
            }

            DiagService.Close(Form.EditContext.Model);
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result =
                        await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null)
                            .ConfigureAwait(false);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
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

        #endregion
    }
}