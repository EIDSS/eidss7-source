using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
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
using EIDSS.Web.Components.Administration.Deduplication.HumanDiseaseReport;
using EIDSS.Web.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.CodeAnalysis.Differencing;
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
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Human.Outbreak
{
    [ViewComponent(Name = "HumanCase")]
    [Area("Outbreak")]
    public class HumanCase : BaseController
    {
        private readonly IOutbreakClient _OutbreakClient;
        readonly private ICrossCuttingClient _crossCuttingClient;
        readonly private ISettlementClient _settlementClient;
        readonly private ICrossCuttingService _crossCuttingService;

        private IConfiguration _configuration;
        public IConfiguration Configuration { get { return _configuration; } }
        public DiseaseReportComponentViewModel _diseaseReportComponentViewModel { get; set; }
        internal CultureInfo uiCultureInfo = Thread.CurrentThread.CurrentUICulture;
        internal CultureInfo cultureInfo = Thread.CurrentThread.CurrentCulture;
        public string CurrentLanguage { get; set; }
        public IHttpContextAccessor _httpContextAccessor;
        public string CountryId { get; set; }
        private readonly ITokenService _tokenService;
        private INotificationSiteAlertService _notificationService;
        private readonly AuthenticatedUser _authenticatedUser;
        private IHumanDiseaseReportClient _humanDiseaseReportClient;
        private UserPermissions userPermissions;
        private IFlexFormClient _flexFormClient;
        private readonly IStringLocalizer _localizer;
        List<HumanDiseaseReportDetailViewModel> detailResponse = new List<HumanDiseaseReportDetailViewModel>();
        private IDiseaseHumanGenderMatrixClient _diseaseHumanGenderMatrixClient;
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

        public HumanCase(IOutbreakClient outbreakClient, ICrossCuttingClient crossCuttingClient, ISettlementClient settlementClient, IConfiguration configuration,
                            ICrossCuttingService crossCuttingService, IHumanDiseaseReportClient humanDiseaseReportClient, ITokenService tokenService,
                            IFlexFormClient flexFormClient, ILogger<OrganizationSearchController> logger, IStringLocalizer localizer,
                            IDiseaseHumanGenderMatrixClient diseaseHumanGenderMatrixClient, INotificationSiteAlertService notificationService,
                            IHttpContextAccessor httpContextAccessor) :
            base(logger, tokenService)
        {
            _OutbreakClient = outbreakClient;

            _httpContextAccessor = httpContextAccessor;
            _crossCuttingClient = crossCuttingClient;
            _settlementClient = settlementClient;
            _crossCuttingService = crossCuttingService;
            _humanDiseaseReportClient = humanDiseaseReportClient;
            _notificationService = notificationService;
            _tokenService = tokenService;
            _configuration = configuration;
            _flexFormClient = flexFormClient;
            _localizer = localizer;
            _diseaseHumanGenderMatrixClient = diseaseHumanGenderMatrixClient;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");

            CurrentLanguage = cultureInfo.Name;
        }

        public async Task<IViewComponentResult> InvokeAsync(HumanCaseViewModel model)
        {
            _diseaseReportComponentViewModel = model.diseaseReportComponentViewModel;
            
            UserPermissions deletePermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
            UserPermissions CanReopenClosedReport = GetUserPermissions(PagePermission.CanReopenClosedHumanDiseaseReportSession);

            OutbreakSessionDetailRequestModel outbreakSessionRequest = new OutbreakSessionDetailRequestModel();
            outbreakSessionRequest.LanguageID = GetCurrentLanguage();
            outbreakSessionRequest.idfsOutbreak = model.idfOutbreak;

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
                    _diseaseReportComponentViewModel.NotificationSection = new DiseaseReportNotificationPageViewModel();
                    _diseaseReportComponentViewModel.NotificationSection.isOutbreakCase = true;
                    _diseaseReportComponentViewModel.NotificationSection.datOutbreakStartDate = outbreakSessionDetail.datStartDate;
                    _diseaseReportComponentViewModel.NotificationSection.PermissionsAccessToNotification = new UserPermissions();
                    _diseaseReportComponentViewModel.NotificationSection.PermissionsAccessToNotification.Create = caseMonitoringPermissions.Create;
                    _diseaseReportComponentViewModel.NotificationSection.PermissionsAccessToNotification.Write = caseMonitoringPermissions.Write;
                    _diseaseReportComponentViewModel.NotificationSection.PermissionsAccessToNotification.Delete = caseMonitoringPermissions.Delete;

                    _diseaseReportComponentViewModel.SymptomsSection = new DiseaseReportSymptomsPageViewModel();
                    _diseaseReportComponentViewModel.FacilityDetailsSection = new DiseaseReportFacilityDetailsPageViewModel();
                    _diseaseReportComponentViewModel.AntibioticVaccineHistorySection = new DiseaseReportAntibioticVaccineHistoryPageViewModel();

                    _diseaseReportComponentViewModel.CaseDetails = new Domain.ViewModels.Outbreak.CaseGetDetailViewModel();
                    _diseaseReportComponentViewModel.CaseDetails.CaseMonitorings = new List<CaseMonitoringGetListViewModel>();
                    _diseaseReportComponentViewModel.CaseDetails.Session = new OutbreakSessionDetailsResponseModel();

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

                    _diseaseReportComponentViewModel.DiseaseReport = new Domain.ViewModels.Veterinary.DiseaseReportGetDetailViewModel();
                    _diseaseReportComponentViewModel.DiseaseReport.ReportCategoryTypeID = (long)model.SessionDetails.OutbreakTypeId;

                    _diseaseReportComponentViewModel.SamplesSection = new DiseaseReportSamplePageViewModel();
                    _diseaseReportComponentViewModel.TestsSection = new DiseaseReportTestPageViewModel();
                    _diseaseReportComponentViewModel.CaseInvestigationSection = new DiseaseReportCaseInvestigationPageViewModel();
                    _diseaseReportComponentViewModel.CaseInvestigationSection.PermissionsAccessToNotification = new UserPermissions();
                    _diseaseReportComponentViewModel.CaseInvestigationSection.PermissionsAccessToNotification.Write = caseMonitoringPermissions.Write;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.PermissionsAccessToNotification.Delete = caseMonitoringPermissions.Delete;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.PermissionsAccessToNotification.Create = caseMonitoringPermissions.Create;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.isOutbreakCase = true;

                    //_diseaseReportComponentViewModel.ContactListSection = new DiseaseReportContactListPageViewModel();
                    _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest = new FlexFormQuestionnaireGetRequestModel();
                    _diseaseReportComponentViewModel.ContactListSection.ContactTracingFlexFormRequest.LangID = GetCurrentLanguage();
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

                HumanPersonDetailsRequestModel request = new HumanPersonDetailsRequestModel();
                HumanPersonDetailsFromHumanIDRequestModel requestID = new HumanPersonDetailsFromHumanIDRequestModel();
                List<DiseaseReportPersonalInformationViewModel> response = new List<DiseaseReportPersonalInformationViewModel>();
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
                        _diseaseReportComponentViewModel.ReportSummary.DateEntered = personInfo.EnteredDate != null ? Convert.ToDateTime(personInfo.EnteredDate).ToString() : DateTime.Today.ToString();
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
                    _diseaseReportComponentViewModel.SymptomsSection.OutBreakSymptomsOnsetDate = detailResponse[0].datOnSetDate;

                    List<CaseGetDetailViewModel> caseDetails = await _OutbreakClient.GetCaseDetail(GetCurrentLanguage(), model.OutbreakCaseReportUID);


                    CaseEPIObservationID = caseDetails.First().CaseQuestionnaireObservationId;

                    if (detailResponse.Count > 0)
                    {
                        var humanDiseaseDetail = detailResponse.FirstOrDefault();

                        _diseaseReportComponentViewModel.HumanCaseClinicalInformation.datFinalDiagnosisDate = humanDiseaseDetail.datFinalDiagnosisDate;

                        _diseaseReportComponentViewModel.ReportSummary.ReportID = humanDiseaseDetail.strCaseId;
                        _diseaseReportComponentViewModel.ReportSummary.ReportStatus = humanDiseaseDetail.CaseProgressStatus;
                        _diseaseReportComponentViewModel.ReportSummary.ReportStatusID = humanDiseaseDetail.idfsCaseProgressStatus.Value;
                        _diseaseReportComponentViewModel.ReportSummary.DateEntered = humanDiseaseDetail.datEnteredDate != null ? Convert.ToDateTime(humanDiseaseDetail.datEnteredDate).ToString() : DateTime.Today.ToString();
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
                        _diseaseReportComponentViewModel.ReportSummary.RelatedToReportIds = humanDiseaseDetail.relatedHumanDiseaseReportIdList;
                        _diseaseReportComponentViewModel.ReportSummary.idfHumanCase = humanDiseaseDetail.idfHumanCase;
                        _diseaseReportComponentViewModel.ReportSummary.HumanID = humanDiseaseDetail.idfHuman;
                        _diseaseReportComponentViewModel.ReportSummary.HumanActualID = humanDiseaseDetail.HumanActualId;
                        _diseaseReportComponentViewModel.ReportSummary.CaseClassification = humanDiseaseDetail.SummaryCaseClassification;
                        _diseaseReportComponentViewModel.ReportSummary.blnFinalSSD = humanDiseaseDetail.blnFinalSSD;
                        _diseaseReportComponentViewModel.ReportSummary.blnInitialSSD = humanDiseaseDetail.blnInitialSSD;
                        _diseaseReportComponentViewModel.ReportSummary.ConnectedDiseaseReportID = humanDiseaseDetail.ConnectedDiseaseReportID;
                        _diseaseReportComponentViewModel.ReportSummary.ConnectedDiseaseEIDSSReportID = humanDiseaseDetail.ConnectedDiseaseEIDSSReportID;
                        _diseaseReportComponentViewModel.ReportSummary.RelateToHumanDiseaseReportID = humanDiseaseDetail.RelateToHumanDiseaseReportID;
                        _diseaseReportComponentViewModel.ReportSummary.RelatedToHumanDiseaseEIDSSReportID = humanDiseaseDetail.RelatedToHumanDiseaseEIDSSReportID;
                        _diseaseReportComponentViewModel.ReportSummary.relatedChildHumanDiseaseReportIdList = humanDiseaseDetail.relatedChildHumanDiseaseReportIdList;
                        _diseaseReportComponentViewModel.ReportSummary.relatedParentHumanDiseaseReportIdList = humanDiseaseDetail.relatedParentHumanDiseaseReportIdList;
                        
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
                model.CaseReportPrintViewModal = new();
                model.CaseReportPrintViewModal.Parameters = new List<KeyValuePair<string, string>>();
                model.CaseReportPrintViewModal.ReportName = "HumanOutbreakCase";
                //model.CaseReportPrintViewModal.ReportHeading = "HumanOutbreakCase";

                if (detailResponse.Count > 0)
                {
                    if (detailResponse.First().idfHumanCase != null)
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
                }

                if (model.diseaseReportComponentViewModel.HumanActualID != 0 && model.diseaseReportComponentViewModel.HumanActualID != null)
                {
                    _diseaseReportComponentViewModel.HumanActualID = model.diseaseReportComponentViewModel.HumanActualID;
                }
                if (model.diseaseReportComponentViewModel.HumanID != 0 && model.diseaseReportComponentViewModel.HumanID != null)
                {
                    _diseaseReportComponentViewModel.HumanID = model.diseaseReportComponentViewModel.HumanID;
                }

                _diseaseReportComponentViewModel.HumanCaseLocation = await LoadCaseLocation(_diseaseReportComponentViewModel.HumanCaseLocation);

                _diseaseReportComponentViewModel.PersonInfoSection = await LoadPersonInfo(model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.NotificationSection = await LoadNotification(model.diseaseReportComponentViewModel.isEdit);
                if (_diseaseReportComponentViewModel != null && _diseaseReportComponentViewModel.PersonInfoSection != null && _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo != null)
                {
                    _diseaseReportComponentViewModel.NotificationSection.DateOfBirth = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.DateOfBirth;
                    _diseaseReportComponentViewModel.NotificationSection.Age = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.Age;
                    _diseaseReportComponentViewModel.NotificationSection.GenderTypeID = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.GenderTypeID;
                    _diseaseReportComponentViewModel.NotificationSection.GenderTypeName = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.GenderTypeName;
                }
                _diseaseReportComponentViewModel.SymptomsSection = await LoadSymptoms(model.diseaseReportComponentViewModel.SymptomsSection, model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.FacilityDetailsSection = await LoadFacilityDetails(model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.AntibioticVaccineHistorySection = await LoadAntibioticVaccineHistoryDetails(model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.SamplesSection = await LoadSampleDetails(model.diseaseReportComponentViewModel.NotificationSection.idfDisease, model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.TestsSection = await LoadTestsDetails(model.diseaseReportComponentViewModel.NotificationSection.idfDisease, model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.CaseInvestigationSection = await LoadCaseInvestigationDetails(model.diseaseReportComponentViewModel.isEdit);


                _diseaseReportComponentViewModel.RiskFactorsSection = await LoadCaseInvestigationRiskFactors(model.diseaseReportComponentViewModel.RiskFactorsSection, 
                            model.diseaseReportComponentViewModel.isEdit, model.diseaseReportComponentViewModel.CaseDetails.Session.HumanCaseQuestionaireTemplateID,
                            detailResponse.Count > 0 ? CaseEPIObservationID : null);

                _diseaseReportComponentViewModel.ContactListSection = await LoadContactList(model.diseaseReportComponentViewModel.NotificationSection.idfDisease, model.diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.FinalOutcomeSection = await LoadFinalOutComeDetails(model.diseaseReportComponentViewModel.NotificationSection.idfDisease, model.diseaseReportComponentViewModel.isEdit);

                if (_diseaseReportComponentViewModel.isConnectedDiseaseReport)
                {
                    _diseaseReportComponentViewModel.idfHumanCaseRelatedTo = _diseaseReportComponentViewModel.idfHumanCase;
                    _diseaseReportComponentViewModel.idfHumanCase = null;
                    _diseaseReportComponentViewModel.strCaseId = null;
                    _diseaseReportComponentViewModel.ReportSummary.ReportStatusID = (long)VeterinaryDiseaseReportStatusTypes.InProcess;
                    _diseaseReportComponentViewModel.ReportSummary.ReportStatus = "In-Process";
                    _diseaseReportComponentViewModel.ReportSummary.ReportID = null;
                    _diseaseReportComponentViewModel.NotificationSection.isConnectedDiseaseReport = _diseaseReportComponentViewModel.isConnectedDiseaseReport;
                    _diseaseReportComponentViewModel.NotificationSection.idfOldDisease = _diseaseReportComponentViewModel.NotificationSection.idfDisease;
                    _diseaseReportComponentViewModel.NotificationSection.idfDisease = null;
                    _diseaseReportComponentViewModel.NotificationSection.strDisease = null;
                    _diseaseReportComponentViewModel.NotificationSection.dateOfDiagnosis = null;
                    _diseaseReportComponentViewModel.NotificationSection.dateOfNotification = null;
                    _diseaseReportComponentViewModel.SymptomsSection.idfCaseClassfication = null;
                    _diseaseReportComponentViewModel.SymptomsSection.strCaseClassification = null;
                    var investigatingOrg = _diseaseReportComponentViewModel.CaseInvestigationSection.idfInvestigatedByOffice;
                    var strInvestingOrg = _diseaseReportComponentViewModel.CaseInvestigationSection.InvestigatedByOffice;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfInvestigatedByOffice = investigatingOrg;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.InvestigatedByOffice = strInvestingOrg;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.StartDateofInvestigation = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.comments = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.Country = null;

                    _diseaseReportComponentViewModel.CaseInvestigationSection.ExposureLocationDescription = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.Region = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.Rayon = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.strGroundType = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.strOutbreakID = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.dblPointAccuracy = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.dblPointElevation = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.dblPointLongitude = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.dblPointDistance = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.dblPointLatitude = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.dblPointDirection = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.dblPointAlignment = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.strPointForeignAddress = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.ExposureDate = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.ExposureLocationDescription = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.ExposureLocationType = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfsYNExposureLocationKnown = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfsYNRelatedToOutbreak = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfOutbreak = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfPointGeoLocation = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfsPointCountry = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfsPointGeoLocationType = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfsPointGroundType = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfsPointRayon = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfsPointRegion = null;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.idfsPointSettlement = null;

                    _diseaseReportComponentViewModel.FinalOutcomeSection = new DiseaseReportFinalOutcomeViewModel();
                    _diseaseReportComponentViewModel.FinalOutcomeSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.isEdit = false;
                    _diseaseReportComponentViewModel.NotificationSection.isEdit = false;
                    _diseaseReportComponentViewModel.ContactListSection.isEdit = false;
                    _diseaseReportComponentViewModel.HumanID = null;
                    _diseaseReportComponentViewModel.NotificationSection.HumanID = null;
                    _diseaseReportComponentViewModel.NotificationSection.idfHumanCase = null;
                    _diseaseReportComponentViewModel.AntibioticVaccineHistorySection.HumanID = null;
                    _diseaseReportComponentViewModel.AntibioticVaccineHistorySection.idfHumanCase = null;
                    _diseaseReportComponentViewModel.SamplesSection.idfHumanCase = null;
                    _diseaseReportComponentViewModel.TestsSection.idfHumanCase = null;
                    _diseaseReportComponentViewModel.ContactListSection.idfHumanCase = null;
                    _diseaseReportComponentViewModel.ContactListSection.HumanID = null;
                    _diseaseReportComponentViewModel.IsReportClosed = false;
                    _diseaseReportComponentViewModel.NotificationSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.SymptomsSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.FacilityDetailsSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.AntibioticVaccineHistorySection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.SamplesSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.TestsSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.RiskFactorsSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.ContactListSection.IsReportClosed = false;
                }

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
            catch (Exception ex)
            {

            }

            var viewData = new ViewDataDictionary<HumanCaseViewModel>(ViewData, model);
            return new ViewViewComponentResult()
            {
                ViewData = viewData
            };
        }

        private async void InitializeModels(HumanCaseViewModel model)
        {
            if (_diseaseReportComponentViewModel.ReportSummary == null)
            {
                _diseaseReportComponentViewModel.ReportSummary = new DiseaseReportSummaryPageViewModel();
            }
            if (_diseaseReportComponentViewModel.NotificationSection == null)
            {
                _diseaseReportComponentViewModel.NotificationSection = new DiseaseReportNotificationPageViewModel();
            }
            _diseaseReportComponentViewModel.NotificationSection.isOutbreakCase = true;
            _diseaseReportComponentViewModel.NotificationSection.datOutbreakStartDate = outbreakSessionDetail.datStartDate;
            if (_diseaseReportComponentViewModel.SymptomsSection == null)
            {
                _diseaseReportComponentViewModel.SymptomsSection = new DiseaseReportSymptomsPageViewModel();
            }
            if (_diseaseReportComponentViewModel.FacilityDetailsSection == null)
            {
                _diseaseReportComponentViewModel.FacilityDetailsSection = new DiseaseReportFacilityDetailsPageViewModel();
            }
            if (_diseaseReportComponentViewModel.AntibioticVaccineHistorySection == null)
            {
                _diseaseReportComponentViewModel.AntibioticVaccineHistorySection = new DiseaseReportAntibioticVaccineHistoryPageViewModel();
            }

            if (_diseaseReportComponentViewModel.CaseDetails == null)
            {
                _diseaseReportComponentViewModel.CaseDetails = new Domain.ViewModels.Outbreak.CaseGetDetailViewModel();
                _diseaseReportComponentViewModel.CaseDetails.CaseMonitorings = new List<CaseMonitoringGetListViewModel>();
                _diseaseReportComponentViewModel.CaseDetails.Session = new OutbreakSessionDetailsResponseModel();
            }

            if(_diseaseReportComponentViewModel.CaseDetails.Session == null)
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

            if (_diseaseReportComponentViewModel.DiseaseReport == null)
            {
                _diseaseReportComponentViewModel.DiseaseReport = new Domain.ViewModels.Veterinary.DiseaseReportGetDetailViewModel();
            }
            _diseaseReportComponentViewModel.DiseaseReport.ReportCategoryTypeID = (long)model.SessionDetails.OutbreakTypeId;

            if (_diseaseReportComponentViewModel.SamplesSection == null)
            {
                _diseaseReportComponentViewModel.SamplesSection = new DiseaseReportSamplePageViewModel();
            }
            if (_diseaseReportComponentViewModel.TestsSection == null)
            {
                _diseaseReportComponentViewModel.TestsSection = new DiseaseReportTestPageViewModel();
            }
            if (_diseaseReportComponentViewModel.CaseInvestigationSection == null)
            {
                _diseaseReportComponentViewModel.CaseInvestigationSection = new DiseaseReportCaseInvestigationPageViewModel();
            }
            if (_diseaseReportComponentViewModel.CaseInvestigationSection == null)
            {
                _diseaseReportComponentViewModel.CaseInvestigationSection.PermissionsAccessToNotification = new UserPermissions();
            }
            _diseaseReportComponentViewModel.CaseInvestigationSection.isOutbreakCase = true;

            if (_diseaseReportComponentViewModel.ContactListSection == null)
            {
                _diseaseReportComponentViewModel.ContactListSection = new DiseaseReportContactListPageViewModel();
            }
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

            if (_diseaseReportComponentViewModel.FinalOutcomeSection == null)
            {
                _diseaseReportComponentViewModel.FinalOutcomeSection = new DiseaseReportFinalOutcomeViewModel();
            }
            if (_diseaseReportComponentViewModel.PersonInfoSection == null)
            {
                _diseaseReportComponentViewModel.PersonInfoSection = new DiseaseReportPersonalInformationPageViewModel();
            }
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
            if (_diseaseReportComponentViewModel.HumanCaseLocation == null)
            {
                _diseaseReportComponentViewModel.HumanCaseLocation = new LocationViewModel();
            }
            if (_diseaseReportComponentViewModel.HumanCaseClinicalInformation == null)
            {
                _diseaseReportComponentViewModel.HumanCaseClinicalInformation = new HumanCaseClinicalInformation();
            }
        }
        public async Task<LocationViewModel> LoadCaseLocation(LocationViewModel caseLocation)
        {
            if (caseLocation == null)
            {
                caseLocation = new LocationViewModel();
            }

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

        public async Task<DiseaseReportPersonalInformationPageViewModel> LoadPersonInfo(bool? isEdit = false)
        {
            #region Person Info
            //Current Address

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

            //Work Address

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

            //School Address

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

            List<DiseaseReportPersonalInformationViewModel> response = new List<DiseaseReportPersonalInformationViewModel>();
            if (_diseaseReportComponentViewModel.HumanID == null || _diseaseReportComponentViewModel.HumanID == 0)
            {
                HumanPersonDetailsRequestModel requestNew = new HumanPersonDetailsRequestModel();
                requestNew.LangID = GetCurrentLanguage();
                requestNew.HumanMasterID = _diseaseReportComponentViewModel.HumanActualID;
                response = await _humanDiseaseReportClient.GetHumanDiseaseReportPersonInfoAsync(requestNew);
            }
            else
            {
                HumanPersonDetailsFromHumanIDRequestModel requestID = new HumanPersonDetailsFromHumanIDRequestModel();
                requestID.LanguageId = GetCurrentLanguage();
                requestID.HumanID = _diseaseReportComponentViewModel.HumanID;
                response = await _humanDiseaseReportClient.GetHumanDiseaseReportFromHumanIDAsync(requestID);
                if (response == null || (response != null && response.Count() == 0))
                {
                    HumanPersonDetailsRequestModel requestNew = new HumanPersonDetailsRequestModel();
                    requestNew.LangID = GetCurrentLanguage();
                    requestNew.HumanMasterID = _diseaseReportComponentViewModel.HumanID;
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

                //Work Address

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

                //School Address

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
            #endregion
            return personalInformationPageViewModel;
        }

        public async Task<DiseaseReportSymptomsPageViewModel> LoadSymptoms(DiseaseReportSymptomsPageViewModel symptomsSection, bool isEdit = false)
        {
            if (!isEdit)
            {
                symptomsSection = new DiseaseReportSymptomsPageViewModel();
                symptomsSection.HumanDiseaseSymptoms = new FlexFormQuestionnaireGetRequestModel();
                symptomsSection.HumanDiseaseSymptoms.idfsFormType = (long?)FlexFormType.HumanDiseaseClinicalSymptoms;
                symptomsSection.HumanDiseaseSymptoms.idfsDiagnosis = outbreakSessionDetail.idfsDiagnosisOrDiagnosisGroup;
                symptomsSection.HumanDiseaseSymptoms.idfObservation = null;
            }

            symptomsSection.HumanDiseaseSymptoms.ObserationFieldID = "idfCaseObservationSymptoms";
            symptomsSection.HumanDiseaseSymptoms.LangID = GetCurrentLanguage();
            symptomsSection.HumanDiseaseSymptoms.Title = _localizer.GetString(FieldLabelResourceKeyConstants.CreateHumanCaseListofSymptomsFieldLabel);
            symptomsSection.HumanDiseaseSymptoms.SubmitButtonID = "btnDummy";
            symptomsSection.HumanDiseaseSymptoms.CallbackFunction = "getFlexFormAnswers10034501();";
            symptomsSection.HumanDiseaseSymptoms.CallbackErrorFunction = "SaveHDR();";
            symptomsSection.caseClassficationDD = new Select2Configruation();
            symptomsSection.caseClassficationDD.ConfigureForPartial = false;

            return symptomsSection;
        }

        [HttpPost]
        public async Task<IActionResult> ReloadSymptoms([FromBody] JsonElement data)
        {

            var jsonObject = JObject.Parse(data.ToString());
            var isEdit = jsonObject["isEdit"] != null && jsonObject["isEdit"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["isEdit"].ToString()) : false;
            long? idfHumanCase = jsonObject["idfHumanCase"] != null && jsonObject["idfHumanCase"].ToString() != string.Empty ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            long? diseaseId = jsonObject["diseaseId"] != null && jsonObject["diseaseId"].ToString() != string.Empty ? long.Parse(jsonObject["diseaseId"].ToString()) : null;
            var isReportClosed = jsonObject["isReportClosed"] != null && jsonObject["isReportClosed"].ToString() != string.Empty ? Convert.ToBoolean(jsonObject["isReportClosed"].ToString()) : false;

            DiseaseReportSymptomsPageViewModel symptomsSection = new DiseaseReportSymptomsPageViewModel();
            symptomsSection.caseClassficationDD = new Select2Configruation();
            symptomsSection.caseClassficationDD.ConfigureForPartial = true;
            symptomsSection.IsReportClosed = isReportClosed;
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
                if (detailResponse != null && detailResponse.Count > 0)
                {
                    symptomsSection.OutBreakSymptomsOnsetDate = detailResponse.FirstOrDefault().datOnSetDate;
                    symptomsSection.strCaseClassification = detailResponse.FirstOrDefault().InitialCaseStatus;
                    symptomsSection.idfCaseClassfication = detailResponse.FirstOrDefault().idfsInitialCaseStatus;
                    symptomsSection.blnInitialSSD = detailResponse.FirstOrDefault().blnInitialSSD;
                    symptomsSection.blnFinalSSD = detailResponse.FirstOrDefault().blnFinalSSD;
                    if (detailResponse.FirstOrDefault().CaseProgressStatus == VeterinaryDiseaseReportStatusTypes.Closed.ToString())
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

            symptomsSection.HumanDiseaseSymptoms = new FlexFormQuestionnaireGetRequestModel();
            symptomsSection.HumanDiseaseSymptoms.idfsFormType = (long?)FlexFormType.HumanCaseQuestionnaire;
            symptomsSection.HumanDiseaseSymptoms.idfsDiagnosis = null;
            symptomsSection.HumanDiseaseSymptoms.idfObservation = null;
            symptomsSection.HumanDiseaseSymptoms.ObserationFieldID = "idfCaseObservationSymptoms";
            symptomsSection.HumanDiseaseSymptoms.SubmitButtonID = "btnDummy";
            symptomsSection.HumanDiseaseSymptoms.LangID = GetCurrentLanguage();
            symptomsSection.HumanDiseaseSymptoms.Title = _localizer.GetString(FieldLabelResourceKeyConstants.CreateHumanCaseListofSymptomsFieldLabel);
            symptomsSection.HumanDiseaseSymptoms.CallbackFunction = "getFlexFormAnswers10034501();";
            symptomsSection.HumanDiseaseSymptoms.CallbackErrorFunction = "SaveHDR();";

            if (isEdit && idfHumanCase != 0 && idfHumanCase != null && detailResponse != null && detailResponse.Count > 0)
                symptomsSection.HumanDiseaseSymptoms.idfObservation = detailResponse.FirstOrDefault().idfCSObservation;
            if (diseaseId != null && diseaseId != 0)
            {
                symptomsSection.HumanDiseaseSymptoms.idfsDiagnosis = diseaseId;
            }

            return PartialView("_DiseaseReportSymptomsPartial", symptomsSection);
        }

        public async Task<DiseaseReportNotificationPageViewModel> LoadNotification(bool isEdit = false)
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
            notificationSection.EmployeeDetails = new ViewModels.Administration.EmployeePersonalInfoPageViewModel();
            notificationSection.EmployeeDetails.PersonalIdTypeDD = new Select2Configruation();
            notificationSection.EmployeeDetails.DepartmentDD = new Select2Configruation();
            notificationSection.EmployeeDetails.eIDSSModalConfiguration = new List<EIDSSModalConfiguration>();
            notificationSection.EmployeeDetails.EmployeeCategoryList = new List<BaseReferenceViewModel>();
            notificationSection.EmployeeDetails.OrganizationDD = new Select2Configruation();
            notificationSection.EmployeeDetails.PositionDD = new Select2Configruation();
            notificationSection.EmployeeDetails.SiteDD = new Select2Configruation();
            UserPermissions employeeuserPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);
            notificationSection.EmployeeDetails.CanManageReferencesandConfiguratuionsPermission = employeeuserPermissions;
            UserPermissions userAccountsuserPermissions = GetUserPermissions(PagePermission.CanManageUserAccounts);
            notificationSection.EmployeeDetails.UserPermissions = userAccountsuserPermissions;
            var CanAccessOrganizationsList = GetUserPermissions(PagePermission.CanAccessOrganizationsList);
            notificationSection.EmployeeDetails.CanAccessOrganizationsList = CanAccessOrganizationsList;

            if (isEdit && detailResponse != null && detailResponse.Count > 0)
            {
                var detailRecord = detailResponse.FirstOrDefault();

                notificationSection.dateOfCompletion = detailRecord.datCompletionPaperFormDate;

                notificationSection.localIdentifier = detailRecord.strLocalIdentifier;

                notificationSection.idfDisease = detailRecord.idfsFinalDiagnosis;
                notificationSection.strDisease = detailRecord.strFinalDiagnosis;

                notificationSection.dateOfDiagnosis = detailRecord.datDateOfDiagnosis;

                notificationSection.dateOfNotification = detailRecord.datNotificationDate;

                notificationSection.idfNotificationSentByFacility = detailRecord.idfSentByOffice;
                notificationSection.strNotificationSentByFacility = detailRecord.SentByOffice;
                notificationSection.idfNotificationSentByName = detailRecord.idfSentByPerson;
                notificationSection.strNotificationSentByName = detailRecord.SentByPerson;

                notificationSection.idfNotificationReceivedByFacility = detailRecord.idfReceivedByOffice;
                notificationSection.strNotificationReceivedByFacility = detailRecord.ReceivedByOffice;
                notificationSection.idfNotificationReceivedByName = detailRecord.idfReceivedByPerson;
                notificationSection.strNotificationReceivedByName = detailRecord.ReceivedByPerson;

                notificationSection.idfStatusOfPatient = detailRecord.idfsFinalState;
                notificationSection.strStatusOfPatient = detailRecord.PatientStatus;

                notificationSection.idfHospitalName = detailRecord.idfHospital;
                notificationSection.strHospitalName = detailRecord.HospitalName;

                notificationSection.idfCurrentLocationOfPatient = detailRecord.idfsHospitalizationStatus;
                notificationSection.strCurrentLocationOfPatient = detailRecord.HospitalizationStatus;

                notificationSection.strOtherLocation = detailRecord.strCurrentLocation;

                if (detailRecord.CaseProgressStatus == VeterinaryDiseaseReportStatusTypes.Closed.ToString())
                {
                    notificationSection.IsReportClosed = true;
                }
            }
            return notificationSection;
        }

        [Route("CheckAgeAndValidateDiseaseCase")]
        [HttpPost]

        public async Task<bool> CheckAgeAndValidateDiseaseCase([FromBody] JsonElement data)
        {
            return false;
        }

        public async Task<DiseaseReportFacilityDetailsPageViewModel> LoadFacilityDetails(bool isEdit = false)
        {
            DiseaseReportFacilityDetailsPageViewModel facilityDetailsSection = new DiseaseReportFacilityDetailsPageViewModel();
            facilityDetailsSection.HospitalSelect = new();
            facilityDetailsSection.DiagnosisSelect = new();
            facilityDetailsSection.FacilitySelect = new();
            facilityDetailsSection.IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed;

            //get the yes/no choices for radio buttons
            var list = await _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.YesNoValueList, HACodeList.HumanHACode);
            facilityDetailsSection.YesNoChoices = list;

            //set some defaults
            facilityDetailsSection.PatientPreviouslySoughtCare = Convert.ToInt64(YesNoUnknown.No);
            facilityDetailsSection.Hospitalized = Convert.ToInt64(YesNoUnknown.No);

            if (detailResponse != null && detailResponse.Count > 0)
            {
                var detail = detailResponse.FirstOrDefault();
                if (detail != null)
                {
                    //get the dates from other sections used for comparison
                    //populate the model for edit
                    if (isEdit)
                    {
                        //sought care?
                        facilityDetailsSection.PatientPreviouslySoughtCare = detail.idfsYNPreviouslySoughtCare;
                        facilityDetailsSection.SoughtCareFacilityID = detail.idfSoughtCareFacility;
                        facilityDetailsSection.FacilitySelect.defaultSelect2Selection = new Select2DataItem() { id = detail.idfSoughtCareFacility.ToString(), text = detail.strSoughtCareFacility };
                        facilityDetailsSection.SoughtCareFirstDate = detail.datFirstSoughtCareDate;
                        facilityDetailsSection.NonNotifiableDiseaseID = detail.idfsNonNotifiableDiagnosis;
                        facilityDetailsSection.DiagnosisSelect.defaultSelect2Selection = new Select2DataItem() { id = detail.idfsNonNotifiableDiagnosis.ToString(), text = detail.stridfsNonNotifiableDiagnosis };

                        //hospitalized?
                        facilityDetailsSection.Hospitalized = detail.idfsYNHospitalization;
                        facilityDetailsSection.HospitalID = detail.idfHospital;
                        facilityDetailsSection.HospitalSelect.defaultSelect2Selection = new Select2DataItem() { id = detail.idfHospital.ToString(), text = detail.HospitalName };
                        facilityDetailsSection.OutbreakHospitalizationDate = detail.datHospitalizationDate;
                        facilityDetailsSection.IsOutbreak = true;
                        facilityDetailsSection.DateOfDischarge = detail.datDischargeDate;
                    }
                }
            }
            return facilityDetailsSection;
        }

        public async Task<DiseaseReportAntibioticVaccineHistoryPageViewModel> LoadAntibioticVaccineHistoryDetails(bool isEdit = false)
        {
            DiseaseReportAntibioticVaccineHistoryPageViewModel antibioticVaccineHistoryDetailsSection = new DiseaseReportAntibioticVaccineHistoryPageViewModel();
            antibioticVaccineHistoryDetailsSection.IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed;
            antibioticVaccineHistoryDetailsSection.antibioticsHistory = new List<DiseaseReportAntiviralTherapiesViewModel>();
            antibioticVaccineHistoryDetailsSection.vaccinationHistory = new List<DiseaseReportVaccinationViewModel>();

            if (isEdit && detailResponse != null && detailResponse.Count > 0)
            {
                antibioticVaccineHistoryDetailsSection.idfsYNAntimicrobialTherapy = detailResponse.FirstOrDefault().idfsYNAntimicrobialTherapy;
                antibioticVaccineHistoryDetailsSection.idfsYNSpecificVaccinationAdministered = detailResponse.FirstOrDefault().idfsYNSpecificVaccinationAdministered;
                HumanAntiviralTherapiesAndVaccinationRequestModel request = new HumanAntiviralTherapiesAndVaccinationRequestModel();
                request.idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase;
                request.LangID = GetCurrentLanguage();

                var antiViralTherapiesReponse = await _humanDiseaseReportClient.GetAntiviralTherapisListAsync(request);
                var vaccinationResponse = await _humanDiseaseReportClient.GetVaccinationListAsync(request);

                antibioticVaccineHistoryDetailsSection.antibioticsHistory = antiViralTherapiesReponse;
                antibioticVaccineHistoryDetailsSection.vaccinationHistory = vaccinationResponse;
                antibioticVaccineHistoryDetailsSection.AdditionalInforMation = detailResponse.FirstOrDefault().strClinicalNotes;
            }

            return antibioticVaccineHistoryDetailsSection;
        }

        public async Task<DiseaseReportCaseInvestigationPageViewModel> LoadCaseInvestigationDetails(bool isEdit = false)
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

            if (isEdit && detailResponse != null && detailResponse.Count > 0)
            {
                var detailRecord = detailResponse.FirstOrDefault();
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
                exposureLocationAddress.Elevation = detailRecord.dblPointElevation != null ? Convert.ToInt32(detailRecord.dblPointElevation) : (int?)null;
                //1345550000000
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
            DiseaseReportSamplePageViewModel diseaseReportSamplePageViewModelSection = new();
            diseaseReportSamplePageViewModelSection.idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase;
            diseaseReportSamplePageViewModelSection.strCaseId = _diseaseReportComponentViewModel.strCaseId;
            diseaseReportSamplePageViewModelSection.YesNoChoices = new();
            diseaseReportSamplePageViewModelSection.idfDisease = diseaseId;
            diseaseReportSamplePageViewModelSection.AddSampleModel = new DiseaseReportSamplePageSampleDetailViewModel();
            diseaseReportSamplePageViewModelSection.AddSampleModel.idfDisease = diseaseId;
            diseaseReportSamplePageViewModelSection.SamplesDetails = new();
            diseaseReportSamplePageViewModelSection.IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed;

            diseaseReportSamplePageViewModelSection.Permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportClinicalInformation);

            if (isEdit && detailResponse != null && detailResponse.Count > 0)
            {
                var _ = detailResponse.FirstOrDefault();
                if (_ != null)
                {
                    diseaseReportSamplePageViewModelSection.AddSampleModel.SymptomsOnsetDate = _.datOnSetDate;
                    diseaseReportSamplePageViewModelSection.SamplesCollectedYN = _.idfsYNSpecimenCollected;
                    diseaseReportSamplePageViewModelSection.SamplesDetails = new();


                    var request = new HumanDiseaseReportSamplesRequestModel()
                    {
                        idfHumanCase = _.idfHumanCase,
                        LangID = GetCurrentLanguage()
                    };
                    var list = await _humanDiseaseReportClient.GetHumanDiseaseReportSamplesListAsync(request);
                    List<DiseaseReportSamplePageSampleDetailViewModel> samplesDetailList = new List<DiseaseReportSamplePageSampleDetailViewModel>();
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
                            strBarcode = item.strBarcode, //TODO - not available from stored proc
                            LocalSampleId = item.strFieldBarcode, //TODO - not available from stored proc
                            SampleConditionRecieved = item.strCondition,
                            SampleKey = item.idfMaterial.GetValueOrDefault(),
                            SampleType = item.strSampleTypeName,
                            SampleTypeID = item.idfsSampleType,
                            SentDate = item.datFieldSentDate,
                            SentToOrganization = item.strSendToOffice,
                            SentToOrganizationID = item.idfSendToOffice,
                            SymptomsOnsetDate = _.datOnSetDate,
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

            if (isEdit && detailResponse != null && detailResponse.Count > 0)
            {
                var _ = detailResponse.FirstOrDefault();
                if (_ != null)
                {
                    diseaseReportTestsPageViewModelSection.TestsConducted = _.idfsYNTestsConducted;
                    diseaseReportTestsPageViewModelSection.TestDetails = new();
                    var request = new HumanTestListRequestModel()
                    {
                        idfHumanCase = _.idfHumanCase,
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
                        idfHumanCase = _.idfHumanCase,
                        LangID = GetCurrentLanguage()
                    };

                    var sampleList = await _humanDiseaseReportClient.GetHumanDiseaseReportSamplesListAsync(samplerequest);
                    List<DiseaseReportSamplePageSampleDetailViewModel> samplesDetailList = new List<DiseaseReportSamplePageSampleDetailViewModel>();
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
                            strBarcode = item.strBarcode, //TODO - not available from stored proc
                            LocalSampleId = item.strFieldBarcode, //TODO - not available from stored proc
                            SampleConditionRecieved = item.strCondition,
                            SampleKey = item.idfMaterial.GetValueOrDefault(),
                            SampleType = item.strSampleTypeName,
                            SampleTypeID = item.idfsSampleType,
                            SentDate = item.datFieldSentDate,
                            SentToOrganization = item.strSendToOffice,
                            SentToOrganizationID = item.idfSendToOffice,
                            SymptomsOnsetDate = _.datOnSetDate,
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
            }

            return diseaseReportTestsPageViewModelSection;
        }

        public async Task<DiseaseReportCaseInvestigationRiskFactorsPageViewModel> LoadCaseInvestigationRiskFactors(
                DiseaseReportCaseInvestigationRiskFactorsPageViewModel riskFactorsSection,
                bool isEdit = false, long? idfsFormTemplate = null, long? idfObservation = null)
        {
            if (idfsFormTemplate != null)
            {
                riskFactorsSection = new DiseaseReportCaseInvestigationRiskFactorsPageViewModel();
                riskFactorsSection.RiskFactors = new FlexFormQuestionnaireGetRequestModel();
                riskFactorsSection.RiskFactors.idfsFormType = (long?)FlexFormType.HumanCaseQuestionnaire;
                riskFactorsSection.RiskFactors.idfsFormTemplate = idfsFormTemplate;
                riskFactorsSection.RiskFactors.idfObservation = isEdit ? idfObservation : null;
                riskFactorsSection.RiskFactors.SubmitButtonID = "btnDummy";
                riskFactorsSection.RiskFactors.LangID = GetCurrentLanguage();
                riskFactorsSection.RiskFactors.Title = _localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportRiskFactorsListofRiskFactorsHeading);
                riskFactorsSection.RiskFactors.CallbackFunction = "SaveHDR();";
                riskFactorsSection.RiskFactors.ObserationFieldID = "idfCaseObservationRiskFactors";
            }
            else
            {
                riskFactorsSection = new DiseaseReportCaseInvestigationRiskFactorsPageViewModel();
            }

            return riskFactorsSection;
        }

        public async Task<IActionResult> ReloadRiskFactors()
        {

        DiseaseReportCaseInvestigationRiskFactorsPageViewModel riskFactorsSection = new DiseaseReportCaseInvestigationRiskFactorsPageViewModel();
            riskFactorsSection.RiskFactors = new FlexFormQuestionnaireGetRequestModel();
            riskFactorsSection.IsReportClosed = IsbSessionClosed;
            riskFactorsSection.RiskFactors.idfsFormType = (long?)FlexFormType.HumanCaseQuestionnaire;
            riskFactorsSection.RiskFactors.idfsFormTemplate = CaseQuestionnaireTemplateID;
            riskFactorsSection.RiskFactors.idfObservation = IsEdit? CaseEPIObservationID : null;
            riskFactorsSection.RiskFactors.SubmitButtonID = "btnDummy";
            riskFactorsSection.RiskFactors.LangID = GetCurrentLanguage();
            riskFactorsSection.RiskFactors.Title = _localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportRiskFactorsListofRiskFactorsHeading);
            riskFactorsSection.RiskFactors.CallbackFunction = "SaveHDR();";
            riskFactorsSection.RiskFactors.ObserationFieldID = "idfCaseObservationRiskFactors";

            return PartialView("_DiseaseReportRiskFactorsPartial", riskFactorsSection);
        }

        public async Task<DiseaseReportContactListPageViewModel> LoadContactList(long? diseaseId, bool isEdit = false)
        {
            DiseaseReportContactListPageViewModel contactListSection = _diseaseReportComponentViewModel.ContactListSection;
            contactListSection.ContactDetails = new List<DiseaseReportContactDetailsViewModel>();
            contactListSection.IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed;
            contactListSection.HumanActualID = _diseaseReportComponentViewModel.HumanActualID;
            if (isEdit)
            {
                contactListSection.idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase;
                contactListSection.HumanID = _diseaseReportComponentViewModel.HumanID;
                HumanDiseaseContactListRequestModel request = new HumanDiseaseContactListRequestModel();
                request.idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase;
                request.LangId = GetCurrentLanguage();
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

        public List<BaseReferenceViewModel> GetRadioButtonChoicesAsync()
        {
            //get the yes/no choices for radio buttons
            List<BaseReferenceViewModel> YesNoChoices = _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.YesNoValueList, EIDSSConstants.HACodeList.HumanHACode).Result;
            return YesNoChoices;
        }

        public List<BaseReferenceViewModel> GetExposureLocation()
        {
            //get the yes/no choices for radio buttons
            List<BaseReferenceViewModel> GeoLocationList = _crossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.GeoLocationType, EIDSSConstants.HACodeList.HumanHACode).Result;
            return GeoLocationList;
        }

        public async Task<JsonResult> GetInitalCaseClassification(int page, string data, string term)
        {
            List<Select2DataItem> select2DataItems = new();
            Select2DataResults select2DataObj = new();
            HumanDiseaseReportLkupCaseClassificationRequestModel request = new HumanDiseaseReportLkupCaseClassificationRequestModel();
            request.LangID = GetCurrentLanguage();

            try
            {
                var list = await _humanDiseaseReportClient.GetHumanDiseaseReportLkupCaseClassificationAsync(request);

                if (list != null)
                {
                    foreach (var item in list)
                    {
                        if (item.blnInitialHumanCaseClassification)
                        {
                            select2DataItems.Add(new Select2DataItem() { id = item.idfsCaseClassification.ToString(), text = item.strDefault });
                        }
                    }
                }
                select2DataObj.results = select2DataItems;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return Json(select2DataObj);
        }

        [HttpGet]
        public async Task<bool> UpdateInvestigatingOrgForFinalOutcome(DiseaseReportCaseInvestigationPageViewModel data)
        {
            try
            {

            }
            catch (Exception ex)
            {
                throw;
            }

            return true;
        }

        public async Task<DiseaseReportFinalOutcomeViewModel> LoadFinalOutComeDetails(long? diseaseId, bool isEdit = false)
        {
            DiseaseReportFinalOutcomeViewModel diseaseReportFinalOutcomeViewModelSection = new();
            diseaseReportFinalOutcomeViewModelSection.idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase;
            diseaseReportFinalOutcomeViewModelSection.strCaseId = _diseaseReportComponentViewModel.strCaseId;

            diseaseReportFinalOutcomeViewModelSection.idfDisease = diseaseId;
            diseaseReportFinalOutcomeViewModelSection.Permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportClinicalInformation);

            diseaseReportFinalOutcomeViewModelSection.IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed;
            diseaseReportFinalOutcomeViewModelSection.idfInvestigatedByOffice = _diseaseReportComponentViewModel.CaseInvestigationSection.idfInvestigatedByOffice;
            if (isEdit && detailResponse != null && detailResponse.Count > 0)
            {
                var _ = detailResponse.FirstOrDefault();
                if (_ != null)
                {
                    diseaseReportFinalOutcomeViewModelSection.blnInitialSSD = _.blnInitialSSD;
                    diseaseReportFinalOutcomeViewModelSection.blnFinalSSD = _.blnFinalSSD;
                    diseaseReportFinalOutcomeViewModelSection.idfsFinalCaseStatus = _.idfsFinalCaseStatus;
                    diseaseReportFinalOutcomeViewModelSection.idfsOutCome = _.idfsOutCome;
                    diseaseReportFinalOutcomeViewModelSection.idfInvestigatedByPerson = _.idfInvestigatedByPerson;
                    diseaseReportFinalOutcomeViewModelSection.strEpidemiologistsName = _.strEpidemiologistsName;
                    diseaseReportFinalOutcomeViewModelSection.blnLabDiagBasis = _.blnLabDiagBasis;
                    diseaseReportFinalOutcomeViewModelSection.blnClinicalDiagBasis = _.blnClinicalDiagBasis;
                    diseaseReportFinalOutcomeViewModelSection.blnEpiDiagBasis = _.blnEpiDiagBasis;
                    diseaseReportFinalOutcomeViewModelSection.datFinalCaseClassificationDate = _.datFinalCaseClassificationDate;
                    diseaseReportFinalOutcomeViewModelSection.datDateOfDeath = _.datDateOfDeath;
                    diseaseReportFinalOutcomeViewModelSection.Comments = _.strSummaryNotes;
                }
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
            if (response.FirstOrDefault() != null)
            {
                var humanId = response.FirstOrDefault().idfHuman;
                var caseId = response.FirstOrDefault().idfHumanCase;

                return RedirectToAction("LoadDiseaseReport", new { humanId = humanId, caseId = caseId, isEdit = true, readOnly = false });
            }

            return View("Index");
        }

        [HttpPost()]
        [Route("SaveHumanCase")]
        public async Task<IActionResult> SaveHumanCase([FromBody] JsonElement data)
        {
            try
            {
                OutbreakCaseCreateRequestModel request = new OutbreakCaseCreateRequestModel();
                OutbreakCaseSaveResponseModel response = new OutbreakCaseSaveResponseModel();

                //General--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                request.LangID = GetCurrentLanguage();
                request.intRowStatus = 0;
                request.User = _authenticatedUser.UserName;

                //Outbreak Case Details------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                request.OutbreakCaseReportUID = (long?) GetJsonValue(data, "OutbreakCaseReportUID", DataType.Long);
                request.idfOutbreak = (long?) GetJsonValue(data, "idfOutbreak", DataType.Long);
                request.idfHumanCase = (long?) GetJsonValue(data, "idfHumanCase", DataType.Long);

                //Human Disease related items for creation-----------------------------------------------------------------------------------------------------------------------------------------------------
                request.idfHumanActual = (long?) GetJsonValue(data, "idfHumanActual", DataType.Long);
                request.idfsDiagnosisOrDiagnosisGroup =
                    (long?) GetJsonValue(data, "idfsDiagnosisOrDiagnosisGroup", DataType.Long);

                //Notification Section (Outbreak/Human)--------------------------------------------------------------------------------------------------------------------------------------------------------
                request.datNotificationDate = (DateTime?) GetJsonValue(data, "datNotificationDate", DataType.DateTime);
                request.idfSentByOffice = (long?) GetJsonValue(data, "notificationSentByFacilityDD", DataType.Long);
                request.idfSentByPerson = (long?) GetJsonValue(data, "notificationSentByNameDD", DataType.Long);
                request.idfReceivedByOffice =
                    (long?) GetJsonValue(data, "notificationReceivedByFacilityDD", DataType.Long);
                request.idfReceivedByPerson = (long?) GetJsonValue(data, "notificationReceivedByNameDD", DataType.Long);

                //Case Location--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                LocationViewModel location = new LocationViewModel();
                location.AdminLevel0Value = long.Parse(CountryId);
                location.AdminLevel1Value = (long?) GetJsonValue(data, "AdminLevel1Value", DataType.Long);
                location.AdminLevel2Value = (long?) GetJsonValue(data, "AdminLevel2Value", DataType.Long);
                location.AdminLevel3Value = (long?) GetJsonValue(data, "AdminLevel3Value", DataType.Long);
                location.AdminLevel4Value = (long?) GetJsonValue(data, "AdminLevel4Value", DataType.Long);
                location.AdminLevel5Value = (long?) GetJsonValue(data, "AdminLevel5Value", DataType.Long);
                location.AdminLevel6Value = (long?) GetJsonValue(data, "AdminLevel6Value", DataType.Long);

                request.CaseGeoLocationID = (long?) GetJsonValue(data, "idfGeoLocation", DataType.Long);
                request.CaseidfsLocation = Common.GetLocationId(location);
                request.CasestrStreetName = GetJsonValue(data, "Street", DataType.String).ToString();
                request.CasestrApartment = GetJsonValue(data, "Apartment", DataType.String).ToString();
                request.CasestrBuilding = GetJsonValue(data, "Building", DataType.String).ToString();
                request.CasestrHouse = GetJsonValue(data, "House", DataType.String).ToString();
                request.CaseidfsPostalCode = GetJsonValue(data, "PostalCode", DataType.String).ToString();
                request.CasestrLatitude = (double?) GetJsonValue(data, "intLocationLatitude", DataType.Double);
                request.CasestrLongitude = (double?) GetJsonValue(data, "intLocationLongitude", DataType.Double);

                var jsonObject = JObject.Parse(data.ToString());

                //Clinical Information-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                request.CaseStatusID = (long?) GetJsonValue(data, "CaseStatusID", DataType.Long);
                request.datOnSetDate = (DateTime?) GetJsonValue(data, "SymptomsOnsetDate", DataType.DateTime);
                request.datFinalDiagnosisDate =
                    (DateTime?) GetJsonValue(data, "datFinalDiagnosisDate", DataType.DateTime);
                request.idfHospital = (long?) GetJsonValue(data, "idfHospital", DataType.Long);
                request.datHospitalizationDate =
                (DateTime?)GetJsonValue(data, "datOutbreakHospitalizationDate", DataType.DateTime);
                request.datDischargeDate = (DateTime?) GetJsonValue(data, "datDischargeDate", DataType.DateTime);
                request.Antimicrobials = JsonConvert.SerializeObject(
                    JObject.Parse(jsonObject["vaccionationAntiViralTherapies"].ToString())["antibioticsHistory"]);
                request.vaccinations = JsonConvert.SerializeObject(
                    JObject.Parse(jsonObject["vaccionationAntiViralTherapies"].ToString())["vaccinationHistory"]);
                request.strClinicalNotes = GetJsonValue(data, "additionalInforMation", DataType.String).ToString();
                request.idfsYNHospitalization = (long?) GetJsonValue(data, "idfsYNHospitalization", DataType.Long);
                request.idfsYNAntimicrobialTherapy =
                    (long?) GetJsonValue(data, "idfsYNAntimicrobialTherapy", DataType.Long);
                request.idfsYNSpecIFicVaccinationAdministered =
                    (long?) GetJsonValue(data, "idfsYNSpecificVaccinationAdministered", DataType.Long);
                request.idfCSObservation = (long?) GetJsonValue(data, "idfCSObservation", DataType.Long);

                //Outbreak Investigation-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
                request.idfInvestigatedByOffice = (long?) GetJsonValue(data, "idfInvestigatedByOffice", DataType.Long);
                request.idfInvestigatedByPerson = (long?) GetJsonValue(data, "idfInvestigatedByPerson", DataType.Long);
                request.StartDateofInvestigation =
                    (DateTime?) GetJsonValue(data, "datInvestigationStartDate", DataType.DateTime);
                request.OutbreakCaseClassificationID =
                    (long?) GetJsonValue(data, "OutbreakCaseClassificationID", DataType.Long);
                request.IsPrimaryCaseFlag =
                    GetJsonValue(data, "isPrimaryCaseFlag", DataType.String).ToString() == "True" ? "t" : "f";
                request.strNote = GetJsonValue(data, "strNote", DataType.String).ToString();
                request.OutbreakCaseObservationID = (long?) GetJsonValue(data, "idfEpiObservation", DataType.Long);

                //Case Monitoring------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                if (jsonObject["caseMonitoringsModel"] != null && !string.IsNullOrEmpty(jsonObject["caseMonitoringsModel"].ToString()))
                {
                    var caseMonitoringsModel = jsonObject["caseMonitoringsModel"].ToString();
                    List<CaseMonitoringSaveRequestModel> caseMonitorings = new List<CaseMonitoringSaveRequestModel>();
                    CaseMonitoringSaveRequestModel caseMonitoring = new CaseMonitoringSaveRequestModel();

                    foreach (JObject item in JArray.Parse(caseMonitoringsModel))
                    {
                        caseMonitoring = new CaseMonitoringSaveRequestModel();

                        caseMonitoring.CaseMonitoringID = (long) GetJsonValue(item, "caseMonitoringId", DataType.Long);
                        caseMonitoring.ObservationID = (long?) GetJsonValue(item, "observationId", DataType.Long);
                        caseMonitoring.InvestigatedByOrganizationID =
                            (long?) GetJsonValue(item, "investigatedByOrganizationId", DataType.Long);
                        caseMonitoring.InvestigatedByPersonID =
                            (long?) GetJsonValue(item, "investigatedByPersonId", DataType.Long);
                        caseMonitoring.MonitoringDate =
                            (DateTime?) GetJsonValue(item, "monitoringDate", DataType.DateTime);
                        caseMonitoring.RowStatus =
                            (int)GetJsonValue(item, "rowStatus", DataType.Int);
                        caseMonitoring.RowAction =
                            (int)GetJsonValue(item, "rowAction", DataType.Int);
                        caseMonitoring.AdditionalComments = GetJsonValue(item, "additionalComments", DataType.String).ToString();

                        caseMonitorings.Add(caseMonitoring);
                    }

                    request.CaseMonitorings = JsonConvert.SerializeObject(caseMonitorings);
                    request.Events = null;
                }

                //Contacts-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

                            var contactCount = 0;
                            var serContactModel = JsonConvert.SerializeObject(parsedContactModel);
                            request.CaseContacts = serContactModel;
                            foreach (var item in parsedContactModel)
                            {
                                contactItem = new ContactGetListViewModel();

                                contactItem.ContactedHumanCasePersonID = !string.IsNullOrEmpty(item["contactedHumanCasePersonID"].ToString()) && long.Parse(item["contactedHumanCasePersonID"].ToString()) != 0 ? long.Parse(item["contactedHumanCasePersonID"].ToString()) : null;
                                contactItem.HumanMasterID = long.Parse(item["humanMasterID"].ToString());
                                contactItem.ContactTypeID = !string.IsNullOrEmpty(item["contactTypeID"].ToString()) && long.Parse(item["contactTypeID"].ToString()) != 0 ? long.Parse(item["contactTypeID"].ToString()) : null;
                                contactItem.HumanID = !string.IsNullOrEmpty(item["humanID"].ToString()) && long.Parse(item["humanID"].ToString()) != 0 ? long.Parse(item["humanID"].ToString()) : null;
                                contactItem.DateOfLastContact = string.IsNullOrEmpty(item["dateOfLastContact"].ToString()) ? null : DateTime.Parse(item["dateOfLastContact"].ToString());
                                contactItem.PlaceOfLastContact = !string.IsNullOrEmpty(item["placeOfLastContact"].ToString()) ? item["placeOfLastContact"].ToString() : null;
                                contactItem.ContactRelationshipTypeID = !string.IsNullOrEmpty(item["contactRelationshipTypeID"].ToString()) && long.Parse(item["contactRelationshipTypeID"].ToString()) != 0 ? long.Parse(item["contactRelationshipTypeID"].ToString()) : null;
                                contactItem.Comment = !string.IsNullOrEmpty(item["comment"].ToString()) ? item["comment"].ToString() : null;
                                contactItem.ContactTracingObservationID = !string.IsNullOrEmpty(item["contactTracingObservationID"].ToString()) && long.Parse(item["contactTracingObservationID"].ToString()) != 0 ? long.Parse(item["contactTracingObservationID"].ToString()) : null;
                                contactItem.ContactStatusID = !string.IsNullOrEmpty(item["contactStatusID"].ToString()) && long.Parse(item["contactStatusID"].ToString()) != 0 ? long.Parse(item["contactStatusID"].ToString()) : null;
                                contactItem.CaseContactID = long.Parse(item["caseContactID"].ToString());
                                contactItem.RowAction = int.Parse(item["rowAction"].ToString());
                                contactItem.RowStatus = int.Parse(item["rowStatus"].ToString());

                                contactList.Add(contactItem);
                            }

                            request.CaseContacts = System.Text.Json.JsonSerializer.Serialize(contactList);
                        }
                    }
                }

                //Samples--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                long lSiteID = 1;
                var sampleDetails = JObject.Parse(jsonObject["sampleModel"].ToString())["samplesDetails"];
                List<SampleSaveRequestModel> samples = new List<SampleSaveRequestModel>();

                foreach (var item in sampleDetails)
                {
                    SampleSaveRequestModel Sample = new SampleSaveRequestModel();
                    Sample.SampleTypeID =
                        !string.IsNullOrEmpty(item["sampleTypeID"].ToString()) &&
                        long.Parse(item["sampleTypeID"].ToString()) != 0
                            ? long.Parse(item["sampleTypeID"].ToString())
                            : null;
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
                request.idfsYNSpecimenCollected = (long?) GetJsonValue(data, "idfsYNSpecimenCollected", DataType.Long);

                //Tests----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                request.idfsYNTestsConducted = (long?) GetJsonValue(data, "idfsYNTestsConducted", DataType.Long);

                var testDetails = JObject.Parse(jsonObject["testModel"].ToString())["testDetails"];

                List<LaboratoryTestSaveRequestModel> tests = new List<LaboratoryTestSaveRequestModel>();
                List<LaboratoryTestInterpretationSaveRequestModel> testInterpretations =
                    new List<LaboratoryTestInterpretationSaveRequestModel>();

                var count = 0;
                foreach (var item in testDetails)
                {
                    LaboratoryTestSaveRequestModel testRequest = new LaboratoryTestSaveRequestModel();
                    LaboratoryTestInterpretationSaveRequestModel interpretationRequest =
                        new LaboratoryTestInterpretationSaveRequestModel();
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
                        count = count + 1;
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
                        !string.IsNullOrEmpty(item["blnNonLaboratoryTest"].ToString())
                            ? Convert.ToBoolean(item["blnNonLaboratoryTest"].ToString())
                            : false;

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
                        !string.IsNullOrEmpty(item["blnValidateStatus"].ToString())
                            ? Convert.ToBoolean(item["blnValidateStatus"].ToString())
                            : false;
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
                        returnValue = Double.Parse(value);
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
            HumanDiseaseReportDeleteRequestModel request = new HumanDiseaseReportDeleteRequestModel();
            var jsonObject = JObject.Parse(data.ToString());
            long? idfHumanCase = !string.IsNullOrEmpty(jsonObject["idfHumanCase"].ToString()) && long.Parse(jsonObject["idfHumanCase"].ToString()) != 0 ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            request.idfHumanCase = !string.IsNullOrEmpty(jsonObject["idfHumanCase"].ToString()) && long.Parse(jsonObject["idfHumanCase"].ToString()) != 0 ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            request.LangID = GetCurrentLanguage();
            var response = await _humanDiseaseReportClient.DeleteHumanDiseaseReport(idfHumanCase,Convert.ToInt64( _authenticatedUser.EIDSSUserId) , Convert.ToInt64(_authenticatedUser.SiteId),false);
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
                GenderForDiseaseOrDiagnosisGroupDiseaseMatrixGetRequestModel request = new GenderForDiseaseOrDiagnosisGroupDiseaseMatrixGetRequestModel();
                request.LanguageID = GetCurrentLanguage();
                request.DiseaseID = disease;
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

        //protected async Task OnHumanDiseaseReportCreation(long? siteID)
        //{
        //    try
        //    {
        //        var eventTypeId = Convert.ToInt64(_authenticatedUser.SiteId) == siteID
        //            ? SystemEventLogTypes.NEW_HUMAN_DISEASE_REPORT_CREATED_ATYOURSITE
        //            : SystemEventLogTypes.NEW_HUMAN_DISEASE_REPORT_CREATED_ATANOTHERSITE;

        //        if (_diseaseReportComponentViewModel.PendingSaveNotifications.All(x => x.NotificationTypeID != (long)eventTypeId))
        //            _diseaseReportComponentViewModel.PendingSaveNotifications.Add(await _notificationService.CreateNotification(0,
        //                ObjectTypeEnum.HumanDiseaseReport, eventTypeId, siteID.Value, null));
        //    }
        //    catch (Exception ex)
        //    {
        //        _logger.LogError(ex.Message, null);
        //        throw;
        //    }
        //}


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
        public async Task GetNeighboringSiteAlerts(long? siteID, SystemEventLogTypes eventTypeId)
        {
            var neighboringSiteList = await _notificationService.GetNeighboringSiteList(siteID);

            if (neighboringSiteList is {Count: > 0})
            {
                foreach (var item in neighboringSiteList)
                {
                    _notificationService.Events ??= new List<EventSaveRequestModel>();
                    _notificationService.Events.Add(await _notificationService.CreateEvent(0,
                        _diseaseReportComponentViewModel.DiseaseReport.DiseaseID, eventTypeId, item.SiteID.Value, null));
                }
            }
        }
    }
}
