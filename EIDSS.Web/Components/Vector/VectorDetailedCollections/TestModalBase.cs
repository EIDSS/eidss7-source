#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.Components.Vector.Common;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
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

#endregion

namespace EIDSS.Web.Components.Vector.VectorDetailedCollections
{
    public class TestModalBase : VectorBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<TestModalBase> Logger { get; set; }

        [Inject] private ITestNameTestResultsMatrixClient TestNameTestResultsMatrix { get; set; }

        [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject] private IVectorTypeFieldTestMatrixClient VectorTypeFieldTestMatrixClient { get; set; }

        [Inject] private IOrganizationClient OrganizationClient { get; set; }

        [Inject] private IPersonClient PersonClient { get; set; }

        #endregion

        #region Parameters

        #endregion

        #region Properties

        protected RadzenTemplateForm<FieldTestGetListViewModel> Form { get; set; }
        protected IList<VectorSampleGetListViewModel> Samples { get; set; }
        protected IList<ConfigurationMatrixViewModel> TestNameTypes { get; set; }
        protected IList<BaseReferenceViewModel> TestCategoryTypes { get; set; }
        protected IList<BaseReferenceViewModel> TestStatuses { get; set; }
        protected IList<FilteredDiseaseGetListViewModel> TestDiseases { get; set; }
        protected IList<TestNameTestResultsMatrixViewModel> TestResultTypes { get; set; }
        protected IList<OrganizationAdvancedGetListViewModel> TestedByInstitutions { get; set; }
        protected IList<PersonForOfficeViewModel> TestedByEmployees { get; set; }
        public string TestNameFieldLabelResourceKey { get; set; }
        public string FieldSampleIDFieldLabelResourceKey { get; set; }
        public string SampleTypeFieldLabelResourceKey { get; set; }
        public string SpeciesFieldLabelResourceKey { get; set; }
        public string AnimalIDFieldLabelResourceKey { get; set; }
        public string ResultFieldLabelResourceKey { get; set; }

        #endregion

        #region Member Variables

        protected bool Disabled;
        protected bool IsDiseaseFiltered;
        protected bool IsTestedByPersonDisabled;

        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// 
        /// </summary>
        protected override void OnInitialized()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            //reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            TestNameFieldLabelResourceKey = FieldLabelResourceKeyConstants.LivestockDiseaseReportPensideTestDetailsModalTestNameFieldLabel;
            FieldSampleIDFieldLabelResourceKey = FieldLabelResourceKeyConstants.LivestockDiseaseReportPensideTestDetailsModalFieldSampleIDFieldLabel;
            SampleTypeFieldLabelResourceKey = FieldLabelResourceKeyConstants.LivestockDiseaseReportPensideTestDetailsModalSampleTypeFieldLabel;
            AnimalIDFieldLabelResourceKey = FieldLabelResourceKeyConstants.LivestockDiseaseReportPensideTestDetailsModalAnimalIDFieldLabel;
            ResultFieldLabelResourceKey = FieldLabelResourceKeyConstants.LivestockDiseaseReportPensideTestDetailsModalResultFieldLabel;

