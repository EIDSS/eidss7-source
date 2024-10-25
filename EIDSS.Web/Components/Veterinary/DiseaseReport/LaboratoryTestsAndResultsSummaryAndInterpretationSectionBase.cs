#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Extensions;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class LaboratoryTestsAndResultsSummaryAndInterpretationSectionBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] protected ITokenService TokenService { get; set; }
        [Inject] private ILogger<LaboratoryTestsAndResultsSummaryAndInterpretationSectionBase> Logger { get; set; }
        [Inject] public IFlexFormClient FlexFormClient { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }
        [Inject] private INotificationSiteAlertService NotificationSiteAlertService { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel Model { get; set; }
        [Parameter] public EventCallback SaveEvent { get; set; }

        #endregion

        #region Properties

        public bool LaboratoryTestsIsLoading { get; set; }
        public bool LaboratoryTestInterpretationsIsLoading { get; set; }
        protected RadzenDataGrid<LaboratoryTestGetListViewModel> LaboratoryTestsGrid { get; set; }

        protected RadzenDataGrid<LaboratoryTestInterpretationGetListViewModel> LaboratoryTestInterpretationsGrid
        {
            get;
            set;
        }

        public bool IsProcessing { get; set; }

        public int LaboratoryTestsCount { get; set; }
        public int LaboratoryTestInterpretationsCount { get; set; }
        private int LaboratoryTestPreviousPageSize { get; set; }
        private int LaboratoryTestInterpretationPreviousPageSize { get; set; }

        public string LabTestsSubSectionHeadingResourceKey { get; set; }
        public string ResultsSummaryAndInterpretationSubSectionResourceKey { get; set; }
        public string LaboratoryTestDetailsHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationDetailsHeadingResourceKey { get; set; }
        public string LaboratoryTestsFieldSampleIdColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestsSpeciesColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestsAnimalIdColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestsTestDiseaseColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestsTestNameColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestsResultObservationColumnHeadingResourceKey { get; set; }
        public string LabSampleIdFieldLabelResourceKey { get; set; }
        public string SampleTypeFieldLabelResourceKey { get; set; }
        public string TestStatusFieldLabelResourceKey { get; set; }
        public string TestCategoryFieldLabelResourceKey { get; set; }
        public string ResultDateFieldLabelResourceKey { get; set; }
        public string DiseaseColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsSpeciesColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsAnimalIdColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsDiseaseColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsTestNameColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsTestCategoryColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsTestResultColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsLabSampleIdColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsSampleTypeColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsFieldSampleIdColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsRuleOutRuleInColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsRuleOutRuleInCommentColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsDateInterpretedColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsInterpretedByColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsValidatedColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsValidatedCommentColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsDateValidatedColumnHeadingResourceKey { get; set; }
        public string LaboratoryTestInterpretationsValidatedByColumnHeadingResourceKey { get; set; }

        public bool CanInterpretTestResultPermissionIndicator { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;
        private int _laboratoryTestsDatabaseQueryCount;
        private int _laboratoryTestsNewRecordCount;
        private int _laboratoryTestsLastDatabasePage;
        private int _laboratoryTestsLastPage = 1;
        private int _laboratoryTestInterpretationsDatabaseQueryCount;
        private int _laboratoryTestInterpretationsNewRecordCount;
        private int _laboratoryTestInterpretationsLastDatabasePage;
        private int _laboratoryTestInterpretationsLastPage = 1;
        private UserPermissions _userPermissions;

        #endregion

        #region Constants

        private const string DefaultSortColumn = "TestNameTypeName";

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public LaboratoryTestsAndResultsSummaryAndInterpretationSectionBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected LaboratoryTestsAndResultsSummaryAndInterpretationSectionBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = TokenService.GetAuthenticatedUser();
            _userPermissions = GetUserPermissions(PagePermission.CanInterpretVetDiseaseReportSessionTestResult);
            CanInterpretTestResultPermissionIndicator = _userPermissions.Execute;

            if (Model.OutbreakCaseIndicator)
                LabTestsSubSectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.CreateVeterinaryCaseLabTestsInterpretationHeading);
            else if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                LabTestsSubSectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportLabTestsHeading);
            else
                LabTestsSubSectionHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportLabTestsHeading);

            if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
            {
                ResultsSummaryAndInterpretationSubSectionResourceKey = Localizer.GetString(HeadingResourceKeyConstants
                    .AvianDiseaseReportResultsSummaryInterpretationHeading);
                LaboratoryTestDetailsHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.AvianDiseaseReportLabTestDetailsModalHeading);
                LaboratoryTestInterpretationDetailsHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants
                    .AvianDiseaseReportInterpretationDetailsModalHeading);

                LaboratoryTestsSpeciesColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportLabTestsSpeciesColumnHeading);
                LaboratoryTestsFieldSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.AvianDiseaseReportLabTestsFieldSampleIDColumnHeading);
                LaboratoryTestsTestDiseaseColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.AvianDiseaseReportLabTestsTestDiseaseColumnHeading);
                LaboratoryTestsTestNameColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .AvianDiseaseReportLabTestsTestNameColumnHeading);
                LaboratoryTestsResultObservationColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.AvianDiseaseReportLabTestsResultObservationColumnHeading);

                LabSampleIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportLabTestsLabSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportLabTestsSampleTypeFieldLabel;
                TestStatusFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportLabTestsTestStatusFieldLabel;
                TestCategoryFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportLabTestsTestCategoryFieldLabel;
                ResultDateFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.AvianDiseaseReportLabTestsResultDateFieldLabel;

                LaboratoryTestInterpretationsSpeciesColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationSpeciesColumnHeading);
                LaboratoryTestInterpretationsDiseaseColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationDiseaseColumnHeading);
                LaboratoryTestInterpretationsTestNameColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationTestNameColumnHeading);
                LaboratoryTestInterpretationsTestCategoryColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationTestCategoryColumnHeading);
                LaboratoryTestInterpretationsTestResultColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationTestResultColumnHeading);
                LaboratoryTestInterpretationsLabSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationLabSampleIDColumnHeading);
                LaboratoryTestInterpretationsSampleTypeColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationSampleTypeColumnHeading);
                LaboratoryTestInterpretationsFieldSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationFieldSampleIDColumnHeading);
                LaboratoryTestInterpretationsRuleOutRuleInColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationRuleOutRuleInColumnHeading);
                LaboratoryTestInterpretationsRuleOutRuleInCommentColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationCommentsRuleOutRuleInColumnHeading);
                LaboratoryTestInterpretationsDateInterpretedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationDateInterpretedColumnHeading);
                LaboratoryTestInterpretationsInterpretedByColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationInterpretedByColumnHeading);
                LaboratoryTestInterpretationsValidatedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationValidatedColumnHeading);
                LaboratoryTestInterpretationsValidatedCommentColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationCommentsValidatedColumnHeading);
                LaboratoryTestInterpretationsDateValidatedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationDateValidatedColumnHeading);
                LaboratoryTestInterpretationsValidatedByColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .AvianDiseaseReportResultsSummaryInterpretationValidatedByColumnHeading);
            }
            else
            {
                ResultsSummaryAndInterpretationSubSectionResourceKey = Localizer.GetString(HeadingResourceKeyConstants
                    .LivestockDiseaseReportResultsSummaryInterpretationHeading);
                LaboratoryTestDetailsHeadingResourceKey =
                    Localizer.GetString(HeadingResourceKeyConstants.LivestockDiseaseReportLabTestDetailsModalHeading);
                LaboratoryTestInterpretationDetailsHeadingResourceKey = Localizer.GetString(HeadingResourceKeyConstants
                    .LivestockDiseaseReportInterpretationDetailsModalHeading);

                LaboratoryTestsFieldSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.LivestockDiseaseReportLabTestsFieldSampleIDColumnHeading);
                LaboratoryTestsAnimalIdColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportLabTestsAnimalIDColumnHeading);
                LaboratoryTestsTestDiseaseColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.LivestockDiseaseReportLabTestsTestDiseaseColumnHeading);
                LaboratoryTestsTestNameColumnHeadingResourceKey = Localizer.GetString(ColumnHeadingResourceKeyConstants
                    .LivestockDiseaseReportLabTestsTestNameColumnHeading);
                LaboratoryTestsResultObservationColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants.LivestockDiseaseReportLabTestsResultObservationColumnHeading);

                LabSampleIdFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportLabTestsLabSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportLabTestsSampleTypeFieldLabel;
                TestStatusFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportLabTestsTestStatusFieldLabel;
                TestCategoryFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportLabTestsTestCategoryFieldLabel;
                ResultDateFieldLabelResourceKey =
                    FieldLabelResourceKeyConstants.LivestockDiseaseReportLabTestsResultDateFieldLabel;

                LaboratoryTestInterpretationsAnimalIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationAnimalIDColumnHeading);
                LaboratoryTestInterpretationsDiseaseColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationDiseaseColumnHeading);
                LaboratoryTestInterpretationsTestNameColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationTestNameColumnHeading);
                LaboratoryTestInterpretationsTestCategoryColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationTestCategoryColumnHeading);
                LaboratoryTestInterpretationsTestResultColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationTestResultColumnHeading);
                LaboratoryTestInterpretationsLabSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationLabSampleIDColumnHeading);
                LaboratoryTestInterpretationsSampleTypeColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationSampleTypeColumnHeading);
                LaboratoryTestInterpretationsFieldSampleIdColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationFieldSampleIDColumnHeading);
                LaboratoryTestInterpretationsRuleOutRuleInColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationRuleOutRuleInColumnHeading);
                LaboratoryTestInterpretationsRuleOutRuleInCommentColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationCommentsRuleOutRuleInColumnHeading);
                LaboratoryTestInterpretationsDateInterpretedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationDateInterpretedColumnHeading);
                LaboratoryTestInterpretationsInterpretedByColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationInterpretedByColumnHeading);
                LaboratoryTestInterpretationsValidatedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationValidatedColumnHeading);
                LaboratoryTestInterpretationsValidatedCommentColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationCommentsValidatedColumnHeading);
                LaboratoryTestInterpretationsDateValidatedColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationDateValidatedColumnHeading);
                LaboratoryTestInterpretationsValidatedByColumnHeadingResourceKey = Localizer.GetString(
                    ColumnHeadingResourceKeyConstants
                        .LivestockDiseaseReportResultsSummaryInterpretationValidatedByColumnHeading);
            }

            // get linked surveillance session
            // lab tests and interpretations
            LoadSurveillanceData();

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
            }

            _disposedValue = true;
        }

        /// <summary>
        ///     Free up managed and unmanaged resources.
        /// </summary>
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                LaboratoryTestsIsLoading = true;
                LaboratoryTestInterpretationsIsLoading = true;

                await JsRuntime.InvokeVoidAsync(
                    "LaboratoryTestsAndResultsSummaryAndInterpretationSection.SetDotNetReference", _token,
                    DotNetObjectReference.Create(this));
            }
        }

        #endregion

        #region Surveillance Linked Report

        private void LoadSurveillanceData()
        {
            if (Model.SessionModel == null) return;

            Model.PendingSaveLaboratoryTests ??= new List<LaboratoryTestGetListViewModel>();

            if (Model.SessionModel.LaboratoryTests is {Count: > 0})
                Model.TestsConductedIndicator = (long) YesNoUnknownEnum.Yes;

            foreach (var test in Model.SessionModel.LaboratoryTests)
            {
                test.TestID = (Model.PendingSaveLaboratoryTests.Count + 1) * -1;
                test.MonitoringSessionID = null;
                test.SampleID = Model.SessionModel.Samples
                    .FirstOrDefault(x => x.SampleIDOriginal == test.SampleID)?.SampleID;
                test.RowAction = (int) RowActionTypeEnum.Insert;
                test.RowStatus = (int) RowStatusTypeEnum.Active;
                _laboratoryTestsNewRecordCount++;
                Model.PendingSaveLaboratoryTests.Add(test);
            }

            Model.PendingSaveLaboratoryTestInterpretations ??= new List<LaboratoryTestInterpretationGetListViewModel>();

            foreach (var interpretation in Model.SessionModel.TestInterpretations)
            {
                interpretation.TestInterpretationID = (Model.PendingSaveLaboratoryTestInterpretations.Count + 1) * -1;
                var testId = Model.SessionModel.LaboratoryTests
                    .FirstOrDefault(x => x.TestIDOriginal == interpretation.TestID)?.TestID;
                if (testId != null)
                    interpretation.TestID = (long) testId;
                interpretation.RowAction = (int) RowActionTypeEnum.Insert;
                interpretation.RowStatus = (int) RowStatusTypeEnum.Active;
                _laboratoryTestInterpretationsNewRecordCount++;
                Model.PendingSaveLaboratoryTestInterpretations.Add(interpretation);
            }
        }

        #endregion

        #region Data Grid Events

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadLaboratoryTestData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (LaboratoryTestsGrid.PageSize != 0)
                    pageSize = LaboratoryTestsGrid.PageSize;

                if (LaboratoryTestPreviousPageSize != pageSize)
                    LaboratoryTestsIsLoading = true;

                if (Model.DiseaseReportID > 0)
                    Model.Samples ??= await GetSamples(Model.DiseaseReportID, 1, 10, "EIDSSLaboratorySampleID", SortConstants.Descending)
                        .ConfigureAwait(false);

                LaboratoryTestPreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (Model.LaboratoryTests is null ||
                        _laboratoryTestsLastPage !=
                        (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize))
                        LaboratoryTestsIsLoading = true;

                    if (LaboratoryTestsIsLoading || !IsNullOrEmpty(args.OrderBy))
                    {
                        if (args.Sorts != null && args.Sorts.Any())
                        {
                            sortColumn = args.Sorts.First().Property;
                            sortOrder = SortConstants.Descending;
                            if (args.Sorts.First().SortOrder.HasValue)
                            {
                                var order = args.Sorts.First().SortOrder;
                                if (order != null && order.Value.ToString() == "Ascending")
                                    sortOrder = SortConstants.Ascending;
                            }
                        }

                        Model.LaboratoryTests =
                            await GetLaboratoryTests(Model.DiseaseReportID, page, pageSize, sortColumn, sortOrder)
                                .ConfigureAwait(false);

                        foreach (var laboratoryTest in Model.LaboratoryTests)
                        {
                            if (!IsNullOrEmpty(laboratoryTest.EIDSSLocalOrFieldSampleID)) continue;
                            if (Model.Samples is null) continue;
                            if (Model.Samples.Any(x => x.SampleID == laboratoryTest.SampleID))
                            {
                                laboratoryTest.EIDSSLocalOrFieldSampleID = Model.Samples
                                    .First(x => x.SampleID == laboratoryTest.SampleID).EIDSSLocalOrFieldSampleID;
                            }
                            else
                            {
                                if (Model.Samples.Any(x => x.RootSampleID == laboratoryTest.RootSampleID))
                                    laboratoryTest.EIDSSLocalOrFieldSampleID = Model.Samples
                                        .First(x => x.RootSampleID == laboratoryTest.RootSampleID)
                                        .EIDSSLocalOrFieldSampleID;
                            }
                        }

                        if (page == 1)
                            _laboratoryTestsDatabaseQueryCount = !Model.LaboratoryTests.Any()
                                ? 0
                                : Model.LaboratoryTests.First().TotalRowCount;
                    }
                    else if (Model.LaboratoryTests != null)
                    {
                        _laboratoryTestsDatabaseQueryCount = Model.LaboratoryTests.All(x =>
                            x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.TestID < 0)
                            ? 0
                            : Model.LaboratoryTests.First(x => x.TestID > 0).TotalRowCount;
                    }

                    if (Model.LaboratoryTests != null)
                        for (var index = 0; index < Model.LaboratoryTests.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.LaboratoryTests[index].TestID < 0)
                            {
                                Model.LaboratoryTests.RemoveAt(index);
                                index--;
                            }

                            if (Model.PendingSaveLaboratoryTests == null || index < 0 ||
                                Model.LaboratoryTests.Count == 0 || Model.PendingSaveLaboratoryTests.All(x =>
                                    x.TestID != Model.LaboratoryTests[index].TestID)) continue;
                            {
                                if (Model.PendingSaveLaboratoryTests
                                        .First(x => x.TestID == Model.LaboratoryTests[index].TestID)
                                        .RowStatus == (int) RowStatusTypeEnum.Inactive)
                                {
                                    Model.LaboratoryTests.RemoveAt(index);
                                    _laboratoryTestsDatabaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.LaboratoryTests[index] = Model.PendingSaveLaboratoryTests.First(x =>
                                        x.TestID == Model.LaboratoryTests[index].TestID);
                                }
                            }
                        }

                    LaboratoryTestsCount = _laboratoryTestsDatabaseQueryCount + _laboratoryTestsNewRecordCount;

                    if (_laboratoryTestsNewRecordCount > 0)
                    {
                        _laboratoryTestsLastDatabasePage = Math.DivRem(_laboratoryTestsDatabaseQueryCount, pageSize,
                            out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _laboratoryTestsLastDatabasePage == 0)
                            _laboratoryTestsLastDatabasePage += 1;

                        if (page >= _laboratoryTestsLastDatabasePage && Model.PendingSaveLaboratoryTests != null &&
                            Model.PendingSaveLaboratoryTests.Any(x => x.TestID < 0))
                        {
                            var newRecordsPendingSave =
                                Model.PendingSaveLaboratoryTests.Where(x => x.TestID < 0).ToList();
                            var counter = 0;
                            var pendingSavePage = page - _laboratoryTestsLastDatabasePage;
                            var quotientNewRecords = Math.DivRem(LaboratoryTestsCount, pageSize,
                                out var remainderNewRecords);

                            if (remainderNewRecords >= pageSize / 2)
                                quotientNewRecords += 1;

                            if (pendingSavePage == 0)
                            {
                                pageSize = pageSize - remainderDatabaseQuery > newRecordsPendingSave.Count
                                    ? newRecordsPendingSave.Count
                                    : pageSize - remainderDatabaseQuery;
                            }
                            else if (page - 1 == quotientNewRecords)
                            {
                                remainderDatabaseQuery = 1;
                                pageSize = remainderNewRecords;
                                Model.LaboratoryTests?.Clear();
                            }
                            else
                            {
                                Model.LaboratoryTests?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.LaboratoryTests?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.LaboratoryTests != null)
                            Model.LaboratoryTests = Model.LaboratoryTests.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _laboratoryTestsLastPage = page;
                }

                LaboratoryTestsIsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveLaboratoryTests(LaboratoryTestGetListViewModel record,
            LaboratoryTestGetListViewModel originalRecord)
        {
            Model.PendingSaveLaboratoryTests ??= new List<LaboratoryTestGetListViewModel>();

            if (Model.PendingSaveLaboratoryTests.Any(x => x.TestID == record.TestID))
            {
                var index = Model.PendingSaveLaboratoryTests.IndexOf(originalRecord);
                Model.PendingSaveLaboratoryTests[index] = record;
            }
            else
            {
                Model.PendingSaveLaboratoryTests.Add(record);
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task LoadLaboratoryTestInterpretationsData(LoadDataArgs args)
        {
            try
            {
                var pageSize = 10;
                string sortColumn = DefaultSortColumn,
                    sortOrder = SortConstants.Descending;

                if (LaboratoryTestInterpretationsGrid.PageSize != 0)
                    pageSize = LaboratoryTestInterpretationsGrid.PageSize;

                if (LaboratoryTestInterpretationPreviousPageSize != pageSize)
                    LaboratoryTestInterpretationsIsLoading = true;

                LaboratoryTestInterpretationPreviousPageSize = pageSize;

                if (args.Top != null)
                {
                    var page = args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize;

                    if (Model.LaboratoryTestInterpretations is null ||
                        _laboratoryTestInterpretationsLastPage !=
                        (args.Skip == null ? 1 : ((int) args.Skip + (int) args.Top) / pageSize))
                        LaboratoryTestInterpretationsIsLoading = true;

                    if (LaboratoryTestInterpretationsIsLoading || !IsNullOrEmpty(args.OrderBy))
                    {
                        if (args.Sorts != null && args.Sorts.Any())
                        {
                            sortColumn = args.Sorts.First().Property;
                            sortOrder = SortConstants.Descending;
                            if (args.Sorts.First().SortOrder.HasValue)
                            {
                                var order = args.Sorts.First().SortOrder;
                                if (order != null && order.Value.ToString() == "Ascending")
                                    sortOrder = SortConstants.Ascending;
                            }
                        }

                        Model.LaboratoryTestInterpretations =
                            await GetLaboratoryTestInterpretations(Model.DiseaseReportID, page, pageSize, sortColumn,
                                    sortOrder)
                                .ConfigureAwait(false);
                        if (page == 1)
                            _laboratoryTestInterpretationsDatabaseQueryCount =
                                !Model.LaboratoryTestInterpretations.Any()
                                    ? 0
                                    : Model.LaboratoryTestInterpretations.First().TotalRowCount;
                    }
                    else if (Model.LaboratoryTestInterpretations != null)
                    {
                        _laboratoryTestInterpretationsDatabaseQueryCount =
                            Model.LaboratoryTestInterpretations.All(x =>
                                x.RowStatus == (int) RowStatusTypeEnum.Inactive || x.TestInterpretationID < 0)
                                ? 0
                                : Model.LaboratoryTestInterpretations.First(x => x.TestInterpretationID > 0)
                                    .TotalRowCount;
                    }

                    if (Model.LaboratoryTestInterpretations != null)
                        for (var index = 0; index < Model.LaboratoryTestInterpretations.Count; index++)
                        {
                            // Remove any added unsaved records; will be added back at the end.
                            if (Model.LaboratoryTestInterpretations[index].TestInterpretationID < 0)
                            {
                                Model.LaboratoryTestInterpretations.RemoveAt(index);
                                index--;
                            }

                            if (Model.PendingSaveLaboratoryTestInterpretations == null || index < 0 ||
                                Model.LaboratoryTestInterpretations.Count == 0 ||
                                Model.PendingSaveLaboratoryTestInterpretations.All(x =>
                                    x.TestInterpretationID !=
                                    Model.LaboratoryTestInterpretations[index].TestInterpretationID)) continue;
                            {
                                if (Model.PendingSaveLaboratoryTestInterpretations
                                        .First(x => x.TestInterpretationID == Model.LaboratoryTestInterpretations[index]
                                            .TestInterpretationID)
                                        .RowStatus == (int) RowStatusTypeEnum.Inactive)
                                {
                                    Model.LaboratoryTestInterpretations.RemoveAt(index);
                                    _laboratoryTestInterpretationsDatabaseQueryCount--;
                                    index--;
                                }
                                else
                                {
                                    Model.LaboratoryTestInterpretations[index] =
                                        Model.PendingSaveLaboratoryTestInterpretations.First(x =>
                                            x.TestInterpretationID == Model.LaboratoryTestInterpretations[index]
                                                .TestInterpretationID);
                                }
                            }
                        }

                    LaboratoryTestInterpretationsCount = _laboratoryTestInterpretationsDatabaseQueryCount +
                                                         _laboratoryTestInterpretationsNewRecordCount;

                    if (_laboratoryTestInterpretationsNewRecordCount > 0)
                    {
                        _laboratoryTestInterpretationsLastDatabasePage = Math.DivRem(
                            _laboratoryTestInterpretationsDatabaseQueryCount, pageSize, out var remainderDatabaseQuery);
                        if (remainderDatabaseQuery > 0 || _laboratoryTestInterpretationsLastDatabasePage == 0)
                            _laboratoryTestInterpretationsLastDatabasePage += 1;

                        if (page >= _laboratoryTestInterpretationsLastDatabasePage &&
                            Model.PendingSaveLaboratoryTestInterpretations != null &&
                            Model.PendingSaveLaboratoryTestInterpretations.Any(x => x.TestInterpretationID < 0))
                        {
                            var newRecordsPendingSave =
                                Model.PendingSaveLaboratoryTestInterpretations.Where(x => x.TestInterpretationID < 0)
                                    .ToList();
                            var counter = 0;
                            var pendingSavePage = page - _laboratoryTestInterpretationsLastDatabasePage;
                            var quotientNewRecords = Math.DivRem(LaboratoryTestInterpretationsCount, pageSize,
                                out var remainderNewRecords);

                            if (remainderNewRecords >= pageSize / 2)
                                quotientNewRecords += 1;

                            if (pendingSavePage == 0)
                            {
                                pageSize = pageSize - remainderDatabaseQuery > newRecordsPendingSave.Count
                                    ? newRecordsPendingSave.Count
                                    : pageSize - remainderDatabaseQuery;
                            }
                            else if (page - 1 == quotientNewRecords)
                            {
                                remainderDatabaseQuery = 1;
                                pageSize = remainderNewRecords;
                                Model.LaboratoryTestInterpretations?.Clear();
                            }
                            else
                            {
                                Model.LaboratoryTestInterpretations?.Clear();
                            }

                            while (counter < pageSize)
                            {
                                Model.LaboratoryTestInterpretations?.Add(pendingSavePage == 0
                                    ? newRecordsPendingSave[counter]
                                    : newRecordsPendingSave[
                                        pendingSavePage * pageSize - remainderDatabaseQuery + counter]);

                                counter += 1;
                            }
                        }

                        if (Model.LaboratoryTestInterpretations != null)
                            Model.LaboratoryTestInterpretations = Model.LaboratoryTestInterpretations.AsQueryable()
                                .OrderBy(sortColumn, sortOrder == SortConstants.Ascending).ToList();
                    }

                    _laboratoryTestInterpretationsLastPage = page;
                }

                LaboratoryTestInterpretationsIsLoading = false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="record"></param>
        /// <param name="originalRecord"></param>
        protected void TogglePendingSaveLaboratoryTestInterpretations(
            LaboratoryTestInterpretationGetListViewModel record,
            LaboratoryTestInterpretationGetListViewModel originalRecord)
        {
            Model.PendingSaveLaboratoryTestInterpretations ??= new List<LaboratoryTestInterpretationGetListViewModel>();

            if (Model.PendingSaveLaboratoryTestInterpretations.Any(x =>
                    x.TestInterpretationID == record.TestInterpretationID))
            {
                var index = Model.PendingSaveLaboratoryTestInterpretations.IndexOf(originalRecord);
                Model.PendingSaveLaboratoryTestInterpretations[index] = record;
            }
            else
            {
                Model.PendingSaveLaboratoryTestInterpretations.Add(record);
            }
        }

        #endregion

        #region Tests Conducted Radio Button List Change Event

        /// <summary>
        /// </summary>
        protected void OnTestsConductedChange()
        {
            LaboratoryTestInterpretationsIsLoading = false;
            LaboratoryTestsIsLoading = false;
        }

        #endregion

        #region Add Laboratory Test Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddLaboratoryTestClick()
        {
            try
            {
                var result = await DiagService.OpenAsync<LaboratoryTest>(
                    Localizer.GetString(LaboratoryTestDetailsHeadingResourceKey),
                    new Dictionary<string, object>
                        {{"Model", new LaboratoryTestGetListViewModel()}, {"DiseaseReport", Model}},
                    new DialogOptions
                    {
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, Draggable = false, Resizable = true, ShowClose = true
                    });

                if (result is LaboratoryTestGetListViewModel model)
                {
                    _laboratoryTestsNewRecordCount += 1;

                    TogglePendingSaveLaboratoryTests(model, null);

                    await LaboratoryTestsGrid.Reload().ConfigureAwait(false);
                }
                else
                {
                    LaboratoryTestsIsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Print Laboratory Tests Click Event

        /// <summary>
        /// </summary>
        protected async Task OnPrintLaboratoryTestsButtonClick()
        {
            try
            {
                const long avian = 10012004;
                const long livestock = 10012003;

                // Reset the cancellation token
                _source = new CancellationTokenSource();
                _token = _source.Token;

                var fullName =
                    $"{authenticatedUser.FirstName} {authenticatedUser.SecondName} {authenticatedUser.LastName}";

                ReportViewModel reportModel = new();
                reportModel.AddParameter("LangID", GetCurrentLanguage());
                reportModel.AddParameter("PersonID", authenticatedUser.PersonId);
                reportModel.AddParameter("SiteID", authenticatedUser.SiteId);
                reportModel.AddParameter("UserFullName", fullName);
                reportModel.AddParameter("UserOrganization", authenticatedUser.Organization);
                reportModel.AddParameter("ObjID", Model.DiseaseReportID.ToString());

                // see if we are Avian or Livestock
                if (Model.ReportCategoryTypeID == avian)
                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTestResultReportHeading),
                        new Dictionary<string, object>
                            {{"ReportName", "VeterinaryCaseLabTestReport"}, {"Parameters", reportModel.Parameters}},
                        new DialogOptions
                        {
                            Style = VeterinaryDiseaseReportConstants.AvianDiseaseReportCaseType,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1150px"
                        });
                else if (Model.ReportCategoryTypeID == livestock)
                    await DiagService.OpenAsync<DisplayReport>(
                        Localizer.GetString(HeadingResourceKeyConstants.LaboratoryTestResultReportHeading),
                        new Dictionary<string, object>
                            {{"ReportName", "VeterinaryCaseLabTestReport"}, {"Parameters", reportModel.Parameters}},
                        new DialogOptions
                        {
                            Style = VeterinaryDiseaseReportConstants.LivestockDiseaseReportCaseType,
                            Left = "150",
                            Resizable = true,
                            Draggable = false,
                            Width = "1150px"
                        });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Laboratory Test Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="laboratoryTest"></param>
        protected async Task OnEditLaboratoryTestClick(object laboratoryTest)
        {
            try
            {
                var result = await DiagService.OpenAsync<LaboratoryTest>(
                    Localizer.GetString(LaboratoryTestDetailsHeadingResourceKey),
                    new Dictionary<string, object>
                    {
                        {"Model", ((LaboratoryTestGetListViewModel) laboratoryTest).ShallowCopy()},
                        {"DiseaseReport", Model}
                    },
                    new DialogOptions
                    {
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, ShowClose = true
                    });

                if (result is LaboratoryTestGetListViewModel model)
                {
                    if (Model.LaboratoryTests.Any(x => x.TestID == ((LaboratoryTestGetListViewModel) result).TestID))
                    {
                        var index = Model.LaboratoryTests.ToList().FindIndex(x =>
                            x.TestID == ((LaboratoryTestGetListViewModel) result).TestID);
                        Model.LaboratoryTests[index] = model;

                        TogglePendingSaveLaboratoryTests(model, (LaboratoryTestGetListViewModel) laboratoryTest);

                        if (Model.LaboratoryTestInterpretations.Any(x =>
                                x.TestID == ((LaboratoryTestGetListViewModel) result).TestID))
                        {
                            var interpretationIndex = Model.LaboratoryTestInterpretations.ToList().FindIndex(x =>
                                x.TestID == ((LaboratoryTestGetListViewModel) result).TestID);

                            Model.LaboratoryTestInterpretations[interpretationIndex].AnimalID =
                                Model.LaboratoryTests[index].AnimalID;
                            Model.LaboratoryTestInterpretations[interpretationIndex].DiseaseID =
                                Model.LaboratoryTests[index].DiseaseID;
                            Model.LaboratoryTestInterpretations[interpretationIndex].DiseaseName =
                                Model.LaboratoryTests[index].DiseaseName;
                            Model.LaboratoryTestInterpretations[interpretationIndex].EIDSSAnimalID =
                                Model.LaboratoryTests[index].EIDSSAnimalID;
                            Model.LaboratoryTestInterpretations[interpretationIndex].EIDSSLaboratorySampleID =
                                Model.LaboratoryTests[index].EIDSSLaboratorySampleID;
                            Model.LaboratoryTestInterpretations[interpretationIndex].EIDSSLocalOrFieldSampleID =
                                Model.LaboratoryTests[index].EIDSSLocalOrFieldSampleID;

                            var isTestResultIndicative = Model.LaboratoryTests[index].IsTestResultIndicative;
                            if (isTestResultIndicative != null)
                                Model.LaboratoryTestInterpretations[interpretationIndex].IndicativeIndicator =
                                    (bool) isTestResultIndicative;

                            Model.LaboratoryTestInterpretations[interpretationIndex].SampleID =
                                Model.LaboratoryTests[index].SampleID;
                            Model.LaboratoryTestInterpretations[interpretationIndex].SampleTypeName =
                                Model.LaboratoryTests[index].SampleTypeName;
                            Model.LaboratoryTestInterpretations[interpretationIndex].Species =
                                Model.LaboratoryTests[index].Species;
                            Model.LaboratoryTestInterpretations[interpretationIndex].SpeciesID =
                                Model.LaboratoryTests[index].SpeciesID;
                            Model.LaboratoryTestInterpretations[interpretationIndex].SpeciesTypeName =
                                Model.LaboratoryTests[index].SpeciesTypeName;
                            Model.LaboratoryTestInterpretations[interpretationIndex].TestCategoryTypeID =
                                Model.LaboratoryTests[index].TestCategoryTypeID;
                            Model.LaboratoryTestInterpretations[interpretationIndex].TestCategoryTypeName =
                                Model.LaboratoryTests[index].TestCategoryTypeName;
                            Model.LaboratoryTestInterpretations[interpretationIndex].TestNameTypeID =
                                Model.LaboratoryTests[index].TestNameTypeID;
                            Model.LaboratoryTestInterpretations[interpretationIndex].TestNameTypeName =
                                Model.LaboratoryTests[index].TestNameTypeName;
                            Model.LaboratoryTestInterpretations[interpretationIndex].TestResultTypeID =
                                Model.LaboratoryTests[index].TestResultTypeID;
                            Model.LaboratoryTestInterpretations[interpretationIndex].TestResultTypeName =
                                Model.LaboratoryTests[index].TestResultTypeName;

                            await LaboratoryTestInterpretationsGrid.Reload().ConfigureAwait(false);
                        }
                    }

                    await LaboratoryTestsGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Laboratory Test Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="laboratoryTest"></param>
        protected async Task OnDeleteLaboratoryTestClick(object laboratoryTest)
        {
            try
            {
                if (CanDeleteLaboratoryTestRecord(((LaboratoryTestGetListViewModel) laboratoryTest).TestID))
                {
                    var result =
                        await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            if (Model.LaboratoryTests.Any(x =>
                                    x.TestID == ((LaboratoryTestGetListViewModel) laboratoryTest).TestID))
                            {
                                if (((LaboratoryTestGetListViewModel) laboratoryTest).TestID <= 0)
                                {
                                    Model.LaboratoryTests.Remove((LaboratoryTestGetListViewModel) laboratoryTest);
                                    Model.PendingSaveLaboratoryTests.Remove(
                                        (LaboratoryTestGetListViewModel) laboratoryTest);
                                    _laboratoryTestsNewRecordCount--;
                                }
                                else
                                {
                                    result = ((LaboratoryTestGetListViewModel) laboratoryTest).ShallowCopy();

                                    // Check if need to de-link the laboratory test from the disease report.
                                    if (result.MonitoringSessionID is not null ||
                                        result.NonLaboratoryTestIndicator == false)
                                    {
                                        result.VeterinaryDiseaseReportID = null;
                                        result.RowAction = (int) RowActionTypeEnum.Update;
                                    }
                                    else
                                    {
                                        result.RowAction = (int) RowActionTypeEnum.Delete;
                                        result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                    }

                                    Model.LaboratoryTests.Remove((LaboratoryTestGetListViewModel) laboratoryTest);

                                    TogglePendingSaveLaboratoryTests(result,
                                        (LaboratoryTestGetListViewModel) laboratoryTest);
                                }
                            }

                            await LaboratoryTestsGrid.Reload().ConfigureAwait(false);

                            DiagService.Close(result);
                        }
                }
                else
                {
                    await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage, null)
                        .ConfigureAwait(false);

                    DiagService.Close();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="laboratoryTestId"></param>
        /// <returns></returns>
        private bool CanDeleteLaboratoryTestRecord(long laboratoryTestId)
        {
            StateHasChanged();

            return Model.LaboratoryTestInterpretations is not null && !Model.LaboratoryTestInterpretations.Any(x =>
                x.TestID == laboratoryTestId && x.RowStatus == (int) RowStatusTypeEnum.Active);
        }

        #endregion

        #region Add Laboratory Test Interpretation Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task OnAddLaboratoryTestInterpretationClick(LaboratoryTestGetListViewModel test)
        {
            try
            {
                var result = await DiagService.OpenAsync<LaboratoryTestInterpretation>(
                    Localizer.GetString(LaboratoryTestInterpretationDetailsHeadingResourceKey),
                    new Dictionary<string, object>
                    {
                        {
                            "Model",
                            new LaboratoryTestInterpretationGetListViewModel
                            {
                                AnimalID = test.AnimalID, DiseaseID = test.DiseaseID, DiseaseName = test.DiseaseName,
                                EIDSSAnimalID = test.EIDSSAnimalID, EIDSSFarmID = test.EIDSSFarmID,
                                EIDSSLaboratorySampleID = test.EIDSSLaboratorySampleID,
                                EIDSSLocalOrFieldSampleID = test.EIDSSLocalOrFieldSampleID, FarmID = test.FarmID,
                                SampleID = test.SampleID, SampleTypeName = test.SampleTypeName, Species = test.Species,
                                SpeciesID = test.SpeciesID, SpeciesTypeName = test.SpeciesTypeName,
                                TestCategoryTypeID = test.TestCategoryTypeID,
                                TestCategoryTypeName = test.TestCategoryTypeName, TestID = test.TestID,
                                TestNameTypeID = test.TestNameTypeID, TestNameTypeName = test.TestNameTypeName,
                                TestResultTypeID = test.TestResultTypeID, TestResultTypeName = test.TestResultTypeName
                            }
                        },
                        {"DiseaseReport", Model}
                    },
                    new DialogOptions
                    {
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, Draggable = false, Resizable = true, ShowClose = true
                    });

                if (result is LaboratoryTestInterpretationGetListViewModel model)
                {
                    _laboratoryTestInterpretationsNewRecordCount += 1;

                    TogglePendingSaveLaboratoryTestInterpretations(model, null);

                    await LaboratoryTestInterpretationsGrid.Reload().ConfigureAwait(false);
                }
                else
                {
                    LaboratoryTestInterpretationsIsLoading = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Edit Laboratory Test Intrepretation Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="laboratoryTestInterpretation"></param>
        protected async Task OnEditLaboratoryTestInterpretationClick(object laboratoryTestInterpretation)
        {
            try
            {
                var result = await DiagService.OpenAsync<LaboratoryTestInterpretation>(
                    Localizer.GetString(LaboratoryTestInterpretationDetailsHeadingResourceKey),
                    new Dictionary<string, object>
                    {
                        {
                            "Model",
                            ((LaboratoryTestInterpretationGetListViewModel) laboratoryTestInterpretation).ShallowCopy()
                        },
                        {"DiseaseReport", Model}
                    },
                    new DialogOptions
                    {
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.DefaultDialogWidth,
                        AutoFocusFirstElement = true,
                        CloseDialogOnOverlayClick = false, ShowClose = true
                    });

                if (result is LaboratoryTestInterpretationGetListViewModel model)
                {
                    if (Model.LaboratoryTestInterpretations.Any(x =>
                            x.TestInterpretationID == ((LaboratoryTestInterpretationGetListViewModel) result)
                            .TestInterpretationID))
                    {
                        var index = Model.LaboratoryTestInterpretations.IndexOf(
                            (LaboratoryTestInterpretationGetListViewModel) laboratoryTestInterpretation);
                        Model.LaboratoryTestInterpretations[index] = model;

                        TogglePendingSaveLaboratoryTestInterpretations(model,
                            (LaboratoryTestInterpretationGetListViewModel) laboratoryTestInterpretation);
                    }

                    await LaboratoryTestInterpretationsGrid.Reload().ConfigureAwait(false);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Laboratory Test Interpretation Button Click Event

        /// <summary>
        /// </summary>
        /// <param name="laboratoryTestInterpretation"></param>
        protected async Task OnDeleteLaboratoryTestInterpretationClick(object laboratoryTestInterpretation)
        {
            try
            {
                var result =
                    await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage, null);

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        if (Model.LaboratoryTestInterpretations.Any(x =>
                                x.TestInterpretationID ==
                                ((LaboratoryTestInterpretationGetListViewModel) laboratoryTestInterpretation)
                                .TestInterpretationID))
                        {
                            if (((LaboratoryTestInterpretationGetListViewModel) laboratoryTestInterpretation)
                                .TestInterpretationID <= 0)
                            {
                                Model.LaboratoryTestInterpretations.Remove(
                                    (LaboratoryTestInterpretationGetListViewModel) laboratoryTestInterpretation);
                                Model.PendingSaveLaboratoryTestInterpretations.Remove(
                                    (LaboratoryTestInterpretationGetListViewModel) laboratoryTestInterpretation);
                                _laboratoryTestInterpretationsNewRecordCount--;
                            }
                            else
                            {
                                result = ((LaboratoryTestInterpretationGetListViewModel) laboratoryTestInterpretation)
                                    .ShallowCopy();
                                result.RowAction = (int) RowActionTypeEnum.Delete;
                                result.RowStatus = (int) RowStatusTypeEnum.Inactive;
                                Model.LaboratoryTestInterpretations.Remove(
                                    (LaboratoryTestInterpretationGetListViewModel) laboratoryTestInterpretation);

                                TogglePendingSaveLaboratoryTestInterpretations(result,
                                    (LaboratoryTestInterpretationGetListViewModel) laboratoryTestInterpretation);
                            }
                        }

                        await LaboratoryTestInterpretationsGrid.Reload().ConfigureAwait(false);

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

        #region Create Connected Disease Report Event

        /// <summary>
        /// </summary>
        /// <param name="laboratoryTestInterpretation"></param>
        /// <returns></returns>
        protected async Task OnCreateConnectedDiseaseReportClick(
            LaboratoryTestInterpretationGetListViewModel laboratoryTestInterpretation)
        {
            IsProcessing = true;

            try
            {
                if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                    await JsRuntime.InvokeAsync<string>("validateAvianDiseaseReport", _token,
                        laboratoryTestInterpretation.TestInterpretationID, false);
                else
                    await JsRuntime.InvokeAsync<string>("validateLivestockDiseaseReport", _token,
                        laboratoryTestInterpretation.TestInterpretationID, false);
            }
            catch (Exception ex)
            {
                IsProcessing = false;
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="laboratoryTestInterpretationId"></param>
        /// <returns></returns>
        [JSInvokable("OnSubmitConnectedDiseaseReport")]
        public async Task OnSubmitConnectedDiseaseReport(long laboratoryTestInterpretationId)
        {
            try
            {
                IsProcessing = true;

                if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                {
                    if (Model.DiseaseReportSummaryValidIndicator &&
                        Model.FarmDetailsSectionValidIndicator &&
                        Model.NotificationSectionValidIndicator &&
                        Model.FarmEpidemiologicalInfoSectionValidIndicator &&
                        Model.SpeciesClinicalInvestigationInfoSectionValidIndicator &&
                        await ValidateDiseaseReportFarmInventory(Model).ConfigureAwait(false))
                    {
                        if (Model.DiseaseReportSummaryModifiedIndicator ||
                            Model.FarmDetailsSectionModifiedIndicator ||
                            Model.NotificationSectionModifiedIndicator ||
                            Model.FarmEpidemiologicalInfoSectionModifiedIndicator ||
                            Model.SpeciesClinicalInvestigationInfoSectionModifiedIndicator ||
                            (Model.PendingSaveCaseLogs is not null && Model.PendingSaveCaseLogs.Count > 0) ||
                            (Model.PendingSaveLaboratoryTestInterpretations is not null &&
                             Model.PendingSaveLaboratoryTestInterpretations.Count > 0) ||
                            (Model.PendingSaveLaboratoryTests is not null &&
                             Model.PendingSaveLaboratoryTests.Count > 0) ||
                            (Model.PendingSaveEvents is not null && Model.PendingSaveEvents.Count > 0) ||
                            (Model.PendingSavePensideTests is not null && Model.PendingSavePensideTests.Count > 0) ||
                            (Model.PendingSaveSamples is not null && Model.PendingSaveSamples.Count > 0) ||
                            (Model.PendingSaveVaccinations is not null && Model.PendingSaveVaccinations.Count > 0))
                        {
                            var result = await ShowWarningDialog(
                                MessageResourceKeyConstants.DoYouWantToSaveYourChangesMessage,
                                null);

                            if (result is DialogReturnResult returnResult)
                            {
                                if (returnResult.ButtonResultText ==
                                    Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                                {
                                    await CreateConnectedDiseaseReport(laboratoryTestInterpretationId);
                                }
                                else
                                {
                                    DiagService.Close(result);

                                    await InvokeAsync(StateHasChanged);
                                }
                            }
                        }
                        else
                        {
                            await CreateConnectedDiseaseReport(laboratoryTestInterpretationId);
                        }
                    }
                }
                else
                {
                    if (Model.DiseaseReportSummaryValidIndicator &&
                        Model.FarmDetailsSectionValidIndicator &&
                        Model.NotificationSectionValidIndicator &&
                        Model.FarmEpidemiologicalInfoSectionValidIndicator &&
                        Model.SpeciesClinicalInvestigationInfoSectionValidIndicator &&
                        Model.ControlMeasuresSectionValidIndicator &&
                        await ValidateDiseaseReportFarmInventory(Model).ConfigureAwait(false))
                    {
                        if (Model.DiseaseReportSummaryModifiedIndicator ||
                            Model.FarmDetailsSectionModifiedIndicator ||
                            Model.NotificationSectionModifiedIndicator ||
                            Model.FarmEpidemiologicalInfoSectionModifiedIndicator ||
                            Model.SpeciesClinicalInvestigationInfoSectionModifiedIndicator ||
                            Model.ControlMeasuresSectionModifiedIndicator ||
                            (Model.PendingSaveAnimals is not null && Model.PendingSaveAnimals.Count > 0) ||
                            (Model.PendingSaveCaseLogs is not null && Model.PendingSaveCaseLogs.Count > 0) ||
                            (Model.PendingSaveLaboratoryTestInterpretations is not null &&
                             Model.PendingSaveLaboratoryTestInterpretations.Count > 0) ||
                            (Model.PendingSaveLaboratoryTests is not null &&
                             Model.PendingSaveLaboratoryTests.Count > 0) ||
                            (Model.PendingSaveEvents is not null && Model.PendingSaveEvents.Count > 0) ||
                            (Model.PendingSavePensideTests is not null && Model.PendingSavePensideTests.Count > 0) ||
                            (Model.PendingSaveSamples is not null && Model.PendingSaveSamples.Count > 0) ||
                            (Model.PendingSaveVaccinations is not null && Model.PendingSaveVaccinations.Count > 0))
                        {
                            var result = await ShowWarningDialog(
                                MessageResourceKeyConstants.DoYouWantToSaveYourChangesMessage,
                                null);

                            if (result is DialogReturnResult returnResult)
                            {
                                if (returnResult.ButtonResultText ==
                                    Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                                {
                                    await CreateConnectedDiseaseReport(laboratoryTestInterpretationId);
                                }
                                else
                                {
                                    DiagService.Close(result);

                                    await InvokeAsync(StateHasChanged);
                                }
                            }
                        }
                        else
                        {
                            await CreateConnectedDiseaseReport(laboratoryTestInterpretationId);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                IsProcessing = false;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="laboratoryTestInterpretationId"></param>
        /// <returns></returns>
        private async Task CreateConnectedDiseaseReport(long laboratoryTestInterpretationId)
        {
            if (Model.LaboratoryTestInterpretations.Any(x =>
                    x.TestInterpretationID == laboratoryTestInterpretationId))
            {
                var laboratoryTestInterpretation =
                    Model.LaboratoryTestInterpretations.First(x =>
                        x.TestInterpretationID == laboratoryTestInterpretationId);

                Model.LaboratoryTestInterpretations.First(x =>
                    x.TestInterpretationID == laboratoryTestInterpretationId).ReportSessionCreatedIndicator = true;

                long? flockOrHerdId = null;
                var flockOrHerdIndex = -1;

                if (Model.LaboratoryTests.First(x => x.TestID == laboratoryTestInterpretation.TestID).SpeciesID !=
                    null)
                {
                    var speciesId = Model.LaboratoryTests
                        .First(x => x.TestID == laboratoryTestInterpretation.TestID).SpeciesID;
                    flockOrHerdId = Model.FarmInventory
                        .First(x => (x.SpeciesID != null) & (x.SpeciesID == speciesId)).FlockOrHerdID;
                    if (flockOrHerdId != null)
                        flockOrHerdIndex = Model.FarmInventory.IndexOf(Model.FarmInventory.First(x =>
                            (x.FlockOrHerdID != null) & (x.FlockOrHerdID == flockOrHerdId)));
                }

                // Save the related to (currently displayed) disease report.
                var response = await SaveDiseaseReport(Model, null, false, null, null).ConfigureAwait(false);

                if (response.ReturnCode == 0)
                {
                    // Refresh to get the updated child collection identifiers set by the database.
                    DiseaseReportGetDetailRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = int.MaxValue - 1,
                        SortColumn = "EIDSSReportID",
                        SortOrder = SortConstants.Ascending,
                        DiseaseReportID = Model.DiseaseReportID
                    };

                    string farmEpiAnswers = null;
                    if (Model.FarmEpidemiologicalInfoObservationParameters is not null)
                        farmEpiAnswers = Model.FarmEpidemiologicalInfoObservationParameters;

                    string controlMeasuresAnswers = null;
                    if (Model.ControlMeasuresFlexFormAnswers is not null)
                        controlMeasuresAnswers = Model.ControlMeasuresObservationParameters;

                    Model = (await VeterinaryClient.GetDiseaseReportDetail(request, _token).ConfigureAwait(false))
                        .First();
                    Model.DiseaseReportSummaryValidIndicator = true;
                    Model.FarmDetailsSectionValidIndicator = true;
                    Model.NotificationSectionValidIndicator = true;
                    Model.FarmEpidemiologicalInfoSectionValidIndicator = true;
                    Model.SpeciesClinicalInvestigationInfoSectionValidIndicator = true;
                    Model.ControlMeasuresSectionValidIndicator = true;
                    Model.FarmLocation = SetFarmLocation(Model);
                    Model.FarmInventory =
                        await GetFarmInventory(Model.DiseaseReportID, Model.FarmMasterID, Model.FarmID)
                            .ConfigureAwait(false);
                    Model.PendingSaveVaccinations = await GetVaccinations(Model.DiseaseReportID, 1, 10,
                        "VaccinationTypeName", SortConstants.Ascending).ConfigureAwait(false);
                    Model.PendingSaveAnimals =
                        await GetAnimals(Model.DiseaseReportID, 1, 10, "EIDSSAnimalID", SortConstants.Descending)
                            .ConfigureAwait(false);
                    Model.PendingSaveSamples = await GetSamples(Model.DiseaseReportID, 1, 10,
                        "EIDSSLaboratorySampleID", SortConstants.Descending).ConfigureAwait(false);
                    Model.PendingSavePensideTests = await GetPensideTests(Model.DiseaseReportID, 1, 10,
                        "PensideTestNameTypeName", SortConstants.Descending).ConfigureAwait(false);
                    Model.PendingSaveLaboratoryTests = await GetLaboratoryTests(Model.DiseaseReportID, 1, 10,
                        "EIDSSLaboratorySampleID", SortConstants.Descending).ConfigureAwait(false);
                    Model.PendingSaveLaboratoryTestInterpretations =
                        await GetLaboratoryTestInterpretations(Model.DiseaseReportID, 1, 10,
                            "EIDSSLaboratorySampleID", SortConstants.Ascending).ConfigureAwait(false);
                    Model.PendingSaveCaseLogs =
                        await GetCaseLogs(Model.DiseaseReportID, 1, 10, "LogDate", SortConstants.Descending)
                            .ConfigureAwait(false);
                    Model.PendingSaveEvents = new List<EventSaveRequestModel>();

                    var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Model.SiteID
                        ? SystemEventLogTypes.NewVeterinaryDiseaseReportWasCreatedAtYourSite
                        : SystemEventLogTypes.NewVeterinaryDiseaseReportWasCreatedAtAnotherSite;
                    Model.PendingSaveEvents.Add(await NotificationSiteAlertService.CreateEvent(Model.DiseaseReportID,
                            Model.DiseaseID, eventTypeId, Model.SiteID,
                            null) //, NotificationSiteAlertService.BuildVeterinaryDiseaseReportLink(Model.ReportCategoryTypeID, Model.FarmMasterID, Model.DiseaseReportID))
                        .ConfigureAwait(false));

                    // Connect the related to disease report identifier.
                    Model.RelatedToVeterinaryDiseaseReportID = Model.DiseaseReportID;
                    Model.RelatedToVeterinaryDiseaseEIDSSReportID = Model.EIDSSReportID;

                    // Reset to save the connected disease report.
                    Model.DiseaseReportID = 0;
                    Model.EIDSSReportID = null;
                    Model.FarmID = null; // Farm master information will be copied to a new farm record.

                    if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                    {
                        FlexFormQuestionnaireGetRequestModel farmEpidemiologicalInfoFlexFormRequest = new()
                        {
                            idfsFormType = (long) FlexibleFormTypeEnum.AvianFarmEpidemiologicalInfo,
                            LangID = GetCurrentLanguage()
                        };
                        Model.FarmEpidemiologicalInfoFlexForm = farmEpidemiologicalInfoFlexFormRequest;
                    }
                    else
                    {
                        FlexFormQuestionnaireGetRequestModel farmEpidemiologicalInfoFlexFormRequest = new()
                        {
                            idfsFormType = (long) FlexibleFormTypeEnum.LivestockFarmFarmEpidemiologicalInfo,
                            LangID = GetCurrentLanguage()
                        };
                        Model.FarmEpidemiologicalInfoFlexForm = farmEpidemiologicalInfoFlexFormRequest;

                        FlexFormQuestionnaireGetRequestModel controlMeasuresFlexFormRequest = new()
                        {
                            idfsFormType = (long) FlexibleFormTypeEnum.LivestockControlMeasures,
                            LangID = GetCurrentLanguage()
                        };
                        Model.ControlMeasuresFlexForm = controlMeasuresFlexFormRequest;
                    }

                    Model.FarmEpidemiologicalObservationID = null;
                    if (Model.FarmEpidemiologicalInfoFlexForm.idfsFormTemplate is null)
                    {
                        var questions =
                            await FlexFormClient.GetQuestionnaire(Model.FarmEpidemiologicalInfoFlexForm);

                        if (questions.Count > 0)
                            Model.FarmEpidemiologicalInfoFlexForm.idfsFormTemplate =
                                questions[0].idfsFormTemplate;
                    }

                    if (Model.FarmEpidemiologicalInfoFlexForm.idfsFormTemplate is > 0)
                        if (farmEpiAnswers is not null)
                        {
                            var flexFormRequest = new FlexFormActivityParametersSaveRequestModel
                            {
                                Answers = farmEpiAnswers,
                                idfsFormTemplate = (long) Model.FarmEpidemiologicalInfoFlexForm.idfsFormTemplate,
                                idfObservation = null,
                                User = authenticatedUser.UserName
                            };
                            var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                            Model.FarmEpidemiologicalObservationID = flexFormResponse.idfObservation;
                        }

                    Model.ControlMeasuresObservationID = null;
                    if (Model.ControlMeasuresFlexForm is not null)
                    {
                        if (Model.ControlMeasuresFlexForm.idfsFormTemplate is null)
                        {
                            var questions =
                                await FlexFormClient.GetQuestionnaire(Model.ControlMeasuresFlexForm);

                            if (questions.Count > 0)
                                Model.ControlMeasuresFlexForm.idfsFormTemplate =
                                    questions[0].idfsFormTemplate;
                        }

                        if (Model.ControlMeasuresFlexForm.idfsFormTemplate is > 0)
                            if (controlMeasuresAnswers is not null)
                            {
                                var flexFormRequest = new FlexFormActivityParametersSaveRequestModel
                                {
                                    Answers = controlMeasuresAnswers,
                                    idfsFormTemplate = (long) Model.ControlMeasuresFlexForm.idfsFormTemplate,
                                    idfObservation = null,
                                    User = authenticatedUser.UserName
                                };
                                var flexFormResponse = await FlexFormClient.SaveAnswers(flexFormRequest);
                                Model.ControlMeasuresObservationID = flexFormResponse.idfObservation;
                            }
                    }

                    // Copy only the associated farm group (flock or herd).
                    if (flockOrHerdId is not null)
                        Model.FarmInventory.ToList().RemoveAll(x =>
                            x != null && x.FlockOrHerdID != Model.FarmInventory[flockOrHerdIndex].FlockOrHerdID);

                    if (laboratoryTestInterpretation.TestID < 0)
                        if (response.ConnectedDiseaseReportLaboratoryTestID != null)
                            laboratoryTestInterpretation.TestID =
                                (long) response.ConnectedDiseaseReportLaboratoryTestID;

                    // Save the connected disease report.
                    response = await SaveDiseaseReport(Model, null, true, laboratoryTestInterpretation.DiseaseID,
                        laboratoryTestInterpretation.TestID).ConfigureAwait(false);

                    if (response.ReturnCode == 0)
                    {
                        string message;

                        if (Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                            message = Format(Localizer.GetString(MessageResourceKeyConstants
                                                 .AvianDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage) +
                                             ".",
                                response.EIDSSReportID);
                        else
                            message = Format(Localizer.GetString(MessageResourceKeyConstants
                                                 .LivestockDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage) +
                                             ".",
                                response.EIDSSReportID);

                        var result = await ShowSuccessDialog(null, message, null,
                            ButtonResourceKeyConstants.ReturnToDashboardButton,
                            Model.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                ? ButtonResourceKeyConstants.AvianDiseaseReportReturnToDiseaseReportButtonText
                                : ButtonResourceKeyConstants.LivestockDiseaseReportReturnToDiseaseReportButtonText);

                        if (result is DialogReturnResult returnResult)
                        {
                            if (returnResult.ButtonResultText ==
                                Localizer.GetString(ButtonResourceKeyConstants.ReturnToDashboardButton))
                            {
                                DiagService.Close();

                                _source?.Cancel();

                                var uri = $"{NavManager.BaseUri}Administration/Dashboard/Index";

                                NavManager.NavigateTo(uri, true);
                            }
                            else
                            {
                                DiagService.Close();

                                const string path = "Veterinary/VeterinaryDiseaseReport/Details";
                                var query =
                                    $"?reportTypeID={Model.ReportTypeID}&diseaseReportID={response.DiseaseReportID}&isEdit=true&isReview=true";
                                var uri = $"{NavManager.BaseUri}{path}{query}";

                                NavManager.NavigateTo(uri, true);
                            }
                        }
                    }
                }
            }
        }

        #endregion

        #region Reload Section Method

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public void ReloadSection()
        {
            Model.LaboratoryTests = null;
            Model.LaboratoryTestInterpretations = null;
            LaboratoryTestsGrid.Reload();
            LaboratoryTestInterpretationsGrid.Reload();

            StateHasChanged();
        }

        #endregion

        #endregion
    }
}