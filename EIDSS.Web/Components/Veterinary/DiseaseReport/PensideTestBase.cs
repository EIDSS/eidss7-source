#region Usings

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using static System.String;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.DiseaseReport
{
    /// <summary>
    /// </summary>
    public class PensideTestBase : VeterinaryBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<PensideTestBase> Logger { get; set; }
        [Inject] protected IDiseasePensideTestMatrixClient DiseasePensideTestMatrixClient { get; set; }
        [Inject] private ITestNameTestResultsMatrixClient TestNameTestResultsMatrix { get; set; }

        #endregion

        #region Parameters

        [Parameter] public DiseaseReportGetDetailViewModel DiseaseReport { get; set; }
        [Parameter] public PensideTestGetListViewModel Model { get; set; }

        #endregion

        #region Properties

        protected RadzenTemplateForm<PensideTestGetListViewModel> Form { get; set; }
        public IEnumerable<DiseasePensideTestMatrixGetRequestResponseModel> PensideTestNameTypes { get; set; }
        public IEnumerable<TestNameTestResultsMatrixViewModel> PensideTestResultTypes { get; set; }
        public string TestNameFieldLabelResourceKey { get; set; }
        public string FieldSampleIdFieldLabelResourceKey { get; set; }
        public string SampleTypeFieldLabelResourceKey { get; set; }
        public string SpeciesFieldLabelResourceKey { get; set; }
        public string AnimalIdFieldLabelResourceKey { get; set; }
        public string ResultFieldLabelResourceKey { get; set; }

        #endregion

        #region Member Variables

        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="token"></param>
        public PensideTestBase(CancellationToken token) : base(token)
        {
        }

        /// <summary>
        /// </summary>
        protected PensideTestBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        protected override void OnInitialized()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            if (DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
            {
                TestNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportPensideTestDetailsModalTestNameFieldLabel;
                FieldSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportPensideTestDetailsModalFieldSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportPensideTestDetailsModalSampleTypeFieldLabel;
                SpeciesFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportPensideTestDetailsModalSpeciesFieldLabel;
                ResultFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .AvianDiseaseReportPensideTestDetailsModalResultFieldLabel;
            }
            else
            {
                TestNameFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportPensideTestDetailsModalTestNameFieldLabel;
                FieldSampleIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportPensideTestDetailsModalFieldSampleIDFieldLabel;
                SampleTypeFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportPensideTestDetailsModalSampleTypeFieldLabel;
                AnimalIdFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportPensideTestDetailsModalAnimalIDFieldLabel;
                ResultFieldLabelResourceKey = FieldLabelResourceKeyConstants
                    .LivestockDiseaseReportPensideTestDetailsModalResultFieldLabel;
            }

            base.OnInitialized();
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
        /// <returns></returns>
        public async Task GetPensideTestNameTypes(LoadDataArgs args)
        {
            try
            {
                if (DiseaseReport.DiseaseID is null)
                {
                    PensideTestNameTypes = new List<DiseasePensideTestMatrixGetRequestResponseModel>();
                }
                else
                {
                    DiseasePensideTestMatrixGetRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = int.MaxValue - 1,
                        SortColumn = "strPensideTestName",
                        SortOrder = SortConstants.Ascending
                    };
                    PensideTestNameTypes = await DiseasePensideTestMatrixClient.GetDiseasePensideTestMatrix(request);

                    PensideTestNameTypes = PensideTestNameTypes.Where(x => x.idfsDiagnosis == DiseaseReport.DiseaseID);

                    if (!IsNullOrEmpty(args.Filter))
                        PensideTestNameTypes = PensideTestNameTypes.Where(c =>
                            c.strPensideTestName != null && c.strPensideTestName.Contains(args.Filter,
                                StringComparison.CurrentCultureIgnoreCase));
                }

                await InvokeAsync(StateHasChanged);
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
        public async Task GetPensideTestResultTypes(LoadDataArgs args)
        {
            try
            {
                if (Model.PensideTestNameTypeID is null)
                {
                    PensideTestResultTypes = new List<TestNameTestResultsMatrixViewModel>();
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
                        idfsTestName = Model.PensideTestNameTypeID,
                        idfsTestResultRelation = (long) TestResultRelationTypeEnum.PensideTest
                    };
                    PensideTestResultTypes = await TestNameTestResultsMatrix.GetTestNameTestResultsMatrixList(request);

                    if (!IsNullOrEmpty(args.Filter))
                        PensideTestResultTypes = PensideTestResultTypes.Where(c =>
                            c.strTestResultName != null && c.strTestResultName.Contains(args.Filter,
                                StringComparison.CurrentCultureIgnoreCase));
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

        #region Penside Test Name Drop Down Change Event

        /// <summary>
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected async Task OnPensideTestChange(object value)
        {
            try
            {
                if (value == null)
                {
                    Model.PensideTestResultTypeID = null;
                    Model.PensideTestResultTypeName = null;
                }
                else
                {
                    await GetPensideTestResultTypes(new LoadDataArgs());
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

        #region Save Button Click Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        public void OnSubmit()
        {
            if (!Form.EditContext.Validate()) return;
            switch (Model.PensideTestID)
            {
                case 0:
                    Model.PensideTestID = (DiseaseReport.PensideTests.Count + 1) * -1;
                    Model.RowAction = (int) RowActionTypeEnum.Insert;
                    Model.RowStatus = (int) RowStatusTypeEnum.Active;
                    break;
                case > 0:
                    Model.RowAction = (int) RowActionTypeEnum.Update;
                    break;
            }

            Model.DiseaseID = DiseaseReport.DiseaseID;

            Model.PensideTestNameTypeName = Model.PensideTestNameTypeID is null
                ? null
                : PensideTestNameTypes.First(x => x.idfsPensideTestName == Model.PensideTestNameTypeID)
                    .strPensideTestName;

            if (Model.SampleID is null)
            {
                Model.EIDSSLocalOrFieldSampleID = null;
                Model.SampleTypeName = null;
            }
            else
            {
                Model.EIDSSLocalOrFieldSampleID = DiseaseReport.Samples.First(x => x.SampleID == Model.SampleID)
                    .EIDSSLocalOrFieldSampleID;
            }

            Model.PensideTestResultTypeName = Model.PensideTestResultTypeID is null
                ? null
                : PensideTestResultTypes.First(x => x.idfsTestResult == Model.PensideTestResultTypeID)
                    .strTestResultName;

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
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage,
                        null);

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