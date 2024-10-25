using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Outbreak.ViewModels;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Outbreak.Controllers
{
    [Area("Outbreak")]
    [Controller]
    public class HumanCaseController : BaseController
    {
        private HumanCaseViewModel _outbreakHumanCasesViewModel;
        public new IConfiguration Configuration { get; }
        public string CurrentLanguage { get; set; }
        public new string CountryId { get; set; }
        private readonly IOutbreakClient _outbreakClient;
        private readonly UserPermissions _userPermissions;
        private readonly UserPermissions _userPermissionsAddEmployee;
        private readonly IPersonClient _personClient;

        private List<OutbreakHumanCaseDetailResponseModel> _getCaseDetailResult;

        private enum DataType
        {
            String,
            Int,
            Long,
            DateTime,
            Double,
            LocationType,
            Boolean
        }

        public HumanCaseController(IOutbreakClient outbreakClient, IConfiguration configuration,
            ITokenService tokenService, IPersonClient personClient, ILogger<HumanCaseController> logger) : base(logger, tokenService)
        {
            _outbreakClient = outbreakClient;
            Configuration = configuration;
            _personClient = personClient;
            _tokenService.GetAuthenticatedUser();
            _userPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);

            CountryId = Configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            _userPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
            _userPermissionsAddEmployee = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);
            CurrentLanguage = cultureInfo.Name;
        }

        public Task<IActionResult> Index(long queryData)
        {
            _outbreakHumanCasesViewModel = new HumanCaseViewModel
            {
                idfOutbreak = queryData,
                CancelURL = $"/Outbreak/OutbreakCases?queryData={queryData}"
            };

            return Task.FromResult<IActionResult>(View(_outbreakHumanCasesViewModel));
        }

        public async Task<IActionResult> Edit(long outbreakId, long caseId, bool readOnly = false)
        {
            var request = new OutbreakHumanCaseDetailRequestModel
            {
                LangID = GetCurrentLanguage(),
                OutbreakCaseReportUID = caseId
            };

            _getCaseDetailResult = await _outbreakClient.GetHumanCaseDetailAsync(request);
            var result = await CaseInit((long)_getCaseDetailResult.First().idfHumanActual, (long)_getCaseDetailResult.First().idfOutbreak);

            _outbreakHumanCasesViewModel.OutbreakCaseReportUID = caseId;
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.idfHumanCase = _getCaseDetailResult.First().idfHumanCase;
            _outbreakHumanCasesViewModel.IsReadOnly = readOnly;
            _outbreakHumanCasesViewModel.RelatedToIdentifiers = _getCaseDetailResult.First().RelatedToIdentifiers;
            _outbreakHumanCasesViewModel.RelatedToReportIdentifiers = _getCaseDetailResult.First().RelatedToReportIdentifiers;

            //Permissions
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.PersonInfoSection = new DiseaseReportPersonalInformationPageViewModel
            {
                PermissionsAccessToPersonalData = _userPermissions
            };
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.isEdit = true;

            //Notification Section
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.NotificationSection = new DiseaseReportNotificationPageViewModel()
            {
                datOutbreakNotification = _getCaseDetailResult.First().datNotificationDate,
                idfNotificationReceivedByFacility = _getCaseDetailResult.First().idfReceivedByOffice,
                strNotificationReceivedByFacility = _getCaseDetailResult.First().ReceivedByOffice,
                idfNotificationReceivedByName = _getCaseDetailResult.First().idfReceivedByPerson,
                strNotificationReceivedByName = _getCaseDetailResult.First().ReceivedByPerson,
                idfNotificationSentByFacility = _getCaseDetailResult.First().idfSentByOffice,
                strNotificationSentByFacility = _getCaseDetailResult.First().SentByOffice,
                idfNotificationSentByName = _getCaseDetailResult.First().idfSentByPerson,
                strNotificationSentByName = _getCaseDetailResult.First().SentByPerson,
                PermissionsAccessToNotification = _userPermissionsAddEmployee
            };

            //Case Location
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.HumanCaseLocation = new Domain.ViewModels.CrossCutting.LocationViewModel()
            {
                AdminLevel0Value = _getCaseDetailResult.First().AdminLevel0Value,
                AdminLevel1Value = _getCaseDetailResult.First().AdminLevel1Value,
                AdminLevel2Value = _getCaseDetailResult.First().AdminLevel2Value,
                AdminLevel3Value = _getCaseDetailResult.First().AdminLevel3Value,
                AdminLevel1Text = _getCaseDetailResult.First().AdminLevel1Text,
                AdminLevel2Text = _getCaseDetailResult.First().AdminLevel2Text,
                AdminLevel3Text = _getCaseDetailResult.First().AdminLevel3Text,
                StreetText = _getCaseDetailResult.First().strStreetName,
                House = _getCaseDetailResult.First().strHouse,
                Building = _getCaseDetailResult.First().strBuilding,
                Apartment = _getCaseDetailResult.First().strApartment,
                PostalCodeText = _getCaseDetailResult.First().strPostCode,
                Latitude = _getCaseDetailResult.First().dblLatitude,
                Longitude = _getCaseDetailResult.First().dblLongitude
            };

            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.CaseidfGeoLocation = (long)_getCaseDetailResult.First().idfGeoLocation;

            //Clinical Information
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.SymptomsSection = new DiseaseReportSymptomsPageViewModel()
            {
                SymptomsOnsetDate = _getCaseDetailResult.First().datOnSetDate,
                idfCaseClassfication = _getCaseDetailResult.First().OutbreakCaseStatusID,
                strCaseClassification = _getCaseDetailResult.First().OutbreakCaseStatusName,
                HumanDiseaseSymptoms = new Domain.RequestModels.FlexForm.FlexFormQuestionnaireGetRequestModel()
                {
                    idfObservation = _getCaseDetailResult.First().idfCSObservation,
                    idfsFormType = (long)FlexFormType.HumanDiseaseClinicalSymptoms,
                    idfsDiagnosis = _getCaseDetailResult.First().idfsDiagnosisOrDiagnosisGroup,
                    LangID = GetCurrentLanguage()
                }
            };

            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.FacilityDetailsSection = new DiseaseReportFacilityDetailsPageViewModel()
            {
                HospitalizationPlace = _getCaseDetailResult.First().strHospitalizationPlace,
                Hospitalized = _getCaseDetailResult.First().idfsYNHospitalization,
                HospitalizationDate = _getCaseDetailResult.First().datHospitalizationDate,
                DateOfDischarge = _getCaseDetailResult.First().datDischargeDate
            };

            //Outbreak Investigation
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.CaseInvestigationSection = new DiseaseReportCaseInvestigationPageViewModel
            {
                idfInvestigatedByOffice = _getCaseDetailResult.First().idfInvestigatedByOffice,
                InvestigatedByOffice = _getCaseDetailResult.First().idfInvestigatedByOffice == null ? string.Empty : _getCaseDetailResult.First().InvestigatedByOffice,
                idfInvestigatedByPerson = _getCaseDetailResult.First().idfInvestigatedByPerson == null ? -1 : (long)_getCaseDetailResult.First().idfInvestigatedByPerson,
                InvestigatedByPerson = _getCaseDetailResult.First().idfInvestigatedByPerson == null ? string.Empty : _getCaseDetailResult.First().InvestigatedByPerson,
                StartDateofInvestigation = _getCaseDetailResult.First().datInvestigationStartDate,
                comments = _getCaseDetailResult.First().strNote,
                PrimaryCase = _getCaseDetailResult.First().IsPrimaryCaseFlag == "1",
                PermissionsAccessToNotification = _userPermissionsAddEmployee,
                OutbreakCaseClassificationID = _getCaseDetailResult.First().OutbreakCaseClassificationID == null ? -1 : (long)_getCaseDetailResult.First().OutbreakCaseClassificationID,
                OutbreakCaseClassificationName = _getCaseDetailResult.First().OutbreakCaseClassificationID == null ? string.Empty : _getCaseDetailResult.First().OutbreakCaseClassificationName,
                CurrentDate = DateTime.Now
            };

            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.RiskFactorsSection = new DiseaseReportCaseInvestigationRiskFactorsPageViewModel
            {
                RiskFactors = new Domain.RequestModels.FlexForm.FlexFormQuestionnaireGetRequestModel
                {
                    idfObservation = _getCaseDetailResult.First().idfEpiObservation,
                    idfsFormType = (long)FlexFormType.HumanCaseQuestionnaire,
                    idfsDiagnosis = _getCaseDetailResult.First().idfsDiagnosisOrDiagnosisGroup,
                    LangID = GetCurrentLanguage()
                }
            };

            //Case Monitoring
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.CaseDetails = new CaseGetDetailViewModel
            {
                CaseTypeId = (long)OutbreakSpeciesTypeEnum.Human
            };

            var monitorings = _getCaseDetailResult.First().CaseMonitorings;
            if (monitorings != null)
            {
                var monitoringsArray = JArray.Parse(monitorings);

                var caseMonitorings = monitoringsArray.Select(jsonObject => new CaseMonitoringGetListViewModel
                {
                    CaseMonitoringId = (long?)GetJsonValue(jsonObject, "idfOutbreakCaseMonitoring", DataType.Long),
                    ObservationId = (long?)GetJsonValue(jsonObject, "idfObservation", DataType.Long),
                    MonitoringDate = (DateTime?)GetJsonValue(jsonObject, "datMonitoringdate", DataType.DateTime),
                    InvestigatedByOrganizationId = (long?)GetJsonValue(jsonObject, "idfInvestigatedByOffice", DataType.Long),
                    InvestigatedByOrganizationName = GetJsonValue(jsonObject, "InvestigatedByOffice", DataType.String).ToString(),
                    InvestigatedByPersonId = (long?)GetJsonValue(jsonObject, "idfInvestigatedByPerson", DataType.Long),
                    InvestigatedByPersonName = GetJsonValue(jsonObject, "InvestigatedByPerson", DataType.String).ToString(),
                    AdditionalComments = GetJsonValue(jsonObject, "strAdditionalComments", DataType.String).ToString(),
                    CaseMonitoringFlexFormRequest = new Domain.RequestModels.FlexForm.FlexFormQuestionnaireGetRequestModel()
                    {
                        idfObservation = (long?)GetJsonValue(jsonObject, "idfObservation", DataType.Long),
                        idfsFormType = (long?)GetJsonValue(jsonObject, "idfsFormType", DataType.Long),
                        idfsDiagnosis = _getCaseDetailResult.First().idfsDiagnosisOrDiagnosisGroup,
                        LangID = GetCurrentLanguage()
                    }
                })
                    .ToList();

                _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.CaseDetails.CaseMonitorings = caseMonitorings.ToList();
            }

            //Contacts
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.ContactListSection = new DiseaseReportContactListPageViewModel
            {
                ContactDetails = new List<DiseaseReportContactDetailsViewModel>()
            };

            //Samples
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.SamplesSection = new DiseaseReportSamplePageViewModel
            {
                SamplesDetails = new List<DiseaseReportSamplePageSampleDetailViewModel>(),
                SamplesCollectedYN = _getCaseDetailResult.First().idfsYNSpecimenCollected
            };

            var samples = _getCaseDetailResult.First().Samples;
            if (samples != null)
            {
                var samplesArray = JArray.Parse(samples);

                foreach (var jsonObject in samplesArray)
                {
                    var sample = new DiseaseReportSamplePageSampleDetailViewModel()
                    {
                        idfMaterial = (long?)GetJsonValue(jsonObject, "idfMaterial", DataType.Long),
                        SampleTypeID = (long?)GetJsonValue(jsonObject, "idfsSampleType", DataType.Long),
                        SampleType = GetJsonValue(jsonObject, "SampleType", DataType.String).ToString(),
                        strFieldBarcode = GetJsonValue(jsonObject, "strFieldBarcode", DataType.String).ToString(),
                        CollectionDate = (DateTime?)GetJsonValue(jsonObject, "datFieldCollectionDate", DataType.DateTime),
                        CollectedByOrganizationID = (long?)GetJsonValue(jsonObject, "idfFieldCollectedByOffice", DataType.Long),
                        CollectedByOrganization = GetJsonValue(jsonObject, "CollectedByOffice", DataType.String).ToString(),
                        CollectedByOfficerID = (long?)GetJsonValue(jsonObject, "idfFieldCollectedByPerson", DataType.Long),
                        CollectedByOfficer = GetJsonValue(jsonObject, "CollectedByPerson", DataType.String).ToString(),
                        SentToOrganizationID = (long?)GetJsonValue(jsonObject, "idfSendToOffice", DataType.Long),
                        SentToOrganization = GetJsonValue(jsonObject, "SentToOffice", DataType.String).ToString(),
                        strNote = GetJsonValue(jsonObject, "strNote", DataType.String).ToString(),
                        SentDate = (DateTime?)GetJsonValue(jsonObject, "datFieldSentDate", DataType.DateTime)
                    };
                    _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.SamplesSection.SamplesDetails.Add(sample);
                }
            }

            //Tests Section
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.TestsSection = new DiseaseReportTestPageViewModel
            {
                TestDetails = new List<DiseaseReportTestDetailForDiseasesViewModel>(),
                TestsConducted = _getCaseDetailResult.First().idfsYNTestsConducted
            };

            var tests = _getCaseDetailResult.First().Tests;
            if (tests != null)
            {
                var testsArray = JArray.Parse(tests);

                foreach (var jsonObject in testsArray)
                {
                    var test = new DiseaseReportTestDetailForDiseasesViewModel()
                    {
                        idfTesting = (long?)GetJsonValue(jsonObject, "idfTesting", DataType.Long),
                        idfMaterial = (long)GetJsonValue(jsonObject, "idfMaterial", DataType.Long),
                        idfsSampleType = (long)GetJsonValue(jsonObject, "idfsSampleType", DataType.Long),
                        strFieldBarcode = GetJsonValue(jsonObject, "strFieldBarcode", DataType.String).ToString(),
                        idfsTestName = (long?)GetJsonValue(jsonObject, "idfsTestName", DataType.Long),
                        idfsTestResult = (long?)GetJsonValue(jsonObject, "idfsTestResult", DataType.Long),
                        idfsTestStatus = (long?)GetJsonValue(jsonObject, "idfsTestStatus", DataType.Long),
                        idfsTestCategory = (long?)GetJsonValue(jsonObject, "idfsTestCategory", DataType.Long),
                        blnValidateStatus = jsonObject["blnValidateStatus"].ToString() == "1",
                        strSampleTypeName = GetJsonValue(jsonObject, "SampleType", DataType.String).ToString(),
                        name = GetJsonValue(jsonObject, "TestName", DataType.String).ToString(),
                        strTestResult = GetJsonValue(jsonObject, "TestResult", DataType.String).ToString(),
                        strTestStatus = GetJsonValue(jsonObject, "TestStatus", DataType.String).ToString(),
                        strTestCategory = GetJsonValue(jsonObject, "TestCategory", DataType.String).ToString(),
                        strTestedByPerson = GetJsonValue(jsonObject, "ValidatedByPerson", DataType.String).ToString(),
                        strValidatedBy = GetJsonValue(jsonObject, "ValidatedByPerson", DataType.String).ToString()
                    };
                    _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.TestsSection.TestDetails.Add(test);
                }
            }

            return View(_outbreakHumanCasesViewModel);
        }

        public async Task<IActionResult> Details(long id, long callbackkey)
        {
            return View(await CaseInit(id, callbackkey));
        }

        private async Task<HumanCaseViewModel> CaseInit(long id, long callbackkey)
        {
            _outbreakHumanCasesViewModel = new HumanCaseViewModel();

            HumanPersonDetailsRequestModel personRequest = new()
            {
                HumanMasterID = id,
                LangID = GetCurrentLanguage()
            };

            var personDetailList = await _personClient.GetHumanDiseaseReportPersonInfoAsync(personRequest);

            _outbreakHumanCasesViewModel.CaseSummaryDetails = new OutbreakCaseSummaryModel
            {
                HumanMasterID = id,
                EIDSSPersonID = personDetailList.FirstOrDefault().EIDSSPersonID,
                Name = personDetailList.FirstOrDefault().FirstOrGivenName + " " + personDetailList.FirstOrDefault().LastOrSurname,
                DateEntered = personDetailList.FirstOrDefault().EnteredDate
            };

            var sessionDetailRequest = new OutbreakSessionDetailRequestModel
            {
                LanguageID = GetCurrentLanguage(),
                idfsOutbreak = callbackkey
            };

            _outbreakHumanCasesViewModel.idfOutbreak = callbackkey;
            _outbreakHumanCasesViewModel.HumanMasterID = id;

            var getSessionDetailResult = await _outbreakClient.GetSessionDetail(sessionDetailRequest);
            _outbreakHumanCasesViewModel.SessionDetails = getSessionDetailResult.FirstOrDefault();
            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel = new DiseaseReportComponentViewModel();

            var parametersRequest = new OutbreakSessionDetailRequestModel
            {
                LanguageID = GetCurrentLanguage(),
                idfsOutbreak = callbackkey
            };

            _outbreakHumanCasesViewModel.diseaseReportComponentViewModel.CaseInvestigationSection = new DiseaseReportCaseInvestigationPageViewModel
            {
                CurrentDate = DateTime.Now
            };

            _outbreakHumanCasesViewModel.SessionParameters = _outbreakClient.GetSessionParametersList(parametersRequest).Result.FirstOrDefault(x => x.OutbreakSpeciesTypeID == (long?)OutbreakSpeciesTypeEnum.Human);

            return _outbreakHumanCasesViewModel;
        }

        private object GetJsonValue(object data, string strKeyword, DataType dt)
        {
            var jsonObject = JObject.Parse(data.ToString());
            var value = jsonObject[strKeyword] != null ? ((jsonObject[strKeyword].ToString() == "") ? null : jsonObject[strKeyword].ToString()) : null;

            object returnValue = null;

            if (value != null)
            {
                switch (dt)
                {
                    case DataType.DateTime:
                        returnValue = DateTime.Parse(value);
                        break;
                    case DataType.Int:
                        returnValue = int.Parse(value);
                        break;
                    case DataType.String:
                        returnValue = value;
                        break;
                    case DataType.Long:
                        returnValue = long.Parse(value);
                        break;
                    case DataType.Double:
                        returnValue = double.Parse(value);
                        break;
                    case DataType.Boolean:
                        returnValue = bool.Parse(value);
                        break;
                }
            }
            else
            {
                returnValue = dt switch
                {
                    DataType.LocationType => LocationType.None,
                    DataType.String => string.Empty,
                    _ => returnValue
                };
            }

            return returnValue;
        }
    }
}
