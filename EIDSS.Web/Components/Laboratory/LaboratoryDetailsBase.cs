#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.FlexForm;
using EIDSS.Domain.ViewModels.Laboratory;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels;
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
using static System.Int32;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Laboratory
{
    /// <summary>
    /// </summary>
    public class LaboratoryDetailsBase : LaboratoryBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<LaboratoryDetailsBase> Logger { get; set; }
        [Inject] private IUserConfigurationService ConfigurationService { get; set; }

        #endregion

        #region Parameters

        [Parameter] public LaboratoryTabEnum Tab { get; set; }
        [Parameter] public long SampleId { get; set; }
        [Parameter] public long? TestId { get; set; }
        [Parameter] public string DiseaseId { get; set; }
        [Parameter] public long? TransferId { get; set; }
        [Parameter] public long? TransferredInSampleId { get; set; }
        [Parameter] public SamplesGetListViewModel Sample { get; set; }
        [Parameter] public TestingGetListViewModel Test { get; set; }
        [Parameter] public TransferredGetListViewModel Transfer { get; set; }

        #endregion

        #region Properties

        public LaboratoryDetailViewModel Model { get; set; }
        protected RadzenTemplateForm<LaboratoryDetailViewModel> Form { get; set; }
        protected FlexForm.FlexForm AdditionalTestDetailsFlexForm { get; set; }
        protected RadzenPanel Panel { get; set; } = new();
        protected List<FlexFormTemplateDeterminantValuesListViewModel> FormTemplates { get; set; }
        protected SampleDetails SampleDetailsComponent { get; set; }
        public bool? MyFavoriteWritePermission { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public LaboratoryDetailsBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected LaboratoryDetailsBase() : base(CancellationToken.None)
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
                authenticatedUser = _tokenService.GetAuthenticatedUser();

                _logger = Logger;

                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                Model = new LaboratoryDetailViewModel
                {
                    SampleID = SampleId,
                    TestID = TestId,
                    TransferID = SampleId,
                    ShowTransferDetails = TransferId != null,
                    Sample = new SamplesGetListViewModel(),
                    Test = new TestingGetListViewModel(),
                    Tests = new List<TestingGetListViewModel>(),
                    Transfer = new TransferredGetListViewModel()
                };

                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratorySamples);
                Model.SamplesWritePermission = _userPermissions.Write;
                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTesting);
                Model.TestingWritePermission = _userPermissions.Write;
                _userPermissions = GetUserPermissions(PagePermission.AccessToLaboratoryTransferred);
                Model.TransferredWritePermission = _userPermissions.Write;

                if (!IsNullOrEmpty(DiseaseId) && DiseaseId.Contains(","))
                {
                    var diseaseIDsSplit = DiseaseId.Split(",");
                    Model.DiseaseID = Convert.ToInt64(diseaseIDsSplit[0]);
                }
                else if (!IsNullOrEmpty(DiseaseId))
                {
                    Model.DiseaseID = Convert.ToInt64(DiseaseId);
                }

                if (Test is not null && TestId is not null && Test.TestID == TestId)
                {
                    Model.Test = Test.ShallowCopy();
                }
                else if (Test is null && TestId is not null)
                {
                    await GetTestDetails((long) TestId);
                }
                else if (SampleId > 0)
                {
                    const string sortColumn = "EIDSSLaboratorySampleID";
                    const string sortOrder = SortConstants.Descending;

                    var request = new TestingGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = sortColumn,
                        SortOrder = sortOrder,
                        DaysFromAccessionDate = null,
                        SampleID = SampleId,
                        FiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                        UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId),
                        UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                        UserOrganizationID = authenticatedUser.OfficeId,
                        UserSiteID = Convert.ToInt64(authenticatedUser.SiteId),
                        UserSiteGroupID = IsNullOrEmpty(authenticatedUser.SiteGroupID)
                            ? null
                            : Convert.ToInt64(authenticatedUser.SiteGroupID)
                    };
                    var tests = await LaboratoryClient.GetTestingList(request, _token);
                    if (_source.IsCancellationRequested == false)
                    {
                        if (tests.Any())
                        {
                            await GetTestDetails(tests.First().TestID);
                        }
                    }
                }

                if (Sample is not null && Sample.SampleID == SampleId)
                    Model.Sample = Sample.ShallowCopy();
                else
                {
                    Model.Sample = await GetSample(SampleId);
                    if (MyFavoriteWritePermission is not null)
                        Model.Sample.WritePermissionIndicator = (bool) MyFavoriteWritePermission;
                }

                if (Model.DiseaseID == 0 && !IsNullOrEmpty(Model.Sample.DiseaseID) &&
                    Model.Sample.DiseaseID.Contains(",") == false)
                    Model.DiseaseID = Convert.ToInt64(Model.Sample.DiseaseID);

                if (SampleId > 0)
                {
                    var sampleDetail = await LaboratoryClient.GetSampleDetail(GetCurrentLanguage(), SampleId,
                        Convert.ToInt64(authenticatedUser.EIDSSUserId), _token);

                    // Apply fields from the get detail method that are not included on the get list to improve performance.
                    Model.Sample.SentToOrganizationName = sampleDetail.SentToOrganizationName;
                    Model.Sample.PatientSpeciesVectorInformation = sampleDetail.PatientSpeciesVectorInformation;
                    Model.Sample.CollectedByOrganizationName = sampleDetail.CollectedByOrganizationName;
                    Model.Sample.CollectedByPersonName = sampleDetail.CollectedByPersonName;
                    Model.Sample.DestructionMethodTypeName = IsNullOrEmpty(Model.Sample.DestructionMethodTypeName) ? sampleDetail.DestructionMethodTypeName : Model.Sample.DestructionMethodTypeName;
                    Model.Sample.ParentEIDSSLaboratorySampleID = sampleDetail.ParentLaboratorySampleEIDSSID;
                    Model.Sample.ReportOrSessionTypeName = sampleDetail.ReportSessionTypeName;
                }

                if (Transfer is not null && TransferId is not null && Transfer.TransferID == TransferId)
                {
                    Model.Transfer = Transfer.ShallowCopy();
                }
                else if (Transfer is null && TransferId is not null)
                {
                    Model.Transfer = await GetTransfer(SampleId, TransferredInSampleId);
                }

                if (TransferId is not null)
                {
                    var transferDetail = await LaboratoryClient.GetTransferDetail(GetCurrentLanguage(),
                        SampleId,
                        Convert.ToInt64(authenticatedUser.EIDSSUserId), _token);

                    // Apply fields from the get detail method that are not included on the get list to improve performance.
                    Model.Transfer.AllowDatesInThePast = ConfigurationService.SystemPreferences.AllowPastDates;
                    Model.Transfer.CanEditSampleTransferFormsAfterTransferIsSaved =
                        GetUserPermissions(PagePermission.CanEditSampleTransferFormsAfterTransferIsSaved).Execute;
                    Model.Transfer.PrintBarcodeIndicator = true;
                    Model.Transfer.SentByPersonName = transferDetail.SentByPersonName;
                    Model.Transfer.TransferredFromOrganizationName = transferDetail.TransferredFromOrganizationName;

                    if (Tab == LaboratoryTabEnum.Transferred)
                    {
                        long? diseaseId = null;
                        var diseaseName = Empty;

                        if (!IsNullOrEmpty(Model.Transfer.DiseaseID))
                        {
                            if (Model.Transfer.DiseaseID.Contains(","))
                            {
                                var diseaseIDsSplit = Model.Transfer.DiseaseID.Split(",");
                                diseaseId = Convert.ToInt64(diseaseIDsSplit[0]);
                            }
                            else
                            {
                                diseaseId = Convert.ToInt64(Model.Transfer.DiseaseID);
                            }

                            if (Model.Transfer.DiseaseName is not null)
                                if (Model.Transfer.DiseaseName.Contains("|"))
                                {
                                    var diseaseNamesSplit = Model.Transfer.DiseaseName.Split("|");
                                    diseaseName = diseaseNamesSplit[0];
                                }
                                else
                                {
                                    diseaseName = Model.Transfer.DiseaseName;
                                }
                        }

                        // Transferred to an external organization; does not use EIDSS, or
                        // the receiving organization cannot enter the results.
                        // Sending organization may enter the test results.
                        LaboratoryService.PendingSaveTesting ??= new List<TestingGetListViewModel>();
                        if (Model.Transfer.TestID is null)
                        {
                            Model.Test = new TestingGetListViewModel
                            {
                                TestID = LaboratoryService.PendingSaveTesting.Count(x =>
                                             x.RowAction == (int) RowActionTypeEnum.Insert) +
                                         1 * -1,
                                DiseaseID = diseaseId,
                                DiseaseName = diseaseName,
                                ExternalTestIndicator = true,
                                ResultEnteredByPersonName = authenticatedUser.LastName +
                                                            (IsNullOrEmpty(authenticatedUser.FirstName)
                                                                ? ""
                                                                : ", " + authenticatedUser.FirstName),
                                PerformedByOrganizationID = Model.Transfer.TransferredToOrganizationID,
                                PerformedByOrganizationName = Model.Transfer.TransferredToOrganizationName
                            };
                            TestId = Model.Test.TestID;
                            Model.Transfer.TestDiseaseID = Model.Test.DiseaseID;
                        }
                    }
                }

                switch (Tab)
                {
                    case LaboratoryTabEnum.Samples:
                        Model.AccordionIndex = 0;
                        break;
                    case LaboratoryTabEnum.Testing:
                        Model.AccordionIndex = 1;
                        break;
                    case LaboratoryTabEnum.Transferred:
                        Model.AccordionIndex = 4;
                        break;
                    case LaboratoryTabEnum.MyFavorites:
                        Model.AccordionIndex = TestId is null ? 0 : 1;
                        break;
                }

                await base.OnInitializedAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
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
            SuppressFinalize(this);
        }

        #endregion

        #region Submit Event

        /// <summary>
        /// </summary>
        protected async Task OnSubmit()
        {
            try
            {
                if (Form.EditContext.Validate())
                {
                    if (TestId is not null)
                    {
                        Model.Test.AdditionalTestDetailsFlexFormRequest = FlexFormRequest;
                        var response = await AdditionalTestDetailsFlexForm.CollectAnswers();
                        await InvokeAsync(StateHasChanged);

                        if (Model.Test.AdditionalTestDetailsFlexFormRequest is not null)
                        {
                            Model.Test.AdditionalTestDetailsFlexFormRequest.idfsFormTemplate =
                                response.idfsFormTemplate;
                            Model.Test.AdditionalTestDetailsFlexFormAnswers = AdditionalTestDetailsFlexForm.Answers;
                            Model.Test.AdditionalTestDetailsObservationParameters = response.Answers;
                        }

                        Model.Test.EIDSSLocalOrFieldSampleID = Model.Sample.EIDSSLocalOrFieldSampleID;
                        Model.Test.RowAction = (int) RowActionTypeEnum.Update;
                        await UpdateTest(Model.Test);

                        if (Model.Test.FavoriteIndicator)
                        {
                            if (LaboratoryService.MyFavorites == null ||
                                LaboratoryService.MyFavorites.All(x => x.TestID != Model.Test.TestID))
                                await GetMyFavorite(Model.Sample, Model.Test, Model.Transfer, null);

                            if (LaboratoryService.MyFavorites != null &&
                                LaboratoryService.MyFavorites.Any(x =>
                                    x.TestID is not null && x.TestID == Model.Test.TestID))
                                await UpdateMyFavorite(LaboratoryService.MyFavorites.First(x =>
                                    x.TestID is not null && x.TestID == Model.Test.TestID));
                        }
                    }

                    Model.Sample.RowAction = (int) RowActionTypeEnum.Update;
                    await UpdateSample(Model.Sample);

                    if (Model.Sample.FavoriteIndicator)
                    {
                        if (LaboratoryService.MyFavorites == null ||
                            LaboratoryService.MyFavorites.All(x => x.SampleID != Model.Sample.SampleID))
                            await GetMyFavorite(Model.Sample, Model.Test, Model.Transfer, null);

                        if (LaboratoryService.MyFavorites is not null &&
                            LaboratoryService.MyFavorites.Any(x => x.SampleID == Model.Sample.SampleID))
                            await UpdateMyFavorite(LaboratoryService.MyFavorites.First(x =>
                                x.SampleID == Model.Sample.SampleID));
                    }

                    if (TransferId is not null)
                    {
                        if (Model.Test.TestID <= 0)
                        {
                            Model.Test.TestID = LaboratoryService.NewTestsAssignedCount + 1 * -1;
                            LaboratoryService.NewTestsAssignedCount += 1;
                            Model.Test.RowAction = (int) RowActionTypeEnum.Insert;
                        }
                        else
                        {
                            Model.Test.RowAction = (int) RowActionTypeEnum.Update;
                        }

                        Model.Test.ActionPerformedIndicator = true;
                        Model.Test.SampleID = Model.Transfer.TransferredOutSampleID;
                        Model.Test.AccessionComment = Model.Transfer.AccessionComment;
                        Model.Test.AccessionConditionOrSampleStatusTypeName =
                            Model.Transfer.AccessionConditionOrSampleStatusTypeName;
                        Model.Test.AccessionDate = Model.Transfer.AccessionDate;
                        Model.Test.EIDSSAnimalID = Model.Transfer.EIDSSAnimalID;
                        Model.Test.EIDSSLaboratorySampleID = Model.Transfer.EIDSSLaboratorySampleID;
                        Model.Test.EIDSSLocalOrFieldSampleID = Model.Transfer.EIDSSLocalOrFieldSampleID;
                        Model.Test.EIDSSReportOrSessionID = Model.Transfer.EIDSSReportOrSessionID;
                        Model.Test.FavoriteIndicator = Model.Transfer.FavoriteIndicator;
                        Model.Test.FunctionalAreaName = Model.Transfer.FunctionalAreaName;
                        Model.Test.PatientOrFarmOwnerName = Model.Transfer.PatientOrFarmOwnerName;
                        Model.Test.SampleTypeName = Model.Transfer.SampleTypeName;
                        Model.Test.SiteID = Model.Transfer.TransferredFromOrganizationSiteID;
                        Model.Test.TransferID = Model.Transfer.TransferID;

                        Model.Transfer.ContactPersonName = Model.Test.ContactPersonName;
                        Model.Transfer.ResultDate = Model.Test.ResultDate;
                        Model.Transfer.StartedDate = Model.Test.StartedDate;
                        Model.Transfer.TestCategoryTypeID = Model.Test.TestCategoryTypeID;
                        Model.Transfer.TestID = Model.Test.TestID;
                        Model.Transfer.TestNameTypeID = Model.Test.TestNameTypeID;
                        Model.Transfer.TestNameTypeName = Model.Test.TestNameTypeName;
                        Model.Transfer.TestResultTypeID = Model.Test.TestResultTypeID;
                        Model.Transfer.TestResultTypeName = Model.Test.TestResultTypeName;
                        Model.Transfer.TestStatusTypeID = Model.Test.TestStatusTypeID;
                        Model.Transfer.TestStatusTypeName = Model.Test.TestStatusTypeName;
                        Model.Transfer.RowAction = (int) RowActionTypeEnum.Update;
                        Model.Transfer.ActionPerformedIndicator = true;

                        await UpdateTest(Model.Test);

                        await UpdateTransfer(Model.Transfer);

                        if (Model.Transfer.FavoriteIndicator)
                        {
                            if (LaboratoryService.MyFavorites == null ||
                                LaboratoryService.MyFavorites.All(x =>
                                    x.SampleID != Model.Transfer.TransferredOutSampleID))
                                await GetMyFavorite(Model.Sample, Model.Test, Model.Transfer, null);

                            if (LaboratoryService.MyFavorites is not null &&
                                LaboratoryService.MyFavorites.Any(x =>
                                    x.SampleID == Model.Transfer.TransferredOutSampleID))
                                await UpdateMyFavorite(LaboratoryService.MyFavorites.First(x =>
                                    x.SampleID == Model.Transfer.TransferredOutSampleID));
                        }

                        if (Model.Transfer.PrintBarcodeIndicator)
                        {
                            await GenerateBarcodeReport(Model.Transfer.EIDSSLaboratorySampleID);

                            DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.Save});
                        }
                        else
                        {
                            DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.Save});
                        }
                    }
                    else
                    {
                        DiagService.Close(new DialogReturnResult {ButtonResultText = DialogResultConstants.Save});
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Print Sample Form Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnSamplePaperFormReportClick()
        {
            try
            {
                ReportViewModel model = new();
                model.AddParameter("ObjID", SampleId.ToString());
                model.AddParameter("LangID", GetCurrentLanguage());
                model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratorySampleReportHeading),
                    new Dictionary<string, object> {{"ReportName", "Samples"}, {"Parameters", model.Parameters}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog,
                        Resizable = true,
                        Draggable = false
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Print Test Form Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnTestResultPaperFormReportClick()
        {
            try
            {
                ReportViewModel model = new();
                model.AddParameter("ObjID", TestId.ToString());
                model.AddParameter("LangID", GetCurrentLanguage());
                model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTestResultReportHeading),
                    new Dictionary<string, object>
                        {{"ReportName", "LaboratoryTests"}, {"Parameters", model.Parameters}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog,
                        Resizable = true,
                        Draggable = false
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Print Transfer Form Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public async Task OnTransferPaperFormReportClick()
        {
            try
            {
                ReportViewModel model = new();
                model.AddParameter("ObjID", SampleId.ToString());
                model.AddParameter("LangID", GetCurrentLanguage());
                model.AddParameter("PersonID", Convert.ToString(authenticatedUser.PersonId));

                await DiagService.OpenAsync<DisplayReport>(
                    Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTransferReportHeading),
                    new Dictionary<string, object>
                        {{"ReportName", "SamplesTransfer"}, {"Parameters", model.Parameters}},
                    new DialogOptions
                    {
                        Style = LaboratoryModuleCSSClassConstants.LaboratoryPaperFormsDialog,
                        Resizable = true,
                        Draggable = false
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Cancel Event

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
                        {
                            SampleDetailsComponent.OnCancel();
                            DiagService.Close(result);
                        }
                }
                else
                {
                    SampleDetailsComponent.OnCancel();
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

        #region Test Methods

        /// <summary>
        /// </summary>
        /// <param name="testId"></param>
        /// <returns></returns>
        private async Task GetTestDetails(long testId)
        {
            Model.Test = await GetTest(testId);

            FlexFormRequest = new FlexFormQuestionnaireGetRequestModel
            {
                LangID = GetCurrentLanguage(),
                idfObservation = Model.Test.ObservationID,
                idfsDiagnosis = Model.Test.DiseaseID,
                idfsFormType = (long) FlexibleFormTypeEnum.LaboratoryTestRun
            };

            FlexFormTemplateGetRequestModel request = new()
            {
                LanguageId = GetCurrentLanguage(),
                idfsFormTemplate = null,
                idfsFormType = (long) FlexibleFormTypeEnum.LaboratoryTestRun
            };
            var formTemplates = await FlexFormClient.GetTemplateList(request);
            FormTemplates = new List<FlexFormTemplateDeterminantValuesListViewModel>();
            foreach (var template in formTemplates)
            {
                var determinantValueTemplate = await GetFlexFormDeterminantValues(template.idfsFormTemplate);
                if (determinantValueTemplate != null)
                    FormTemplates.Add(determinantValueTemplate);
            }

            var formTemplate = FormTemplates.Where(x => x.idfsBaseReference == Model.Test.TestNameTypeID)
                .ToList();
            if (formTemplate.Any())
                FlexFormRequest.idfsFormTemplate = formTemplate.First().idfsFormTemplate;

            AdditionalTestDetailsFlexForm ??= new FlexForm.FlexForm();
            if (Model.Test.AdditionalTestDetailsFlexFormAnswers is not null)
                FlexFormRequest.ReviewAnswers = Model.Test.AdditionalTestDetailsFlexFormAnswers;
            await AdditionalTestDetailsFlexForm.SetRequestParameter(FlexFormRequest);

            if (testId > 0)
            {
                var testDetail = await LaboratoryClient.GetTestDetail(GetCurrentLanguage(), testId,
                    Convert.ToInt64(authenticatedUser.EIDSSUserId), _token);

                // Apply fields from the get detail method that are not included on the get list to improve performance.
                Model.Test.ResultEnteredByPersonName ??= testDetail.ResultEnteredByPersonName;
                Model.Test.ValidatedByPersonName ??= testDetail.ValidatedByPersonName;

                //Allow updating of the test fields for an external test until the test/transfer is saved.
                if (Model.Test.ExternalTestIndicator)
                {
                    Model.Test.TestCategoryTypeDisabledIndicator = false;
                    Model.Test.TestNameTypeDisabledIndicator = false;
                    Model.Test.TestResultTypeDisabledIndicator = false;
                    Model.Test.ResultDateDisabledIndicator = false;
                    Model.Test.TestedByDisabledIndicator = false;
                }
            }
        }

        #endregion

        #region Additional Test Details Events

        /// <summary>
        /// </summary>
        /// <param name="formTemplateId"></param>
        /// <returns></returns>
        private async Task<FlexFormTemplateDeterminantValuesListViewModel> GetFlexFormDeterminantValues(
            long formTemplateId)
        {
            FlexFormTemplateDeterminantValuesGetRequestModel request = new();

            try
            {
                request.LanguageId = GetCurrentLanguage();
                request.idfsFormTemplate = formTemplateId;

                var list = await FlexFormClient.GetTemplateDeterminantValues(request);
                return list?.FirstOrDefault();
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