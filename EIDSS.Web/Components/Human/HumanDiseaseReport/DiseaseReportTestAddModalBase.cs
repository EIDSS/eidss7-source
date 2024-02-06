using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.Components.CrossCutting;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Domain.ViewModels;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using static System.String;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class DiseaseReportTestAddModalBase : BaseComponent
    {
        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IHumanDiseaseReportClient HumanDiseaseReportClient { get; set; }

        [Inject]
        private ILogger<DiseaseReportSampleAddModalBase> Logger { get; set; }

        [Inject]
        private ITestNameTestResultsMatrixClient TestNameTestResultsMatrixClient { get; set; }

        [Parameter]
        public List<DiseaseReportSamplePageSampleDetailViewModel> SamplesDetails { get; set; }

        [Parameter]
        public DiseaseReportTestDetailForDiseasesViewModel Model { get; set; }

        [Parameter]
        public long? idfDisease { get; set; }

        [Parameter]
        public DateTime? SymptomsOnsetDate { get; set; }

        [Parameter]
        public int localSampleIdCount { get; set; }

        [Parameter]
        public string? LocalSampleID { get; set; }

        [Parameter]
        public long? idfHumanCase { get; set; }

        [Parameter]
        public string strCaseId { get; set; }

        [Parameter]
        public bool IsReportClosed { get; set; }

        public DiseaseReportTestDetailForDiseasesViewModel TestDetailModel { get; set; }

        protected IEnumerable<FilteredDiseaseGetListViewModel> Diseases;
        protected IEnumerable<DiseaseReportSamplePageSampleDetailViewModel> LocalSampleIDs;
        protected IEnumerable<OrganizationAdvancedGetListViewModel> TestLaboratory;

        protected List<FiltersViewModel> TestNames;

        protected IEnumerable<FiltersViewModel> TestCategory;

        protected IEnumerable<FiltersViewModel> TestResult;

        protected IEnumerable<FiltersViewModel> RuleOutRuleIn;

        protected RadzenTemplateForm<DiseaseReportTestDetailForDiseasesViewModel> Form;

        protected int TestCount { get; set; }

        protected int TestCategoryCount { get; set; }

        protected int RuleOutRuleInCount { get; set; }

        protected int TestResultCount { get; set; }
        protected int DiseaseCount { get; set; }
        protected bool IsDiseaseSelected { get; set; }
        protected int TestLabCount { get; set; }
        protected EditContext EditContext { get; set; }

        private UserPermissions _userPermissions;

        protected bool CanInterpretResults { get; set; }

        protected bool CanValidateHumanTestResultInterpretation { get; set; }

        protected bool EnableInterpretedComments { get; set; } = true;
        protected bool EnableValidated { get; set; } = true;

        protected bool BlnEnableValidatedComments { get; set; } = true;

        protected bool BlnEnteredByLab { get; set; }
        private bool _oldValidatedStatus;

        protected override async Task OnInitializedAsync()
        {
            try
            {
                DiagService.OnOpen += ModalOpen;
                DiagService.OnClose += ModalClose;

                _userPermissions = GetUserPermissions(PagePermission.CanInterpretHumanTestResult);
                CanInterpretResults = _userPermissions.Execute;

                _userPermissions = GetUserPermissions(PagePermission.CanValidateTestHumanResultInterpretation);
                CanValidateHumanTestResultInterpretation = _userPermissions.Execute;

                _logger = Logger;
                Model ??= new DiseaseReportTestDetailForDiseasesViewModel();

                TestDetailModel = Model;
                EditContext = new EditContext(TestDetailModel);
                _oldValidatedStatus = TestDetailModel.blnValidateStatus;
                if (!IsNullOrEmpty(LocalSampleID) && IsNullOrEmpty(TestDetailModel.strFieldBarcode))
                {
                    TestDetailModel.strFieldBarcode = LocalSampleID;
                }

                if (idfDisease != null && idfDisease != 0)
                {
                    TestDetailModel.idfsDiagnosis = idfDisease;
                    await LoadDiseaseList(null);
                    await UpdateDiseaseName(TestDetailModel.idfsDiagnosis);
                }

                if (!IsNullOrEmpty(TestDetailModel.strBarcode))
                {
                    BlnEnteredByLab = true;
                }

                await LoadInterpretedStatusList(null);
                await LoadTestName(TestDetailModel.filterTestByDisease);

                if (TestDetailModel.idfsTestName != 0 && TestDetailModel.idfsTestName != null)
                {
                    await LoadTestResult(TestDetailModel.idfsTestName.ToString());
                    await UpdateTestName(TestDetailModel.idfsTestName);
                }
                else
                {
                    await LoadTestResult(null);
                }

                EnableValidatedComments(TestDetailModel.blnValidateStatus);
                UpdateRuleOutRuleInName(TestDetailModel.idfsInterpretedStatus);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        private static void ModalOpen(string title, Type type, Dictionary<string, object> parameters, DialogOptions options)
        {
            //modal open event callback
        }

        private static void ModalClose(dynamic result)
        {
            //modal close event callback
        }

        public void Dispose()
        {
            DiagService.OnOpen -= ModalOpen;
            DiagService.OnClose -= ModalClose;
        }

        public async Task LoadLocalSampleIDs(LoadDataArgs args)
        {
            try
            {
                if (SamplesDetails is {Count: > 0})
                {
                    LocalSampleIDs = SamplesDetails;
                    localSampleIdCount = SamplesDetails.Count;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task LoadDiseaseList(LoadDataArgs args)
        {
            try
            {
                FilteredDiseaseRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    AccessoryCode = HACodeList.HumanHACode,
                    AdvancedSearchTerm = args?.Filter,
                    UsingType = UsingType.StandardCaseType,
                    UserEmployeeID = Convert.ToInt64(authenticatedUser.PersonId)
                };

                var list = await CrossCuttingClient.GetFilteredDiseaseList(request);

                Diseases = list.AsODataEnumerable();

                DiseaseCount = Diseases.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task LoadSampleType(object value)
        {
            try
            {
                if (value != null && SamplesDetails != null)
                {
                    var h = SamplesDetails.Where(x => x.LocalSampleId == value.ToString());
                    var diseaseReportSamplePageSampleDetailViewModels = h.ToList();
                    if (diseaseReportSamplePageSampleDetailViewModels.Any())
                    {
                        TestDetailModel.strSampleTypeName = diseaseReportSamplePageSampleDetailViewModels.FirstOrDefault()?.SampleType;
                        var sampleTypeId = diseaseReportSamplePageSampleDetailViewModels
                            .FirstOrDefault().SampleTypeID;
                        if (sampleTypeId != null)
                            TestDetailModel.idfsSampleType = sampleTypeId.Value;
                        TestDetailModel.datFieldCollectionDate = diseaseReportSamplePageSampleDetailViewModels.FirstOrDefault()?.CollectionDate;
                        TestDetailModel.datFieldSentDate = diseaseReportSamplePageSampleDetailViewModels.FirstOrDefault()?.SentDate;
                        TestDetailModel.strBarcode = diseaseReportSamplePageSampleDetailViewModels.FirstOrDefault()?.strBarcode;
                    }
                }
                else
                {
                    TestDetailModel.strSampleTypeName = null;
                }
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task LoadTestName(bool? args)
        {
            try
            {
                var tempData = new List<FiltersViewModel>();

                if (args == true)
                {
                    var request = new HumanTestNameForDiseasesRequestModel
                    {
                        langId = GetCurrentLanguage(),
                        idfsDiagnosis = TestDetailModel.idfsDiagnosis,
                        PageSize = 100,
                        MaxPagesPerFetch = 1,
                        PaginationSet = 1
                    };

                    var list = await HumanDiseaseReportClient.GetHumanDiseaseReportTestNameForDiseasesAsync(request);
                    var filteredList = list.AsODataEnumerable();

                    tempData.AddRange(filteredList.Select(item => new FiltersViewModel {idfsBaseReference = item.idfsTestName, StrDefault = item.strTestName}));
                }
                else
                {
                    var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.TestName, HACodeList.HumanHACode);
                    var filteredList = list.AsODataEnumerable();

                    tempData.AddRange(filteredList.Select(item => new FiltersViewModel {idfsBaseReference = item.IdfsBaseReference, StrDefault = item.Name}));
                }

                TestNames = tempData;
                TestCount = TestNames.Count;
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task LoadTestCategoryList(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.TestCategory, HACodeList.HumanHACode);
                var filteredList = list.AsODataEnumerable();
                var tempData = filteredList.Select(item => new FiltersViewModel {idfsBaseReference = item.IdfsBaseReference, StrDefault = item.Name}).ToList();
                TestCategory = tempData.AsODataEnumerable();
                TestCategoryCount = TestCategory.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task LoadInterpretedStatusList(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.RuleInRuleOut, HACodeList.HumanHACode);
                var filteredList = list.AsODataEnumerable();
                var tempData = filteredList.Select(item => new FiltersViewModel {idfsBaseReference = item.IdfsBaseReference, StrDefault = item.Name}).ToList();
                RuleOutRuleIn = tempData.AsODataEnumerable();
                RuleOutRuleInCount = RuleOutRuleIn.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task UpdateDiseaseName(object value)
        {
            try
            {
                if (value != null)
                {
                    var h = Diseases.Where(x => x.DiseaseID == long.Parse(value.ToString() ?? Empty));
                    var filteredDiseaseGetListViewModels = h.ToList();
                    if (filteredDiseaseGetListViewModels.Any())
                    {
                        TestDetailModel.strDiagnosis = filteredDiseaseGetListViewModels.FirstOrDefault()?.DiseaseName;
                    }

                    IsDiseaseSelected = true;

                    await LoadTestName(true);
                }
                else
                {
                    IsDiseaseSelected = false;
                    TestDetailModel.idfsTestName = null;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public void UpdateTestCategoryName(object value)
        {
            try
            {
                if (value == null) return;
                var h = TestCategory.Where(x => x.idfsBaseReference == long.Parse(value.ToString() ?? Empty));
                var filtersViewModels = h.ToList();
                if (filtersViewModels.Any())
                {
                    TestDetailModel.strTestCategory = filtersViewModels.FirstOrDefault()?.StrDefault;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public void UpdateTestResultName(object value)
        {
            try
            {
                if (value == null) return;
                var h = TestResult.Where(x => x.idfsBaseReference == long.Parse(value.ToString() ?? Empty));
                var filtersViewModels = h.ToList();
                if (filtersViewModels.Any())
                {
                    TestDetailModel.strTestResult = filtersViewModels.FirstOrDefault()?.StrDefault;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateTestName(object value)
        {
            try
            {
                if (value != null)
                {
                    var h = TestNames.Where(x => x.idfsBaseReference == long.Parse(value.ToString() ?? Empty));
                    var filtersViewModels = h.ToList();
                    if (filtersViewModels.Any())
                    {
                        TestDetailModel.name = filtersViewModels.FirstOrDefault()?.StrDefault;
                        await LoadTestResult(value.ToString());
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public void UpdateTestLabName(object value)
        {
            try
            {
                if (value == null) return;
                var h = TestLaboratory.Where(x => x.idfOffice == long.Parse(value.ToString() ?? Empty));
                var organizationAdvancedGetListViewModels = h.ToList();
                if (organizationAdvancedGetListViewModels.Any())
                {
                    TestDetailModel.strTestedByOffice = organizationAdvancedGetListViewModels.FirstOrDefault()?.name;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public void UpdateRuleOutRuleInName(object value)
        {
            try
            {
                EnableInterpretedComments = CanInterpretResults;
                EnableValidated = CanValidateHumanTestResultInterpretation;

                if (value == null) return;
                //if (long.Parse(value.ToString() ?? Empty) == TestDetailModel.idfsInterpretedStatus) return;

                var h = RuleOutRuleIn.Where(x => x.idfsBaseReference == long.Parse(value.ToString() ?? Empty));
                var filtersViewModels = h.ToList();
                if (!filtersViewModels.Any()) return;
                TestDetailModel.strInterpretedStatus = filtersViewModels.FirstOrDefault()?.StrDefault;
                TestDetailModel.datInterpretedDate ??= DateTime.Today;
                TestDetailModel.strInterpretedBy = authenticatedUser.UserName;
                TestDetailModel.idfInterpretedByPerson = long.Parse(authenticatedUser.PersonId);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public void EnableValidatedComments(bool value)
        {
            try
            {
                BlnEnableValidatedComments = false;

                if (value == _oldValidatedStatus) return;
                if (value)
                {
                    BlnEnableValidatedComments = true;
                    TestDetailModel.datValidationDate = DateTime.Today;
                    TestDetailModel.strValidatedBy = authenticatedUser.UserName;
                    TestDetailModel.idfValidatedByPerson = long.Parse(authenticatedUser.PersonId);
                }
                else
                {
                    BlnEnableValidatedComments = false;
                    TestDetailModel.strValidateComment = null;
                    TestDetailModel.strValidatedBy = null;
                    TestDetailModel.idfValidatedByPerson = null;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task LoadTestResult(string args)
        {
            try
            {
                if (!IsNullOrEmpty(args) && Model.idfsTestName != 0)
                {
                    var request = new TestNameTestResultsMatrixGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        idfsTestName = Model.idfsTestName,
                        idfsTestResultRelation = BaseReferenceTypeIds.LabTest,
                        Page = 1,
                        PageSize = 100,
                        SortColumn = "strTestResultDefault",
                        SortOrder = SortConstants.Ascending,
                    };

                    var list = await TestNameTestResultsMatrixClient.GetTestNameTestResultsMatrixList(request);
                    var filteredList = list.AsODataEnumerable();
                    var tempData = filteredList.Select(item => new FiltersViewModel {idfsBaseReference = item.idfsTestResult, StrDefault = item.strTestResultName}).ToList();

                    TestResult = tempData;
                    TestResultCount = TestResult.Count();
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task LoadTestLaboratory(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = HACodeList.HumanHACode,
                    AdvancedSearch = null,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long)OrganizationTypes.Laboratory,
                };

                if (args != null)
                {
                    request.AdvancedSearch = args.Filter;
                }

                var list = await OrganizationClient.GetOrganizationAdvancedList(request);
                TestLaboratory = list.AsODataEnumerable();
                TestLabCount = TestLaboratory.Count();
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected void HandleValidTestSubmit(DiseaseReportTestDetailForDiseasesViewModel model)
        {
            try
            {
                if (Form.IsValid)
                {
                    DiagService.Close(Form.EditContext.IsModified() ? EditContext : null);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task HandleInvalidTestSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };

                buttons.Add(okButton);

                //TODO - display the validation Errors on the dialog?
                var dialogParams = new Dictionary<string, object>
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.FieldIsRequiredMessage)
                    }
                };
                // await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                if (result is DialogReturnResult)
                {
                    //do nothing because it is just the ok button
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }
    }
}