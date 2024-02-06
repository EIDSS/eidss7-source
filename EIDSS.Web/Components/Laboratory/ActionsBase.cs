#region Usings

using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    /// <summary>
    /// </summary>
    public class ActionsBase : LaboratoryBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<ActionsBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private new ICrossCuttingClient CrossCuttingClient { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }
        [Parameter] public EventCallback AccessionInEvent { get; set; }
        [Parameter] public EventCallback AliquotEvent { get; set; }
        [Parameter] public EventCallback AssignTestEvent { get; set; }
        [Parameter] public EventCallback AmendTestResultEvent { get; set; }
        [Parameter] public EventCallback BatchEvent { get; set; }
        [Parameter] public EventCallback CancelTransferOutEvent { get; set; }
        [Parameter] public EventCallback PrintTransferEvent { get; set; }
        [Parameter] public EventCallback ApproveEvent { get; set; }
        [Parameter] public EventCallback RejectEvent { get; set; }
        [Parameter] public EventCallback AddGroupResultEvent { get; set; }

        #endregion

        #region Properties

        public bool AccessionDisabledIndicator
        {
            get
            {
                _accessionDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.CanPerformSampleAccessionIn);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is { Count: > 0 } && _userPermissions.Execute &&
                            !LaboratoryService.SelectedSamples.Any(x =>
                                x.AccessionIndicator == 1 || x.AccessionConditionTypeID is not null))
                            _accessionDisabledIndicator = false;

                        break;

                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 } && _userPermissions.Execute &&
                            !LaboratoryService.SelectedMyFavorites.Any(x =>
                                x.AccessionIndicator == 1 || x.AccessionConditionTypeID is not null))
                            _accessionDisabledIndicator = false;

                        break;
                }

                return _accessionDisabledIndicator;
            }
        }

        public bool AliquotDisabledIndicator
        {
            get
            {
                _aliquotDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is { Count: > 0 } && _userPermissions.Create)
                            if (LaboratoryService.SelectedSamples.All(x =>
                                    x.AccessionConditionTypeID is (long)AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long)AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long)SampleStatusTypeEnum.InRepository))
                                _aliquotDisabledIndicator = false;
                        break;

                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SearchMyFavorites is { Count: > 0 } && _userPermissions.Create)
                            if (LaboratoryService.SearchMyFavorites.All(x =>
                                    x.AccessionConditionTypeID is (long)AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long)AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long)SampleStatusTypeEnum.InRepository))
                                _aliquotDisabledIndicator = false;
                        break;
                }

                return _aliquotDisabledIndicator;
            }
        }

        public bool AssignTestDisabledIndicator
        {
            get
            {
                _assignTestDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTesting);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.SelectedSamples is { Count: > 0 } && _userPermissions.Create)
                        {
                            bool conditionSampleOk;
                            var diseaseSampleOk = conditionSampleOk = false;

                            var diseaseId = LaboratoryService.SelectedSamples.First().DiseaseID;
                            if (LaboratoryService.SelectedSamples.All(x =>
                                    x.DiseaseID == diseaseId)) // all diseases must be the same
                                diseaseSampleOk = true;

                            if (LaboratoryService.SelectedSamples.All(x =>
                                    x.AccessionConditionTypeID is (long)AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long)AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long)SampleStatusTypeEnum.InRepository))
                                conditionSampleOk = true;

                            if (diseaseSampleOk && conditionSampleOk) _assignTestDisabledIndicator = false;
                        }

                        break;

                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is { Count: > 0 } && _userPermissions.Create)
                            // All diseases for the selected records must be the same to assign a new test from the testing tab.
                            _assignTestDisabledIndicator =
                                LaboratoryService.SelectedTesting.GroupBy(x => x.DiseaseID).Count() != 1;
                        break;

                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 } && _userPermissions.Create)
                            if (LaboratoryService.SelectedMyFavorites.All(x =>
                                    x.AccessionConditionTypeID is (long)AccessionConditionTypeEnum
                                            .AcceptedInGoodCondition
                                        or (long)AccessionConditionTypeEnum.AcceptedInPoorCondition
                                    && x.SampleStatusTypeID == (long)SampleStatusTypeEnum.InRepository))
                                _assignTestDisabledIndicator = false;
                        break;
                }

                return _assignTestDisabledIndicator;
            }
        }

        public bool BatchDisabledIndicator
        {
            get
            {
                _batchDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryBatches);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.SelectedTesting is { Count: > 0 } && _userPermissions.Create)
                        {
                            var selectedDiseaseId = LaboratoryService.SelectedTesting.First().DiseaseID;
                            var selectedTestNameTypeId =
                                LaboratoryService.SelectedTesting.First().TestNameTypeID;
                            const long inProgress = (long)TestStatusTypeEnum.InProgress;

                            var selectedCount = LaboratoryService.SelectedTesting.Count;
                            _batchDisabledIndicator = selectedCount != LaboratoryService.SelectedTesting.Count(x =>
                                selectedTestNameTypeId != null && x.TestNameTypeID == (long)selectedTestNameTypeId && x.DiseaseID == selectedDiseaseId && x.TestStatusTypeID == inProgress && x.TestNameTypeID != null && x.TestResultTypeID == null);
                        }
                        break;

                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.SelectedMyFavorites is { Count: > 0 } && _userPermissions.Create)
                        {
                            var selectedDiseaseId = LaboratoryService.SelectedMyFavorites.First().DiseaseID;
                            var selectedTestNameTypeId =
                                LaboratoryService.SelectedMyFavorites.First().TestNameTypeID;
                            const long inProgress = (long)TestStatusTypeEnum.InProgress;

                            var selectedCount = LaboratoryService.SelectedMyFavorites.Count;
                            _batchDisabledIndicator = selectedCount != LaboratoryService.SelectedMyFavorites.Count(x =>
                                selectedTestNameTypeId != null && x.TestNameTypeID != null && x.TestNameTypeID == (long)selectedTestNameTypeId && x.DiseaseID == selectedDiseaseId && x.TestStatusTypeID == inProgress && x.TestNameTypeID != null && x.TestResultTypeID == null);
                        }
                        break;
                }

                return _batchDisabledIndicator;
            }
        }

        public bool CancelTransferDisabledIndicator
        {
            get
            {
                _cancelTransferDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTransferred);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Transferred:
                        if (LaboratoryService.SelectedTransferred is { Count: > 0 } && _userPermissions.Delete)
                            _cancelTransferDisabledIndicator = false;
                        break;
                }

                return _cancelTransferDisabledIndicator;
            }
        }

        public bool PrintTransferDisabledIndicator
        {
            get
            {
                _printTransferDisabledIndicator = true;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Transferred:
                        if (LaboratoryService.SelectedTransferred is { Count: > 0 })
                            _printTransferDisabledIndicator = false;
                        break;
                }

                return _printTransferDisabledIndicator;
            }
        }

        public bool RemoveSampleDisabledIndicator
        {
            get
            {
                _removeSampleDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryBatches);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Batches:

                        if (LaboratoryService.SelectedBatchTests is { Count: > 0 } && _userPermissions.Write) _removeSampleDisabledIndicator = false;
                        break;
                }

                return _removeSampleDisabledIndicator;
            }
        }

        public bool AddGroupResultDisabledIndicator
        {
            get
            {
                _addGroupResultDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryBatches);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Batches:

                        if (LaboratoryService.SelectedBatches is
                            { Count: 1 } && _userPermissions.Write) //only 1 batch at a time allowed to get a group result
                            if (!LaboratoryService.SelectedBatches.Any(x =>
                                    x.BatchStatusTypeID is (long)BatchTestStatusTypeEnum.Closed))
                                _addGroupResultDisabledIndicator = false;
                        break;
                }

                return _addGroupResultDisabledIndicator;
            }
        }

        public bool CloseBatchDisabledIndicator
        {
            get
            {
                _closeBatchDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryBatches);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Batches:
                        if (LaboratoryService.SelectedBatches is { Count: > 0 } && _userPermissions.Write)
                            if (!LaboratoryService.SelectedBatches.Any(x =>
                                    x.BatchStatusTypeID is (long)BatchTestStatusTypeEnum.Closed))
                                _closeBatchDisabledIndicator = false;
                        break;
                }

                return _closeBatchDisabledIndicator;
            }
        }

        public bool ApproveDisabledIndicator
        {
            get
            {
                _approveDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryApprovals);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Approvals:
                        if (LaboratoryService.SelectedApprovals is { Count: > 0 } && _userPermissions.Write)
                            _approveDisabledIndicator = false;
                        break;
                }

                return _approveDisabledIndicator;
            }
        }

        public bool RejectDisabledIndicator
        {
            get
            {
                _rejectDisabledIndicator = true;

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryApprovals);

                switch (Tab)
                {
                    case LaboratoryTabEnum.Approvals:
                        if (LaboratoryService.SelectedApprovals is { Count: > 0 } && _userPermissions.Write)
                            _rejectDisabledIndicator = false;
                        break;
                }

                return _rejectDisabledIndicator;
            }
        }

        public bool SaveDisabledIndicator
        {
            get
            {
                _saveDisabledIndicator = true;

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        if (LaboratoryService.PendingSaveSamples is { Count: > 0 }) _saveDisabledIndicator = false;
                        break;

                    case LaboratoryTabEnum.Testing:
                        if (LaboratoryService.PendingSaveTesting is { Count: > 0 }) _saveDisabledIndicator = false;
                        break;

                    case LaboratoryTabEnum.Transferred:
                        if (LaboratoryService.PendingSaveTransferred is { Count: > 0 }) _saveDisabledIndicator = false;
                        break;

                    case LaboratoryTabEnum.MyFavorites:
                        if (LaboratoryService.PendingSaveMyFavorites is { Count: > 0 }) _saveDisabledIndicator = false;
                        break;

                    case LaboratoryTabEnum.Batches:
                        if (LaboratoryService.PendingSaveBatches is { Count: > 0 }
                            || LaboratoryService.PendingSaveTesting is { Count: > 0 })
                            _saveDisabledIndicator = false;
                        break;

                    case LaboratoryTabEnum.Approvals:
                        if (LaboratoryService.PendingSaveApprovals is { Count: > 0 }) _saveDisabledIndicator = false;
                        break;
                }

                authenticatedUser.ChangesPendingSave = !_saveDisabledIndicator;

                return _saveDisabledIndicator;
            }
        }

        #endregion

        #region Member Variables

        private bool _accessionDisabledIndicator;
        private bool _aliquotDisabledIndicator;
        private bool _assignTestDisabledIndicator;
        private bool _batchDisabledIndicator;
        private bool _cancelTransferDisabledIndicator;
        private bool _printTransferDisabledIndicator;
        private bool _removeSampleDisabledIndicator;
        private bool _addGroupResultDisabledIndicator;
        private bool _closeBatchDisabledIndicator;
        private bool _approveDisabledIndicator;
        private bool _rejectDisabledIndicator;
        private bool _saveDisabledIndicator;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public ActionsBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected ActionsBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            base.OnInitialized();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            try
            {
                if (firstRender)
                    await JsRuntime.InvokeVoidAsync("LaboratoryActions.SetDotNetReference", _token,
                        DotNetObjectReference.Create(this));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion

        #region Accession Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnAccessionClick()
        {
            var result = await DiagService.OpenAsync<AccessionInDialog>(Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAccessionInFormHeading),
                new Dictionary<string, object> { { "Tab", Tab } },
                new DialogOptions
                {
                    ShowTitle = true,
                    Style = LaboratoryModuleCSSClassConstants.AccessionInDialog,
                    AutoFocusFirstElement = true,
                    CloseDialogOnOverlayClick = true,
                    ShowClose = true,
                    Draggable = false,
                    Resizable = false
                });

            if (result is DialogReturnResult returnResult && returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                await AccessionInEvent.InvokeAsync();
        }

        #endregion

        #region Aliquot Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnAliquotClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<CreateAliquotDerivative>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAliquotsDerivativesModalHeading),
                    new Dictionary<string, object> { { "Tab", Tab } },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.CreateAliquotDerivativeDialog,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == 0)
                    await AliquotEvent.InvokeAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Assign Test Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnAssignTestClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<AssignTest>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAssignTestModalHeading),
                    new Dictionary<string, object> { { "Tab", Tab } },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.AssignTestDialog,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    await AssignTestEvent.InvokeAsync();

                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Amend Test Result Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnAmendTestResultClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<AmendTestResult>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryAmendTestResultModalHeading),
                    new Dictionary<string, object> { { "Test", LaboratoryService.SelectedTesting.FirstOrDefault() } },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.AmendTestResultDialog,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    await AmendTestResultEvent.InvokeAsync();

                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Batch Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnBatchClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<CreateBatch>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryCreateBatchModalHeading),
                    new Dictionary<string, object>
                    {
                        {"SelectedTests", LaboratoryService.SelectedTesting},
                        {"LaboratoryModuleAction", (int) LaboratoryModuleActions.CreateBatch}, {"Batch", null}
                    },
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.CreateBatchDialog,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    await BatchEvent.InvokeAsync();

                    DiagService.Close(result);
                }

                //if (result == null)
                //    await BatchEvent.InvokeAsync();
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
        public async Task OnCloseBatchClick()
        {
            var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.TestStatus, HACodeList.NoneHACode);
            var canCloseBatchIndicator = true;

            foreach (var batch in LaboratoryService.SelectedBatches)
            {
                if (!canCloseBatchIndicator) continue;
                if (batch.Tests is null || !batch.Tests.Any()) continue;
                if (!batch.Tests.Any(x => x.TestResultTypeID is null))
                {
                    batch.BatchStatusTypeID = (long)BatchTestStatusTypeEnum.Closed;
                    batch.BatchStatusTypeName =
                        list.First(x => x.IdfsBaseReference == (long)BatchTestStatusTypeEnum.Closed).Name;
                    batch.RowAction = (int)RowActionTypeEnum.Update;
                    TogglePendingSaveBatches(batch);
                }
                else
                {
                    canCloseBatchIndicator = false;
                    await ShowErrorDialog(
                        MessageResourceKeyConstants.BatchesAllTestResultsMustBeEnteredToCloseABatchMessage,
                        null);
                }
            }

            if (canCloseBatchIndicator)
                await SaveEvent.InvokeAsync();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnRemoveSampleClick()
        {
            LaboratoryService.SelectedBatchTests ??= new List<TestingGetListViewModel>();

            foreach (var test in LaboratoryService.SelectedBatchTests)
            {
                test.BatchTestID = null;
                test.RowAction = (int)RowActionTypeEnum.Update;
                test.ActionPerformedIndicator = true;
                TogglePendingSaveTesting(test);
            }

            LaboratoryService.SelectedBatchTests.Clear();
            await SaveEvent.InvokeAsync();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddGroupResultClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<AddGroupResult>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryBatchResultsDetailsModalHeading),
                    new Dictionary<string, object> { { "Batch", LaboratoryService.SelectedBatches.FirstOrDefault() } },
                    new DialogOptions
                    {
                        Width = LaboratoryModuleCSSClassConstants.DefaultDialogWidth,
                        Height = "250px",
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                if (result is DialogReturnResult)
                {
                    await AddGroupResultEvent.InvokeAsync();

                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Cancel Transfer Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnCancelTransferClick()
        {
            try
            {
                List<DialogButton> buttons = new();
                DialogButton yesButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                DialogButton noButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                Dictionary<string, object> dialogParams = new()
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants
                            .LaboratoryTransferredAreYouSureYouWantToCancelThisTransferMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        await CancelTransfer();

                        await CancelTransferOutEvent.InvokeAsync();

                        DiagService.Close(result);
                    }
                    else
                    {
                        DiagService.Close(result);
                    }
                }
                else
                {
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Print Transfer Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnPrintTransferClick()
        {
            try
            {
                ReportViewModel model = new();
                model.AddParameter("ObjID", LaboratoryService.SelectedTransferred.First().TransferID.ToString());
                model.AddParameter("LangID", GetCurrentLanguage());
                model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));

                var result = await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(ButtonResourceKeyConstants.LaboratoryTransferReportButtonText),
                    new Dictionary<string, object>
                        {{"ReportName", "SamplesTransfer"}, {"Parameters", model.Parameters}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog,
                        Resizable = true,
                        Draggable = false
                    });

                if (result == null)
                    return;

                await PrintTransferEvent.InvokeAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Approve Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("OnApproveClick")]
        public async Task OnApproveClick()
        {
            try
            {
                await Approve(Tab);

                await ApproveEvent.InvokeAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                await JsRuntime.InvokeAsync<string>("hideApproveProcessingIndicator", _token).ConfigureAwait(false);
            }
        }

        #endregion

        #region Reject Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("OnRejectClick")]
        public async Task OnRejectClick()
        {
            try
            {
                await Reject(Tab);

                await RejectEvent.InvokeAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                await JsRuntime.InvokeAsync<string>("hideRejectProcessingIndicator", _token).ConfigureAwait(false);
            }
        }

        #endregion

        #region Save Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable("OnSaveClick")]
        public async Task OnSaveClick()
        {
            try
            {
                var response = await SaveLaboratory();

                if (response == 0)
                    await SaveEvent.InvokeAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                await JsRuntime.InvokeAsync<string>("hideProcessingIndicator", _token).ConfigureAwait(false);

                if (LaboratoryService.TestResultExternalEnteredOrValidationRejectedIndicator)
                    await JsRuntime.InvokeAsync<string>("updateNotificationEnvelopeCount", _token).ConfigureAwait(false);

                LaboratoryService.TestResultExternalEnteredOrValidationRejectedIndicator = false;
            }
        }

        #endregion

        #endregion
    }
}