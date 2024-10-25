using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Outbreak.ViewModels;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Human.Outbreak
{
    [ViewComponent(Name = "HumanCase")]
    [Area("Outbreak")]
    public class HumanCase : BaseController
    {
        private readonly IOutbreakClient _OutbreakClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfiguration _configuration;
        private DiseaseReportComponentViewModel _diseaseReportComponentViewModel;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly INotificationSiteAlertService _notificationService;
        private readonly AuthenticatedUser _authenticatedUser;
        private readonly IHumanDiseaseReportClient _humanDiseaseReportClient;
        private readonly IStringLocalizer _localizer;
        private HumanDiseaseReportDetailViewModel detailResponse;
        private readonly IDiseaseHumanGenderMatrixClient _diseaseHumanGenderMatrixClient;
        private OutbreakSessionDetailsResponseModel outbreakSessionDetail;

        private bool IsbSessionClosed { get; set; }
        private bool IsEdit { get; set; }
        private long? CaseQuestionnaireTemplateID { get; set; }
        private long? CaseEPIObservationID { get; set; }


        private enum DataType
        {
            String,
            Int,
            Long,
            DateTime,
            Double,
            LocationType
        }

        public HumanCase(
            IOutbreakClient outbreakClient,
            ICrossCuttingClient crossCuttingClient,
            IConfiguration configuration,
            IHumanDiseaseReportClient humanDiseaseReportClient,
            ITokenService tokenService,
            ILogger<OrganizationSearchController> logger,
            IStringLocalizer localizer,
            IDiseaseHumanGenderMatrixClient diseaseHumanGenderMatrixClient,
            INotificationSiteAlertService notificationService,
            IHttpContextAccessor httpContextAccessor)
            : base(logger, tokenService)
        {
            _OutbreakClient = outbreakClient;

            _httpContextAccessor = httpContextAccessor;
            _crossCuttingClient = crossCuttingClient;
            _humanDiseaseReportClient = humanDiseaseReportClient;
            _notificationService = notificationService;
            _configuration = configuration;
            _localizer = localizer;
            _diseaseHumanGenderMatrixClient = diseaseHumanGenderMatrixClient;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
        }

        public async Task<IViewComponentResult> InvokeAsync(HumanCaseViewModel model)
        {
            _diseaseReportComponentViewModel = model.diseaseReportComponentViewModel;

            UserPermissions deletePermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
            UserPermissions CanReopenClosedReport = GetUserPermissions(PagePermission.CanReopenClosedHumanDiseaseReportSession);

            OutbreakSessionDetailRequestModel outbreakSessionRequest = new()
            {
                LanguageID = GetCurrentLanguage(),
                idfsOutbreak = model.idfOutbreak
            };

            List<OutbreakSessionDetailsResponseModel> result = await _OutbreakClient.GetSessionDetail(outbreakSessionRequest);
            outbreakSessionDetail = result.FirstOrDefault();

            bool bSessionClosed = (result.First().idfsOutbreakStatus == (long)OutbreakSessionStatus.Closed) || model.IsReadOnly;
            IsbSessionClosed = bSessionClosed;

            _diseaseReportComponentViewModel.isDeleteEnabled = deletePermissions.Delete;
            try
            {
                _diseaseReportComponentViewModel.HumanActualID = model.CaseSummaryDetails.HumanMasterID;

                IsEdit = _diseaseReportComponentViewModel.isEdit;

                //Sumarry Section
                if (!_diseaseReportComponentViewModel.isEdit)
                {
                    InitializeModels(model);

                    UserPermissions caseMonitoringPermissions = GetUserPermissions(PagePermission.AccessToOutbreakHumanCaseData);

                    _diseaseReportComponentViewModel.ReportSummary = new DiseaseReportSummaryPageViewModel();
                    _diseaseReportComponentViewModel.NotificationSection = new DiseaseReportNotificationPageViewModel
                    {
                        isOutbreakCase = true,
                        datOutbreakStartDate = outbreakSessionDetail.datStartDate,
                        PermissionsAccessToNotification = new UserPermissions()
                    };
                    _diseaseReportComponentViewModel.NotificationSection.PermissionsAccessToNotification.Create = caseMonitoringPermissions.Create;
                    _diseaseReportComponentViewModel.NotificationSection.PermissionsAccessToNotification.Write = caseMonitoringPermissions.Write;
                    _diseaseReportComponentViewModel.NotificationSection.PermissionsAccessToNotification.Delete = caseMonitoringPermissions.Delete;

                    _diseaseReportComponentViewModel.SymptomsSection = new DiseaseReportSymptomsPageViewModel();
                    _diseaseReportComponentViewModel.FacilityDetailsSection = new DiseaseReportFacilityDetailsPageViewModel();
                    _diseaseReportComponentViewModel.AntibioticVaccineHistorySection = new DiseaseReportAntibioticVaccineHistoryPageViewModel();

                    _diseaseReportComponentViewModel.CaseDetails = new CaseGetDetailViewModel
                    {
                        CaseMonitorings = new List<CaseMonitoringGetListViewModel>(),
                        Session = new OutbreakSessionDetailsResponseModel()
                    };

                    if (model.SessionParameters != null)
                    {
                        if (model.SessionParameters.CaseMonitoringTemplateID != null)
                        {
                            _diseaseReportComponentViewModel.CaseDetails.Session.HumanCaseMonitoringTemplateID = model.SessionParameters.CaseMonitoringTemplateID;
                        }
                        if (model.SessionParameters.CaseQuestionaireTemplateID != null)
                        {
                            _diseaseReportComponentViewModel.CaseDetails.Session.HumanCaseQuestionaireTemplateID = model.SessionParameters.CaseQuestionaireTemplateID;
                            CaseQuestionnaireTemplateID = model.SessionParameters.CaseQuestionaireTemplateID;
                        }
                        if (model.SessionParameters.ContactTracingTemplateID != null)
                        {
                            _diseaseReportComponentViewModel.CaseDetails.Session.HumanContactTracingTemplateID = model.SessionParameters.ContactTracingTemplateID;
                        }
                    }

                    _diseaseReportComponentViewModel.CaseDetails.WritePermissionIndicator = caseMonitoringPermissions.Write;
                    _diseaseReportComponentViewModel.CaseDetails.DeletePermissionIndicator = caseMonitoringPermissions.Delete;
                    _diseaseReportComponentViewModel.CaseDetails.CreatePermissionIndicator = caseMonitoringPermissions.Create;
                    _diseaseReportComponentViewModel.CaseDetails.CaseDisabledIndicator = false;

                    _diseaseReportComponentViewModel.DiseaseReport = new Domain.ViewModels.Veterinary.DiseaseReportGetDetailViewModel
                    {
                        ReportCategoryTypeID = (long)model.SessionDetails.OutbreakTypeId
                    };

                    _diseaseReportComponentViewModel.SamplesSection = new DiseaseReportSamplePageViewModel();
                    _diseaseReportComponentViewModel.TestsSection = new DiseaseReportTestPageViewModel();
                    _diseaseReportComponentViewModel.CaseInvestigationSection = new DiseaseReportCaseInvestigationPageViewModel
                    {
                        PermissionsAccessToNotification = new UserPermissions()
                    };
                    _diseaseReportComponentViewModel.CaseInvestigationSection.PermissionsAccessToNotification.Write = caseMonitoringPermissions.Write;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.PermissionsAccessToNotification.Delete = caseMonitoringPermissions.Delete;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.PermissionsAccessToNotification.Create = caseMonitoringPermissions.Create;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.isOutbreakCase = true;

                    _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest = new FlexFormQuestionnaireGetRequestModel
                    {
                        LangID = GetCurrentLanguage()
                    };
                    if (model.SessionParameters != null)
                    {
                        if (model.SessionParameters.ContactTracingTemplateID != null)
                        {
                            _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest.idfsFormType = FlexFormTypes.OutbreakHumanContactCT;
                            _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest.idfsFormTemplate = model.SessionParameters.ContactTracingTemplateID;
                            _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest.idfObservation = null;
                        }
                    }

                    _diseaseReportComponentViewModel.FinalOutcomeSection = new DiseaseReportFinalOutcomeViewModel();
                    _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo = new DiseaseReportPersonalInformationViewModel();
                    _diseaseReportComponentViewModel.PersonInfoSection.PermissionsAccessToPersonalData = new UserPermissions();
                    _diseaseReportComponentViewModel.PersonInfoSection.PersonalIdTypeDD = new Select2Configruation();
                    _diseaseReportComponentViewModel.PersonInfoSection.SchoolAddressCountryDD = new Select2Configruation();
                    _diseaseReportComponentViewModel.PersonInfoSection.OccupationDD = new Select2Configruation();
                    _diseaseReportComponentViewModel.PersonInfoSection.CurrentAddress = new LocationViewModel();

                    //Outbreak Case Related Models
                    _diseaseReportComponentViewModel.HumanCaseLocation = new LocationViewModel();
                    _diseaseReportComponentViewModel.HumanCaseClinicalInformation = new HumanCaseClinicalInformation();
                }
                else
                {
                    InitializeModels(model);
                }

                _diseaseReportComponentViewModel.CaseDetails.DiseaseId = (long)model.SessionDetails.idfsDiagnosisOrDiagnosisGroup;
                _diseaseReportComponentViewModel.CaseDetails.CaseId = model.OutbreakCaseReportUID;
                _diseaseReportComponentViewModel.CaseDetails.Session.OutbreakTypeId = (long)OutbreakTypeEnum.Human;

                HumanPersonDetailsRequestModel request = new();
                HumanPersonDetailsFromHumanIDRequestModel requestID = new();
                List<DiseaseReportPersonalInformationViewModel> response = new();
                if (!_diseaseReportComponentViewModel.isEdit)
                {
                    await OnHumanDiseaseReportCreation(long.Parse(_authenticatedUser.SiteId));
                    _httpContextAccessor.HttpContext.Response.Cookies.Append("HDRNotifications", JsonConvert.SerializeObject(_diseaseReportComponentViewModel.PendingSaveEvents));
                    request.LangID = GetCurrentLanguage();
                    request.HumanMasterID = _diseaseReportComponentViewModel.HumanActualID;
                    response = await _humanDiseaseReportClient.GetHumanDiseaseReportPersonInfoAsync(request);
                    _diseaseReportComponentViewModel.HumanCaseLocation.AdminLevel0Value = response[0].HumanidfsCountry;
                    _diseaseReportComponentViewModel.HumanCaseLocation.AdminLevel0Text = response[0].HumanCountry;
                    _diseaseReportComponentViewModel.HumanCaseLocation.AdminLevel1Value = response[0].HumanidfsRegion;
                    _diseaseReportComponentViewModel.HumanCaseLocation.AdminLevel1Text = response[0].HumanRegion;
                    _diseaseReportComponentViewModel.HumanCaseLocation.AdminLevel2Value = response[0].HumanidfsRayon;
                    _diseaseReportComponentViewModel.HumanCaseLocation.AdminLevel2Text = response[0].HumanRayon;
                    _diseaseReportComponentViewModel.HumanCaseLocation.AdminLevel3Value = response[0].HumanidfsSettlement;
                    _diseaseReportComponentViewModel.HumanCaseLocation.AdminLevel3Text = response[0].HumanSettlement;
                    _diseaseReportComponentViewModel.HumanCaseLocation.StreetText = response[0].HumanstrStreetName;
                    _diseaseReportComponentViewModel.HumanCaseLocation.House = response[0].HumanstrHouse;
                    _diseaseReportComponentViewModel.HumanCaseLocation.Building = response[0].HumanstrBuilding;
                    _diseaseReportComponentViewModel.HumanCaseLocation.Apartment = response[0].HumanstrApartment;
                    _diseaseReportComponentViewModel.HumanCaseLocation.PostalCodeText = response[0].HumanstrPostalCode;

                    if (response != null && response.Count > 0)
                    {
                        var personInfo = response.FirstOrDefault();
                        _diseaseReportComponentViewModel.ReportSummary.PersonID = personInfo.EIDSSPersonID;
                        _diseaseReportComponentViewModel.ReportSummary.PersonName = personInfo.PatientFarmOwnerName;
                        _diseaseReportComponentViewModel.ReportSummary.DateEntered = personInfo.EnteredDate ?? DateTime.Today;
                        _diseaseReportComponentViewModel.ReportSummary.EnteredBy = _authenticatedUser.UserName;
                        _diseaseReportComponentViewModel.ReportSummary.EnteredByOrganization = _authenticatedUser.Organization;
                        if (_diseaseReportComponentViewModel.isEdit && personInfo.HumanId != 0 && personInfo.HumanActualId != 0)
                        {
                            _diseaseReportComponentViewModel.HumanActualID = personInfo.HumanActualId;
                            _diseaseReportComponentViewModel.HumanID = personInfo.HumanId;
                        }
                    }
                }
                else
                {
                    var detailRequest = new HumanDiseaseReportDetailRequestModel()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = 10,
                        SearchHumanCaseId = Convert.ToInt64(_diseaseReportComponentViewModel.idfHumanCase),
                        SortColumn = "datEnteredDate",
                        SortOrder = "desc"
                    };

                    detailResponse = await _humanDiseaseReportClient.GetHumanDiseaseDetail(detailRequest);

                    //Transfer of HDR field to Outbreak for validation separation purposes.
                    //this should not be done, if it wasn't for sharing HDR with HC.
                    _diseaseReportComponentViewModel.SymptomsSection.OutBreakSymptomsOnsetDate = detailResponse.datOnSetDate;

                    List<CaseGetDetailViewModel> caseDetails = await _OutbreakClient.GetCaseDetail(GetCurrentLanguage(), model.OutbreakCaseReportUID);


                    CaseEPIObservationID = caseDetails.First().CaseQuestionnaireObservationId;

                    if (detailResponse != null)
                    {
                        var humanDiseaseDetail = detailResponse;

                        _diseaseReportComponentViewModel.HumanCaseClinicalInformation.datFinalDiagnosisDate = humanDiseaseDetail.datFinalDiagnosisDate;

                        _diseaseReportComponentViewModel.ReportSummary.ReportID = humanDiseaseDetail.strCaseId;
                        _diseaseReportComponentViewModel.ReportSummary.ReportStatus = humanDiseaseDetail.CaseProgressStatus;
                        _diseaseReportComponentViewModel.ReportSummary.ReportStatusID = humanDiseaseDetail.idfsCaseProgressStatus.Value;
                        _diseaseReportComponentViewModel.ReportSummary.DateEntered = humanDiseaseDetail.datEnteredDate ?? DateTime.Today;
                        _diseaseReportComponentViewModel.ReportSummary.EnteredBy = humanDiseaseDetail.EnteredByPerson;
                        _diseaseReportComponentViewModel.ReportSummary.EnteredByOrganization = humanDiseaseDetail.strOfficeEnteredBy;
                        _diseaseReportComponentViewModel.ReportSummary.ReportType = humanDiseaseDetail.ReportType;
                        if (humanDiseaseDetail.DiseaseReportTypeID != null && humanDiseaseDetail.DiseaseReportTypeID != 0)
                            _diseaseReportComponentViewModel.ReportSummary.ReportTypeID = humanDiseaseDetail.DiseaseReportTypeID.Value;
                        _diseaseReportComponentViewModel.ReportSummary.LegacyID = humanDiseaseDetail.LegacyCaseID;
                        _diseaseReportComponentViewModel.ReportSummary.SessionID = humanDiseaseDetail.strMonitoringSessionID;
                        _diseaseReportComponentViewModel.ReportSummary.Disease = humanDiseaseDetail.strFinalDiagnosis;
                        _diseaseReportComponentViewModel.ReportSummary.DateLastUpdated = humanDiseaseDetail.datModificationDate.ToString();
                        _diseaseReportComponentViewModel.ReportSummary.PersonID = humanDiseaseDetail.EIDSSPersonID;
                        _diseaseReportComponentViewModel.ReportSummary.PersonName = humanDiseaseDetail.PatientFarmOwnerName;
                        _diseaseReportComponentViewModel.ReportSummary.idfHumanCase = humanDiseaseDetail.idfHumanCase;
                        _diseaseReportComponentViewModel.ReportSummary.HumanID = humanDiseaseDetail.idfHuman;
                        _diseaseReportComponentViewModel.ReportSummary.HumanActualID = humanDiseaseDetail.HumanActualId;
                        _diseaseReportComponentViewModel.ReportSummary.CaseClassification = humanDiseaseDetail.SummaryCaseClassification;
                        _diseaseReportComponentViewModel.ReportSummary.blnFinalSSD = humanDiseaseDetail.blnFinalSSD;
                        _diseaseReportComponentViewModel.ReportSummary.blnInitialSSD = humanDiseaseDetail.blnInitialSSD;

                        //Setting at Detail View Model
                        _diseaseReportComponentViewModel.HumanActualID = humanDiseaseDetail.HumanActualId;
                        _diseaseReportComponentViewModel.HumanID = humanDiseaseDetail.idfHuman;
                        _diseaseReportComponentViewModel.idfHumanCase = humanDiseaseDetail.idfHumanCase;
                        _diseaseReportComponentViewModel.strCaseId = humanDiseaseDetail.strCaseId;
                        _diseaseReportComponentViewModel.ReportStatus = humanDiseaseDetail.CaseProgressStatus;
                        _diseaseReportComponentViewModel.ReportStatusID = humanDiseaseDetail.idfsCaseProgressStatus.Value;
                        if (_diseaseReportComponentViewModel.ReportStatusID == (long)VeterinaryDiseaseReportStatusTypes.Closed)
                        {
                            _diseaseReportComponentViewModel.IsReportClosed = true;
                            _diseaseReportComponentViewModel.ReportSummary.IsReportClosed = true;
                            _diseaseReportComponentViewModel.ReportSummary.blnCanReopenClosedCase = CanReopenClosedReport.Execute;
                        }
                    }
                }
                //End
                model.CaseReportPrintViewModal = new()
                {
                    Parameters = new List<KeyValuePair<string, string>>(),
                    ReportName = "HumanOutbreakCase"
                };

                if (detailResponse != null)
                {
                    model.CaseReportPrintViewModal.Parameters.Add(new KeyValuePair<string, string>("LangID", GetCurrentLanguage()));
                    model.CaseReportPrintViewModal.Parameters.Add(new KeyValuePair<string, string>("ObjID", model.OutbreakCaseReportUID.ToString()));
                    model.CaseReportPrintViewModal.Parameters.Add(new KeyValuePair<string, string>("UserOrganization", _authenticatedUser.Organization));
                    model.CaseReportPrintViewModal.Parameters.Add(new KeyValuePair<string, string>("PersonID", _authenticatedUser.PersonId.ToString()));
                    model.CaseReportPrintViewModal.Parameters.Add(new KeyValuePair<string, string>("SiteID", _authenticatedUser.SiteId.ToString()));
                    model.CaseReportPrintViewModal.Parameters.Add(new KeyValuePair<string, string>("UserFullName", _authenticatedUser.UserName));
                    model.CaseReportPrintViewModal.Parameters.Add(new KeyValuePair<string, string>("IncludeSignature", "True"));
                    model.CaseReportPrintViewModal.Parameters.Add(new KeyValuePair<string, string>("PrintDateTime", DateTime.Now.ToShortDateString().ToString(new CultureInfo(GetCurrentLanguage()))));
                }

                if (model.diseaseReportComponentViewModel.HumanActualID != 0 && model.diseaseReportComponentViewModel.HumanActualID != null)
                {
                    _diseaseReportComponentViewModel.HumanActualID = model.diseaseReportComponentViewModel.HumanActualID;
                }
                if (model.diseaseReportComponentViewModel.HumanID != 0 && model.diseaseReportComponentViewModel.HumanID != null)
                {
                    _diseaseReportComponentViewModel.HumanID = model.diseaseReportComponentViewModel.HumanID;
                }

                _diseaseReportComponentViewModel.HumanCaseLocation = LoadCaseLocation(_diseaseReportComponentViewModel.HumanCaseLocation);

                _diseaseReportComponentViewModel.PersonInfoSection = await LoadPersonInfo();

                _diseaseReportComponentViewModel.NotificationSection = LoadNotification(model.diseaseReportComponentViewModel.isEdit);
                if (_diseaseReportComponentViewModel != null && _diseaseReportComponentViewModel.PersonInfoSection != null && _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo != null)
                {
                    _diseaseReportComponentViewModel.NotificationSection.DateOfBirth = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.DateOfBirth;
                    _diseaseReportComponentViewModel.NotificationSection.GenderTypeID = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.GenderTypeID;
                    _diseaseReportComponentViewModel.NotificationSection.GenderTypeName = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.GenderTypeName;
                }
                _diseaseReportComponentViewModel.SymptomsSection = LoadSymptoms(model.diseaseReportComponentViewModel.SymptomsSection, model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.FacilityDetailsSection = await LoadFacilityDetails(model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.AntibioticVaccineHistorySection = await LoadAntibioticVaccineHistoryDetails(model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.SamplesSection = await LoadSampleDetails(model.diseaseReportComponentViewModel.NotificationSection.idfDisease, model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.TestsSection = await LoadTestsDetails(model.diseaseReportComponentViewModel.NotificationSection.idfDisease, model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.CaseInvestigationSection = LoadCaseInvestigationDetails(model.diseaseReportComponentViewModel.isEdit);


                _diseaseReportComponentViewModel.RiskFactorsSection = LoadCaseInvestigationRiskFactors(model.diseaseReportComponentViewModel.isEdit, model.diseaseReportComponentViewModel.CaseDetails.Session.HumanCaseQuestionaireTemplateID, detailResponse != null ? CaseEPIObservationID : null);

                _diseaseReportComponentViewModel.ContactListSection = await LoadContactList(model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.FinalOutcomeSection = LoadFinalOutComeDetails(model.diseaseReportComponentViewModel.NotificationSection.idfDisease, model.diseaseReportComponentViewModel.isEdit);

                if (bSessionClosed)
                {
                    _diseaseReportComponentViewModel.ReportSummary.IsReportClosed = true;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.FinalOutcomeSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.IsReportClosed = true;
                    _diseaseReportComponentViewModel.NotificationSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.SymptomsSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.FacilityDetailsSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.AntibioticVaccineHistorySection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.SamplesSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.TestsSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.RiskFactorsSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.ContactListSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.SamplesSection.IsReportClosed = true;

                    _diseaseReportComponentViewModel.HumanCaseLocation.IsLocationDisabled = bSessionClosed;
                    _diseaseReportComponentViewModel.CaseDetails.CaseDisabledIndicator = bSessionClosed;
                }
                else
                {
                    _diseaseReportComponentViewModel.SamplesSection.idfDisease = _diseaseReportComponentViewModel.CaseDetails.DiseaseId;
                }
            }
            catch (Exception)
            {

            }

            var viewData = new ViewDataDictionary<HumanCaseViewModel>(ViewData, model);
            return new ViewViewComponentResult()
            {
                ViewData = viewData
            };
        }

        private void InitializeModels(HumanCaseViewModel model)
        {
            _diseaseReportComponentViewModel.ReportSummary ??= new DiseaseReportSummaryPageViewModel();
            _diseaseReportComponentViewModel.NotificationSection ??= new DiseaseReportNotificationPageViewModel();
            _diseaseReportComponentViewModel.NotificationSection.isOutbreakCase = true;
            _diseaseReportComponentViewModel.NotificationSection.datOutbreakStartDate = outbreakSessionDetail.datStartDate;
            _diseaseReportComponentViewModel.SymptomsSection ??= new DiseaseReportSymptomsPageViewModel();
            _diseaseReportComponentViewModel.FacilityDetailsSection ??= new DiseaseReportFacilityDetailsPageViewModel();
            _diseaseReportComponentViewModel.AntibioticVaccineHistorySection ??= new DiseaseReportAntibioticVaccineHistoryPageViewModel();

            _diseaseReportComponentViewModel.CaseDetails ??= new CaseGetDetailViewModel
            {
                CaseMonitorings = new List<CaseMonitoringGetListViewModel>(),
                Session = new OutbreakSessionDetailsResponseModel()
            };

            if (_diseaseReportComponentViewModel.CaseDetails.Session == null)
            {
                _diseaseReportComponentViewModel.CaseDetails.Session = new OutbreakSessionDetailsResponseModel();
            }

            if (model.SessionParameters != null)
            {
                if (model.SessionParameters.CaseMonitoringTemplateID != null)
                {
                    _diseaseReportComponentViewModel.CaseDetails.Session.HumanCaseMonitoringTemplateID = model.SessionParameters.CaseMonitoringTemplateID;
                }

                if (model.SessionParameters.CaseQuestionaireTemplateID != null)
                {
                    _diseaseReportComponentViewModel.CaseDetails.Session.HumanCaseQuestionaireTemplateID = model.SessionParameters.CaseQuestionaireTemplateID;
                }

                if (model.SessionParameters.ContactTracingTemplateID != null)
                {
                    _diseaseReportComponentViewModel.CaseDetails.Session.HumanContactTracingTemplateID = model.SessionParameters.ContactTracingTemplateID;
                }
            }

            UserPermissions caseMonitoringPermissions = GetUserPermissions(PagePermission.AccessToOutbreakHumanCaseData);

            _diseaseReportComponentViewModel.CaseDetails.WritePermissionIndicator = caseMonitoringPermissions.Write;
            _diseaseReportComponentViewModel.CaseDetails.DeletePermissionIndicator = caseMonitoringPermissions.Delete;
            _diseaseReportComponentViewModel.CaseDetails.CreatePermissionIndicator = caseMonitoringPermissions.Create;
            _diseaseReportComponentViewModel.CaseDetails.CaseDisabledIndicator = false;

            _diseaseReportComponentViewModel.DiseaseReport ??= new Domain.ViewModels.Veterinary.DiseaseReportGetDetailViewModel();
            _diseaseReportComponentViewModel.DiseaseReport.ReportCategoryTypeID = (long)model.SessionDetails.OutbreakTypeId;

            _diseaseReportComponentViewModel.SamplesSection ??= new DiseaseReportSamplePageViewModel();
            _diseaseReportComponentViewModel.TestsSection ??= new DiseaseReportTestPageViewModel();
            _diseaseReportComponentViewModel.CaseInvestigationSection ??= new DiseaseReportCaseInvestigationPageViewModel();
            if (_diseaseReportComponentViewModel.CaseInvestigationSection == null)
            {
                _diseaseReportComponentViewModel.CaseInvestigationSection.PermissionsAccessToNotification = new UserPermissions();
            }
            _diseaseReportComponentViewModel.CaseInvestigationSection.isOutbreakCase = true;

            _diseaseReportComponentViewModel.ContactListSection ??= new DiseaseReportContactListPageViewModel();
            if (_diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest == null)
            {
                _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest = new FlexFormQuestionnaireGetRequestModel();
            }

            _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest.LangID = GetCurrentLanguage();
            _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest.idfsFormType = FlexFormTypes.OutbreakHumanContactCT;

            if (model.SessionParameters != null)
            {
                if (model.SessionParameters.ContactTracingTemplateID != null)
                {
                    _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest.idfsFormTemplate = model.SessionParameters.ContactTracingTemplateID;
                    _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest.idfObservation = null;
                }
            }

            _diseaseReportComponentViewModel.FinalOutcomeSection ??= new DiseaseReportFinalOutcomeViewModel();
            _diseaseReportComponentViewModel.PersonInfoSection ??= new DiseaseReportPersonalInformationPageViewModel();
            if (_diseaseReportComponentViewModel.PersonInfoSection.PersonInfo == null)
            {
                _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo = new DiseaseReportPersonalInformationViewModel();
            }
            if (_diseaseReportComponentViewModel.PersonInfoSection.PermissionsAccessToPersonalData == null)
            {
                _diseaseReportComponentViewModel.PersonInfoSection.PermissionsAccessToPersonalData = new UserPermissions();
            }
            if (_diseaseReportComponentViewModel.PersonInfoSection.PersonalIdTypeDD == null)
            {
                _diseaseReportComponentViewModel.PersonInfoSection.PersonalIdTypeDD = new Select2Configruation();
            }
            if (_diseaseReportComponentViewModel.PersonInfoSection.SchoolAddressCountryDD == null)
            {
                _diseaseReportComponentViewModel.PersonInfoSection.SchoolAddressCountryDD = new Select2Configruation();
            }
            if (_diseaseReportComponentViewModel.PersonInfoSection.OccupationDD == null)
            {
                _diseaseReportComponentViewModel.PersonInfoSection.OccupationDD = new Select2Configruation();
            }
            if (_diseaseReportComponentViewModel.PersonInfoSection.CurrentAddress == null)
            {
                _diseaseReportComponentViewModel.PersonInfoSection.CurrentAddress = new LocationViewModel();
            }
            _diseaseReportComponentViewModel.HumanCaseLocation ??= new LocationViewModel();
            _diseaseReportComponentViewModel.HumanCaseClinicalInformation ??= new HumanCaseClinicalInformation();
        }

        private LocationViewModel LoadCaseLocation(LocationViewModel caseLocation)
        {
            caseLocation ??= new LocationViewModel();

            caseLocation.CallingObjectID = "caseLocation_";
            caseLocation.IsHorizontalLayout = true;
            caseLocation.ShowAdminLevel0 = false;
            caseLocation.ShowAdminLevel1 = true;
            caseLocation.ShowAdminLevel2 = true;
            caseLocation.ShowAdminLevel3 = true;
            caseLocation.ShowAdminLevel4 = false;
            caseLocation.ShowAdminLevel5 = false;
            caseLocation.ShowAdminLevel6 = false;
            caseLocation.ShowSettlementType = false;
            caseLocation.ShowSettlement = true;
            caseLocation.ShowStreet = true;
            caseLocation.ShowBuilding = true;
            caseLocation.ShowApartment = true;
            caseLocation.ShowElevation = false;
            caseLocation.ShowHouse = true;
            caseLocation.ShowLatitude = true;
            caseLocation.ShowLongitude = true;
            caseLocation.ShowMap = true;
            caseLocation.ShowBuildingHouseApartmentGroup = true;
            caseLocation.ShowPostalCode = true;
            caseLocation.ShowCoordinates = true;
            caseLocation.IsDbRequiredAdminLevel1 = true;
            caseLocation.IsDbRequiredAdminLevel2 = true;
            caseLocation.IsDbRequiredAdminLevel3 = false;
            caseLocation.IsDbRequiredApartment = false;
            caseLocation.IsDbRequiredBuilding = false;
            caseLocation.IsDbRequiredHouse = false;
            caseLocation.IsDbRequiredSettlement = false;
            caseLocation.IsDbRequiredSettlementType = false;
            caseLocation.IsDbRequiredStreet = false;
            caseLocation.IsDbRequiredPostalCode = false;
            caseLocation.AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"));
            caseLocation.EnableAdminLevel1 = false;
            caseLocation.EnableAdminLevel2 = false;
            caseLocation.EnableAdminLevel3 = false;
            caseLocation.EnableSettlement = false;
            caseLocation.EnableStreet = false;
            caseLocation.EnableApartment = false;
            caseLocation.EnableBuilding = false;
            caseLocation.EnableHouse = false;
            caseLocation.EnablePostalCode = false;
            caseLocation.EnabledLatitude = false;
            caseLocation.EnabledLongitude = false;
            caseLocation.DivAdminLevel1 = false;
            caseLocation.DivAdminLevel2 = false;
            caseLocation.DivAdminLevel3 = false;
            caseLocation.DivSettlement = false;
            caseLocation.DivStreet = false;
            caseLocation.DivApartment = false;
            caseLocation.DivBuilding = false;
            caseLocation.DivHouse = false;
            caseLocation.DivLatitude = false;
            caseLocation.DivLongitude = false;

            return caseLocation;
        }

        private async Task<DiseaseReportPersonalInformationPageViewModel> LoadPersonInfo()
        {
            DiseaseReportPersonalInformationPageViewModel personalInformationPageViewModel = _diseaseReportComponentViewModel.PersonInfoSection;
            LocationViewModel currentAddress = new()
            {
                CallingObjectID = "currentAddress_",
                IsHorizontalLayout = true,
                ShowAdminLevel0 = false,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = true,
                ShowAdminLevel4 = false,
                ShowAdminLevel5 = false,
                ShowAdminLevel6 = false,
                ShowSettlementType = false,
                ShowSettlement = true,
                ShowStreet = true,
                ShowBuilding = true,
                ShowApartment = true,
                ShowElevation = false,
                ShowHouse = true,
                ShowLatitude = true,
                ShowLongitude = true,
                ShowMap = true,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = true,
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = true,
                IsDbRequiredAdminLevel3 = true,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID")),
                EnableAdminLevel1 = false,
                EnableAdminLevel2 = false,
                EnableAdminLevel3 = false,
                EnableSettlement = false,
                EnableStreet = false,
                EnableApartment = false,
                EnableBuilding = false,
                EnableHouse = false,
                EnablePostalCode = false,
                EnabledLatitude = false,
                EnabledLongitude = false,
                DivAdminLevel1 = false,
                DivAdminLevel2 = false,
                DivAdminLevel3 = false,
                DivSettlement = false,
                DivStreet = false,
                DivApartment = false,
                DivBuilding = false,
                DivHouse = false,
                DivLatitude = false,
                DivLongitude = false
            };

            LocationViewModel workAddress = new()
            {
                CallingObjectID = "workAddress_",
                IsHorizontalLayout = true,
                ShowAdminLevel0 = true,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = true,
                ShowAdminLevel4 = false,
                ShowAdminLevel5 = false,
                ShowAdminLevel6 = false,
                ShowSettlement = true,
                ShowStreet = true,
                ShowBuilding = true,
                ShowApartment = true,
                ShowElevation = false,
                ShowHouse = true,
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = true,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = false,
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = true,
                IsDbRequiredAdminLevel3 = true,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID")),
                EnableAdminLevel0 = false,
                EnableAdminLevel1 = false,
                EnableAdminLevel2 = false,
                EnableAdminLevel3 = false,
                EnableSettlement = false,
                EnableStreet = false,
                EnableApartment = false,
                EnableBuilding = false,
                EnableHouse = false,
                EnablePostalCode = false,
                EnabledLatitude = false,
                EnabledLongitude = false,
                DivAdminLevel0 = false,
                DivAdminLevel1 = false,
                DivAdminLevel2 = false,
                DivAdminLevel3 = false,
                DivSettlement = false,
                DivStreet = false,
                DivApartment = false,
                DivBuilding = false,
                DivHouse = false,
                DivLatitude = false,
                DivLongitude = false
            };

            LocationViewModel schoolAddress = new()
            {
                CallingObjectID = "schoolAddress_",
                IsHorizontalLayout = true,
                ShowAdminLevel0 = true,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = true,
                ShowAdminLevel4 = false,
                ShowAdminLevel5 = false,
                ShowAdminLevel6 = false,
                ShowSettlement = false,
                ShowSettlementType = false,
                ShowStreet = true,
                ShowBuilding = true,
                ShowApartment = true,
                ShowElevation = false,
                ShowHouse = true,
                ShowLatitude = false,
                ShowLongitude = false,
                ShowMap = true,
                ShowBuildingHouseApartmentGroup = true,
                ShowPostalCode = true,
                ShowCoordinates = false,
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = true,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID")),
                EnableAdminLevel0 = false,
                EnableAdminLevel1 = false,
                EnableAdminLevel2 = false,
                EnableAdminLevel3 = false,
                EnableSettlement = false,
                EnableStreet = false,
                EnableApartment = false,
                EnableBuilding = false,
                EnableHouse = false,
                EnablePostalCode = false,
                EnabledLatitude = false,
                EnabledLongitude = false,
                DivAdminLevel0 = false,
                DivAdminLevel1 = false,
                DivAdminLevel2 = false,
                DivAdminLevel3 = false,
                DivSettlement = false,
                DivStreet = false,
                DivApartment = false,
                DivBuilding = false,
                DivHouse = false,
                DivLatitude = false,
                DivLongitude = false
            };
            _diseaseReportComponentViewModel.PersonInfoSection.PersonalIdTypeDD = new Select2Configruation();

            List<DiseaseReportPersonalInformationViewModel> response = new();
            if (_diseaseReportComponentViewModel.HumanID == null || _diseaseReportComponentViewModel.HumanID == 0)
            {
                HumanPersonDetailsRequestModel requestNew = new()
                {
                    LangID = GetCurrentLanguage(),
                    HumanMasterID = _diseaseReportComponentViewModel.HumanActualID
                };
                response = await _humanDiseaseReportClient.GetHumanDiseaseReportPersonInfoAsync(requestNew);
            }
            else
            {
                HumanPersonDetailsFromHumanIDRequestModel requestID = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    HumanID = _diseaseReportComponentViewModel.HumanID
                };
                response = await _humanDiseaseReportClient.GetHumanDiseaseReportFromHumanIDAsync(requestID);
                if (response == null || (response != null && response.Count == 0))
                {
                    HumanPersonDetailsRequestModel requestNew = new()
                    {
                        LangID = GetCurrentLanguage(),
                        HumanMasterID = _diseaseReportComponentViewModel.HumanID
                    };
                    response = await _humanDiseaseReportClient.GetHumanDiseaseReportPersonInfoAsync(requestNew);
                }
            }

            if (response != null && response.Count > 0)
            {
                var personInfo = response.FirstOrDefault();

                currentAddress.AdminLevel1Text = personInfo.HumanRegion;
                currentAddress.AdminLevel1Value = personInfo.HumanidfsRegion;
                currentAddress.AdminLevel2Text = personInfo.HumanRayon;
                currentAddress.AdminLevel2Value = personInfo.HumanidfsRayon;
                currentAddress.AdminLevel3Value = personInfo.HumanidfsSettlement;
                currentAddress.AdminLevel3Text = personInfo.HumanSettlement;
                currentAddress.PostalCodeText = personInfo.HumanstrPostalCode;
                currentAddress.Latitude = personInfo.HumanstrLatitude;
                currentAddress.Longitude = personInfo.HumanstrLongitude;
                currentAddress.StreetText = personInfo.HumanstrStreetName;
                currentAddress.Street = 1;
                currentAddress.House = personInfo.HumanstrHouse;
                currentAddress.Building = personInfo.HumanstrBuilding;
                currentAddress.Apartment = personInfo.HumanstrApartment;

                workAddress.AdminLevel1Text = personInfo.EmployerRegion;
                workAddress.AdminLevel1Value = personInfo.EmployeridfsRegion;
                workAddress.AdminLevel2Text = personInfo.EmployerRayon;
                workAddress.AdminLevel2Value = personInfo.EmployeridfsRayon;
                workAddress.SettlementId = personInfo.EmployeridfsSettlement;
                workAddress.SettlementText = personInfo.EmployerSettlement;
                workAddress.PostalCodeText = personInfo.EmployerstrPostalCode;
                workAddress.StreetText = personInfo.EmployerstrStreetName;
                workAddress.Street = 1;
                workAddress.House = personInfo.EmployerstrHouse;
                workAddress.Building = personInfo.EmployerstrBuilding;
                workAddress.Apartment = personInfo.EmployerstrApartment;

                schoolAddress.AdminLevel1Text = personInfo.SchoolRegion;
                schoolAddress.AdminLevel1Value = personInfo.SchoolidfsRegion;
                schoolAddress.AdminLevel2Text = personInfo.SchoolRayon;
                schoolAddress.AdminLevel2Value = personInfo.SchoolidfsRayon;
                schoolAddress.SettlementId = personInfo.SchoolidfsSettlement;
                schoolAddress.SettlementText = personInfo.SchoolSettlement;
                schoolAddress.PostalCodeText = personInfo.SchoolstrPostalCode;
                schoolAddress.StreetText = personInfo.SchoolstrStreetName;
                schoolAddress.Street = 1;
                schoolAddress.House = personInfo.SchoolstrHouse;
                schoolAddress.Building = personInfo.SchoolstrBuilding;
                schoolAddress.Apartment = personInfo.SchoolstrApartment;
                if (personalInformationPageViewModel != null
                    && personalInformationPageViewModel.PermissionsAccessToPersonalData != null)
                {
                    if (!personalInformationPageViewModel.PermissionsAccessToPersonalData.AccessToPersonalData)
                    {
                        personInfo.PersonalID = "********";
                        personInfo.FirstOrGivenName = "********";
                        personInfo.SecondName = "********";
                        personInfo.LastOrSurname = "********";
                    }
                    if (!personalInformationPageViewModel.PermissionsAccessToPersonalData.AccessToGenderAndAgeData)
                    {
                        personInfo.GenderTypeName = "********";
                        personInfo.GenderTypeID = 0;
                    }
                }

                personalInformationPageViewModel.PersonInfo = personInfo;
            }
            personalInformationPageViewModel.CurrentAddress = currentAddress;
            personalInformationPageViewModel.WorkAddress = workAddress;
            personalInformationPageViewModel.SchoolAddress = schoolAddress;

            return personalInformationPageViewModel;
        }

        private DiseaseReportSymptomsPageViewModel LoadSymptoms(DiseaseReportSymptomsPageViewModel symptomsSection, bool isEdit = false)
        {
            if (!isEdit)
            {
                symptomsSection = new DiseaseReportSymptomsPageViewModel
                {
                    HumanDiseaseSymptoms = new FlexFormQuestionnaireGetRequestModel
                    {
                        idfsFormType = (long?)FlexFormType.HumanDiseaseClinicalSymptoms,
                        idfsDiagnosis = outbreakSessionDetail.idfsDiagnosisOrDiagnosisGroup,
                        idfObservation = null
                    }
                };
            }

            symptomsSection.HumanDiseaseSymptoms.ObserationFieldID = "idfCaseObservationSymptoms";
            symptomsSection.HumanDiseaseSymptoms.LangID = GetCurrentLanguage();
            symptomsSection.HumanDiseaseSymptoms.Title = _localizer.GetString(FieldLabelResourceKeyConstants.CreateHumanCaseListofSymptomsFieldLabel);
            symptomsSection.HumanDiseaseSymptoms.SubmitButtonID = "btnDummy";
            symptomsSection.HumanDiseaseSymptoms.CallbackFunction = "getFlexFormAnswers10034501();";
            symptomsSection.HumanDiseaseSymptoms.CallbackErrorFunction = "SaveHDR();";
            symptomsSection.caseClassficationDD = new Select2Configruation
            {
                ConfigureForPartial = false
            };

            return symptomsSection;
        }

        [HttpPost]
        public async Task<IActionResult> ReloadSymptoms([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString());
            var isEdit = jsonObject["isEdit"] != null && jsonObject["isEdit"].ToString() != string.Empty && Convert.ToBoolean(jsonObject["isEdit"].ToString());
            long? idfHumanCase = jsonObject["idfHumanCase"] != null && jsonObject["idfHumanCase"].ToString() != string.Empty ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            long? diseaseId = jsonObject["diseaseId"] != null && jsonObject["diseaseId"].ToString() != string.Empty ? long.Parse(jsonObject["diseaseId"].ToString()) : null;
            var isReportClosed = jsonObject["isReportClosed"] != null && jsonObject["isReportClosed"].ToString() != string.Empty && Convert.ToBoolean(jsonObject["isReportClosed"].ToString());

            DiseaseReportSymptomsPageViewModel symptomsSection = new()
            {
                caseClassficationDD = new Select2Configruation
                {
                    ConfigureForPartial = true
                },
                IsReportClosed = isReportClosed
            };
            if (isEdit && idfHumanCase != 0 && idfHumanCase != null)
            {
                var detailRequest = new HumanDiseaseReportDetailRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SearchHumanCaseId = Convert.ToInt64(idfHumanCase),
                    SortColumn = "datEnteredDate",
                    SortOrder = "desc"
                };
                detailResponse = await _humanDiseaseReportClient.GetHumanDiseaseDetail(detailRequest);
                if (detailResponse != null)
                {
                    symptomsSection.OutBreakSymptomsOnsetDate = detailResponse.datOnSetDate;
                    symptomsSection.strCaseClassification = detailResponse.InitialCaseStatus;
                    symptomsSection.idfCaseClassfication = detailResponse.idfsInitialCaseStatus;
                    symptomsSection.blnInitialSSD = detailResponse.blnInitialSSD;
                    symptomsSection.blnFinalSSD = detailResponse.blnFinalSSD;
                    if (detailResponse.CaseProgressStatus == VeterinaryDiseaseReportStatusTypes.Closed.ToString())
                    {
                        symptomsSection.IsReportClosed = true;
                    }
                }
            }
            else
            {
                symptomsSection.OutBreakSymptomsOnsetDate = string.IsNullOrEmpty(jsonObject["SymptomsOnsetDate"].ToString()) ? null : DateTime.Parse(jsonObject["SymptomsOnsetDate"].ToString());
                //Case Classification
                symptomsSection.idfCaseClassfication = !string.IsNullOrEmpty(jsonObject["caseClassficationDD"].ToString()) && long.Parse(jsonObject["caseClassficationDD"].ToString()) != 0 ? long.Parse(jsonObject["caseClassficationDD"].ToString()) : null;
                symptomsSection.strCaseClassification = !string.IsNullOrEmpty(jsonObject["strCaseClassification"].ToString()) ? jsonObject["strCaseClassification"].ToString() : null;
            }

            symptomsSection.HumanDiseaseSymptoms = new FlexFormQuestionnaireGetRequestModel
            {
                idfsFormType = (long?)FlexFormType.HumanCaseQuestionnaire,
                idfsDiagnosis = null,
                idfObservation = null,
                ObserationFieldID = "idfCaseObservationSymptoms",
                SubmitButtonID = "btnDummy",
                LangID = GetCurrentLanguage(),
                Title = _localizer.GetString(FieldLabelResourceKeyConstants.CreateHumanCaseListofSymptomsFieldLabel),
                CallbackFunction = "getFlexFormAnswers10034501();",
                CallbackErrorFunction = "SaveHDR();"
            };

            if (isEdit && idfHumanCase != 0 && idfHumanCase != null && detailResponse != null)
                symptomsSection.HumanDiseaseSymptoms.idfObservation = detailResponse.idfCSObservation;
            if (diseaseId != null && diseaseId != 0)
            {
                symptomsSection.HumanDiseaseSymptoms.idfsDiagnosis = diseaseId;
            }

            return PartialView("_DiseaseReportSymptomsPartial", symptomsSection);
        }

        private DiseaseReportNotificationPageViewModel LoadNotification(bool isEdit = false)
        {
            DiseaseReportNotificationPageViewModel notificationSection = _diseaseReportComponentViewModel.NotificationSection;
            _diseaseReportComponentViewModel.NotificationSection.idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase;
            _diseaseReportComponentViewModel.NotificationSection.HumanID = _diseaseReportComponentViewModel.HumanID;
            _diseaseReportComponentViewModel.NotificationSection.HumanActualID = _diseaseReportComponentViewModel.HumanActualID;
            _diseaseReportComponentViewModel.NotificationSection.isEdit = isEdit;
            notificationSection.diseaseDD = new Select2Configruation();
            notificationSection.notificationSentByFacilityDD = new Select2Configruation();
            notificationSection.notificationSentByNameDD = new Select2Configruation();
            notificationSection.notificationReceivedByFacilityDD = new Select2Configruation();
            notificationSection.notificationReceivedByNameDD = new Select2Configruation();
            notificationSection.statusOfPatientAtNotificationDD = new Select2Configruation();
            notificationSection.notificationSentByFacilityDDValidated = new Select2Configruation();
            notificationSection.notificationSentByNameDDValidated = new Select2Configruation();
            notificationSection.hospitalNameDD = new Select2Configruation();
            notificationSection.currentLocationOfPatientDD = new Select2Configruation();
            notificationSection.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            notificationSection.EmployeeDetails = new ViewModels.Administration.EmployeePersonalInfoPageViewModel
            {
                PersonalIdTypeDD = new Select2Configruation(),
                DepartmentDD = new Select2Configruation(),
                eIDSSModalConfiguration = new List<EIDSSModalConfiguration>(),
                EmployeeCategoryList = new List<BaseReferenceViewModel>(),
                OrganizationDD = new Select2Configruation(),
                PositionDD = new Select2Configruation(),
                SiteDD = new Select2Configruation()
            };
            UserPermissions employeeuserPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);
            notificationSection.EmployeeDetails.CanManageReferencesandConfiguratuionsPermission = employeeuserPermissions;
            UserPermissions userAccountsuserPermissions = GetUserPermissions(PagePermission.CanManageUserAccounts);
            notificationSection.EmployeeDetails.UserPermissions = userAccountsuserPermissions;
            var CanAccessOrganizationsList = GetUserPermissions(PagePermission.CanAccessOrganizationsList);
            notificationSection.EmployeeDetails.CanAccessOrganizationsList = CanAccessOrganizationsList;

            if (isEdit && detailResponse != null)
            {
                notificationSection.dateOfCompletion = detailResponse.datCompletionPaperFormDate;

                notificationSection.localIdentifier = detailResponse.strLocalIdentifier;

                notificationSection.idfDisease = detailResponse.idfsFinalDiagnosis;
                notificationSection.strDisease = detailResponse.strFinalDiagnosis;

                notificationSection.dateOfDiagnosis = detailResponse.DateOfDiagnosis;

                notificationSection.dateOfNotification = detailResponse.datNotificationDate;

                notificationSection.idfNotificationSentByFacility = detailResponse.idfSentByOffice;
                notificationSection.strNotificationSentByFacility = detailResponse.SentByOffice;
                notificationSection.idfNotificationSentByName = detailResponse.idfSentByPerson;
                notificationSection.strNotificationSentByName = detailResponse.SentByPerson;

                notificationSection.idfNotificationReceivedByFacility = detailResponse.idfReceivedByOffice;
                notificationSection.strNotificationReceivedByFacility = detailResponse.ReceivedByOffice;
                notificationSection.idfNotificationReceivedByName = detailResponse.idfReceivedByPerson;
                notificationSection.strNotificationReceivedByName = detailResponse.ReceivedByPerson;

                notificationSection.idfStatusOfPatient = detailResponse.idfsFinalState;
                notificationSection.strStatusOfPatient = detailResponse.PatientStatus;

                notificationSection.idfHospitalName = detailResponse.idfHospital;
                notificationSection.strHospitalName = detailResponse.HospitalName;

                notificationSection.idfCurrentLocationOfPatient = detailResponse.idfsHospitalizationStatus;
                notificationSection.strCurrentLocationOfPatient = detailResponse.HospitalizationStatus;

                notificationSection.strOtherLocation = detailResponse.strCurrentLocation;

                if (detailResponse.CaseProgressStatus == VeterinaryDiseaseReportStatusTypes.Closed.ToString())
                {
                    notificationSection.IsReportClosed = true;
                }
            }
            return notificationSection;
        }

        public async Task<DiseaseReportFacilityDetailsPageViewModel> LoadFacilityDetails(bool isEdit = false)
        {
            DiseaseReportFacilityDetailsPageViewModel facilityDetailsSection = new()
            {
                DiagnosisSelect = new(),
                FacilitySelect = new(),
                IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed
            };

            //get the yes/no choices for radio buttons
            var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.YesNoValueList, HACodeList.HumanHACode);
            facilityDetailsSection.YesNoChoices = list;

            //set some defaults
            facilityDetailsSection.PatientPreviouslySoughtCare = Convert.ToInt64(YesNoUnknown.No);
            facilityDetailsSection.Hospitalized = Convert.ToInt64(YesNoUnknown.No);

            //get the dates from other sections used for comparison
            //populate the model for edit
            if (detailResponse != null && isEdit)
            {
                //sought care?
                facilityDetailsSection.PatientPreviouslySoughtCare = detailResponse.idfsYNPreviouslySoughtCare;
                facilityDetailsSection.SoughtCareFacilityID = detailResponse.idfSoughtCareFacility;
                facilityDetailsSection.SoughtCareFacilityText = detailResponse.strSoughtCareFacility;
                facilityDetailsSection.FacilitySelect.defaultSelect2Selection = new Select2DataItem() { id = detailResponse.idfSoughtCareFacility.ToString(), text = detailResponse.strSoughtCareFacility };
                facilityDetailsSection.SoughtCareFirstDate = detailResponse.datFirstSoughtCareDate;
                facilityDetailsSection.NonNotifiableDiseaseID = detailResponse.idfsNonNotifiableDiagnosis;
                facilityDetailsSection.NonNotifiableDiseaseText = detailResponse.stridfsNonNotifiableDiagnosis;
                facilityDetailsSection.DiagnosisSelect.defaultSelect2Selection = new Select2DataItem() { id = detailResponse.idfsNonNotifiableDiagnosis.ToString(), text = detailResponse.stridfsNonNotifiableDiagnosis };

                //hospitalized?
                facilityDetailsSection.Hospitalized = detailResponse.idfsYNHospitalization;
                facilityDetailsSection.HospitalizationPlace = detailResponse.strHospitalizationPlace;
                facilityDetailsSection.OutbreakHospitalizationDate = detailResponse.datHospitalizationDate;
                facilityDetailsSection.IsOutbreak = true;
                facilityDetailsSection.DateOfDischarge = detailResponse.datDischargeDate;
            }
            return facilityDetailsSection;
        }

        public async Task<DiseaseReportAntibioticVaccineHistoryPageViewModel> LoadAntibioticVaccineHistoryDetails(bool isEdit = false)
        {
            DiseaseReportAntibioticVaccineHistoryPageViewModel antibioticVaccineHistoryDetailsSection = new()
            {
                IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed,
                antibioticsHistory = new List<DiseaseReportAntiviralTherapiesViewModel>(),
                vaccinationHistory = new List<DiseaseReportVaccinationViewModel>()
            };

            if (isEdit && detailResponse != null)
            {
                antibioticVaccineHistoryDetailsSection.idfsYNAntimicrobialTherapy = detailResponse.idfsYNAntimicrobialTherapy;
                antibioticVaccineHistoryDetailsSection.idfsYNSpecificVaccinationAdministered = detailResponse.idfsYNSpecificVaccinationAdministered;
                HumanAntiviralTherapiesAndVaccinationRequestModel request = new()
                {
                    idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase,
                    LangID = GetCurrentLanguage()
                };

                var antiViralTherapiesReponse = await _humanDiseaseReportClient.GetAntiviralTherapisListAsync(request);
                var vaccinationResponse = await _humanDiseaseReportClient.GetVaccinationListAsync(request);

                antibioticVaccineHistoryDetailsSection.antibioticsHistory = antiViralTherapiesReponse;
                antibioticVaccineHistoryDetailsSection.vaccinationHistory = vaccinationResponse;
                antibioticVaccineHistoryDetailsSection.AdditionalInforMation = detailResponse.strClinicalNotes;
            }

            return antibioticVaccineHistoryDetailsSection;
        }

        private DiseaseReportCaseInvestigationPageViewModel LoadCaseInvestigationDetails(bool isEdit = false)
        {
            DiseaseReportCaseInvestigationPageViewModel caseInvestigationPageViewModelSection = _diseaseReportComponentViewModel.CaseInvestigationSection;
            caseInvestigationPageViewModelSection.InvestigatedByOfficeDD = new Select2Configruation();
            caseInvestigationPageViewModelSection.OutbreakInvestigationSentByNameDD = new Select2Configruation();
            caseInvestigationPageViewModelSection.OutbreakCaseClassificationByNameDD = new Select2Configruation();
            caseInvestigationPageViewModelSection.YNExposureLocationKnownRD = GetRadioButtonChoicesAsync();
            caseInvestigationPageViewModelSection.ExposureLocationRD = GetExposureLocation();
            caseInvestigationPageViewModelSection.GroundTypeDD = new Select2Configruation();
            caseInvestigationPageViewModelSection.ForeignCountryDD = new Select2Configruation();

            LocationViewModel exposureLocationAddress = new()
            {
                CallingObjectID = "CaseInvestigationSection_",
                IsHorizontalLayout = true,
                ShowAdminLevel0 = false,
                ShowAdminLevel1 = true,
                ShowAdminLevel2 = true,
                ShowAdminLevel3 = true,
                ShowAdminLevel4 = false,
                ShowAdminLevel5 = false,
                ShowAdminLevel6 = false,
                ShowSettlementType = true,
                ShowSettlement = false,
                ShowStreet = false,
                ShowBuilding = false,
                ShowApartment = false,
                ShowElevation = true,
                ShowHouse = false,
                ShowLatitude = true,
                ShowLongitude = true,
                ShowMap = true,
                ShowBuildingHouseApartmentGroup = false,
                ShowPostalCode = false,
                ShowCoordinates = true,
                IsDbRequiredAdminLevel1 = true,
                IsDbRequiredAdminLevel2 = true,
                IsDbRequiredAdminLevel3 = true,
                IsDbRequiredApartment = false,
                IsDbRequiredBuilding = false,
                IsDbRequiredHouse = false,
                IsDbRequiredSettlement = false,
                IsDbRequiredSettlementType = false,
                IsDbRequiredStreet = false,
                IsDbRequiredPostalCode = false,
                AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID")),
                EnableAdminLevel1 = true,
                EnableAdminLevel2 = true,
                EnableAdminLevel3 = true,
                EnableSettlement = true,
                EnableStreet = false,
                EnableApartment = false,
                EnableBuilding = false,
                EnableHouse = false,
                EnablePostalCode = false,
                EnabledLatitude = true,
                EnabledLongitude = true,
                DivAdminLevel1 = true,
                DivAdminLevel2 = true,
                DivAdminLevel3 = true,
            };

            caseInvestigationPageViewModelSection.ExposureLocationAddress = exposureLocationAddress;
            caseInvestigationPageViewModelSection.CurrentDate = DateTime.Today;

            if (isEdit && detailResponse != null)
            {
                var detailRecord = detailResponse;
                caseInvestigationPageViewModelSection.idfInvestigatedByOffice = detailRecord.idfInvestigatedByOffice;
                caseInvestigationPageViewModelSection.InvestigatedByOffice = detailRecord.InvestigatedByOffice;
                caseInvestigationPageViewModelSection.StartDateofInvestigation = detailRecord.StartDateofInvestigation;
                caseInvestigationPageViewModelSection.strOutbreakID = detailRecord.strOutbreakID;
                caseInvestigationPageViewModelSection.idfOutbreak = detailRecord.idfOutbreak;
                caseInvestigationPageViewModelSection.comments = detailRecord.strNote;

                caseInvestigationPageViewModelSection.YNExposureLocationKnown = detailRecord.YNExposureLocationKnown;
                caseInvestigationPageViewModelSection.ExposureDate = detailRecord.datExposureDate;
                caseInvestigationPageViewModelSection.ExposureLocationType = detailRecord.ExposureLocationType;
                caseInvestigationPageViewModelSection.idfsYNExposureLocationKnown = detailRecord.idfsYNExposureLocationKnown;

                caseInvestigationPageViewModelSection.idfPointGeoLocation = detailRecord.idfPointGeoLocation;
                caseInvestigationPageViewModelSection.idfsPointGeoLocationType = detailRecord.idfsPointGeoLocationType;

                caseInvestigationPageViewModelSection.idfsPointCountry = detailRecord.idfsPointCountry;
                caseInvestigationPageViewModelSection.Country = detailRecord.Country;

                caseInvestigationPageViewModelSection.idfsPointGroundType = detailRecord.idfsPointGroundType;
                //strground type not avaialble
                caseInvestigationPageViewModelSection.strGroundType = detailRecord.strGroundType;

                caseInvestigationPageViewModelSection.idfsPointRegion = detailRecord.idfsPointRegion;
                caseInvestigationPageViewModelSection.idfsPointRayon = detailRecord.idfsPointRayon;
                caseInvestigationPageViewModelSection.idfsPointSettlement = detailRecord.idfsPointSettlement;
                caseInvestigationPageViewModelSection.Region = detailRecord.Region;
                caseInvestigationPageViewModelSection.Rayon = detailRecord.Rayon;
                caseInvestigationPageViewModelSection.Settlement = detailRecord.Settlement;

                caseInvestigationPageViewModelSection.dblPointLatitude = detailRecord.dblPointLatitude;
                caseInvestigationPageViewModelSection.dblPointLongitude = detailRecord.dblPointLongitude;
                caseInvestigationPageViewModelSection.dblPointElevation = detailRecord.dblPointElevation;
                caseInvestigationPageViewModelSection.dblPointDistance = detailRecord.dblPointDistance;

                caseInvestigationPageViewModelSection.strPointForeignAddress = detailRecord.strPointForeignAddress;
                exposureLocationAddress.AdminLevel1Text = detailRecord.Region;
                exposureLocationAddress.AdminLevel1Value = detailRecord.idfsPointRegion;
                exposureLocationAddress.AdminLevel2Text = detailRecord.Rayon;
                exposureLocationAddress.AdminLevel2Value = detailRecord.idfsPointRayon;
                exposureLocationAddress.AdminLevel3Text = detailRecord.Settlement;
                exposureLocationAddress.AdminLevel3Value = detailRecord.idfsPointSettlement;
                exposureLocationAddress.Latitude = detailRecord.dblPointLatitude;
                exposureLocationAddress.Longitude = detailRecord.dblPointLongitude;
                exposureLocationAddress.Elevation = detailRecord.dblPointElevation != null ? Convert.ToInt32(detailRecord.dblPointElevation) : null;

                caseInvestigationPageViewModelSection.ExposureLocationAddress = exposureLocationAddress;
                //Direction not available
                caseInvestigationPageViewModelSection.dblPointDirection = detailRecord.dblPointAlignment;

                if (detailRecord.CaseProgressStatus == VeterinaryDiseaseReportStatusTypes.Closed.ToString())
                {
                    caseInvestigationPageViewModelSection.IsReportClosed = true;
                }
            }

            return caseInvestigationPageViewModelSection;
        }

        public async Task<DiseaseReportSamplePageViewModel> LoadSampleDetails(long? diseaseId, bool isEdit = false)
        {
            DiseaseReportSamplePageViewModel diseaseReportSamplePageViewModelSection = new()
            {
                idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase,
                strCaseId = _diseaseReportComponentViewModel.strCaseId,
                YesNoChoices = new(),
                idfDisease = diseaseId,
                AddSampleModel = new DiseaseReportSamplePageSampleDetailViewModel
                {
                    idfDisease = diseaseId
                },
                SamplesDetails = new(),
                IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed,
                Permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportClinicalInformation)
            };

            if (isEdit && detailResponse != null)
            {
                diseaseReportSamplePageViewModelSection.AddSampleModel.SymptomsOnsetDate = detailResponse.datOnSetDate;
                diseaseReportSamplePageViewModelSection.SamplesCollectedYN = detailResponse.idfsYNSpecimenCollected;
                diseaseReportSamplePageViewModelSection.SamplesDetails = new();

                var request = new HumanDiseaseReportSamplesRequestModel()
                {
                    idfHumanCase = detailResponse.idfHumanCase,
                    LangID = GetCurrentLanguage()
                };
                var list = await _humanDiseaseReportClient.GetHumanDiseaseReportSamplesListAsync(request);
                List<DiseaseReportSamplePageSampleDetailViewModel> samplesDetailList = new();
                int i = 0;
                foreach (var item in list)
                {
                    //map the incoming human samples list to the generic list so we can reuse samples component
                    samplesDetailList.Add(new DiseaseReportSamplePageSampleDetailViewModel()
                    {
                        RowID = i + 1,
                        AccessionDate = item.datAccession,
                        idfMaterial = item.idfMaterial,
                        AdditionalTestNotes = item.strNote,
                        CollectedByOfficer = item.strFieldCollectedByPerson,
                        CollectedByOfficerID = item.idfFieldCollectedByPerson,
                        CollectedByOrganization = item.strFieldCollectedByOffice,
                        CollectedByOrganizationID = item.idfFieldCollectedByOffice,
                        CollectionDate = item.datFieldCollectionDate,
                        strBarcode = item.strBarcode,
                        LocalSampleId = item.strFieldBarcode,
                        SampleConditionRecieved = item.strCondition,
                        SampleKey = item.idfMaterial.GetValueOrDefault(),
                        SampleType = item.strSampleTypeName,
                        SampleTypeID = item.idfsSampleType,
                        SentDate = item.datFieldSentDate,
                        SentToOrganization = item.strSendToOffice,
                        SentToOrganizationID = item.idfSendToOffice,
                        SymptomsOnsetDate = detailResponse.datOnSetDate,
                        blnAccessioned = item.blnAccessioned,
                        sampleGuid = item.sampleGuid,
                        idfsSiteSentToOrg = item.idfsSite,
                        SampleStatus = item.SampleStatusTypeName,
                        LabSampleID = item.strBarcode,
                        FunctionalAreaName = item.FunctionalAreaName,
                        FunctionalAreaID = item.FunctionalAreaID,
                        strNote = item.strNote
                    });
                }
                diseaseReportSamplePageViewModelSection.SamplesDetails = samplesDetailList;
                diseaseReportSamplePageViewModelSection.ActiveSamplesDetails = samplesDetailList;
            }

            return diseaseReportSamplePageViewModelSection;
        }

        public async Task<DiseaseReportTestPageViewModel> LoadTestsDetails(long? diseaseId, bool isEdit = false)
        {
            DiseaseReportTestPageViewModel diseaseReportTestsPageViewModelSection = _diseaseReportComponentViewModel.TestsSection;
            diseaseReportTestsPageViewModelSection.idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase;
            diseaseReportTestsPageViewModelSection.strCaseId = _diseaseReportComponentViewModel.strCaseId;
            diseaseReportTestsPageViewModelSection.YesNoChoices = new();
            diseaseReportTestsPageViewModelSection.idfDisease = diseaseId;
            diseaseReportTestsPageViewModelSection.AddTestModel = new DiseaseReportTestPageTestDetailViewModel();
            diseaseReportTestsPageViewModelSection.TestDetails = new();
            diseaseReportTestsPageViewModelSection.SamplesDetails = new();
            diseaseReportTestsPageViewModelSection.IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed;
            if (_diseaseReportComponentViewModel.SamplesSection != null && _diseaseReportComponentViewModel.SamplesSection.SamplesDetails != null)
                diseaseReportTestsPageViewModelSection.SamplesDetails = _diseaseReportComponentViewModel.SamplesSection.SamplesDetails;

            diseaseReportTestsPageViewModelSection.Permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportClinicalInformation);

            if (isEdit && detailResponse != null)
            {
                diseaseReportTestsPageViewModelSection.TestsConducted = detailResponse.idfsYNTestsConducted;
                diseaseReportTestsPageViewModelSection.TestDetails = new();
                var request = new HumanTestListRequestModel()
                {
                    idfHumanCase = detailResponse.idfHumanCase,
                    LangID = GetCurrentLanguage(),
                    SearchDiagnosis = null
                };
                var list = await _humanDiseaseReportClient.GetHumanDiseaseReportTestListAsync(request);
                diseaseReportTestsPageViewModelSection.TestDetails = list;
                if (list.Count > 0)
                    diseaseReportTestsPageViewModelSection.TestsConducted = (long)YesNoUnknown.Yes;
                else
                    diseaseReportTestsPageViewModelSection.TestsConducted = (long)YesNoUnknown.No;

                var samplerequest = new HumanDiseaseReportSamplesRequestModel()
                {
                    idfHumanCase = detailResponse.idfHumanCase,
                    LangID = GetCurrentLanguage()
                };

                var sampleList = await _humanDiseaseReportClient.GetHumanDiseaseReportSamplesListAsync(samplerequest);
                List<DiseaseReportSamplePageSampleDetailViewModel> samplesDetailList = new();
                int i = 0;
                foreach (var item in sampleList)
                {
                    //map the incoming human samples list to the generic list so we can reuse samples component
                    samplesDetailList.Add(new DiseaseReportSamplePageSampleDetailViewModel()
                    {
                        RowID = i + 1,
                        AccessionDate = item.datAccession,
                        AdditionalTestNotes = item.strNote,
                        CollectedByOfficer = item.strFieldCollectedByPerson,
                        CollectedByOfficerID = item.idfFieldCollectedByPerson,
                        CollectedByOrganization = item.strFieldCollectedByOffice,
                        CollectedByOrganizationID = item.idfFieldCollectedByOffice,
                        CollectionDate = item.datFieldCollectionDate,
                        strBarcode = item.strBarcode,
                        LocalSampleId = item.strFieldBarcode,
                        SampleConditionRecieved = item.strCondition,
                        SampleKey = item.idfMaterial.GetValueOrDefault(),
                        SampleType = item.strSampleTypeName,
                        SampleTypeID = item.idfsSampleType,
                        SentDate = item.datFieldSentDate,
                        SentToOrganization = item.strSendToOffice,
                        SentToOrganizationID = item.idfSendToOffice,
                        SymptomsOnsetDate = detailResponse.datOnSetDate,
                        blnAccessioned = item.blnAccessioned,
                        intRowStatus = item.intRowStatus,
                        SampleStatus = item.SampleStatusTypeName,
                        LabSampleID = item.strBarcode,
                        FunctionalAreaName = item.FunctionalAreaName,
                        FunctionalAreaID = item.FunctionalAreaID,
                        strNote = item.strNote
                    });
                }
                diseaseReportTestsPageViewModelSection.SamplesDetails = samplesDetailList;
            }

            return diseaseReportTestsPageViewModelSection;
        }

        private DiseaseReportCaseInvestigationRiskFactorsPageViewModel LoadCaseInvestigationRiskFactors(bool isEdit = false, long? idfsFormTemplate = null, long? idfObservation = null)
        {
            var riskFactorsSection = new DiseaseReportCaseInvestigationRiskFactorsPageViewModel();
            if (idfsFormTemplate != null)
            {
                riskFactorsSection.RiskFactors = new FlexFormQuestionnaireGetRequestModel
                {
                    idfsFormType = (long?)FlexFormType.HumanCaseQuestionnaire,
                    idfsFormTemplate = idfsFormTemplate,
                    idfObservation = isEdit ? idfObservation : null,
                    SubmitButtonID = "btnDummy",
                    LangID = GetCurrentLanguage(),
                    Title = _localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportRiskFactorsListofRiskFactorsHeading),
                    CallbackFunction = "SaveHDR();",
                    ObserationFieldID = "idfCaseObservationRiskFactors"
                };
            }

            return riskFactorsSection;
        }

        public IActionResult ReloadRiskFactors()
        {
            DiseaseReportCaseInvestigationRiskFactorsPageViewModel riskFactorsSection = new()
            {
                IsReportClosed = IsbSessionClosed,
                RiskFactors = new FlexFormQuestionnaireGetRequestModel
                {
                    idfsFormType = (long?)FlexFormType.HumanCaseQuestionnaire,
                    idfsFormTemplate = CaseQuestionnaireTemplateID,
                    idfObservation = IsEdit ? CaseEPIObservationID : null,
                    SubmitButtonID = "btnDummy",
                    LangID = GetCurrentLanguage(),
                    Title = _localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportRiskFactorsListofRiskFactorsHeading),
                    CallbackFunction = "SaveHDR();",
                    ObserationFieldID = "idfCaseObservationRiskFactors"
                }
            };

            return PartialView("_DiseaseReportRiskFactorsPartial", riskFactorsSection);
        }

        private async Task<DiseaseReportContactListPageViewModel> LoadContactList(bool isEdit = false)
        {
            DiseaseReportContactListPageViewModel contactListSection = _diseaseReportComponentViewModel.ContactListSection;
            contactListSection.ContactDetails = new List<DiseaseReportContactDetailsViewModel>();
            contactListSection.IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed;
            contactListSection.HumanActualID = _diseaseReportComponentViewModel.HumanActualID;
            if (isEdit)
            {
                contactListSection.idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase;
                contactListSection.HumanID = _diseaseReportComponentViewModel.HumanID;
                HumanDiseaseContactListRequestModel request = new()
                {
                    idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase,
                    LangId = GetCurrentLanguage()
                };
                var response = await _humanDiseaseReportClient.GetHumanDiseaseContactListAsync(request);
                if (response != null)
                {
                    contactListSection.ContactDetails = response;
                    if (response.Count > 0)
                    {
                        foreach (var item in response)
                        {
                            if (item.blnForeignAddress == null || item.blnForeignAddress == false)
                            {
                                if (!string.IsNullOrEmpty(item.strPostCode))
                                {
                                    item.strPatientAddressString = item.strPostCode;
                                }
                                if (!string.IsNullOrEmpty(item.strStreetName))
                                {
                                    item.strPatientAddressString += "," + item.strStreetName;
                                }
                                if (!string.IsNullOrEmpty(item.strHouse))
                                {
                                    item.strPatientAddressString += "," + item.strHouse;
                                }
                                if (!string.IsNullOrEmpty(item.strBuilding))
                                {
                                    item.strPatientAddressString += "," + item.strBuilding;
                                }
                                if (!string.IsNullOrEmpty(item.strApartment))
                                {
                                    item.strPatientAddressString += "," + item.strApartment;
                                }
                                if (!string.IsNullOrEmpty(item.strContactPhone))
                                {
                                    item.strPatientAddressString += "," + item.strContactPhone;
                                }
                                if (!string.IsNullOrEmpty(item.strPatientAddressString))
                                {
                                    item.strPatientAddressString = item.strPatientAddressString.TrimStart(',');
                                    item.strPatientAddressString = item.strPatientAddressString.TrimEnd(',');
                                }
                            }
                        }
                    }
                }
            }
            return contactListSection;
        }

        private List<BaseReferenceViewModel> GetRadioButtonChoicesAsync()
        {
            //get the yes/no choices for radio buttons
            List<BaseReferenceViewModel> YesNoChoices = _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.YesNoValueList, HACodeList.HumanHACode).Result;
            return YesNoChoices;
        }

        private List<BaseReferenceViewModel> GetExposureLocation()
        {
            //get the yes/no choices for radio buttons
            List<BaseReferenceViewModel> GeoLocationList = _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.GeoLocationType, HACodeList.HumanHACode).Result;
            return GeoLocationList;
        }

        private DiseaseReportFinalOutcomeViewModel LoadFinalOutComeDetails(long? diseaseId, bool isEdit = false)
        {
            DiseaseReportFinalOutcomeViewModel diseaseReportFinalOutcomeViewModelSection = new()
            {
                idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase,
                strCaseId = _diseaseReportComponentViewModel.strCaseId,

                idfDisease = diseaseId,
                Permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportClinicalInformation),

                IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed,
                idfInvestigatedByOffice = _diseaseReportComponentViewModel.CaseInvestigationSection.idfInvestigatedByOffice
            };

            if (isEdit && detailResponse != null)
            {
                diseaseReportFinalOutcomeViewModelSection.blnInitialSSD = detailResponse.blnInitialSSD;
                diseaseReportFinalOutcomeViewModelSection.blnFinalSSD = detailResponse.blnFinalSSD;
                diseaseReportFinalOutcomeViewModelSection.idfsFinalCaseStatus = detailResponse.idfsFinalCaseStatus;
                diseaseReportFinalOutcomeViewModelSection.idfsOutCome = detailResponse.idfsOutCome;
                diseaseReportFinalOutcomeViewModelSection.idfInvestigatedByPerson = detailResponse.idfInvestigatedByPerson;
                diseaseReportFinalOutcomeViewModelSection.strEpidemiologistsName = detailResponse.strEpidemiologistsName;
                diseaseReportFinalOutcomeViewModelSection.blnLabDiagBasis = detailResponse.blnLabDiagBasis;
                diseaseReportFinalOutcomeViewModelSection.blnClinicalDiagBasis = detailResponse.blnClinicalDiagBasis;
                diseaseReportFinalOutcomeViewModelSection.blnEpiDiagBasis = detailResponse.blnEpiDiagBasis;
                diseaseReportFinalOutcomeViewModelSection.datFinalCaseClassificationDate = detailResponse.datFinalCaseClassificationDate;
                diseaseReportFinalOutcomeViewModelSection.datDateOfDeath = detailResponse.datDateOfDeath;
                diseaseReportFinalOutcomeViewModelSection.datDateOfDischarge = detailResponse.datDischargeDate;
                diseaseReportFinalOutcomeViewModelSection.Comments = detailResponse.strSummaryNotes;
            }

            return diseaseReportFinalOutcomeViewModelSection;
        }

        public async Task<IActionResult> SelectForEdit(long? id)
        {
            var request = new HumanDiseaseReportDetailRequestModel()
            {
                LanguageId = GetCurrentLanguage(),
                Page = 1,
                PageSize = 10,
                SearchHumanCaseId = id.Value,
                SortColumn = "datEnteredDate",
                SortOrder = "desc"
            };
            var response = await _humanDiseaseReportClient.GetHumanDiseaseDetail(request);
            if (response != null)
            {
                var humanId = response.idfHuman;
                var caseId = response.idfHumanCase;

                return RedirectToAction("LoadDiseaseReport", new { humanId, caseId, isEdit = true, readOnly = false });
            }

            return View("Index");
        }

        [HttpPost()]
        [Route("SaveHumanCase")]
        public async Task<IActionResult> SaveHumanCase([FromBody] JsonElement data)
        {
            try
            {
                OutbreakCaseCreateRequestModel request = new();
                OutbreakCaseSaveResponseModel response = new();

                request.LangID = GetCurrentLanguage();
                request.intRowStatus = 0;
                request.User = _authenticatedUser.UserName;

                request.OutbreakCaseReportUID = (long?)GetJsonValue(data, "OutbreakCaseReportUID", DataType.Long);
                request.idfOutbreak = (long?)GetJsonValue(data, "idfOutbreak", DataType.Long);
                request.idfHumanCase = (long?)GetJsonValue(data, "idfHumanCase", DataType.Long);

                request.idfHumanActual = (long?)GetJsonValue(data, "idfHumanActual", DataType.Long);
                request.idfsDiagnosisOrDiagnosisGroup =
                    (long?)GetJsonValue(data, "idfsDiagnosisOrDiagnosisGroup", DataType.Long);

                request.datNotificationDate = (DateTime?)GetJsonValue(data, "datNotificationDate", DataType.DateTime);
                request.idfSentByOffice = (long?)GetJsonValue(data, "notificationSentByFacilityDD", DataType.Long);
                request.idfSentByPerson = (long?)GetJsonValue(data, "notificationSentByNameDD", DataType.Long);
                request.idfReceivedByOffice =
                    (long?)GetJsonValue(data, "notificationReceivedByFacilityDD", DataType.Long);
                request.idfReceivedByPerson = (long?)GetJsonValue(data, "notificationReceivedByNameDD", DataType.Long);

                LocationViewModel location = new()
                {
                    AdminLevel0Value = long.Parse(CountryId),
                    AdminLevel1Value = (long?)GetJsonValue(data, "AdminLevel1Value", DataType.Long),
                    AdminLevel2Value = (long?)GetJsonValue(data, "AdminLevel2Value", DataType.Long),
                    AdminLevel3Value = (long?)GetJsonValue(data, "AdminLevel3Value", DataType.Long),
                    AdminLevel4Value = (long?)GetJsonValue(data, "AdminLevel4Value", DataType.Long),
                    AdminLevel5Value = (long?)GetJsonValue(data, "AdminLevel5Value", DataType.Long),
                    AdminLevel6Value = (long?)GetJsonValue(data, "AdminLevel6Value", DataType.Long)
                };

                request.CaseGeoLocationID = (long?)GetJsonValue(data, "idfGeoLocation", DataType.Long);
                request.CaseidfsLocation = Common.GetLocationId(location);
                request.CasestrStreetName = GetJsonValue(data, "Street", DataType.String).ToString();
                request.CasestrApartment = GetJsonValue(data, "Apartment", DataType.String).ToString();
                request.CasestrBuilding = GetJsonValue(data, "Building", DataType.String).ToString();
                request.CasestrHouse = GetJsonValue(data, "House", DataType.String).ToString();
                request.CaseidfsPostalCode = GetJsonValue(data, "PostalCode", DataType.String).ToString();
                request.CasestrLatitude = (double?)GetJsonValue(data, "intLocationLatitude", DataType.Double);
                request.CasestrLongitude = (double?)GetJsonValue(data, "intLocationLongitude", DataType.Double);

                var jsonObject = JObject.Parse(data.ToString());

                request.CaseStatusID = (long?)GetJsonValue(data, "CaseStatusID", DataType.Long);
                request.datOnSetDate = (DateTime?)GetJsonValue(data, "SymptomsOnsetDate", DataType.DateTime);
                request.datFinalDiagnosisDate =
                    (DateTime?)GetJsonValue(data, "datFinalDiagnosisDate", DataType.DateTime);
                request.strHospitalName = jsonObject["strHospitalName"] != null ? jsonObject["strHospitalName"].ToString() : "";
                request.datHospitalizationDate =
                (DateTime?)GetJsonValue(data, "datOutbreakHospitalizationDate", DataType.DateTime);
                request.datDischargeDate = (DateTime?)GetJsonValue(data, "datDischargeDate", DataType.DateTime);
                request.Antimicrobials = JsonConvert.SerializeObject(
                    JObject.Parse(jsonObject["vaccionationAntiViralTherapies"].ToString())["antibioticsHistory"]);
                request.vaccinations = JsonConvert.SerializeObject(
                    JObject.Parse(jsonObject["vaccionationAntiViralTherapies"].ToString())["vaccinationHistory"]);
                request.strClinicalNotes = GetJsonValue(data, "additionalInforMation", DataType.String).ToString();
                request.idfsYNHospitalization = (long?)GetJsonValue(data, "idfsYNHospitalization", DataType.Long);
                request.idfsYNAntimicrobialTherapy =
                    (long?)GetJsonValue(data, "idfsYNAntimicrobialTherapy", DataType.Long);
                request.idfsYNSpecIFicVaccinationAdministered =
                    (long?)GetJsonValue(data, "idfsYNSpecificVaccinationAdministered", DataType.Long);
                request.idfCSObservation = (long?)GetJsonValue(data, "idfCSObservation", DataType.Long);

                request.idfInvestigatedByOffice = (long?)GetJsonValue(data, "idfInvestigatedByOffice", DataType.Long);
                request.idfInvestigatedByPerson = (long?)GetJsonValue(data, "idfInvestigatedByPerson", DataType.Long);
                request.StartDateofInvestigation =
                    (DateTime?)GetJsonValue(data, "datInvestigationStartDate", DataType.DateTime);
                request.OutbreakCaseClassificationID =
                    (long?)GetJsonValue(data, "OutbreakCaseClassificationID", DataType.Long);
                request.IsPrimaryCaseFlag =
                    GetJsonValue(data, "isPrimaryCaseFlag", DataType.String).ToString() == "True" ? "t" : "f";
                request.strNote = GetJsonValue(data, "strNote", DataType.String).ToString();
                request.OutbreakCaseObservationID = (long?)GetJsonValue(data, "idfEpiObservation", DataType.Long);

                if (jsonObject["caseMonitoringsModel"] != null && !string.IsNullOrEmpty(jsonObject["caseMonitoringsModel"].ToString()))
                {
                    var caseMonitoringsModel = jsonObject["caseMonitoringsModel"].ToString();
                    List<CaseMonitoringSaveRequestModel> caseMonitorings = new();
                    CaseMonitoringSaveRequestModel caseMonitoring = new();

                    foreach (JObject item in JArray.Parse(caseMonitoringsModel))
                    {
                        caseMonitoring = new CaseMonitoringSaveRequestModel
                        {
                            CaseMonitoringID = (long)GetJsonValue(item, "caseMonitoringId", DataType.Long),
                            ObservationID = (long?)GetJsonValue(item, "observationId", DataType.Long),
                            InvestigatedByOrganizationID =
                            (long?)GetJsonValue(item, "investigatedByOrganizationId", DataType.Long),
                            InvestigatedByPersonID =
                            (long?)GetJsonValue(item, "investigatedByPersonId", DataType.Long),
                            MonitoringDate =
                            (DateTime?)GetJsonValue(item, "monitoringDate", DataType.DateTime),
                            RowStatus =
                            (int)GetJsonValue(item, "rowStatus", DataType.Int),
                            RowAction =
                            (int)GetJsonValue(item, "rowAction", DataType.Int),
                            AdditionalComments = GetJsonValue(item, "additionalComments", DataType.String).ToString()
                        };

                        caseMonitorings.Add(caseMonitoring);
                    }

                    request.CaseMonitorings = JsonConvert.SerializeObject(caseMonitorings);
                    request.Events = null;
                }

                if (jsonObject["contactsModel"] != null)
                {
                    var contactModel = jsonObject["contactsModel"].ToString();

                    if (!string.IsNullOrEmpty(contactModel))
                    {
                        var parsedContactModel = JArray.Parse(contactModel);

                        if (parsedContactModel != null)
                        {
                            var contactList = new List<ContactGetListViewModel>();
                            var contactItem = new ContactGetListViewModel();

                            var serContactModel = JsonConvert.SerializeObject(parsedContactModel);
                            request.CaseContacts = serContactModel;
                            foreach (var item in parsedContactModel)
                            {
                                contactItem = new ContactGetListViewModel
                                {
                                    ContactedHumanCasePersonID = !string.IsNullOrEmpty(item["contactedHumanCasePersonID"].ToString()) && long.Parse(item["contactedHumanCasePersonID"].ToString()) != 0 ? long.Parse(item["contactedHumanCasePersonID"].ToString()) : null,
                                    HumanMasterID = long.Parse(item["humanMasterID"].ToString()),
                                    ContactTypeID = !string.IsNullOrEmpty(item["contactTypeID"].ToString()) && long.Parse(item["contactTypeID"].ToString()) != 0 ? long.Parse(item["contactTypeID"].ToString()) : null,
                                    HumanID = !string.IsNullOrEmpty(item["humanID"].ToString()) && long.Parse(item["humanID"].ToString()) != 0 ? long.Parse(item["humanID"].ToString()) : null,
                                    DateOfLastContact = string.IsNullOrEmpty(item["dateOfLastContact"].ToString()) ? null : DateTime.Parse(item["dateOfLastContact"].ToString()),
                                    PlaceOfLastContact = !string.IsNullOrEmpty(item["placeOfLastContact"].ToString()) ? item["placeOfLastContact"].ToString() : null,
                                    ContactRelationshipTypeID = !string.IsNullOrEmpty(item["contactRelationshipTypeID"].ToString()) && long.Parse(item["contactRelationshipTypeID"].ToString()) != 0 ? long.Parse(item["contactRelationshipTypeID"].ToString()) : null,
                                    Comment = !string.IsNullOrEmpty(item["comment"].ToString()) ? item["comment"].ToString() : null,
                                    ContactTracingObservationID = !string.IsNullOrEmpty(item["contactTracingObservationID"].ToString()) && long.Parse(item["contactTracingObservationID"].ToString()) != 0 ? long.Parse(item["contactTracingObservationID"].ToString()) : null,
                                    ContactStatusID = !string.IsNullOrEmpty(item["contactStatusID"].ToString()) && long.Parse(item["contactStatusID"].ToString()) != 0 ? long.Parse(item["contactStatusID"].ToString()) : null,
                                    CaseContactID = long.Parse(item["caseContactID"].ToString()),
                                    RowAction = int.Parse(item["rowAction"].ToString()),
                                    RowStatus = int.Parse(item["rowStatus"].ToString())
                                };

                                contactList.Add(contactItem);
                            }

                            request.CaseContacts = System.Text.Json.JsonSerializer.Serialize(contactList);
                        }
                    }
                }

                long lSiteID = 1;
                var sampleDetails = JObject.Parse(jsonObject["sampleModel"].ToString())["samplesDetails"];
                List<SampleSaveRequestModel> samples = new();

                foreach (var item in sampleDetails)
                {
                    SampleSaveRequestModel Sample = new()
                    {
                        SampleTypeID =
                        !string.IsNullOrEmpty(item["sampleTypeID"].ToString()) &&
                        long.Parse(item["sampleTypeID"].ToString()) != 0
                            ? long.Parse(item["sampleTypeID"].ToString())
                            : null
                    };
                    var blnNumberingSchema =
                        !string.IsNullOrEmpty(item["blnNumberingSchema"].ToString()) &&
                        int.Parse(item["blnNumberingSchema"].ToString()) != 0
                            ? int.Parse(item["blnNumberingSchema"].ToString())
                            : 0;
                    if (blnNumberingSchema == 1 || blnNumberingSchema == 2)
                    {
                        Sample.EIDSSLocalOrFieldSampleID = "";
                    }
                    else
                    {
                        Sample.EIDSSLocalOrFieldSampleID = !string.IsNullOrEmpty(item["localSampleId"].ToString())
                            ? item["localSampleId"].ToString()
                            : null;
                    }

                    if (!string.IsNullOrEmpty(item["collectionDate"].ToString()))
                    {
                        Sample.CollectionDate = DateTime.Parse(item["collectionDate"].ToString());
                    }

                    Sample.CollectedByOrganizationID =
                        !string.IsNullOrEmpty(item["collectedByOrganizationID"].ToString()) &&
                        long.Parse(item["collectedByOrganizationID"].ToString()) != 0
                            ? long.Parse(item["collectedByOrganizationID"].ToString())
                            : null;
                    Sample.CollectedByPersonID =
                        !string.IsNullOrEmpty(item["collectedByOfficerID"].ToString()) &&
                        long.Parse(item["collectedByOfficerID"].ToString()) != 0
                            ? long.Parse(item["collectedByOfficerID"].ToString())
                            : null;
                    if (!string.IsNullOrEmpty(item["sentDate"].ToString()))
                    {
                        Sample.SentDate = DateTime.Parse(item["sentDate"].ToString());
                    }

                    Sample.SentToOrganizationID =
                        !string.IsNullOrEmpty(item["sentToOrganizationID"].ToString()) &&
                        long.Parse(item["sentToOrganizationID"].ToString()) != 0
                            ? long.Parse(item["sentToOrganizationID"].ToString())
                            : null;

                    long.TryParse(item["idfsSiteSentToOrg"].ToString(), out lSiteID);
                    Sample.SiteID = lSiteID;

                    Sample.DiseaseID = request.idfsDiagnosisOrDiagnosisGroup;
                    Sample.SampleID =
                        !string.IsNullOrEmpty(item["idfMaterial"].ToString()) &&
                        long.Parse(item["idfMaterial"].ToString()) != 0
                            ? long.Parse(item["idfMaterial"].ToString())
                            : 0;
                    if (Sample.SampleID == 0)
                        Sample.SampleID = item["newRecordId"] != null ? long.Parse(item["newRecordId"].ToString()) : 1;
                    Sample.RowStatus =
                        !string.IsNullOrEmpty(item["intRowStatus"].ToString()) &&
                        int.Parse(item["intRowStatus"].ToString()) != 0
                            ? int.Parse(item["intRowStatus"].ToString())
                            : 0;
                    Sample.CurrentSiteID = null;
                    Sample.HumanMasterID = request.idfHumanActual;
                    Sample.HumanID = request.idfHumanActual;
                    Sample.HumanDiseaseReportID = request.idfHumanCase;
                    Sample.RowAction = item["rowAction"] != null ? int.Parse(item["rowAction"].ToString()) : 2;
                    Sample.ReadOnlyIndicator = false;
                    samples.Add(Sample);
                }

                var strSamplesNew = System.Text.Json.JsonSerializer.Serialize(samples);

                request.CaseSamples = strSamplesNew;
                request.idfsYNSpecimenCollected = (long?)GetJsonValue(data, "idfsYNSpecimenCollected", DataType.Long);

                request.idfsYNTestsConducted = (long?)GetJsonValue(data, "idfsYNTestsConducted", DataType.Long);

                var testDetails = JObject.Parse(jsonObject["testModel"].ToString())["testDetails"];

                List<LaboratoryTestSaveRequestModel> tests = new();
                List<LaboratoryTestInterpretationSaveRequestModel> testInterpretations =
                    new();

                var count = 0;
                foreach (var item in testDetails)
                {
                    LaboratoryTestSaveRequestModel testRequest = new();
                    LaboratoryTestInterpretationSaveRequestModel interpretationRequest =
                        new();
                    testRequest.SampleID =
                        !string.IsNullOrEmpty(item["idfMaterial"].ToString()) &&
                        long.Parse(item["idfMaterial"].ToString()) != 0
                            ? long.Parse(item["idfMaterial"].ToString())
                            : null;
                    testRequest.TestID =
                        !string.IsNullOrEmpty(item["idfTesting"].ToString()) &&
                        long.Parse(item["idfTesting"].ToString()) != 0
                            ? long.Parse(item["idfTesting"].ToString())
                            : 0;

                    if (testRequest.TestID == 0)
                    {
                        count++;
                        testRequest.TestID = count;
                    }

                    testRequest.HumanDiseaseReportID =
                        !string.IsNullOrEmpty(item["idfHumanCase"].ToString()) &&
                        long.Parse(item["idfHumanCase"].ToString()) != 0
                            ? long.Parse(item["idfHumanCase"].ToString())
                            : null;
                    testRequest.TestCategoryTypeID =
                        !string.IsNullOrEmpty(item["idfsTestCategory"].ToString()) &&
                        long.Parse(item["idfsTestCategory"].ToString()) != 0
                            ? long.Parse(item["idfsTestCategory"].ToString())
                            : null;
                    testRequest.TestNameTypeID =
                        !string.IsNullOrEmpty(item["idfsTestName"].ToString()) &&
                        long.Parse(item["idfsTestName"].ToString()) != 0
                            ? long.Parse(item["idfsTestName"].ToString())
                            : null;
                    testRequest.TestResultTypeID =
                        !string.IsNullOrEmpty(item["idfsTestResult"].ToString()) &&
                        long.Parse(item["idfsTestResult"].ToString()) != 0
                            ? long.Parse(item["idfsTestResult"].ToString())
                            : null;
                    testRequest.TestStatusTypeID =
                        !string.IsNullOrEmpty(item["idfsTestStatus"].ToString()) &&
                        long.Parse(item["idfsTestStatus"].ToString()) != 0
                            ? long.Parse(item["idfsTestStatus"].ToString())
                            : 0;

                    if (!string.IsNullOrEmpty(item["datSampleStatusDate"].ToString()))
                    {
                        testRequest.ResultDate = DateTime.Parse(item["datSampleStatusDate"].ToString());
                    }

                    if (!string.IsNullOrEmpty(item["datFieldCollectionDate"].ToString()))
                    {
                        testRequest.ReceivedDate = DateTime.Parse(item["datFieldCollectionDate"].ToString());
                    }

                    testRequest.TestedByPersonID =
                        !string.IsNullOrEmpty(item["idfTestedByPerson"].ToString()) &&
                        long.Parse(item["idfTestedByPerson"].ToString()) != 0
                            ? long.Parse(item["idfTestedByPerson"].ToString())
                            : null;
                    testRequest.TestedByOrganizationID =
                        !string.IsNullOrEmpty(item["idfTestedByOffice"].ToString()) &&
                        long.Parse(item["idfTestedByOffice"].ToString()) != 0
                            ? long.Parse(item["idfTestedByOffice"].ToString())
                            : null;
                    testRequest.RowStatus =
                        !string.IsNullOrEmpty(item["intRowStatus"].ToString()) &&
                        int.Parse(item["intRowStatus"].ToString()) != 0
                            ? int.Parse(item["intRowStatus"].ToString())
                            : 0;

                    testRequest.HumanDiseaseReportID = request.idfHumanCase;
                    testRequest.RowAction = item["rowAction"] != null ? int.Parse(item["rowAction"].ToString()) : 2;
                    testRequest.ReadOnlyIndicator = false;
                    testRequest.DiseaseID =
                        !string.IsNullOrEmpty(item["idfsDiagnosis"].ToString()) &&
                        long.Parse(item["idfsDiagnosis"].ToString()) != 0
                            ? long.Parse(item["idfsDiagnosis"].ToString())
                            : 0;
                    testRequest.NonLaboratoryTestIndicator =
                        !string.IsNullOrEmpty(item["blnNonLaboratoryTest"].ToString()) && Convert.ToBoolean(item["blnNonLaboratoryTest"].ToString());

                    interpretationRequest.TestID = testRequest.TestID;
                    interpretationRequest.TestInterpretationID =
                        !string.IsNullOrEmpty(item["idfTestValidation"].ToString()) &&
                        long.Parse(item["idfTestValidation"].ToString()) != 0
                            ? long.Parse(item["idfTestValidation"].ToString())
                            : 0;
                    interpretationRequest.InterpretedByPersonID =
                        !string.IsNullOrEmpty(item["idfInterpretedByPerson"].ToString()) &&
                        long.Parse(item["idfInterpretedByPerson"].ToString()) != 0
                            ? long.Parse(item["idfInterpretedByPerson"].ToString())
                            : null;
                    interpretationRequest.InterpretedStatusTypeID =
                        !string.IsNullOrEmpty(item["idfsInterpretedStatus"].ToString()) &&
                        long.Parse(item["idfsInterpretedStatus"].ToString()) != 0
                            ? long.Parse(item["idfsInterpretedStatus"].ToString())
                            : null;

                    if (!string.IsNullOrEmpty(item["datInterpretedDate"].ToString()))
                    {
                        interpretationRequest.InterpretedDate = DateTime.Parse(item["datInterpretedDate"].ToString());
                    }

                    interpretationRequest.InterpretedComment = item["strInterpretedComment"].ToString();
                    interpretationRequest.ValidatedByPersonID =
                        !string.IsNullOrEmpty(item["idfValidatedByPerson"].ToString()) &&
                        long.Parse(item["idfValidatedByPerson"].ToString()) != 0
                            ? long.Parse(item["idfValidatedByPerson"].ToString())
                            : null;

                    if (!string.IsNullOrEmpty(item["datValidationDate"].ToString()))
                    {
                        interpretationRequest.ValidatedDate = DateTime.Parse(item["datValidationDate"].ToString());
                    }

                    interpretationRequest.ValidatedComment = item["strValidateComment"].ToString();
                    interpretationRequest.RowStatus =
                        !string.IsNullOrEmpty(item["intRowStatus"].ToString()) &&
                        int.Parse(item["intRowStatus"].ToString()) != 0
                            ? int.Parse(item["intRowStatus"].ToString())
                            : 0;
                    interpretationRequest.ValidatedStatusIndicator =
                        !string.IsNullOrEmpty(item["blnValidateStatus"].ToString()) && Convert.ToBoolean(item["blnValidateStatus"].ToString());
                    interpretationRequest.DiseaseID = request.idfHumanCase;
                    interpretationRequest.RowAction =
                        item["rowAction"] != null ? int.Parse(item["rowAction"].ToString()) : 2;
                    interpretationRequest.ReadOnlyIndicator = false;
                    interpretationRequest.DiseaseID =
                        !string.IsNullOrEmpty(item["idfsDiagnosis"].ToString()) &&
                        long.Parse(item["idfsDiagnosis"].ToString()) != 0
                            ? long.Parse(item["idfsDiagnosis"].ToString())
                            : 0;
                    tests.Add(testRequest);
                    testInterpretations.Add(interpretationRequest);
                }

                request.CaseTests = System.Text.Json.JsonSerializer.Serialize(tests);

                var result = await _OutbreakClient.SetCase(request);
                if (result != null)
                {
                    response = result;
                    if (request.OutbreakCaseReportUID == -1)
                    {
                        response.ReturnMessage =
                            string.Format(
                                _localizer.GetString(MessageResourceKeyConstants
                                    .CreateHumanCaseHumanCasehasbeensavedsuccessfullyNewCaseIDMessage),
                                response.strOutbreakCaseId);
                    }
                    else if (request.OutbreakCaseReportUID != null && request.OutbreakCaseReportUID != 0)
                    {
                        response.ReturnMessage =
                            _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                    }
                }

                return Ok(response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }

            return null;
        }

        private static object GetJsonValue(object data, string strKeyword, DataType dt)
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
                }
            }
            else
            {
                switch (dt)
                {
                    case DataType.LocationType:
                        returnValue = LocationType.None;
                        break;
                    case DataType.String:
                        returnValue = string.Empty;
                        break;
                }
            }

            return returnValue;
        }

        [HttpPost()]
        [Route("DeleteHumanCaseReport")]
        public async Task<IActionResult> DeleteHumanCaseReport([FromBody] JsonElement data)
        {
            HumanDiseaseReportDeleteRequestModel request = new();
            var jsonObject = JObject.Parse(data.ToString());
            long? idfHumanCase = !string.IsNullOrEmpty(jsonObject["idfHumanCase"].ToString()) && long.Parse(jsonObject["idfHumanCase"].ToString()) != 0 ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            request.idfHumanCase = !string.IsNullOrEmpty(jsonObject["idfHumanCase"].ToString()) && long.Parse(jsonObject["idfHumanCase"].ToString()) != 0 ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            request.LangID = GetCurrentLanguage();
            var response = await _humanDiseaseReportClient.DeleteHumanDiseaseReport(idfHumanCase, Convert.ToInt64(_authenticatedUser.EIDSSUserId), Convert.ToInt64(_authenticatedUser.SiteId), false);
            return Ok(response);
        }

        public async Task<bool> CheckDiseaseForGender(string data)
        {
            JObject jsonObject = JObject.Parse(data);
            long? disease = !string.IsNullOrEmpty(jsonObject["disease"].ToString()) && long.Parse(jsonObject["disease"].ToString()) != 0 ? long.Parse(jsonObject["disease"].ToString()) : null;
            long? gender = !string.IsNullOrEmpty(jsonObject["gender"].ToString()) && long.Parse(jsonObject["gender"].ToString()) != 0 ? long.Parse(jsonObject["gender"].ToString()) : null;
            bool isInValid = false;

            try
            {
                GenderForDiseaseOrDiagnosisGroupDiseaseMatrixGetRequestModel request = new()
                {
                    LanguageID = GetCurrentLanguage(),
                    DiseaseID = disease
                };
                var response = await _diseaseHumanGenderMatrixClient.GetGenderForDiseaseOrDiagnosisGroupMatrix(request);
                if (response != null && response.Count > 0)
                {
                    if (response.FirstOrDefault().GenderID != gender)
                    {
                        isInValid = true;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return isInValid;
        }

        protected async Task OnHumanDiseaseReportCreation(long? siteID)
        {
            try
            {
                var eventTypeId = Convert.ToInt64(_authenticatedUser.SiteId) == siteID
                    ? SystemEventLogTypes.NewHumanDiseaseReportWasCreatedAtYourSite
                    : SystemEventLogTypes.NewHumanDiseaseReportWasCreatedAtAnotherSite;
                var notification = await _notificationService.CreateEvent(0,
                    _diseaseReportComponentViewModel.DiseaseReport.DiseaseID, eventTypeId, siteID.Value, null);
                _notificationService.Events.Add(notification);
                _httpContextAccessor.HttpContext.Response.Cookies.Append("HDRNotifications", JsonConvert.SerializeObject(_notificationService.Events));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task GetSiteAlertForInitialCaseClassification(string data)
        {
            JObject jsonObject = JObject.Parse(data);
            long? classification = !string.IsNullOrEmpty(jsonObject["idfCaseClassfication"].ToString()) && long.Parse(jsonObject["idfCaseClassfication"].ToString()) != 0 ? long.Parse(jsonObject["idfCaseClassfication"].ToString()) : null;
            long? idfHumanCase = !string.IsNullOrEmpty(jsonObject["idfHumanCase"].ToString()) && long.Parse(jsonObject["idfHumanCase"].ToString()) != 0 ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            long? idfHuman = !string.IsNullOrEmpty(jsonObject["idfHuman"].ToString()) && long.Parse(jsonObject["idfHuman"].ToString()) != 0 ? long.Parse(jsonObject["idfHuman"].ToString()) : null;
            long? idfsSite = !string.IsNullOrEmpty(jsonObject["idfsSite"].ToString()) && long.Parse(jsonObject["idfsSite"].ToString()) != 0 ? long.Parse(jsonObject["idfsSite"].ToString()) : null;
            try
            {
                if (idfHumanCase != null)
                {
                    var eventTypeId = Convert.ToInt64(_authenticatedUser.SiteId) == idfsSite
                        ? SystemEventLogTypes.HumanDiseaseReportClassificationWasChangedAtYourSite
                        : SystemEventLogTypes.HumanDiseaseReportClassificationWasChangedAtAnotherSite;
                    _notificationService.Events = JsonConvert.DeserializeObject<List<EventSaveRequestModel>>(Request.Cookies["HDRNotifications"] ?? string.Empty);

                    if (_notificationService.Events == null)
                    {
                        _notificationService.Events = new List<EventSaveRequestModel>();
                        _notificationService.Events.Add(await _notificationService.CreateEvent(idfHumanCase.Value,
                            _diseaseReportComponentViewModel.DiseaseReport.DiseaseID, eventTypeId, idfsSite.Value, null));
                    }
                    else if (_notificationService.Events.All(x => x.EventTypeId != (long)eventTypeId))
                        _notificationService.Events.Add(await _notificationService.CreateEvent(idfHumanCase.Value,
                            _diseaseReportComponentViewModel.DiseaseReport.DiseaseID, eventTypeId, idfsSite.Value, null));

                    _httpContextAccessor.HttpContext.Response.Cookies.Append("HDRNotifications", JsonConvert.SerializeObject(_notificationService.Events));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }
        public async Task GetSiteAlertForReopenClosedHDR(string data)
        {
            JObject jsonObject = JObject.Parse(data);

            long? idfHumanCase = !string.IsNullOrEmpty(jsonObject["idfHumanCase"].ToString()) && long.Parse(jsonObject["idfHumanCase"].ToString()) != 0 ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            long? idfsSite = !string.IsNullOrEmpty(jsonObject["idfsSite"].ToString()) && long.Parse(jsonObject["idfsSite"].ToString()) != 0 ? long.Parse(jsonObject["idfsSite"].ToString()) : null;
            try
            {
                if (idfHumanCase != null)
                {
                    const SystemEventLogTypes eventTypeId = SystemEventLogTypes.ClosedHumanDiseaseReportWasReopenedAtYourSite;
                    _notificationService.Events = JsonConvert.DeserializeObject<List<EventSaveRequestModel>>(Request.Cookies["HDRNotifications"] ?? string.Empty);

                    if (_notificationService.Events == null)
                    {
                        _notificationService.Events = new List<EventSaveRequestModel>();
                        _notificationService.Events.Add(await _notificationService.CreateEvent(idfHumanCase.Value,
                            _diseaseReportComponentViewModel.DiseaseReport.DiseaseID, eventTypeId, idfsSite.Value, null));
                    }
                    else if (_notificationService.Events.All(x => x.EventTypeId != (long)eventTypeId))
                        _notificationService.Events.Add(await _notificationService.CreateEvent(idfHumanCase.Value,
                            _diseaseReportComponentViewModel.DiseaseReport.DiseaseID, eventTypeId, idfsSite.Value, null));

                    _httpContextAccessor.HttpContext.Response.Cookies.Append("HDRNotifications", JsonConvert.SerializeObject(_notificationService.Events));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }
    }
}
