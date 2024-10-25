#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.GC;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    public class CreateBatchBase : LaboratoryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<CreateBatchBase> Logger { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }
        [Parameter] public List<TestingGetListViewModel> SelectedTests { get; set; }
        [Parameter] public int LaboratoryModuleAction { get; set; }
        [Parameter] public BatchesGetListViewModel Batch { get; set; }

        #endregion

        #region Properties

        public TestingGetListViewModel Test { get; set; }
        public List<EmployeeLookupGetListViewModel> EmployeeList { get; set; }
        protected RadzenTemplateForm<BatchesGetListViewModel> Form { get; set; }
        public bool IsBatchIdVisible { get; set; }
        public bool IsTestCategoryVisible { get; set; }
        public bool IsTestResultVisible { get; set; }
        public bool IsTestResultDateVisible { get; set; }
        public bool IsNoteVisible { get; set; }
        public string BatchId { get; set; }
        public string TestStartedDate { get; set; }
        public string TestResultDate { get; set; }
        public string Note { get; set; }
        protected FlexForm.FlexForm QualityControlValuesFlexForm { get; set; }

        #endregion

        #region Member Variables

        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public CreateBatchBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected CreateBatchBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            try
            {
                _logger = Logger;

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                SelectedTests ??= new List<TestingGetListViewModel>();
                Test = SelectedTests.Count == 0 ? new TestingGetListViewModel() : SelectedTests.First();

                BatchId = Empty;

                Batch ??= new BatchesGetListViewModel();

                if (LaboratoryService.TestResultTypes is null || !LaboratoryService.TestResultTypes.Any())
                {
                    await GetTestResultTypes();
                    await InvokeAsync(StateHasChanged);
                }

                if (LaboratoryModuleAction == (int)LaboratoryModuleActions.EditBatch)
                {
                    BatchId = Batch.EIDSSBatchTestID;
                    IsBatchIdVisible = true;
                    IsTestCategoryVisible = false;
                    IsTestResultVisible = true;
                    IsTestResultDateVisible = true;
                    IsNoteVisible = true;

                    if (SelectedTests is not null && SelectedTests.Any())
                    {
                        SelectedTests = SelectedTests.OrderBy(x => x.StartedDate).ToList();
                        if (SelectedTests.Any(x => x.StartedDate is not null))
                            TestStartedDate = SelectedTests.First(x => x.StartedDate is not null).StartedDate
                                ?.ToShortDateString();
                        SelectedTests = SelectedTests.OrderByDescending(x => x.ResultDate).ToList();
                        if (SelectedTests.Any(x => x.ResultDate is not null))
                            TestResultDate = SelectedTests.First(x => x.ResultDate is not null).ResultDate
                                ?.ToShortDateString();
                    }

                    Note = Test.Note;
                }
                else
                {
                    TestStartedDate = DateTime.Now.ToShortDateString();

                    IsBatchIdVisible = false;
                    IsTestCategoryVisible = true;
                    IsTestResultVisible = false;
                    IsTestResultDateVisible = false;
                    IsNoteVisible = false;
                }

                FlexFormRequest = new FlexFormQuestionnaireGetRequestModel
                {
                    LangID = GetCurrentLanguage(),
                    idfObservation = Batch.ObservationID,
                    idfsDiagnosis = Test.DiseaseID,
                    idfsFormType = (long)FlexibleFormTypeEnum.LaboratoryBatchTest
                };

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        // <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
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

        #region Save Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnSaveClick()
        {
            try
            {
                var batchStatusTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    BaseReferenceConstants.TestStatus, HACodeList.NoneHACode);

                Batch.QualityControlValuesFlexFormRequest = FlexFormRequest;
                var response = await QualityControlValuesFlexForm.CollectAnswers();
                await InvokeAsync(StateHasChanged);
                Batch.QualityControlValuesFlexFormRequest.idfsFormTemplate = response.idfsFormTemplate;
                Batch.QualityControlValuesFlexFormAnswers = QualityControlValuesFlexForm.Answers;
                Batch.QualityControlValuesObservationParameters = response.Answers;

                BatchesGetListViewModel batch = new()
                {
                    BatchTestID = Batch.BatchTestID > 0 ? Batch.BatchTestID : -1,
                    BatchTestTestNameTypeID = SelectedTests.First().TestNameTypeID,
                    BatchStatusTypeID = Batch.BatchTestID > 0 ? Batch.BatchStatusTypeID : (long) BatchTestStatusTypeEnum.InProgress,
                    EIDSSBatchTestID = Batch.BatchTestID > 0 ? Batch.EIDSSBatchTestID : null,
                    PerformedByOrganizationID = authenticatedUser.OfficeId,
                    PerformedByPersonID = Convert.ToInt64(authenticatedUser.PersonId),
                    QualityControlValuesFlexFormAnswers = Batch.QualityControlValuesFlexFormAnswers, 
                    QualityControlValuesObservationParameters = Batch.QualityControlValuesObservationParameters,
                    QualityControlValuesFlexFormRequest = Batch.QualityControlValuesFlexFormRequest,
                    SiteID = Convert.ToInt64(authenticatedUser.SiteId),
                    PerformedDate = DateTime.Now,
                    RowStatus = (int)RowStatusTypeEnum.Active,
                    TestRequested = Empty,
                    RowAction = Batch.BatchTestID > 0 ? (int) RowActionTypeEnum.Update : (int) RowActionTypeEnum.Insert,
                    TotalPages = Batch.TotalPages,
                    TotalRowCount = Batch.TotalRowCount
                };

                if (Batch.BatchTestID <= 0)
                    batch.BatchStatusTypeName = batchStatusTypes
                        .First(x => x.IdfsBaseReference == (long) BatchTestStatusTypeEnum.InProgress).Name;
                else
                    batch.BatchStatusTypeName =
                        batchStatusTypes.First(x => x.IdfsBaseReference == Batch.BatchStatusTypeID).Name;

                if (Test.TestResultTypeID == null)
                {
                    Test.ResultDate = null;
                    Test.ResultEnteredByOrganizationID = null;
                    Test.ResultEnteredByPersonID = null;
                    Test.ResultEnteredByPersonName = null;
                }
                else
                {
                    Test.ResultDate = DateTime.Now;
                    Test.ResultEnteredByOrganizationID = authenticatedUser.OfficeId;
                    Test.ResultEnteredByPersonName = authenticatedUser.LastName + ", " + authenticatedUser.FirstName;

                    if (LaboratoryService.TestStatusTypes is null)
                        await GetTestStatusTypes();

                    if (LaboratoryService.TestStatusTypes != null && LaboratoryService.TestStatusTypes.Any(x =>
                            x.IdfsBaseReference == (long)TestStatusTypeEnum.Preliminary))
                        Test.TestStatusTypeID = LaboratoryService.TestStatusTypes
                            .First(x => x.IdfsBaseReference == (long)TestStatusTypeEnum.Preliminary).IdfsBaseReference;
                }

                foreach (var test in SelectedTests)
                {
                    test.BatchTestID = Batch.BatchTestID > 0 ? Batch.BatchTestID : -1;
                    test.TestCategoryTypeID = Test.TestCategoryTypeID;
                    test.RowAction = (int) RowActionTypeEnum.Update;
                    test.Note = Note;
                    test.StartedDate ??= DateTime.Now;
                    test.ResultDate = Test.ResultDate;
                    test.ResultEnteredByOrganizationID = Test.ResultEnteredByOrganizationID;
                    test.ResultEnteredByPersonName = Test.ResultEnteredByPersonName;
                    test.TestedByOrganizationID = Test.TestedByOrganizationID;
                    test.TestedByPersonID = Test.TestedByPersonID;
                    test.TestResultTypeID = Test.TestResultTypeID;
                    test.TestStatusTypeID = Test.TestStatusTypeID;
                    test.ActionPerformedIndicator = true;
                    TogglePendingSaveTesting(test);
                }

                TogglePendingSaveBatches(batch);

                if (LaboratoryModuleAction == (int) LaboratoryModuleActions.CreateBatch) await SaveLaboratory();

                DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.OK});
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Load Data Method

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task GetTestedByEmployees(LoadDataArgs args)
        {
            try
            {
                if (authenticatedUser is not null)
                {
                    EmployeeLookupGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        AccessoryCode = HACodeList.HumanHACode,
                        AdvancedSearch = IsNullOrEmpty(args.Filter) ? null : args.Filter,
                        OrganizationID = Convert.ToInt64(authenticatedUser.OfficeId),
                        SortColumn = "FullName",
                        SortOrder = SortConstants.Ascending
                    };

                    var list = await CrossCuttingClient.GetEmployeeLookupList(request);
                    EmployeeList = list;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Add Employee Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddEmployeeClick()
        {
            try
            {
                var dialogParams = new Dictionary<string, object>();

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
                    Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth, Height = CSSClassConstants.DefaultDialogHeight,
                        Resizable = true, Draggable = false
                    });

                if (result == null)
                    return;

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Cancel Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancelClick()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form?.EditContext != null && Form.EditContext.IsModified())
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

        #region Test Result Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        protected void OnTestResultChange(object value)
        {
            TestResultDate = value == null ? Empty : DateTime.Now.ToShortDateString();
        }

        #endregion

        #endregion
    }
}