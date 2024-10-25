using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Human.Controllers
{
    [Area("Human")]
    [Controller]
    public class HumanDiseaseReportController : BaseController
    {
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private readonly AuthenticatedUser _authenticatedUser;
        private readonly IHumanDiseaseReportClient _humanDiseaseReportClient;
        private readonly UserPermissions _userPermissions;
        private readonly UserPermissions _userPermissionsAddEmployee;
        private readonly IPersonClient _personClient;
        private readonly IStringLocalizer _localizer;
        private readonly IHumanActiveSurveillanceSessionClient _humanActiveSurveillanceSessionClient;

        public string CurrentLanguage { get; set; }

        public HumanDiseaseReportController(
            ICrossCuttingClient crossCuttingClient,
            IConfiguration configuration,
            IPersonClient personClient,
            IHumanDiseaseReportClient humanDiseaseReportClient,
            IStringLocalizer localizer,
            ILogger<HumanDiseaseReportController> logger,
            ITokenService tokenService,
            IHumanActiveSurveillanceSessionClient humanActiveSurveillanceSessionClient)
            : base(logger, tokenService)
        {
            _crossCuttingClient = crossCuttingClient;
            _humanDiseaseReportClient = humanDiseaseReportClient;
            _configuration = configuration;
            _personClient = personClient;
            _localizer = localizer;
            _humanActiveSurveillanceSessionClient = humanActiveSurveillanceSessionClient;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            _userPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
            _userPermissionsAddEmployee = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);
            CurrentLanguage = cultureInfo.Name;
        }

        public IActionResult Index()
        {
            return View();
        }

        public async Task<IActionResult> LoadDiseaseReport(long? humanId, long? caseId, bool isEdit = false, bool readOnly = false, int startIndex = 1, bool isReopenClosedReport = false, long? idfMonitoringSession = null, long? idfTesting = null, bool isFromWhoExport = false)
        {
            var diseaseReportPageViewModel = new DiseaseReportDetailPageViewModel
            {
                ReportComponent = new DiseaseReportComponentViewModel
                {
                    StartIndex = startIndex
                }
            };
            if (isEdit || readOnly)
                diseaseReportPageViewModel.ReportComponent.HumanID = humanId;
            else
                diseaseReportPageViewModel.ReportComponent.HumanActualID = humanId;
            diseaseReportPageViewModel.ReportComponent.isEdit = isEdit;

            diseaseReportPageViewModel.ReportComponent.DiseaseReportCaseInvestigationPrintViewModel.Parameters = new List<KeyValuePair<string, string>>();
            diseaseReportPageViewModel.ReportComponent.DiseaseReportCaseInvestigationPrintViewModel.ReportHeading = _localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportCaseInvestigationDetailsHeading);
            diseaseReportPageViewModel.ReportComponent.DiseaseReportCaseInvestigationPrintViewModel.ReportName = "CaseInvestigation";

            if (caseId != null)
            {
                diseaseReportPageViewModel.ReportComponent.DiseaseReportCaseInvestigationPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("ObjID", caseId.Value.ToString()));
                diseaseReportPageViewModel.ReportComponent.DiseaseReportCaseInvestigationPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("LangID", GetCurrentLanguage()));
                diseaseReportPageViewModel.ReportComponent.DiseaseReportCaseInvestigationPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("PersonID", _authenticatedUser.PersonId));
            }

            diseaseReportPageViewModel.ReportComponent.DiseaseReportContactPrintViewModel.Parameters = new List<KeyValuePair<string, string>>();
            diseaseReportPageViewModel.ReportComponent.DiseaseReportContactPrintViewModel.ReportHeading = _localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportNotificationHeading);
            diseaseReportPageViewModel.ReportComponent.DiseaseReportContactPrintViewModel.ReportName = "UrgentNotificationForm";

            if (caseId != null)
            {
                diseaseReportPageViewModel.ReportComponent.DiseaseReportContactPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("ObjID", caseId.Value.ToString()));
                diseaseReportPageViewModel.ReportComponent.DiseaseReportContactPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("LangID", GetCurrentLanguage()));
                diseaseReportPageViewModel.ReportComponent.DiseaseReportContactPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("PersonID", _authenticatedUser.PersonId));
            }

            diseaseReportPageViewModel.ReportComponent.idfHumanCase = caseId;
            diseaseReportPageViewModel.ReportComponent.IsReopenClosedReport = isReopenClosedReport;
            diseaseReportPageViewModel.ReportComponent.PersonInfoSection = new DiseaseReportPersonalInformationPageViewModel
            {
                PermissionsAccessToPersonalData = _userPermissions
            };

            diseaseReportPageViewModel.ReportComponent.NotificationSection = new DiseaseReportNotificationPageViewModel();

            if (idfMonitoringSession != null)
            {
                var sessionRequest = new ActiveSurveillanceSessionDetailRequestModel
                {
                    LanguageID = GetCurrentLanguage(),
                    MonitoringSessionID = idfMonitoringSession
                };
                var sessionResult = await _humanActiveSurveillanceSessionClient.GetHumanActiveSurveillanceSessionDetailAsync(sessionRequest);

                diseaseReportPageViewModel.ReportComponent.NotificationSection.idfDisease = sessionResult.First().DiseaseID;
                diseaseReportPageViewModel.ReportComponent.NotificationSection.strDisease = sessionResult.First().DiseaseName;

                diseaseReportPageViewModel.ReportComponent.ReportSummary = new DiseaseReportSummaryPageViewModel
                {
                    Disease = sessionResult.First().DiseaseName,
                    ReportStatusID = (long)VeterinaryDiseaseReportStatusTypes.InProcess
                };

                var reportTypeRequest = new BaseReferenceTranslationRequestModel
                {
                    LanguageID = GetCurrentLanguage(),
                    idfsBaseReference = CaseReportType.Active
                };

                var reportTypeBaseReference = await _crossCuttingClient.GetBaseReferenceTranslation(reportTypeRequest);
                diseaseReportPageViewModel.ReportComponent.ReportSummary.ReportType = reportTypeBaseReference.First().name;
                diseaseReportPageViewModel.ReportComponent.ReportSummary.ReportTypeID = CaseReportType.Active;
                diseaseReportPageViewModel.ReportComponent.ReportSummary.SessionID = sessionResult.First().EIDSSSessionID;
                diseaseReportPageViewModel.ReportComponent.ReportSummary.IsReportTypeDisabled = true;

                var requestTests = new ActiveSurveillanceSessionTestsRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    idfMonitoringSession = idfMonitoringSession,
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "ResultDate",
                    SortOrder = "asc"
                };

                var iRow = 0;
                var testList = await _humanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionTests(requestTests);
                var personId = long.Parse(testList.First(x => x.ID == idfTesting).PersonID.ToString());
                var testsDetailList = testList.Where(x => x.PersonID == personId)
                    .ToList()
                    .Select(test => new DiseaseReportTestDetailForDiseasesViewModel()
                    {
                        RowID = ++iRow,
                        strFieldBarcode = test.FieldSampleID,
                        strDiagnosis = test.Diagnosis,
                        idfsDiagnosis = test.DiseaseID,
                        name = test.TestName,
                        idfsTestName = test.TestNameID,
                        strTestCategory = test.TestCategory,
                        idfsTestCategory = test.TestCategoryID,
                        strTestResult = test.TestResult,
                        idfsTestResult = test.TestResultID,
                        strSampleTypeName = test.SampleType
                    })
                    .ToList();

                diseaseReportPageViewModel.ReportComponent.TestsSection = new DiseaseReportTestPageViewModel
                {
                    TestsConducted = YesNoValues.Yes,
                    TestDetails = testsDetailList,
                    TestsLoaded = true,
                };

                var requestDetailedInformation = new ActiveSurveillanceSessionDetailedInformationRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    idfMonitoringSession = idfMonitoringSession,
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "intOrder",
                    SortOrder = "asc"
                };

                var detailedInformation = await _humanActiveSurveillanceSessionClient.GetActiveSurveillanceSessionDetailedInformation(requestDetailedInformation);
                var samplesDetailList = detailedInformation.Where(x => x.PersonID == personId && x.idfsSampleType != (long)SampleTypes.Unknown)
                    .ToList()
                    .Select(item => new DiseaseReportSamplePageSampleDetailViewModel
                    {
                        RowID = ++iRow,
                        idfMaterial = item.ID,
                        CollectionDate = item.CollectionDate,
                        LocalSampleId = item.FieldSampleID,
                        SampleType = item.SampleType,
                        SampleTypeID = item.idfsSampleType,
                        SentToOrganization = item.SentToOrganization,
                        SentToOrganizationID = item.idfSendToOffice,
                        strNote = item.Comment
                    })
                    .ToList();

                diseaseReportPageViewModel.ReportComponent.SamplesSection = new DiseaseReportSamplePageViewModel
                {
                    SamplesCollectedYN = YesNoValues.Yes,
                    SamplesDetails = samplesDetailList
                };
            }

            diseaseReportPageViewModel.ReportComponent.NotificationSection.PermissionsAccessToNotification = _userPermissionsAddEmployee;
            diseaseReportPageViewModel.ReportComponent.SymptomsSection = new DiseaseReportSymptomsPageViewModel();
            diseaseReportPageViewModel.ReportComponent.FacilityDetailsSection = new DiseaseReportFacilityDetailsPageViewModel
            {
                YesNoChoices = new List<BaseReferenceViewModel>(),
                BaseReferencePermissions = _tokenService.GerUserPermissions(PagePermission.CanManageBaseReferencePage)
            };
            diseaseReportPageViewModel.ReportComponent.SamplesSection ??= new DiseaseReportSamplePageViewModel();
            diseaseReportPageViewModel.ReportComponent.SamplesSection.YesNoChoices = new List<BaseReferenceViewModel>();
            diseaseReportPageViewModel.ReportComponent.TestsSection ??= new DiseaseReportTestPageViewModel();
            diseaseReportPageViewModel.ReportComponent.TestsSection.YesNoChoices = new List<BaseReferenceViewModel>();
            diseaseReportPageViewModel.ReportComponent.CaseInvestigationSection = new DiseaseReportCaseInvestigationPageViewModel
            {
                ExposureLocationAddress = new LocationViewModel()
            };
            diseaseReportPageViewModel.ReportComponent.RiskFactorsSection = new DiseaseReportCaseInvestigationRiskFactorsPageViewModel();
            diseaseReportPageViewModel.ReportComponent.ContactListSection = new DiseaseReportContactListPageViewModel();
            diseaseReportPageViewModel.ReportComponent.AntibioticVaccineHistorySection = new DiseaseReportAntibioticVaccineHistoryPageViewModel();
            diseaseReportPageViewModel.ReportComponent.FinalOutcomeSection = new DiseaseReportFinalOutcomeViewModel();
            diseaseReportPageViewModel.ReportComponent.idfParentMonitoringSession = idfMonitoringSession;
            diseaseReportPageViewModel.ReportComponent.ConnectedTestId = idfTesting;
            diseaseReportPageViewModel.ReportComponent.IsFromWHOExport = isFromWhoExport;

            return View("Details", diseaseReportPageViewModel);
        }

        public async Task<IActionResult> SelectForEdit(long id)
        {
            var request = new HumanDiseaseReportDetailRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                SearchHumanCaseId = id,
                SortColumn = "HumanDiseaseReportID",
                SortOrder = SortConstants.Ascending
            };
            var response = await _humanDiseaseReportClient.GetHumanDiseaseDetail(request);
            if (response == null) return View("Index");
            var humanId = response.idfHuman;
            var caseId = response.idfHumanCase;

            return RedirectToAction("LoadDiseaseReport", new { humanId, caseId, isEdit = true, readOnly = false });
        }

        public async Task<IActionResult> SelectForReadOnly(long id)
        {
            var request = new HumanDiseaseReportDetailRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                SearchHumanCaseId = id,
                SortColumn = "HumanDiseaseReportID",
                SortOrder = SortConstants.Ascending
            };
            var response = await _humanDiseaseReportClient.GetHumanDiseaseDetail(request);
            if (response == null) return View("Index");
            var humanId = response.idfHuman;
            var caseId = response.idfHumanCase;

            return RedirectToAction("LoadDiseaseReport", new { humanId, caseId, isEdit = true, readOnly = true, StartIndex = 9 });
        }

        public async Task<JsonResult> GetPersonListForOrg(int page, string data, string term)
        {
            var select2DataItems = new List<Select2DataItem>();
            var select2DataObj = new Select2DataResults();

            var jsonArray = JArray.Parse(data);
            long officeId = 0;
            if (jsonArray.Count > 0)
            {
                dynamic jsonObject = JObject.Parse(jsonArray[0].ToString());

                if (jsonObject["id"] != null)
                {
                    officeId = (long)jsonObject["id"];
                }
            }
            var request = new GetPersonForOfficeRequestModel
            {
                intHACode = HACodeList.HumanHACode,
                LangID = GetCurrentLanguage(),
                OfficeID = officeId,
                AdvancedSearch = term
            };

            var list = await _personClient.GetPersonListForOffice(request);
            if (list != null)
            {
                select2DataItems.AddRange(list.Select(item => new Select2DataItem { id = item.idfPerson.ToString(), text = item.FullName }));
            }
            select2DataObj.results = select2DataItems;

            return Json(select2DataObj);
        }

        public async Task<JsonResult> LoadInitialCaseClassification()
        {
            Select2DataResults select2DataObj = new();
            var request = new HumanDiseaseReportLkupCaseClassificationRequestModel
            {
                LangID = GetCurrentLanguage()
            };
            var list = await _humanDiseaseReportClient.GetHumanDiseaseReportLkupCaseClassificationAsync(request);
            select2DataObj.results = list.Where(x => x.blnInitialHumanCaseClassification
                                                     && x.strHACode.Split(',').ToList().Contains(HACodeList.HumanHACode.ToString()))
                .Select(x => new Select2DataItem()
                {
                    id = x.idfsCaseClassification.ToString(),
                    text = x.strName
                }).ToList();
            return Json(select2DataObj);
        }
    }
}