            base.OnInitialized();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            base.Dispose(disposing);
        }

        #endregion

        #region Load Data Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        public void GetSamples(LoadDataArgs args)
        {
            try
            {
                Samples ??= new List<VectorSampleGetListViewModel>();

                // get the samples list from the animal samples grid
                if (VectorSessionStateContainer.DetailedCollectionsSamplesList != null && VectorSessionStateContainer.DetailedCollectionsSamplesList.Count > 0)
                {
                    Samples = VectorSessionStateContainer.DetailedCollectionsSamplesList.Where(x => x.RowStatus == (int)RowStatusTypeEnum.Active).ToList();
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="args"></param>
        /// <returns></returns>
        protected async Task GetDiseases(LoadDataArgs args)
        {
            try
            {
                TestDiseases ??= new List<FilteredDiseaseGetListViewModel>();

                var request = new FilteredDiseaseRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = HACodeList.VectorHACode,
                    UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId),
                    UsingType = null,
                    AdvancedSearchTerm = string.IsNullOrEmpty(args.Filter) ? null : args.Filter
                };
                TestDiseases = await CrossCuttingClient.GetFilteredDiseaseList(request);

                // filter by filter criteria
                if (!string.IsNullOrEmpty(args.Filter))
                {
                    TestDiseases = TestDiseases.Where(d => d.DiseaseName != null && d.DiseaseName.Contains(args.Filter)).ToList();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public async Task GetTestNameTypes(LoadDataArgs args)
        {
            try
            {
                var request = new VectorTypeFieldTestMatrixGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsVectorType = VectorSessionStateContainer.DetailVectorTypeID,
                    Page = args.Skip != null & args.Skip != 0 ? args.Skip.Value : 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "strPensideTestName",
                    SortOrder = SortConstants.Descending
                };
                TestNameTypes = await VectorTypeFieldTestMatrixClient.GetVectorTypeFieldTestMatrixList(request);

                // filter by filter criteria
                if (!string.IsNullOrEmpty(args.Filter))
                    TestNameTypes = TestNameTypes.Where(c => c.strFieldTest != null && (c.strFieldTest.Contains(args.Filter))).ToList();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public async Task GetTestCategoryTypes(LoadDataArgs args)
        {
            try
            {
                TestCategoryTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.TestCategory, HACodeList.VectorHACode);

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

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public async Task GetTestResultTypes(LoadDataArgs args)
        {
            try
            {
                if (VectorSessionStateContainer.FieldTestDetail.TestNameTypeID is null)
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
                        idfsTestName = VectorSessionStateContainer.FieldTestDetail.TestNameTypeID,
                        idfsTestResultRelation = null
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

        public async Task GetTestedByInstitution(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = HACodeList.VectorHACode,
                    AdvancedSearch = null,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long?)OrganizationTypes.Laboratory
                };
                if (args is {Filter: { }})
                {
                    request.AdvancedSearch = args.Filter;
                }
                var list = await OrganizationClient.GetOrganizationAdvancedList(request);

                TestedByInstitutions = list.ToList().GroupBy(x => x.idfOffice).Select(x => x.First()).ToList();

                await InvokeAsync(StateHasChanged);

            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task GetTestedByEmployees(LoadDataArgs args)
        {
            try
            {
                if (VectorSessionStateContainer.FieldTestDetail.TestedByOrganizationID != null)
                {
                    var request = new GetPersonForOfficeRequestModel
                    {
                        intHACode = HACodeList.VectorHACode,
                        LangID = GetCurrentLanguage(),
                        OfficeID = VectorSessionStateContainer.FieldTestDetail.TestedByOrganizationID
                    };
                    if (args != null && string.IsNullOrEmpty(args.Filter))
                        request.AdvancedSearch = args.Filter;
                    var list = await PersonClient.GetPersonListForOffice(request);

                    TestedByEmployees = list.ToList();

                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        #endregion

        #region Events

        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        protected async Task OnFilterByDiseaseChange(bool value)
        {
            if (value)
            {
                // filter by the selected disease
                var filterList = new List<FilterDescriptor>
                {
                    new() { Property = "DiseaseID", FilterValue = VectorSessionStateContainer.FieldTestDetail.DiseaseID }
                };
                await GetTestNameTypes(new LoadDataArgs { Filters = filterList });
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
                var filterList = new List<FilterDescriptor>
                {
                    new() { Property = "DiseaseID", FilterValue = VectorSessionStateContainer.FieldTestDetail.DiseaseID }
                };
                await GetTestNameTypes(new LoadDataArgs { Filters = filterList });
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        /// <returns></returns>
        protected void OnSampleChange(object value)
        {
            try
            {
                if (value == null || Samples == null || !Samples.Any())
                {
                    VectorSessionStateContainer.FieldTestDetail.EIDSSAnimalID = null;
                    VectorSessionStateContainer.FieldTestDetail.FarmID = null;
                    VectorSessionStateContainer.FieldTestDetail.EIDSSFarmID = null;
                    VectorSessionStateContainer.FieldTestDetail.Species = null;
                    VectorSessionStateContainer.FieldTestDetail.SpeciesID = null;
                    VectorSessionStateContainer.FieldTestDetail.SpeciesTypeName = null;
                    VectorSessionStateContainer.FieldTestDetail.ResultDate = null;
                    VectorSessionStateContainer.FieldTestDetail.SampleTypeID = null;
                    VectorSessionStateContainer.FieldTestDetail.SampleTypeName = null;
                    Disabled = true;
                }
                else
                {
                    var sample = Samples.First(x => x.SampleID == (long)value);
                    VectorSessionStateContainer.FieldTestDetail.EIDSSAnimalID = null;
                    VectorSessionStateContainer.FieldTestDetail.Species = null;
                    VectorSessionStateContainer.FieldTestDetail.FarmID = null;
                    VectorSessionStateContainer.FieldTestDetail.EIDSSFarmID = null;
                    VectorSessionStateContainer.FieldTestDetail.SpeciesID = sample.SpeciesTypeID;
                    VectorSessionStateContainer.FieldTestDetail.SpeciesTypeName = sample.SpeciesTypeName;
                    VectorSessionStateContainer.FieldTestDetail.ResultDate = sample.SampleStatusDate;
                    VectorSessionStateContainer.FieldTestDetail.SampleTypeID = sample.SampleTypeID;
                    VectorSessionStateContainer.FieldTestDetail.SampleTypeName = sample.SampleTypeName;
                    VectorSessionStateContainer.FieldTestDetail.CollectionDate = sample.CollectionDate;
                    Disabled = false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OpenEmployeeAddModal()
        {
            try
            {
                var dialogParams = new Dictionary<string, object>();

                var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams, new DialogOptions { Width = "700px", Resizable = true, Draggable = false });

                if (result == null)
                    return;

                if (((EditContext) result).Validate())
                {
                }
                else
                {
                    //Logger.LogInformation("HandleSubmit called: Form is INVALID");
                }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task OnTestedByOrganizationChange(object value)
        {
            try
            {
                if (value != null)
                {
                    await GetTestedByEmployees(new LoadDataArgs());
                    IsTestedByPersonDisabled = false;
                    await InvokeAsync(StateHasChanged);
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

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public void OnSubmit()
        {
            if (!Form.EditContext.Validate()) return;

            VectorSessionStateContainer.DetailedCollectionsFieldTestsList ??= new List<FieldTestGetListViewModel>();

            switch (VectorSessionStateContainer.FieldTestDetail.TestID)
            {
                case 0:
                    VectorSessionStateContainer.FieldTestDetail.TestID = (VectorSessionStateContainer.DetailedCollectionsFieldTestsList.Count + 1) * -1;
                    VectorSessionStateContainer.FieldTestDetail.RowAction = (int)RowActionTypeEnum.Insert;
                    VectorSessionStateContainer.FieldTestDetail.RowStatus = (int)RowStatusTypeEnum.Active;
                    break;
                case > 0:
                    VectorSessionStateContainer.FieldTestDetail.RowAction = (int)RowActionTypeEnum.Update;
                    break;
            }

            VectorSessionStateContainer.FieldTestDetail.VectorSessionID = VectorSessionStateContainer.VectorSessionKey;

            VectorSessionStateContainer.FieldTestDetail.DiseaseName = VectorSessionStateContainer.FieldTestDetail.DiseaseID is null 
                ? null 
                : TestDiseases.First(x => x.DiseaseID == VectorSessionStateContainer.FieldTestDetail.DiseaseID).DiseaseName;
            
            VectorSessionStateContainer.FieldTestDetail.TestNameTypeName = VectorSessionStateContainer.FieldTestDetail.TestNameTypeID is null 
                ? null 
                : TestNameTypes.First(x => x.idfsPensideTestName == VectorSessionStateContainer.FieldTestDetail.TestNameTypeID).strPensideTestName;

            VectorSessionStateContainer.FieldTestDetail.TestedByOrganizationName = VectorSessionStateContainer.FieldTestDetail.TestedByOrganizationID is null
                ? null
                : TestedByInstitutions.First(x => x.idfOffice == VectorSessionStateContainer.FieldTestDetail.TestedByOrganizationID).name;

            VectorSessionStateContainer.FieldTestDetail.TestedByPersonName = VectorSessionStateContainer.FieldTestDetail.TestedByPersonID is null
                ? null
                : TestedByEmployees.First(x => x.idfPerson == VectorSessionStateContainer.FieldTestDetail.TestedByPersonID).FullName;

            if (VectorSessionStateContainer.FieldTestDetail.SampleID is null)
            {
                VectorSessionStateContainer.FieldTestDetail.EIDSSLocalOrFieldSampleID = null;
                VectorSessionStateContainer.FieldTestDetail.SampleTypeName = null;
            }
            else
            {
                VectorSessionStateContainer.FieldTestDetail.EIDSSLocalOrFieldSampleID = Samples.First(x => x.SampleID == VectorSessionStateContainer.FieldTestDetail.SampleID).EIDSSLocalOrFieldSampleID;
                VectorSessionStateContainer.FieldTestDetail.SampleTypeName = Samples.First(x => x.SampleTypeID == VectorSessionStateContainer.FieldTestDetail.SampleTypeID).SampleTypeName;
            }

            VectorSessionStateContainer.FieldTestDetail.TestResultTypeName = VectorSessionStateContainer.FieldTestDetail.TestResultTypeID is null 
                ? null 
                : TestResultTypes.First(x => x.idfsTestResult == VectorSessionStateContainer.FieldTestDetail.TestResultTypeID).strTestResultName;

            VectorSessionStateContainer.FieldTestDetail.TestCategoryTypeName = VectorSessionStateContainer.FieldTestDetail.TestCategoryTypeID is null
                ? null
                : TestCategoryTypes.First(x => x.IdfsBaseReference == VectorSessionStateContainer.FieldTestDetail.TestCategoryTypeID).Name;

            if (VectorSessionStateContainer.FieldTestDetail.TestStatusTypeID == 0)
                VectorSessionStateContainer.FieldTestDetail.TestStatusTypeID = (long)TestStatusTypeEnum.Preliminary;

            VectorSessionStateContainer.FieldTestDetail.NonLaboratoryTestIndicator = true;

            DiagService.Close(Form.EditContext.Model);
        }

        #endregion

        #region Cancel Button Click Event

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        protected new async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null);

                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                            DiagService.Close(result);
                    }
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
