﻿using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
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
using Radzen;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components
{
    [ViewComponent(Name = "DiseaseReport")]
    [Area("Human")]
    public class DiseaseReportController : BaseController
    {
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
        private readonly IDiseaseAgeGroupMatrixClient _diseaseAgeGroupClient;
        private readonly IAdminClient _adminClient;
        private readonly IPersonClient _personClient;

        public string CurrentLanguage { get; set; }

        public DiseaseReportController(
            ICrossCuttingClient crossCuttingClient,
            IConfiguration configuration,
            IHumanDiseaseReportClient humanDiseaseReportClient,
            ITokenService tokenService,
            ILogger<DiseaseReportController> logger,
            IStringLocalizer localizer,
            IDiseaseHumanGenderMatrixClient diseaseHumanGenderMatrixClient,
            IDiseaseAgeGroupMatrixClient diseaseAgeGroupClient,
            IAdminClient adminClient,
            INotificationSiteAlertService notificationService,
            IHttpContextAccessor httpContextAccessor,
            IPersonClient personClient)
            : base(logger, tokenService)
        {
            _httpContextAccessor = httpContextAccessor;
            _crossCuttingClient = crossCuttingClient;
            _humanDiseaseReportClient = humanDiseaseReportClient;
            _notificationService = notificationService;
            _configuration = configuration;
            _localizer = localizer;
            _diseaseHumanGenderMatrixClient = diseaseHumanGenderMatrixClient;
            _diseaseAgeGroupClient = diseaseAgeGroupClient;
            _adminClient = adminClient;
            _personClient = personClient;

            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");

            CurrentLanguage = cultureInfo.Name;
        }

        public async Task<IViewComponentResult> InvokeAsync(DiseaseReportComponentViewModel diseaseReportComponentViewModel)
        {
            _httpContextAccessor.HttpContext.Response.Cookies.Delete("HDRNotifications");
            _diseaseReportComponentViewModel = diseaseReportComponentViewModel;
            var deletePermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
            var CanReopenClosedReport = GetUserPermissions(PagePermission.CanReopenClosedHumanDiseaseReportSession);

            _diseaseReportComponentViewModel.isDeleteEnabled = deletePermissions.Delete;
            _diseaseReportComponentViewModel.IsSaveEnabled = _diseaseReportComponentViewModel.idfHumanCase > 0 ? deletePermissions.Write : deletePermissions.Create;

            try
            {
                //Summary Section
                _diseaseReportComponentViewModel.ReportSummary ??= new DiseaseReportSummaryPageViewModel();

                HumanPersonDetailsRequestModel request = new();
                HumanPersonDetailsFromHumanIDRequestModel requestID = new();
                List<DiseaseReportPersonalInformationViewModel> response = new();
                if (!_diseaseReportComponentViewModel.isEdit)
                {
                    request.LangID = GetCurrentLanguage();
                    request.HumanMasterID = _diseaseReportComponentViewModel.HumanActualID;
                    response = await _humanDiseaseReportClient.GetHumanDiseaseReportPersonInfoAsync(request);
                    if (response != null && response.Count > 0)
                    {
                        var personInfo = response.FirstOrDefault();
                        _diseaseReportComponentViewModel.ReportSummary.PersonID = personInfo.EIDSSPersonID;
                        _diseaseReportComponentViewModel.ReportSummary.PersonName = personInfo.PatientFarmOwnerName;

                        _diseaseReportComponentViewModel.ReportSummary.IdfSessionID = diseaseReportComponentViewModel.idfParentMonitoringSession;

                        CultureInfo currentCulture = CultureInfo.CurrentCulture;
                        CultureInfo.CurrentCulture = CultureInfo.GetCultureInfo(GetCurrentLanguage());
                        _diseaseReportComponentViewModel.ReportSummary.DateEntered = DateTime.Now;
                        CultureInfo.CurrentCulture = currentCulture;

                        _diseaseReportComponentViewModel.ReportSummary.EnteredBy = _authenticatedUser.LastName + ", " + _authenticatedUser.FirstName;
                        _diseaseReportComponentViewModel.ReportSummary.idfPersonEnteredBy = long.Parse(_authenticatedUser.PersonId);
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
                        SortColumn = "idfHumanCase",
                        SortOrder = SortConstants.Ascending
                    };
                    detailResponse = await _humanDiseaseReportClient.GetHumanDiseaseDetail(detailRequest);

                    _diseaseReportComponentViewModel.CaseDisabled = detailResponse.idfOutbreak != null;

                    if (detailResponse != null)
                    {
                        _diseaseReportComponentViewModel.isPrintEnabled = true;
                        var humanDiseaseDetail = detailResponse;
                        _diseaseReportComponentViewModel.idfsSite = humanDiseaseDetail.idfsSite;

                        // Filtration
                        if (humanDiseaseDetail.idfsSite != Convert.ToInt64(_authenticatedUser.SiteId))
                        {
                            var permissionsRequest = new RecordPermissionsGetRequestModel
                            {
                                LanguageId = GetCurrentLanguage(),
                                RecordID = Convert.ToInt64(_diseaseReportComponentViewModel.idfHumanCase),
                                UserEmployeeID = Convert.ToInt64(_authenticatedUser.PersonId),
                                UserOrganizationID = Convert.ToInt64(_authenticatedUser.OfficeId),
                                UserSiteID = Convert.ToInt64(_authenticatedUser.SiteId)
                            };
                            var diseaseReport = await _humanDiseaseReportClient.GetHumanDiseaseDetailPermissions(permissionsRequest);
                            if (diseaseReport.Any())
                            {
                                deletePermissions.AccessToGenderAndAgeData =
                                    diseaseReport.First().AccessToGenderAndAgeDataPermissionIndicator;
                                deletePermissions.AccessToPersonalData =
                                    diseaseReport.First().AccessToPersonalDataPermissionIndicator;
                                deletePermissions.Delete =
                                    diseaseReport.First().DeletePermissionIndicator;
                                deletePermissions.Write =
                                    diseaseReport.First().WritePermissionIndicator;

                                _diseaseReportComponentViewModel.isDeleteEnabled = deletePermissions.Delete;

                                _diseaseReportComponentViewModel.IsSaveEnabled = _diseaseReportComponentViewModel.idfHumanCase > 0 ? deletePermissions.Write : deletePermissions.Create;
                            }
                            else
                            {
                                deletePermissions.AccessToGenderAndAgeData = false;
                                deletePermissions.AccessToPersonalData = false;
                                deletePermissions.Delete = false;
                                deletePermissions.Write = false;
                            }
                        }

                        _diseaseReportComponentViewModel.ReportSummary.IdfSessionID =
                            humanDiseaseDetail.idfParentMonitoringSession;

                        _diseaseReportComponentViewModel.ReportSummary.ReportID = humanDiseaseDetail.strCaseId;
                        _diseaseReportComponentViewModel.ReportSummary.ReportStatus = humanDiseaseDetail.CaseProgressStatus;
                        _diseaseReportComponentViewModel.ReportSummary.ReportStatusID = humanDiseaseDetail.idfsCaseProgressStatus.Value;
                        CultureInfo currentCulture = CultureInfo.CurrentCulture;
                        CultureInfo.CurrentCulture = CultureInfo.GetCultureInfo(GetCurrentLanguage());
                        _diseaseReportComponentViewModel.ReportSummary.DateEntered = humanDiseaseDetail.datEnteredDate != null ? humanDiseaseDetail.datEnteredDate : DateTime.Now;

                        _diseaseReportComponentViewModel.ReportSummary.EnteredBy = humanDiseaseDetail.EnteredByPerson;
                        _diseaseReportComponentViewModel.ReportSummary.idfPersonEnteredBy = humanDiseaseDetail.idfPersonEnteredBy;
                        _diseaseReportComponentViewModel.ReportSummary.EnteredByOrganization = humanDiseaseDetail.strOfficeEnteredBy;
                        _diseaseReportComponentViewModel.ReportSummary.ReportType = humanDiseaseDetail.ReportType;
                        if (humanDiseaseDetail.DiseaseReportTypeID != null && humanDiseaseDetail.DiseaseReportTypeID != 0)
                            _diseaseReportComponentViewModel.ReportSummary.ReportTypeID = humanDiseaseDetail.DiseaseReportTypeID.Value;
                        _diseaseReportComponentViewModel.ReportSummary.LegacyID = humanDiseaseDetail.LegacyCaseID;
                        _diseaseReportComponentViewModel.ReportSummary.SessionID = humanDiseaseDetail.strMonitoringSessionID;
                        _diseaseReportComponentViewModel.ReportSummary.DiseaseID =
                            humanDiseaseDetail.idfsFinalDiagnosis;
                        _diseaseReportComponentViewModel.ReportSummary.Disease = humanDiseaseDetail.strFinalDiagnosis;
                        _diseaseReportComponentViewModel.ReportSummary.DateLastUpdated = Convert.ToDateTime((humanDiseaseDetail.datModificationDate).ToString()).ToString("g");
                        CultureInfo.CurrentCulture = currentCulture;
                        _diseaseReportComponentViewModel.ReportSummary.PersonID = humanDiseaseDetail.EIDSSPersonID;
                        _diseaseReportComponentViewModel.ReportSummary.PersonName = humanDiseaseDetail.PatientFarmOwnerName;

                        _diseaseReportComponentViewModel.ReportSummary.idfHumanCase = humanDiseaseDetail.idfHumanCase;
                        _diseaseReportComponentViewModel.ReportSummary.HumanID = humanDiseaseDetail.idfHuman;
                        _diseaseReportComponentViewModel.ReportSummary.HumanActualID = humanDiseaseDetail.HumanActualId;
                        _diseaseReportComponentViewModel.ReportSummary.CaseClassification = humanDiseaseDetail.SummaryCaseClassification;
                        _diseaseReportComponentViewModel.ReportSummary.blnFinalSSD = humanDiseaseDetail.blnFinalSSD != null ? humanDiseaseDetail.blnFinalSSD : false;
                        _diseaseReportComponentViewModel.ReportSummary.blnInitialSSD = humanDiseaseDetail.blnInitialSSD != null ? humanDiseaseDetail.blnInitialSSD : false;
                        _diseaseReportComponentViewModel.ReportSummary.idfsSite = humanDiseaseDetail.idfsSite;

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

                if (diseaseReportComponentViewModel.HumanActualID != 0 && diseaseReportComponentViewModel.HumanActualID != null)
                {
                    _diseaseReportComponentViewModel.HumanActualID = diseaseReportComponentViewModel.HumanActualID;
                }
                if (diseaseReportComponentViewModel.HumanID != 0 && diseaseReportComponentViewModel.HumanID != null)
                {
                    _diseaseReportComponentViewModel.HumanID = diseaseReportComponentViewModel.HumanID;
                }

                _diseaseReportComponentViewModel.PersonInfoSection = await LoadPersonInfo();

                if (detailResponse != null)
                {
                    _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.ReportedAge = detailResponse.intPatientAge;
                    _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.ReportedAgeUOMID = detailResponse.idfsHumanAgeType;
                    _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.Age = detailResponse.HumanAgeType;
                }

                _diseaseReportComponentViewModel.NotificationSection = LoadNotification(diseaseReportComponentViewModel.isEdit);
                if (_diseaseReportComponentViewModel != null && _diseaseReportComponentViewModel.PersonInfoSection != null && _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo != null)
                {
                    _diseaseReportComponentViewModel.NotificationSection.DateOfBirth = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.DateOfBirth;

                    if (_diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.ReportedAge != null)
                    {
                        if (_diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.ReportedAge >= 0)
                        {
                            _diseaseReportComponentViewModel.NotificationSection.ReportedAge = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.ReportedAge;
                            _diseaseReportComponentViewModel.NotificationSection.ReportedAgeUOMID = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.ReportedAgeUOMID;
                        }
                    }
                    else
                    {
                        _diseaseReportComponentViewModel.NotificationSection.ReportedAge = null;
                    }

                    _diseaseReportComponentViewModel.NotificationSection.GenderTypeID = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.GenderTypeID;
                    _diseaseReportComponentViewModel.NotificationSection.GenderTypeName = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.GenderTypeName;
                }
                _diseaseReportComponentViewModel.SymptomsSection = LoadSymptoms(diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.FacilityDetailsSection = await LoadFacilityDetails(diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.AntibioticVaccineHistorySection = await LoadAntibioticVaccineHistoryDetails(diseaseReportComponentViewModel.isEdit);

                if (_diseaseReportComponentViewModel.SamplesSection.SamplesDetails == null)
                {
                    _diseaseReportComponentViewModel.SamplesSection = await LoadSampleDetails(diseaseReportComponentViewModel.NotificationSection.idfDisease, diseaseReportComponentViewModel.isEdit);
                }

                if (!_diseaseReportComponentViewModel.TestsSection.TestsLoaded)
                {
                    _diseaseReportComponentViewModel.TestsSection = await LoadTestsDetails(diseaseReportComponentViewModel.NotificationSection.idfDisease, diseaseReportComponentViewModel.isEdit);
                }

                _diseaseReportComponentViewModel.CaseInvestigationSection = LoadCaseInvestigationDetails(diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.RiskFactorsSection = await LoadCaseInvestigationRiskFactors(diseaseReportComponentViewModel.NotificationSection.idfDisease);

                _diseaseReportComponentViewModel.ContactListSection = await LoadContactList(diseaseReportComponentViewModel.isEdit);

                _diseaseReportComponentViewModel.FinalOutcomeSection = LoadFinalOutComeDetails(diseaseReportComponentViewModel.NotificationSection.idfDisease, diseaseReportComponentViewModel.isEdit);

                if (_diseaseReportComponentViewModel.IsReopenClosedReport.Value)
                {
                    _diseaseReportComponentViewModel.ReportSummary.ReportStatus = "In Process";
                    _diseaseReportComponentViewModel.ReportSummary.ReportStatusID = (long)VeterinaryDiseaseReportStatusTypes.InProcess;
                    _diseaseReportComponentViewModel.ReportStatus = "In Process";
                    _diseaseReportComponentViewModel.ReportStatusID = (long)VeterinaryDiseaseReportStatusTypes.InProcess;
                    _diseaseReportComponentViewModel.IsReportClosed = false;
                    _diseaseReportComponentViewModel.ReportSummary.IsReportClosed = false;
                    _diseaseReportComponentViewModel.NotificationSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.SymptomsSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.FacilityDetailsSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.AntibioticVaccineHistorySection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.SamplesSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.TestsSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.RiskFactorsSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.FinalOutcomeSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.ContactListSection.IsReportClosed = false;
                    _diseaseReportComponentViewModel.IsReopenClosedReport = false;
                }

                _diseaseReportComponentViewModel.ReportSummary.DefaultReportStatus = Common.GetBaseReferenceTranslation(GetCurrentLanguage(), CaseStatus.InProgress, _crossCuttingClient);
                _diseaseReportComponentViewModel.ReportSummary.DefaultReportType = Common.GetBaseReferenceTranslation(GetCurrentLanguage(), CaseReportType.Passive, _crossCuttingClient);

                if (_diseaseReportComponentViewModel.CaseDisabled)
                {
                    _diseaseReportComponentViewModel.IsReportClosed = true;
                    _diseaseReportComponentViewModel.ReportSummary.IsReportClosed = true;
                    _diseaseReportComponentViewModel.NotificationSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.SymptomsSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.SymptomsSection.HumanDiseaseSymptoms.IsFormDisabled = true;
                    _diseaseReportComponentViewModel.FacilityDetailsSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.AntibioticVaccineHistorySection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.SamplesSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.TestsSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.CaseInvestigationSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.RiskFactorsSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.FinalOutcomeSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.ContactListSection.IsReportClosed = true;
                    _diseaseReportComponentViewModel.IsReopenClosedReport = true;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, ex);
            }

            var viewData = new ViewDataDictionary<DiseaseReportComponentViewModel>(ViewData, _diseaseReportComponentViewModel);
            return new ViewViewComponentResult()
            {
                ViewData = viewData
            };
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
                IsDbRequiredAdminLevel3 = false,
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

            List<DiseaseReportPersonalInformationViewModel> response;
            if (_diseaseReportComponentViewModel.HumanID is null or 0)
            {
                var requestNew = new HumanPersonDetailsRequestModel
                {
                    LangID = GetCurrentLanguage(),
                    HumanMasterID = _diseaseReportComponentViewModel.HumanActualID
                };
                response = await _humanDiseaseReportClient.GetHumanDiseaseReportPersonInfoAsync(requestNew);
            }
            else
            {
                var requestID = new HumanPersonDetailsFromHumanIDRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    HumanID = _diseaseReportComponentViewModel.HumanID
                };
                response = await _humanDiseaseReportClient.GetHumanDiseaseReportFromHumanIDAsync(requestID);
                if (response == null || !response.Any())
                {
                    var requestNew = new HumanPersonDetailsRequestModel
                    {
                        LangID = GetCurrentLanguage(),
                        HumanMasterID = _diseaseReportComponentViewModel.HumanID
                    };
                    response = await _humanDiseaseReportClient.GetHumanDiseaseReportPersonInfoAsync(requestNew);
                }
            }

            if (response.Count > 0)
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

        private DiseaseReportSymptomsPageViewModel LoadSymptoms(bool isEdit = false)
        {
            DiseaseReportSymptomsPageViewModel symptomsSection = _diseaseReportComponentViewModel.SymptomsSection;

            if (isEdit && detailResponse != null)
            {
                symptomsSection.idfHuman = detailResponse.idfHuman;
                symptomsSection.idfHumanCase = detailResponse.idfHumanCase;
                symptomsSection.idfsSite = detailResponse.idfsSite;
                symptomsSection.SymptomsOnsetDate = detailResponse.datOnSetDate;
                symptomsSection.strCaseClassification = detailResponse.InitialCaseStatus;
                symptomsSection.idfCaseClassfication = detailResponse.idfsInitialCaseStatus;
                symptomsSection.blnInitialSSD = detailResponse.blnInitialSSD != null ? detailResponse.blnInitialSSD : false;
                symptomsSection.blnFinalSSD = detailResponse.blnFinalSSD != null ? detailResponse.blnFinalSSD : false;
                symptomsSection.DiseaseID = detailResponse.idfsFinalDiagnosis;

                if (detailResponse.CaseProgressStatus == DiseaseReportStatusTypeEnum.Closed.ToString())
                {
                    symptomsSection.IsReportClosed = true;
                }
            }

            symptomsSection.HumanDiseaseSymptoms = new FlexFormQuestionnaireGetRequestModel
            {
                idfsFormType = (long?)FlexFormType.HumanDiseaseClinicalSymptoms
            };

            if (isEdit && detailResponse != null)
            {
                symptomsSection.HumanDiseaseSymptoms.idfsDiagnosis = detailResponse.idfsFinalDiagnosis;
                symptomsSection.HumanDiseaseSymptoms.idfObservation = detailResponse.idfCSObservation;
            }
            else
            {
                symptomsSection.HumanDiseaseSymptoms.idfsDiagnosis = null;
                symptomsSection.HumanDiseaseSymptoms.idfObservation = null;
            }

            symptomsSection.HumanDiseaseSymptoms.ObserationFieldID = "idfCaseObservationSymptoms";
            symptomsSection.HumanDiseaseSymptoms.LangID = GetCurrentLanguage();
            symptomsSection.HumanDiseaseSymptoms.Title = _localizer.GetString(FieldLabelResourceKeyConstants.CreateHumanCaseListofSymptomsFieldLabel);
            symptomsSection.HumanDiseaseSymptoms.SubmitButtonID = "btnDummy";
            symptomsSection.HumanDiseaseSymptoms.CallbackFunction = "getFlexFormAnswers10034011();";
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
                caseClassficationDD = new Select2Configruation()
            };
            symptomsSection.caseClassficationDD.ConfigureForPartial = true;
            symptomsSection.IsReportClosed = isReportClosed;
            symptomsSection.DiseaseID = diseaseId;

            if (isEdit && idfHumanCase != 0 && idfHumanCase != null)
            {
                var detailRequest = new HumanDiseaseReportDetailRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SearchHumanCaseId = Convert.ToInt64(idfHumanCase),
                    SortColumn = "datEnteredDate",
                    SortOrder = SortConstants.Descending
                };
                detailResponse = await _humanDiseaseReportClient.GetHumanDiseaseDetail(detailRequest);
                if (detailResponse != null)
                {
                    symptomsSection.idfHuman = detailResponse.idfHuman;
                    symptomsSection.idfHumanCase = detailResponse.idfHumanCase;
                    symptomsSection.idfsSite = detailResponse.idfsSite;
                    symptomsSection.SymptomsOnsetDate = detailResponse.datOnSetDate;
                    symptomsSection.strCaseClassification = detailResponse.InitialCaseStatus;
                    symptomsSection.idfCaseClassfication = detailResponse.idfsInitialCaseStatus;
                    symptomsSection.blnInitialSSD = detailResponse.blnInitialSSD != null ? detailResponse.blnInitialSSD : false;
                    symptomsSection.blnFinalSSD = detailResponse.blnFinalSSD != null ? detailResponse.blnFinalSSD : false;
                    if (detailResponse.CaseProgressStatus == VeterinaryDiseaseReportStatusTypes.Closed.ToString())
                    {
                        symptomsSection.IsReportClosed = true;
                    }
                }
            }
            else
            {
                symptomsSection.SymptomsOnsetDate = string.IsNullOrEmpty(jsonObject["SymptomsOnsetDate"].ToString()) ? null : DateTime.Parse(jsonObject["SymptomsOnsetDate"].ToString());
                //Case Classification
                symptomsSection.idfCaseClassfication = !string.IsNullOrEmpty(jsonObject["caseClassficationDD"].ToString()) && long.Parse(jsonObject["caseClassficationDD"].ToString()) != 0 ? long.Parse(jsonObject["caseClassficationDD"].ToString()) : null;
                symptomsSection.strCaseClassification = !string.IsNullOrEmpty(jsonObject["strCaseClassification"].ToString()) ? jsonObject["strCaseClassification"].ToString() : null;
            }

            symptomsSection.HumanDiseaseSymptoms = new FlexFormQuestionnaireGetRequestModel
            {
                IsFormDisabled = isReportClosed,
                idfsFormType = (long?)FlexFormType.HumanDiseaseClinicalSymptoms,
                idfsDiagnosis = null,
                idfObservation = null,
                ObserationFieldID = "idfCaseObservationSymptoms",
                SubmitButtonID = "btnDummy",
                LangID = GetCurrentLanguage(),
                Title = _localizer.GetString(FieldLabelResourceKeyConstants.HumanDiseaseReportSymptomsListofSymptomsFieldLabel),
                CallbackFunction = "getFlexFormAnswers10034011();"
            };

            if (isEdit && idfHumanCase != 0 && idfHumanCase != null && detailResponse != null)
            {
                symptomsSection.HumanDiseaseSymptoms.idfObservation = detailResponse.idfCSObservation;
            }

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
            notificationSection.notificationSentByFacilityDDValidated = new Select2Configruation();
            notificationSection.notificationSentByNameDDValidated = new Select2Configruation();
            notificationSection.notificationReceivedByFacilityDD = new Select2Configruation();
            notificationSection.notificationReceivedByNameDD = new Select2Configruation();
            notificationSection.statusOfPatientAtNotificationDD = new Select2Configruation();
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
                var detailRecord = detailResponse;

                notificationSection.dateOfCompletion = detailRecord.datCompletionPaperFormDate;

                notificationSection.localIdentifier = detailRecord.strLocalIdentifier;

                notificationSection.idfDisease = detailRecord.idfsFinalDiagnosis;
                notificationSection.strDisease = detailRecord.strFinalDiagnosis;

                notificationSection.dateOfDiagnosis = detailRecord.DateOfDiagnosis;

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

                notificationSection.ChangedDiseaseId = detailRecord.ChangedDiseaseId;
                notificationSection.ChangedDiseaseName = detailRecord.ChangedDiseaseName;
                notificationSection.DateOfChangedDiagnosis = detailRecord.DateOfChangedDiagnosis;
            }
            return notificationSection;
        }

        private async Task<DiseaseReportFacilityDetailsPageViewModel> LoadFacilityDetails(bool isEdit = false)
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
                facilityDetailsSection.HospitalizationDate = detailResponse.datHospitalizationDate;
                facilityDetailsSection.DateOfDischarge = detailResponse.datDischargeDate;
            }
            return facilityDetailsSection;
        }

        private async Task<DiseaseReportAntibioticVaccineHistoryPageViewModel> LoadAntibioticVaccineHistoryDetails(bool isEdit = false)
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
                caseInvestigationPageViewModelSection.ExposureLocationType = detailRecord.ExposureLocationType;
                caseInvestigationPageViewModelSection.idfsYNExposureLocationKnown = detailRecord.idfsYNExposureLocationKnown;

                if (detailRecord.idfsYNExposureLocationKnown == YesNoValues.Yes)
                {
                    caseInvestigationPageViewModelSection.ExposureDate = detailRecord.datExposureDate;
                    caseInvestigationPageViewModelSection.idfPointGeoLocation = detailRecord.idfPointGeoLocation;
                    caseInvestigationPageViewModelSection.idfsPointGeoLocationType = detailRecord.idfsPointGeoLocationType;

                    var idfsPointGeoLocationType = detailRecord.idfsPointGeoLocationType.GetValueOrDefault();
                    if (idfsPointGeoLocationType is GeoLocationTypes.Foreign)
                    {
                        caseInvestigationPageViewModelSection.idfsPointCountry = detailRecord.idfsPointCountry;
                        caseInvestigationPageViewModelSection.Country = detailRecord.Country;
                        caseInvestigationPageViewModelSection.strPointForeignAddress = detailRecord.strPointForeignAddress;
                    }

                    if (idfsPointGeoLocationType is GeoLocationTypes.ExactPoint or GeoLocationTypes.RelativePoint)
                    {
                        caseInvestigationPageViewModelSection.idfsPointRegion = detailRecord.idfsPointRegion;
                        caseInvestigationPageViewModelSection.idfsPointRayon = detailRecord.idfsPointRayon;
                        caseInvestigationPageViewModelSection.idfsPointSettlement = detailRecord.idfsPointSettlement;
                        caseInvestigationPageViewModelSection.Region = detailRecord.Region;
                        caseInvestigationPageViewModelSection.Rayon = detailRecord.Rayon;
                        caseInvestigationPageViewModelSection.dblPointLatitude = detailRecord.dblPointLatitude;
                        caseInvestigationPageViewModelSection.dblPointLongitude = detailRecord.dblPointLongitude;
                        caseInvestigationPageViewModelSection.dblPointElevation = detailRecord.dblPointElevation;
                        caseInvestigationPageViewModelSection.Settlement = detailRecord.Settlement;
                        exposureLocationAddress.Elevation = detailRecord.dblPointElevation != null ? Convert.ToInt32(detailRecord.dblPointElevation) : null;
                        exposureLocationAddress.AdminLevel1Text = detailRecord.Region;
                        exposureLocationAddress.AdminLevel1Value = detailRecord.idfsPointRegion;
                        exposureLocationAddress.AdminLevel2Text = detailRecord.Rayon;
                        exposureLocationAddress.AdminLevel2Value = detailRecord.idfsPointRayon;
                        exposureLocationAddress.AdminLevel3Text = detailRecord.Settlement;
                        exposureLocationAddress.AdminLevel3Value = detailRecord.idfsPointSettlement;
                        exposureLocationAddress.Latitude = detailRecord.dblPointLatitude;
                        exposureLocationAddress.Longitude = detailRecord.dblPointLongitude;
                    }
                    
                    if (idfsPointGeoLocationType is GeoLocationTypes.RelativePoint)
                    {
                        caseInvestigationPageViewModelSection.idfsPointGroundType = detailRecord.idfsPointGroundType;
                        caseInvestigationPageViewModelSection.strGroundType = detailRecord.strGroundType;
                        caseInvestigationPageViewModelSection.dblPointDistance = detailRecord.dblPointDistance;
                    }


                    caseInvestigationPageViewModelSection.ExposureLocationAddress = exposureLocationAddress;
                    //Direction not available
                    caseInvestigationPageViewModelSection.dblPointDirection = detailRecord.dblPointAlignment;
                }

                if (detailRecord.CaseProgressStatus == VeterinaryDiseaseReportStatusTypes.Closed.ToString())
                {
                    caseInvestigationPageViewModelSection.IsReportClosed = true;
                }
            }

            return caseInvestigationPageViewModelSection;
        }

        private async Task<DiseaseReportSamplePageViewModel> LoadSampleDetails(long? diseaseId, bool isEdit = false)
        {
            DiseaseReportSamplePageViewModel diseaseReportSamplePageViewModelSection = new()
            {
                idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase,
                strCaseId = _diseaseReportComponentViewModel.strCaseId,
                YesNoChoices = new List<BaseReferenceViewModel>(),
                idfDisease = diseaseId,
                AddSampleModel = new DiseaseReportSamplePageSampleDetailViewModel
                {
                    idfDisease = diseaseId
                },
                SamplesDetails = new List<DiseaseReportSamplePageSampleDetailViewModel>(),
                IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed,

                Permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportClinicalInformation)
            };

            if (isEdit && detailResponse != null)
            {
                diseaseReportSamplePageViewModelSection.AddSampleModel.SymptomsOnsetDate = detailResponse.datOnSetDate;
                diseaseReportSamplePageViewModelSection.SamplesCollectedYN = detailResponse.idfsYNSpecimenCollected;
                diseaseReportSamplePageViewModelSection.SamplesDetails = new List<DiseaseReportSamplePageSampleDetailViewModel>();

                var request = new HumanDiseaseReportSamplesRequestModel()
                {
                    idfHumanCase = detailResponse.idfHumanCase,
                    LangID = GetCurrentLanguage()
                };

                var list = await _humanDiseaseReportClient.GetHumanDiseaseReportSamplesListAsync(request);

                List<DiseaseReportSamplePageSampleDetailViewModel> samplesDetailList = new();
                var i = 0;
                // if the sample type is 'unknown' do not show the sample unless this is a
                //  basic syndromic surveillance report that was migrated
                foreach (var item in list.Where(x => x.idfsSampleType != (long)SampleTypes.Unknown
                                                     || detailResponse.blnFinalSSD.GetValueOrDefault()
                                                     || detailResponse.blnInitialSSD.GetValueOrDefault()))
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
                        strNote = item.strNote,
                        idfDisease = item.DiseaseID
                    });
                    i++;
                }
                diseaseReportSamplePageViewModelSection.SamplesDetails = samplesDetailList;
                diseaseReportSamplePageViewModelSection.ActiveSamplesDetails = samplesDetailList;
            }

            return diseaseReportSamplePageViewModelSection;
        }

        private async Task<DiseaseReportTestPageViewModel> LoadTestsDetails(long? diseaseId, bool isEdit = false)
        {
            var diseaseReportTestsPageViewModelSection = _diseaseReportComponentViewModel.TestsSection;
            diseaseReportTestsPageViewModelSection.idfHumanCase = _diseaseReportComponentViewModel.idfHumanCase;
            diseaseReportTestsPageViewModelSection.strCaseId = _diseaseReportComponentViewModel.strCaseId;
            diseaseReportTestsPageViewModelSection.YesNoChoices = new List<BaseReferenceViewModel>();
            diseaseReportTestsPageViewModelSection.idfDisease = diseaseId;
            diseaseReportTestsPageViewModelSection.AddTestModel = new DiseaseReportTestPageTestDetailViewModel();
            diseaseReportTestsPageViewModelSection.TestDetails = new List<DiseaseReportTestDetailForDiseasesViewModel>();
            diseaseReportTestsPageViewModelSection.SamplesDetails = new List<DiseaseReportSamplePageSampleDetailViewModel>();
            diseaseReportTestsPageViewModelSection.IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed;
            if (_diseaseReportComponentViewModel.SamplesSection is { SamplesDetails: { } })
                diseaseReportTestsPageViewModelSection.SamplesDetails = _diseaseReportComponentViewModel.SamplesSection.SamplesDetails;

            diseaseReportTestsPageViewModelSection.Permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportClinicalInformation);

            if (isEdit && detailResponse != null)
            {
                diseaseReportTestsPageViewModelSection.TestsLoaded = true;
                diseaseReportTestsPageViewModelSection.TestsConducted = detailResponse.idfsYNTestsConducted;
                diseaseReportTestsPageViewModelSection.TestDetails = new();
                diseaseReportTestsPageViewModelSection.idfHumanCase = detailResponse.idfHumanCase;
                diseaseReportTestsPageViewModelSection.idfsSite = detailResponse.idfsSite;
                var request = new HumanTestListRequestModel()
                {
                    idfHumanCase = detailResponse.idfHumanCase,
                    LangID = GetCurrentLanguage(),
                    SearchDiagnosis = null
                };
                var list = await _humanDiseaseReportClient.GetHumanDiseaseReportTestListAsync(request);
                diseaseReportTestsPageViewModelSection.TestDetails = list;

                var sampleRequest = new HumanDiseaseReportSamplesRequestModel()
                {
                    idfHumanCase = detailResponse.idfHumanCase,
                    LangID = GetCurrentLanguage()
                };

                var list2 = await _humanDiseaseReportClient.GetHumanDiseaseReportSamplesListAsync(sampleRequest);

                List<DiseaseReportSamplePageSampleDetailViewModel> samplesDetailList = new();
                var i = 0;
                //  basic syndromic surveillance report that was migrated
                foreach (var item in list2.Where(x => x.idfsSampleType != (long)SampleTypes.Unknown
                                                     || detailResponse.blnFinalSSD.GetValueOrDefault()
                                                     || detailResponse.blnInitialSSD.GetValueOrDefault()))
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
                    i++;
                }
                diseaseReportTestsPageViewModelSection.SamplesDetails = samplesDetailList;
            }

            return diseaseReportTestsPageViewModelSection;
        }

        private Task<DiseaseReportCaseInvestigationRiskFactorsPageViewModel> LoadCaseInvestigationRiskFactors(long? diseaseId)
        {
            var riskFactorsSection = new DiseaseReportCaseInvestigationRiskFactorsPageViewModel();
            long? idfObservation = null;
            riskFactorsSection.RiskFactors = new FlexFormQuestionnaireGetRequestModel
            {
                idfsFormType = (long?)FlexFormType.HumanDiseaseQuestionnaire
            };
            riskFactorsSection.IsReportClosed = _diseaseReportComponentViewModel.IsReportClosed;
            if (diseaseId != null && diseaseId != 0)
            {
                riskFactorsSection.RiskFactors.idfsDiagnosis = diseaseId;
            }
            if (detailResponse != null)
            {
                idfObservation = detailResponse?.idfEpiObservation;
            }
            riskFactorsSection.RiskFactors.idfObservation = idfObservation;
            riskFactorsSection.RiskFactors.SubmitButtonID = "btnDummy";
            riskFactorsSection.RiskFactors.LangID = GetCurrentLanguage();
            riskFactorsSection.RiskFactors.Title = _localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportRiskFactorsListofRiskFactorsHeading);
            riskFactorsSection.RiskFactors.CallbackFunction = "SaveHDR();";
            riskFactorsSection.RiskFactors.ObserationFieldID = "idfCaseObservationRiskFactors";
            return Task.FromResult(riskFactorsSection);
        }

        public async Task<IActionResult> ReloadRiskFactors(long? diseaseId, long? idfHumanCase, bool isEdit = false, bool isReportClosed = false)
        {
            DiseaseReportCaseInvestigationRiskFactorsPageViewModel riskFactorsSection = new()
            {
                IsReportClosed = isReportClosed
            };

            long? idfObservation = null;
            if (isEdit && idfHumanCase != 0 && idfHumanCase != null)
            {
                var detailRequest = new HumanDiseaseReportDetailRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 10,
                    SearchHumanCaseId = Convert.ToInt64(idfHumanCase),
                    SortColumn = "datEnteredDate",
                    SortOrder = SortConstants.Descending
                };
                detailResponse = await _humanDiseaseReportClient.GetHumanDiseaseDetail(detailRequest);
                if (detailResponse != null)
                {
                    idfObservation = detailResponse.idfEpiObservation;
                }
            }

            riskFactorsSection.RiskFactors = new FlexFormQuestionnaireGetRequestModel
            {
                IsFormDisabled = isReportClosed,
                idfsFormType = (long?)FlexFormType.HumanDiseaseQuestionnaire
            };
            if (diseaseId != null && diseaseId != 0)
            {
                riskFactorsSection.RiskFactors.idfsDiagnosis = diseaseId;
            }
            else
                riskFactorsSection.RiskFactors.idfsDiagnosis = null;
            riskFactorsSection.RiskFactors.SubmitButtonID = "btnDummy";
            riskFactorsSection.RiskFactors.idfObservation = idfObservation;
            riskFactorsSection.RiskFactors.CallbackFunction = "SaveHDR();";
            riskFactorsSection.RiskFactors.LangID = GetCurrentLanguage();
            riskFactorsSection.RiskFactors.Title = _localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportRiskFactorsListofRiskFactorsHeading);

            riskFactorsSection.RiskFactors.ObserationFieldID = "idfCaseObservationRiskFactors";

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
                                item.strPatientAddressString = string.Join(", ", new List<string>
                                {
                                    item.strPostCode,
                                    item.strStreetName,
                                    item.strHouse,
                                    item.strBuilding,
                                    item.strApartment,
                                    item.strContactPhone
                                }.Where(x => !string.IsNullOrEmpty(x)));
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
                idfInvestigatedByOffice = _diseaseReportComponentViewModel.CaseInvestigationSection.idfInvestigatedByOffice,
                datDateOfDeath = _diseaseReportComponentViewModel.PersonInfoSection.PersonInfo.DateOfDeath,
                datDateOfDischarge = _diseaseReportComponentViewModel.FinalOutcomeSection.datDateOfDischarge
            };
            if (isEdit && detailResponse != null)
            {
                diseaseReportFinalOutcomeViewModelSection.idfsSite = detailResponse.idfsSite;
                diseaseReportFinalOutcomeViewModelSection.blnInitialSSD = detailResponse.blnInitialSSD != null ? detailResponse.blnInitialSSD : false;
                diseaseReportFinalOutcomeViewModelSection.blnFinalSSD = detailResponse.blnFinalSSD != null ? detailResponse.blnFinalSSD : false;
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
                SortOrder = SortConstants.Descending
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

        [HttpPost]
        [Route("SaveHumanDiseaseReport")]
        public async Task<IActionResult> SaveHumanDiseaseReport([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            bool permission;

            if (Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfHumanCase"]) is not null)
            {
                if (_authenticatedUser.SiteTypeId >= (long)SiteTypes.ThirdLevel)
                {
                    var permissionsRequest = new RecordPermissionsGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        RecordID = (long)Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfHumanCase"]),
                        UserEmployeeID = Convert.ToInt64(_authenticatedUser.PersonId),
                        UserOrganizationID = Convert.ToInt64(_authenticatedUser.OfficeId),
                        UserSiteID = Convert.ToInt64(_authenticatedUser.SiteId)
                    };
                    var diseaseReport =
                        await _humanDiseaseReportClient.GetHumanDiseaseDetailPermissions(permissionsRequest);
                    if (diseaseReport.Any())
                    {
                        if (diseaseReport.First().SiteID != Convert.ToInt64(_authenticatedUser.SiteId))
                            permission = diseaseReport.First().WritePermissionIndicator;
                        else
                        {
                            var permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
                            permission = permissions.Write;
                        }
                    }
                    else
                        permission = false;
                }
                else
                {
                    var permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
                    permission = permissions.Write;
                }
            }
            else
            {
                var permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
                permission = permissions.Create;
            }

            var request = new HumanSetDiseaseReportRequestModel();
            var response = new SetHumanDiseaseReportResponseModel();

            if (!permission)
            {
                response.ReturnCode = 99;
                response.ReturnMessage = _localizer.GetString(MessageResourceKeyConstants
                    .WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage);

                return Ok(response);
            }

            request.LanguageID = GetCurrentLanguage();
            request.idfHumanCase = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfHumanCase"]);
            request.idfsSite = long.Parse(_authenticatedUser.SiteId);
            if (request.idfHumanCase != null && request.idfHumanCase != 0)
            {
                request.idfHuman = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfHuman"]);
                request.idfHumanActual = null;
                request.strHumanCaseId = jsonObject["strHumanCaseId"].ToString();
            }
            else
            {
                request.idfHumanActual = GetHumanActualId(jsonObject);
                request.idfHuman = null;
            }

            request.DateOfBirth = GetDateOfBirth(jsonObject);
            request.intPatientAge = Common.GetDataForEmptyOrNullInt32JsonToken(jsonObject["intPatientAge"]);
            request.idfsHumanAgeType = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsHumanAgeType"]);

            bool? IsFromWHOExport = jsonObject["IsFromWHOExport"] != null && Convert.ToBoolean(jsonObject["IsFromWHOExport"].ToString());
            var DesNotifications = (Request.Cookies["HDRNotifications"] != null ? JsonConvert.DeserializeObject<List<EventSaveRequestModel>>(Request.Cookies["HDRNotifications"]) : null) ??
                                   new List<EventSaveRequestModel>();

            //Connection to Human Active Surveillance Session
            request.idfParentMonitoringSession = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfParentMonitoringSession"]);
            request.ConnectedTestId = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["ConnectedTestId"]);

            request.DiseaseReportTypeID = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["DiseaseReportTypeID"]);
            request.idfsCaseProgressStatus = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsCaseProgressStatus"]);
            request.idfPersonEnteredBy = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["EnteredByPersonID"]);
            request.idfsFinalDiagnosis = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["diseaseDD"]);
            request.idfsFinalState = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["statusOfPatientAtNotificationDD"]);
            request.idfSentByOffice = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["notificationSentByFacilityDD"]);
            request.idfSentByPerson = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["notificationSentByNameDD"]);
            request.idfReceivedByOffice = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["notificationReceivedByFacilityDD"]);
            request.idfReceivedByPerson = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["notificationReceivedByNameDD"]);
            //Need to check the field for Current Location of Patient and Status of Patient at Notification
            request.idfsHospitalizationStatus = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["currentLocationOfPatientDD"]);
            request.idfHospital = jsonObject["hospitalNameDD"] != null && !string.IsNullOrEmpty(jsonObject["hospitalNameDD"].ToString()) ? Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["hospitalNameDD"]) : Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfHospital"]);
            request.datCompletionPaperFormDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["dateOfCompletion"]);
            request.datDateOfDiagnosis = Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["dateOfDiagnosis"]);
            request.datNotificationDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["dateOfNotification"]);

            request.strLocalIdentifier = jsonObject["strLocalIdentifier"] != null && !string.IsNullOrEmpty(jsonObject["strLocalIdentifier"].ToString()) ? jsonObject["strLocalIdentifier"].ToString() : null;

            request.datOnSetDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["SymptomsOnsetDate"]);

            request.idfsInitialCaseStatus = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["caseClassficationDD"]);

            request.idfCSObservation = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfCSObservation"]);

            // Changed Disease
            var changedDiseaseId = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["ChangedDiseaseId"]);
            if (changedDiseaseId != null)
            {
                request.ChangedDiseaseId = changedDiseaseId;
                request.DateOfChangedDiagnosis = Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["DateOfChangedDiagnosis"]);
                request.ChangeDiagnosisReasonId = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["ChangeDiagnosisReasonId"]);
            }

            //Facility Details
            request.idfsYNPreviouslySoughtCare = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsYNPreviouslySoughtCare"]);
            request.idfSoughtCareFacility = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfSoughtCareFacility"]);
            request.datFirstSoughtCareDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["datFirstSoughtCareDate"]);
            request.idfsNonNotIFiableDiagnosis = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsNonNotIFiableDiagnosis"]);
            request.idfsYNHospitalization = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsYNHospitalization"]);
            request.datHospitalizationDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["datHospitalizationDate"]);

            request.strHospitalName = jsonObject["strHospitalName"] != null ? jsonObject["strHospitalName"].ToString() : "";
            request.strCurrentLocation = jsonObject["strOtherLocation"] != null && !string.IsNullOrEmpty(jsonObject["strOtherLocation"].ToString()) ? jsonObject["strOtherLocation"].ToString() : null;

            //Antibiotic and Vaccination History
            var vaccinationAntiViralTherapies = jsonObject["vaccionationAntiViralTherapies"].ToString();
            var parsedVaccinationAntiViralTherapiesModel = JObject.Parse(vaccinationAntiViralTherapies);

            request.idfsYNAntimicrobialTherapy = Common.GetDataForEmptyOrNullLongJsonToken(parsedVaccinationAntiViralTherapiesModel["idfsYNAntimicrobialTherapy"]);
            request.idfsYNSpecIFicVaccinationAdministered = Common.GetDataForEmptyOrNullLongJsonToken(parsedVaccinationAntiViralTherapiesModel["idfsYNSpecificVaccinationAdministered"]);
            request.strClinicalNotes = parsedVaccinationAntiViralTherapiesModel["additionalInforMation"].ToString();

            //Vaccination List
            var vaccinationList = parsedVaccinationAntiViralTherapiesModel["vaccinationHistory"];
            var serVaccinationList = JsonConvert.SerializeObject(vaccinationList);
            if (serVaccinationList == "[]")
            {
                request.VaccinationsParameters = null;
            }
            else
            {
                request.VaccinationsParameters = serVaccinationList;
            }

            //Antiviral Therapies List

            var antibioticsHistory = parsedVaccinationAntiViralTherapiesModel["antibioticsHistory"];
            var serAntibioticsHistory = JsonConvert.SerializeObject(antibioticsHistory);
            if (serAntibioticsHistory == "[]")
            {
                request.AntiviralTherapiesParameters = null;
            }
            else
            {
                request.AntiviralTherapiesParameters = serAntibioticsHistory;
            }

            //Samples
            //where Local Identifier Goes

            var sampleModel = jsonObject["sampleModel"].ToString();
            var parsedSamples = JObject.Parse(sampleModel);
            request.idfsYNSpecimenCollected = Common.GetDataForEmptyOrNullLongJsonToken(parsedSamples["samplesCollectedYN"]);
            request.idfsNotCollectedReason = Common.GetDataForEmptyOrNullLongJsonToken(parsedSamples["reasonID"]);

            //Sample List
            var sampleDetails = parsedSamples["samplesDetails"];
            List<SampleSaveRequestModel> samples = new();

            foreach (var item in sampleDetails)
            {
                SampleSaveRequestModel Sample = new()
                {
                    SampleTypeID = Common.GetDataForEmptyOrNullLongJsonToken(item["sampleTypeID"])
                };
                var blnNumberingSchema = !string.IsNullOrEmpty(item["blnNumberingSchema"].ToString()) && int.Parse(item["blnNumberingSchema"].ToString()) != 0 ? int.Parse(item["blnNumberingSchema"].ToString()) : 0;
                if (blnNumberingSchema == 1 || blnNumberingSchema == 2)
                {
                    Sample.EIDSSLocalOrFieldSampleID = "";
                }
                else
                {
                    Sample.EIDSSLocalOrFieldSampleID = !string.IsNullOrEmpty(item["localSampleId"].ToString()) ? item["localSampleId"].ToString() : null;
                }
                Sample.CollectionDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(item["collectionDate"]);
                Sample.CollectedByOrganizationID = Common.GetDataForEmptyOrNullLongJsonToken(item["collectedByOrganizationID"]);
                Sample.CollectedByPersonID = Common.GetDataForEmptyOrNullLongJsonToken(item["collectedByOfficerID"]);
                Sample.SentDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(item["sentDate"]);
                Sample.SentToOrganizationID = Common.GetDataForEmptyOrNullLongJsonToken(item["sentToOrganizationID"]);

                Sample.SiteID = Common.GetDataForlongJsonToken(item["idfsSiteSentToOrg"]);
                if (Sample.SiteID == 0)
                    Sample.SiteID = 1;

                Sample.DiseaseID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfDisease"]);
                Sample.SampleID = Common.GetDataForlongJsonToken(item["idfMaterial"]);
                if (Sample.SampleID == 0)
                    Sample.SampleID = Common.GetDataForlongJsonToken(item["newRecordId"]) == 0 ? 1 : Common.GetDataForlongJsonToken(item["newRecordId"]);
                Sample.RowStatus = Common.GetDataForintJsonToken(item["intRowStatus"]);
                Sample.CurrentSiteID = null;
                Sample.HumanMasterID = request.idfHumanActual;
                Sample.HumanID = request.idfHuman;
                Sample.HumanDiseaseReportID = request.idfHumanCase;
                Sample.RowAction = item["rowAction"] != null ? int.Parse(item["rowAction"].ToString()) : 2;
                Sample.ReadOnlyIndicator = false;
                Sample.Comments = item["strNote"].ToString();
                samples.Add(Sample);
            }

            var strSamplesNew = System.Text.Json.JsonSerializer.Serialize(samples);

            if (strSamplesNew == "[]")
            {
                request.SamplesParameters = null;
            }
            else
            {
                request.SamplesParameters = strSamplesNew;
            }

            //Test
            var testModel = jsonObject["testModel"].ToString();
            var parsedTests = JObject.Parse(testModel);
            request.idfsYNTestsConducted = Common.GetDataForEmptyOrNullLongJsonToken(parsedTests["testsConducted"]);

            if (parsedTests["events"] != null)
            {
                var parsedTestNotifications = parsedTests["events"];
                DesNotifications.AddRange(parsedTestNotifications.Select(item => new EventSaveRequestModel()
                {
                    EventId = Common.GetDataForlongJsonToken(item["eventId"]),
                    LoginSiteId = Convert.ToInt64(_authenticatedUser.SiteId),
                    ObjectId = Common.GetDataForEmptyOrNullLongJsonToken(item["objectId"]),
                    DiseaseId = Common.GetDataForlongJsonToken(item["diseaseId"]),
                    EventTypeId = !string.IsNullOrEmpty(item["eventTypeId"].ToString()) && long.Parse(item["eventTypeId"].ToString()) != 0 ? long.Parse(item["eventTypeId"].ToString()) : null,
                    InformationString = !string.IsNullOrEmpty(item["informationString"].ToString()) ? item["informationString"].ToString() : null,
                    SiteId = Common.GetDataForEmptyOrNullLongJsonToken(item["siteId"]), //site id of where the record was created.
                    UserId = Common.GetDataForEmptyOrNullLongJsonToken(item["userId"]),
                    LocationId = Common.GetDataForEmptyOrNullLongJsonToken(item["locationId"])
                }));
            }

            //Test List
            var testDetails = parsedTests["testDetails"];

            List<LaboratoryTestSaveRequestModel> tests = new();
            List<LaboratoryTestInterpretationSaveRequestModel> testInterpretations = new();
            var count = 0;
            foreach (var item in testDetails)
            {
                LaboratoryTestSaveRequestModel testRequest = new();
                LaboratoryTestInterpretationSaveRequestModel interpretationRequest = new();
                testRequest.SampleID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfMaterial"]);

                testRequest.TestID = Common.GetDataForlongJsonToken(item["idfTesting"]);
                if (testRequest.TestID == 0)
                {
                    count++;
                    testRequest.TestID = count;
                }

                testRequest.HumanDiseaseReportID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfHumanCase"]);
                testRequest.TestCategoryTypeID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsTestCategory"]);
                testRequest.TestNameTypeID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsTestName"]);
                testRequest.TestResultTypeID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsTestResult"]);
                testRequest.TestStatusTypeID = Common.GetDataForlongJsonToken(item["idfsTestStatus"]);
                testRequest.ResultDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(item["datConcludedDate"]);
                testRequest.ReceivedDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(item["datFieldCollectionDate"]);
                testRequest.TestedByPersonID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfTestedByPerson"]);
                testRequest.TestedByOrganizationID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfTestedByOffice"]);
                testRequest.RowStatus = Common.GetDataForintJsonToken(item["intRowStatus"]);
                testRequest.HumanDiseaseReportID = request.idfHumanCase;
                testRequest.RowAction = Common.GetDataForintJsonToken(item["rowAction"]);
                var isEdit = Convert.ToBoolean(bool.Parse(jsonObject["IsEdit"].ToString()));

                testRequest.RowAction = testRequest.RowAction == 0 ? 2 : testRequest.RowAction;

                if (request.idfParentMonitoringSession is not null && isEdit == false)
                {
                    testRequest.RowAction = 1;
                }
                testRequest.ReadOnlyIndicator = false;
                testRequest.DiseaseID = Common.GetDataForlongJsonToken(item["idfsDiagnosis"]);
                testRequest.NonLaboratoryTestIndicator = !string.IsNullOrEmpty(item["blnNonLaboratoryTest"].ToString()) && Convert.ToBoolean(item["blnNonLaboratoryTest"].ToString());

                interpretationRequest.TestID = testRequest.TestID;
                interpretationRequest.TestInterpretationID = Common.GetDataForlongJsonToken(item["idfTestValidation"]);
                interpretationRequest.InterpretedByPersonID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfInterpretedByPerson"]);
                interpretationRequest.InterpretedStatusTypeID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsInterpretedStatus"]);
                interpretationRequest.InterpretedDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(item["datInterpretedDate"]);
                interpretationRequest.InterpretedComment = item["strInterpretedComment"]?.ToString();
                interpretationRequest.ValidatedByPersonID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfValidatedByPerson"]);
                interpretationRequest.ValidatedDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(item["datValidationDate"]);
                interpretationRequest.ValidatedComment = item["strValidateComment"]?.ToString();
                interpretationRequest.RowStatus = Common.GetDataForintJsonToken(item["intRowStatus"]);
                interpretationRequest.ValidatedStatusIndicator = !string.IsNullOrEmpty(item["blnValidateStatus"].ToString()) && Convert.ToBoolean(item["blnValidateStatus"].ToString());

                if (interpretationRequest.TestInterpretationID <= 0)
                    interpretationRequest.RowAction = (int)RowActionTypeEnum.Insert;
                else
                    interpretationRequest.RowAction = testRequest.RowAction;

                interpretationRequest.ReadOnlyIndicator = false;
                interpretationRequest.DiseaseID = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsDiagnosis"]);
                tests.Add(testRequest);
                testInterpretations.Add(interpretationRequest);
            }

            var strTestNew = System.Text.Json.JsonSerializer.Serialize(tests);

            if (strTestNew == "[]")
            {
                request.TestsParameters = null;
            }
            else
            {
                request.TestsParameters = strTestNew;
            }

            var strTestInterpretation = System.Text.Json.JsonSerializer.Serialize(testInterpretations);

            if (strTestInterpretation == "[]")
            {
                request.TestsInterpretationParameters = null;
            }
            else
            {
                request.TestsInterpretationParameters = strTestInterpretation;
            }

            //Case Investigation Details
            request.StartDateofInvestigation = Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["StartDateofInvestigation"]);
            request.datExposureDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["datExposureDate"]);

            request.idfInvestigatedByOffice = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfInvestigatedByOffice"]);
            request.idfOutbreak = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfOutbreak"]);
            request.strNote = jsonObject["strNote"] != null && !string.IsNullOrEmpty(jsonObject["strNote"].ToString()) ? jsonObject["strNote"].ToString() : null;

            request.idfsYNExposureLocationKnown = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsYNExposureLocationKnown"]);
            request.idfsGeoLocationType = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsGeoLocationType"]);

            if (request.idfsGeoLocationType != null)
            {
                request.idfPointGeoLocation = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfPointGeoLocation"]);
                request.idfsLocationRegion = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsLocationRegion"]);
                request.idfsLocationRayon = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsLocationRayon"]);
                request.idfsLocationSettlement = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsLocationSettlement"]);

                request.intLocationLatitude = Common.GetDataForEmptyOrNullDoubleJsonToken(jsonObject["intLocationLatitude"]);
                request.intLocationLongitude = Common.GetDataForEmptyOrNullDoubleJsonToken(jsonObject["intLocationLongitude"]);
                request.intElevation = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["intElevation"]);
                request.idfsLocationGroundType = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsLocationGroundType"]);

                request.intLocationDistance = Common.GetDataForEmptyOrNullDoubleJsonToken(jsonObject["intLocationDistance"]);
                request.intLocationDirection = Common.GetDataForEmptyOrNullDoubleJsonToken(jsonObject["intLocationDirection"]);

                if (request.idfsGeoLocationType == GeoLocationTypes.Foreign)
                {
                    request.strForeignAddress = jsonObject["strForeignAddress"] != null && !string.IsNullOrEmpty(jsonObject["strForeignAddress"].ToString()) ? jsonObject["strForeignAddress"].ToString() : null;
                    request.idfsLocationCountry = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfsLocationCountry"]);
                }
            }
            // Risk Factors
            request.idfEpiObservation = Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfEpiObservation"]);

            DiseaseReportContactSaveRequestModel contactRequest = new();
            //Contact List
            if (jsonObject["contactsModel"] != null)
            {
                var contactModel = jsonObject["contactsModel"].ToString();
                var parsedContactModel = JObject.Parse(contactModel);
                if (parsedContactModel != null && parsedContactModel["contactDetails"] != null)
                {
                    var contactDetails = parsedContactModel["contactDetails"];
                    List<DiseaseReportContactSaveRequestModel> contactList = new();
                    var serContactModel = JsonConvert.SerializeObject(contactDetails);
                    request.ContactsParameters = serContactModel;
                    foreach (var item in contactDetails)
                    {
                        DiseaseReportContactSaveRequestModel contactItem = new()
                        {
                            HumanId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfHuman"]),
                            HumanMasterId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfHumanActual"]),
                            ContactTypeId = (long?)OutbreakContactTypeEnum.Human,
                            ContactedCasePersonId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfContactedCasePerson"]),
                            DateOfLastContact = Common.GetDataForEmptyOrNullDateTimeJsonToken(item["datDateOfLastContact"]),
                            PlaceOfLastContact = item["strPlaceInfo"] != null && !string.IsNullOrEmpty(item["strPlaceInfo"].ToString()) ? item["strPlaceInfo"].ToString() : null,
                            ContactRelationshipTypeId = item["idfsPersonContactType"].ToString() != "0" ? long.Parse(item["idfsPersonContactType"].ToString()) : (long?)PatientRelationshipTypeEnum.Other,
                            Comments = item["strComments"] != null && !string.IsNullOrEmpty(item["strComments"].ToString()) ? item["strComments"].ToString() : null,
                            FirstName = item["strFirstName"] != null && !string.IsNullOrEmpty(item["strFirstName"].ToString()) ? item["strFirstName"].ToString() : null,
                            SecondName = item["strSecondName"] != null && !string.IsNullOrEmpty(item["strSecondName"].ToString()) ? item["strSecondName"].ToString() : null,
                            LastName = item["strSecondName"] != null && !string.IsNullOrEmpty(item["strLastName"].ToString()) ? item["strLastName"].ToString() : null,
                            DateOfBirth = Common.GetDataForEmptyOrNullDateTimeJsonToken(item["datDateofBirth"]),
                            GenderTypeId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsHumanGender"]),
                            CitizenshipTypeId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfCitizenship"]),
                            ContactPhone = item["strContactPhone"] != null && !string.IsNullOrEmpty(item["strContactPhone"].ToString()) ? item["strContactPhone"].ToString() : null,
                            ContactPhoneTypeId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfContactPhoneType"])
                        };
                        var isForiegnAddress = !string.IsNullOrEmpty(item["blnForeignAddress"].ToString()) && Convert.ToBoolean(item["blnForeignAddress"].ToString());
                        if (isForiegnAddress)
                        {
                            contactItem.ForeignAddressString = item["strPatientAddressString"] != null && !string.IsNullOrEmpty(item["strPatientAddressString"].ToString()) ? item["strPatientAddressString"].ToString() : null;
                            contactItem.LocationId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsCountry"]);
                        }
                        else
                        {
                            contactItem.Street = item["strStreetName"] != null && !string.IsNullOrEmpty(item["strStreetName"].ToString()) ? item["strStreetName"].ToString() : null;
                            contactItem.PostalCode = item["strPostCode"] != null && !string.IsNullOrEmpty(item["strPostCode"].ToString()) ? item["strPostCode"].ToString() : null;
                            contactItem.House = item["strHouse"] != null && !string.IsNullOrEmpty(item["strHouse"].ToString()) ? item["strHouse"].ToString() : null;
                            contactItem.Building = item["strBuilding"] != null && !string.IsNullOrEmpty(item["strBuilding"].ToString()) ? item["strBuilding"].ToString() : null;
                            contactItem.Apartment = item["strApartment"] != null && !string.IsNullOrEmpty(item["strApartment"].ToString()) ? item["strApartment"].ToString() : null;

                            contactItem.Apartment = item["strApartment"] != null && !string.IsNullOrEmpty(item["strApartment"].ToString()) ? item["strApartment"].ToString() : null;
                            contactItem.LocationId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsSettlement"]);
                            if (contactItem.LocationId == null || contactItem.LocationId == 0)
                            {
                                contactItem.LocationId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsRayon"]);
                            }
                            if (contactItem.LocationId == null || contactItem.LocationId == 0)
                            {
                                contactItem.LocationId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsRegion"]);
                            }
                            if (contactItem.LocationId == null || contactItem.LocationId == 0)
                            {
                                contactItem.LocationId = Common.GetDataForEmptyOrNullLongJsonToken(item["idfsCountry"]);
                            }
                        }

                        contactItem.RowStatus = Common.GetDataForintJsonToken(item["rowStatus"]);

                        contactItem.RowAction = Common.GetDataForintJsonToken(item["rowAction"]);
                        contactItem.RowAction = contactItem.RowAction == 0 ? 2 : contactItem.RowAction;

                        if (contactItem.RowAction == 2)
                            contactItem.AddressId = Common.GetDataForEmptyOrNullLongJsonToken(item["addressID"]);

                        contactItem.AuditUserName = _authenticatedUser.UserName;
                        contactList.Add(contactItem);
                    }

                    var serContactModelNew = JsonConvert.SerializeObject(contactList);
                    request.ContactsParameters = serContactModelNew;
                }
            }

            //Final Outcome

            var finalOutcomeModel = jsonObject["finalOutcomeModel"].ToString();
            if (finalOutcomeModel != null && finalOutcomeModel != "")
            {
                var parsedFinalOutcomeModel = JObject.Parse(finalOutcomeModel);
                request.idfsFinalCaseStatus = Common.GetDataForEmptyOrNullLongJsonToken(parsedFinalOutcomeModel["idfsFinalCaseStatus"]);
                request.idfsOutcome = Common.GetDataForEmptyOrNullLongJsonToken(parsedFinalOutcomeModel["idfsOutCome"]);

                //date
                request.DateofClassification = Common.GetDataForEmptyOrNullDateTimeJsonToken(parsedFinalOutcomeModel["datFinalCaseClassificationDate"]);
                request.datDateofDeath = Common.GetDataForEmptyOrNullDateTimeJsonToken(parsedFinalOutcomeModel["datDateOfDeath"]);
                request.datDischargeDate = Common.GetDataForEmptyOrNullDateTimeJsonToken(parsedFinalOutcomeModel["datDateOfDischarge"]);
				//boolean
				request.blnClinicalDiagBasis = parsedFinalOutcomeModel["blnClinicalDiagBasis"] != null && !string.IsNullOrEmpty(parsedFinalOutcomeModel["blnClinicalDiagBasis"].ToString()) && Convert.ToBoolean(parsedFinalOutcomeModel["blnClinicalDiagBasis"].ToString());
                request.blnEpiDiagBasis = parsedFinalOutcomeModel["blnEpiDiagBasis"] != null && !string.IsNullOrEmpty(parsedFinalOutcomeModel["blnEpiDiagBasis"].ToString()) && Convert.ToBoolean(parsedFinalOutcomeModel["blnEpiDiagBasis"].ToString());
                request.blnLabDiagBasis = parsedFinalOutcomeModel["blnLabDiagBasis"] != null && !string.IsNullOrEmpty(parsedFinalOutcomeModel["blnLabDiagBasis"].ToString()) && Convert.ToBoolean(parsedFinalOutcomeModel["blnLabDiagBasis"].ToString());

                request.idfInvestigatedByPerson = Common.GetDataForEmptyOrNullLongJsonToken(parsedFinalOutcomeModel["idfInvestigatedByPerson"]);
                request.strEpidemiologistsName = parsedFinalOutcomeModel["strEpidemiologistsName"] != null && !string.IsNullOrEmpty(parsedFinalOutcomeModel["strEpidemiologistsName"].ToString()) ? parsedFinalOutcomeModel["strEpidemiologistsName"].ToString() : null;
                request.strSummaryNotes = parsedFinalOutcomeModel["comments"] != null && !string.IsNullOrEmpty(parsedFinalOutcomeModel["comments"].ToString()) ? parsedFinalOutcomeModel["comments"].ToString() : null;

                if (parsedFinalOutcomeModel["events"] != null)
                {
                    var BlazerNotification = parsedFinalOutcomeModel["events"];
                    DesNotifications.AddRange(BlazerNotification.Select(item => new EventSaveRequestModel()
                    {
                        EventId = Common.GetDataForlongJsonToken(item["eventId"]),
                        LoginSiteId = Convert.ToInt64(_authenticatedUser.SiteId),
                        ObjectId = Common.GetDataForEmptyOrNullLongJsonToken(item["objectId"]),
                        DiseaseId = Common.GetDataForlongJsonToken(item["diseaseId"]),
                        EventTypeId = !string.IsNullOrEmpty(item["eventTypeId"].ToString()) && long.Parse(item["eventTypeId"].ToString()) != 0 ? long.Parse(item["eventTypeId"].ToString()) : null,
                        InformationString = !string.IsNullOrEmpty(item["informationString"].ToString()) ? item["informationString"].ToString() : null,
                        SiteId = Common.GetDataForEmptyOrNullLongJsonToken(item["siteId"]), //site id of where the record was created.
                        UserId = Common.GetDataForEmptyOrNullLongJsonToken(item["userId"]),
                        LocationId = Common.GetDataForEmptyOrNullLongJsonToken(item["locationId"])
                    }));
                }
            }

            request.AuditUser = _authenticatedUser.UserName;

            if (request.idfHumanCase == null)
            {
                DesNotifications.Add(await _notificationService.CreateEvent(0, request.idfsFinalDiagnosis, SystemEventLogTypes.NewHumanDiseaseReportWasCreatedAtYourSite, long.Parse(_authenticatedUser.SiteId), null));
            }
            request.Events = JsonConvert.SerializeObject(DesNotifications);

            var result = await _humanDiseaseReportClient.SaveHumanDiseaseReport(request);
            if (result.Count > 0)
            {
                await UpdateHumanActual(jsonObject);

                response = result.FirstOrDefault();
                response.IsFromWHOExport = IsFromWHOExport;
                if (request.idfHumanCase is null or 0)
                {
                    response.Header = string.Format(_localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading));
                    response.ReturnMessage = string.Format(_localizer.GetString(MessageResourceKeyConstants.HumanDiseaseReportYouSuccessfullyCreatedANewDiseaseReportInTheEIDSSSystemTheEIDSSIDIsMessage), response.strHumanCaseID);
                    _httpContextAccessor.HttpContext.Response.Cookies.Delete("HDRNotifications");
                }
                else if (request.idfHumanCase != null && request.idfHumanCase != 0)
                {
                        response.ReturnMessage = _localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage);
                        _httpContextAccessor.HttpContext.Response.Cookies.Delete("HDRNotifications");
                }
            }
            return Ok(response);
        }

        private async Task UpdateHumanActual(JObject jsonObject)
        {
            var humanActualId = GetHumanActualId(jsonObject);
            if (humanActualId == null)
            {
                return;
            }

            var request = new UpdateHumanActualRequestModel
            {
                HumanActualId = humanActualId.Value,
                DateOfBirth = GetDateOfBirth(jsonObject),
                DateOfDeath = Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["DateOfDeath"])
            };

            await _personClient.UpdatePersonAsync(request);
        }

        private static long? GetHumanActualId(JObject jsonObject)
        {
            return Common.GetDataForEmptyOrNullLongJsonToken(jsonObject["idfHumanActual"]);
        }

        private static DateTime? GetDateOfBirth(JObject jsonObject)
        {
            return Common.GetDataForEmptyOrNullDateTimeJsonToken(jsonObject["DateOfBirth"]);
        }

        [HttpPost]
        [Route("DeleteHumanDiseaseReport")]
        public async Task<IActionResult> DeleteHumanDiseaseReport([FromBody] JsonElement data)
        {
            var jsonObject = JObject.Parse(data.ToString() ?? string.Empty);
            long? idfHumanCase =
                !string.IsNullOrEmpty(jsonObject["idfHumanCase"]?.ToString()) &&
                long.Parse(jsonObject["idfHumanCase"].ToString()) != 0
                    ? long.Parse(jsonObject["idfHumanCase"].ToString())
                    : null;

            bool permission;

            if (_authenticatedUser.SiteTypeId >= (long)SiteTypes.ThirdLevel)
            {
                var permissionsRequest = new RecordPermissionsGetRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    RecordID = Convert.ToInt64(idfHumanCase),
                    UserEmployeeID = Convert.ToInt64(_authenticatedUser.PersonId),
                    UserOrganizationID = Convert.ToInt64(_authenticatedUser.OfficeId),
                    UserSiteID = Convert.ToInt64(_authenticatedUser.SiteId)
                };
                var diseaseReport =
                    await _humanDiseaseReportClient.GetHumanDiseaseDetailPermissions(permissionsRequest);
                if (diseaseReport.Any())
                {
                    if (diseaseReport.First().SiteID != Convert.ToInt64(_authenticatedUser.SiteId))
                        permission = diseaseReport.First().DeletePermissionIndicator;
                    else
                    {
                        var permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
                        permission = permissions.Delete;
                    }
                }
                else
                    permission = false;
            }
            else
            {
                var permissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
                permission = permissions.Delete;
            }

            var response = new APIPostResponseModel();

            if (permission)
            {
                response = await _humanDiseaseReportClient.DeleteHumanDiseaseReport(idfHumanCase,
                    Convert.ToInt64(_authenticatedUser.EIDSSUserId), Convert.ToInt64(_authenticatedUser.SiteId), false);
            }
            else
            {
                response.ReturnCode = 99;
                response.ReturnMessage = _localizer.GetString(MessageResourceKeyConstants
                    .WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage);
            }

            return Json(response);
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

                if (gender != null)
                {
                    var response = await _diseaseHumanGenderMatrixClient.GetGenderForDiseaseOrDiagnosisGroupMatrix(request);
                    if (response != null && response.Count > 0)
                    {
                        if (response.FirstOrDefault().GenderID != gender)
                        {
                            isInValid = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return isInValid;
        }

        public async Task<bool> CheckDiseaseForAgeGroup(string data)
        {
            JObject jsonObject = JObject.Parse(data);
            long? disease = !string.IsNullOrEmpty(jsonObject["disease"].ToString()) && long.Parse(jsonObject["disease"].ToString()) != 0 ? long.Parse(jsonObject["disease"].ToString()) : null;
            long? reportedAge = !string.IsNullOrEmpty(jsonObject["reportedAge"].ToString()) && long.Parse(jsonObject["reportedAge"].ToString()) != 0
                ? long.Parse(jsonObject["reportedAge"].ToString()) : null;
            long? reportedAgeUOMID = !string.IsNullOrEmpty(jsonObject["reportedAgeUOMID"].ToString()) && long.Parse(jsonObject["reportedAgeUOMID"].ToString()) != 0
                ? long.Parse(jsonObject["reportedAgeUOMID"].ToString()) : null;
            bool isInValid = false;

            try
            {
                if (reportedAge != null && reportedAgeUOMID != null)
                {
                    var request = new DiseaseAgeGroupGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        IdfsDiagnosis = disease,
                        Page = 1,
                        PageSize = 50,
                        SortColumn = "idfDiagnosisAgeGroupToDiagnosis",
                        SortOrder = SortConstants.Ascending.ToLower()
                    };
                    var response = await _diseaseAgeGroupClient.GetDiseaseAgeGroupMatrix(request);
                    var requestAG = new AgeGroupGetRequestModel()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = 50,
                        SortColumn = "Intorder",
                        SortOrder = SortConstants.Ascending.ToLower()
                    };
                    var responseAG = await _adminClient.GetAgeGroupList(requestAG);

                    if (response != null && response.Count > 0 && responseAG != null && responseAG.ToList().Count > 0)
                    {
                        var ageGroup = responseAG.ToList()
                            .FirstOrDefault(x => x.idfsAgeType == reportedAgeUOMID && response.Select(y => y.IdfsDiagnosisAgeGroup).Contains(x.KeyId)
                                && reportedAge >= x.IntLowerBoundary && reportedAge <= x.IntUpperBoundary);
                        if (ageGroup == null)
                        {
                            isInValid = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return isInValid;
        }

        public async Task GetSiteAlertForInitialCaseClassification(string data)
        {
            JObject jsonObject = JObject.Parse(data);
            long? classification = !string.IsNullOrEmpty(jsonObject["idfCaseClassfication"].ToString()) && long.Parse(jsonObject["idfCaseClassfication"].ToString()) != 0 ? long.Parse(jsonObject["idfCaseClassfication"].ToString()) : null;
            long? idfHumanCase = !string.IsNullOrEmpty(jsonObject["idfHumanCase"].ToString()) && long.Parse(jsonObject["idfHumanCase"].ToString()) != 0 ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            long? idfHuman = !string.IsNullOrEmpty(jsonObject["idfHuman"].ToString()) && long.Parse(jsonObject["idfHuman"].ToString()) != 0 ? long.Parse(jsonObject["idfHuman"].ToString()) : null;
            long? idfsSite = !string.IsNullOrEmpty(jsonObject["idfsSite"].ToString()) && long.Parse(jsonObject["idfsSite"].ToString()) != 0 ? long.Parse(jsonObject["idfsSite"].ToString()) : null;
            long? diseaseID = !string.IsNullOrEmpty(jsonObject["DiseaseID"].ToString()) && long.Parse(jsonObject["DiseaseID"].ToString()) != 0 ? long.Parse(jsonObject["DiseaseID"].ToString()) : null;

            try
            {
                if (idfHumanCase != null)
                {
                    const SystemEventLogTypes eventTypeId = SystemEventLogTypes.HumanDiseaseReportClassificationWasChangedAtYourSite;
                    _notificationService.Events = JsonConvert.DeserializeObject<List<EventSaveRequestModel>>(Request.Cookies["HDRNotifications"] ?? string.Empty);

                    if (_notificationService.Events == null)
                    {
                        _notificationService.Events = new List<EventSaveRequestModel>();
                        _notificationService.Events.Add(await _notificationService.CreateEvent(idfHumanCase.Value, diseaseID, eventTypeId, idfsSite.Value, null));
                    }
                    else if (_notificationService.Events.All(x => x.EventTypeId != (long)eventTypeId))
                        _notificationService.Events.Add(await _notificationService.CreateEvent(idfHumanCase.Value, diseaseID, eventTypeId, idfsSite.Value, null));

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
            var jsonObject = JObject.Parse(data);

            long? idfHumanCase = !string.IsNullOrEmpty(jsonObject["idfHumanCase"].ToString()) && long.Parse(jsonObject["idfHumanCase"].ToString()) != 0 ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            long? idfsSite = !string.IsNullOrEmpty(jsonObject["idfsSite"].ToString()) && long.Parse(jsonObject["idfsSite"].ToString()) != 0 ? long.Parse(jsonObject["idfsSite"].ToString()) : null;
            long? diseaseID = !string.IsNullOrEmpty(jsonObject["DiseaseID"].ToString()) && long.Parse(jsonObject["DiseaseID"].ToString()) != 0 ? long.Parse(jsonObject["DiseaseID"].ToString()) : null;

            try
            {
                if (idfHumanCase != null)
                {
                    const SystemEventLogTypes eventTypeId = SystemEventLogTypes.ClosedHumanDiseaseReportWasReopenedAtYourSite;
                    _notificationService.Events = JsonConvert.DeserializeObject<List<EventSaveRequestModel>>(Request.Cookies["HDRNotifications"] ?? string.Empty);

                    if (_notificationService.Events == null)
                    {
                        _notificationService.Events = new List<EventSaveRequestModel>();
                        _notificationService.Events.Add(await _notificationService.CreateEvent(idfHumanCase.Value, diseaseID, eventTypeId, idfsSite.Value, null));
                    }
                    else if (_notificationService.Events.All(x => x.EventTypeId != (long)eventTypeId))
                        _notificationService.Events.Add(await _notificationService.CreateEvent(idfHumanCase.Value, diseaseID, eventTypeId, idfsSite.Value, null));

                    _httpContextAccessor.HttpContext.Response.Cookies.Append("HDRNotifications", JsonConvert.SerializeObject(_notificationService.Events));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        [HttpPost()]
        [Route("PrintHumanDiseaseReport")]
        public IActionResult PrintHumanDiseaseReport([FromBody] JsonElement data)
        {
            // Test showing a modal
            HumanSetDiseaseReportRequestModel request = new();
            SetHumanDiseaseReportResponseModel response = new();

            request.LanguageID = GetCurrentLanguage();
            var jsonObject = JObject.Parse(data.ToString());
            request.idfHumanCase = !string.IsNullOrEmpty(jsonObject["idfHumanCase"].ToString()) && long.Parse(jsonObject["idfHumanCase"].ToString()) != 0 ? long.Parse(jsonObject["idfHumanCase"].ToString()) : null;
            request.idfsSite = long.Parse(_authenticatedUser.SiteId);
            if (request.idfHumanCase != null && request.idfHumanCase != 0)
            {
                request.idfHuman = !string.IsNullOrEmpty(jsonObject["idfHuman"].ToString()) && long.Parse(jsonObject["idfHuman"].ToString()) != 0 ? long.Parse(jsonObject["idfHuman"].ToString()) : null;
                request.idfHumanActual = null;
                request.strHumanCaseId = jsonObject["strHumanCaseId"].ToString();
            }
            else
            {
                request.idfHumanActual = !string.IsNullOrEmpty(jsonObject["idfHumanActual"].ToString()) && long.Parse(jsonObject["idfHumanActual"].ToString()) != 0 ? long.Parse(jsonObject["idfHumanActual"].ToString()) : null;
                request.idfHuman = null;
            }

            var DesNotifications = Request.Cookies["HDRNotifications"] != null ? JsonConvert.DeserializeObject<List<EventSaveRequestModel>>(Request.Cookies["HDRNotifications"]) : null;
            DesNotifications ??= new List<EventSaveRequestModel>();

            request.DiseaseReportTypeID = !string.IsNullOrEmpty(jsonObject["DiseaseReportTypeID"].ToString()) && long.Parse(jsonObject["DiseaseReportTypeID"].ToString()) != 0 ? long.Parse(jsonObject["DiseaseReportTypeID"].ToString()) : null;
            request.idfsCaseProgressStatus = !string.IsNullOrEmpty(jsonObject["idfsCaseProgressStatus"].ToString()) && long.Parse(jsonObject["idfsCaseProgressStatus"].ToString()) != 0 ? long.Parse(jsonObject["idfsCaseProgressStatus"].ToString()) : null;
            request.idfPersonEnteredBy = long.Parse(_authenticatedUser.PersonId);
            request.idfsFinalDiagnosis = jsonObject["diseaseDD"] != null && long.Parse(jsonObject["diseaseDD"].ToString()) != 0 ? long.Parse(jsonObject["diseaseDD"].ToString()) : null;
            //Need to check the field for Current Location of Patient and Status of Patient at Notification
            request.idfsFinalState = !string.IsNullOrEmpty(jsonObject["statusOfPatientAtNotificationDD"].ToString()) && long.Parse(jsonObject["statusOfPatientAtNotificationDD"].ToString()) != 0 ? long.Parse(jsonObject["statusOfPatientAtNotificationDD"].ToString()) : null;
            request.idfSentByOffice = !string.IsNullOrEmpty(jsonObject["notificationSentByFacilityDD"].ToString()) && long.Parse(jsonObject["notificationSentByFacilityDD"].ToString()) != 0 ? long.Parse(jsonObject["notificationSentByFacilityDD"].ToString()) : null;
            request.idfSentByPerson = !string.IsNullOrEmpty(jsonObject["notificationSentByNameDD"].ToString()) && long.Parse(jsonObject["notificationSentByNameDD"].ToString()) != 0 ? long.Parse(jsonObject["notificationSentByNameDD"].ToString()) : null;
            request.idfReceivedByOffice = !string.IsNullOrEmpty(jsonObject["notificationReceivedByFacilityDD"].ToString()) && long.Parse(jsonObject["notificationReceivedByFacilityDD"].ToString()) != 0 ? long.Parse(jsonObject["notificationReceivedByFacilityDD"].ToString()) : null;
            request.idfReceivedByPerson = !string.IsNullOrEmpty(jsonObject["notificationReceivedByNameDD"].ToString()) && long.Parse(jsonObject["notificationReceivedByNameDD"].ToString()) != 0 ? long.Parse(jsonObject["notificationReceivedByNameDD"].ToString()) : null;
            //Need to check the field for Current Location of Patient and Status of Patient at Notification
            request.idfsHospitalizationStatus = !string.IsNullOrEmpty(jsonObject["currentLocationOfPatientDD"].ToString()) && long.Parse(jsonObject["currentLocationOfPatientDD"].ToString()) != 0 ? long.Parse(jsonObject["currentLocationOfPatientDD"].ToString()) : null;
            request.idfHospital = !string.IsNullOrEmpty(jsonObject["hospitalNameDD"].ToString()) && long.Parse(jsonObject["hospitalNameDD"].ToString()) != 0 ? long.Parse(jsonObject["hospitalNameDD"].ToString()) : null;
            request.datCompletionPaperFormDate = string.IsNullOrEmpty(jsonObject["dateOfCompletion"].ToString()) ? null : DateTime.Parse(jsonObject["dateOfCompletion"].ToString());
            request.datDateOfDiagnosis = jsonObject["dateOfDiagnosis"] != null && !string.IsNullOrEmpty(jsonObject["dateOfDiagnosis"].ToString()) ? DateTime.Parse(jsonObject["dateOfDiagnosis"].ToString()) : null;
            request.datNotificationDate = jsonObject["dateOfNotification"] != null && !string.IsNullOrEmpty(jsonObject["dateOfNotification"].ToString()) ? DateTime.Parse(jsonObject["dateOfNotification"].ToString()) : null;

            request.strLocalIdentifier = jsonObject["strLocalIdentifier"].ToString();
            //Symptoms

            request.datOnSetDate = jsonObject["SymptomsOnsetDate"] != null && !string.IsNullOrEmpty(jsonObject["SymptomsOnsetDate"].ToString()) ? DateTime.Parse(jsonObject["SymptomsOnsetDate"].ToString()) : null;
            //Case Classification
            if (jsonObject["caseClassficationDD"] != null)
            {
                request.idfsInitialCaseStatus =
                    !string.IsNullOrEmpty(jsonObject["caseClassficationDD"].ToString()) &&
                    long.Parse(jsonObject["caseClassficationDD"].ToString()) != 0
                        ? long.Parse(jsonObject["caseClassficationDD"].ToString())
                        : null;
            }

            request.idfCSObservation = jsonObject["idfCSObservation"] != null && !string.IsNullOrEmpty(jsonObject["idfCSObservation"].ToString()) && long.Parse(jsonObject["idfCSObservation"].ToString()) != 0 ? long.Parse(jsonObject["idfCSObservation"].ToString()) : null;

            //Facility Details
            request.idfsYNPreviouslySoughtCare = jsonObject["idfsYNPreviouslySoughtCare"] != null && !string.IsNullOrEmpty(jsonObject["idfsYNPreviouslySoughtCare"].ToString()) && long.Parse(jsonObject["idfsYNPreviouslySoughtCare"].ToString()) != 0 ? long.Parse(jsonObject["idfsYNPreviouslySoughtCare"].ToString()) : null;
            request.idfSoughtCareFacility = !string.IsNullOrEmpty(jsonObject["idfSoughtCareFacility"].ToString()) && long.Parse(jsonObject["idfSoughtCareFacility"].ToString()) != 0 ? long.Parse(jsonObject["idfSoughtCareFacility"].ToString()) : null;
            request.idfsNonNotIFiableDiagnosis = !string.IsNullOrEmpty(jsonObject["idfsNonNotIFiableDiagnosis"].ToString()) && long.Parse(jsonObject["idfsNonNotIFiableDiagnosis"].ToString()) != 0 ? long.Parse(jsonObject["idfsNonNotIFiableDiagnosis"].ToString()) : null;
            request.idfsYNHospitalization = !string.IsNullOrEmpty(jsonObject["idfsYNHospitalization"].ToString()) && long.Parse(jsonObject["idfsYNHospitalization"].ToString()) != 0 ? long.Parse(jsonObject["idfsYNHospitalization"].ToString()) : null;

            request.datFirstSoughtCareDate = jsonObject["datFirstSoughtCareDate"] != null && !string.IsNullOrEmpty(jsonObject["datFirstSoughtCareDate"].ToString()) ? DateTime.Parse(jsonObject["datFirstSoughtCareDate"].ToString()) : null;
            request.datHospitalizationDate = jsonObject["datHospitalizationDate"] != null && !string.IsNullOrEmpty(jsonObject["datHospitalizationDate"].ToString()) ? DateTime.Parse(jsonObject["datHospitalizationDate"].ToString()) : null;
            request.idfHospital = !string.IsNullOrEmpty(jsonObject["idfHospital"].ToString()) && long.Parse(jsonObject["idfHospital"].ToString()) != 0 ? long.Parse(jsonObject["idfHospital"].ToString()) : null;

            request.strHospitalName = string.IsNullOrEmpty(jsonObject["strHospitalName"].ToString()) ? null : jsonObject["strHospitalName"].ToString();
            request.strCurrentLocation = jsonObject["strOtherLocation"].ToString();

            //Antibiotic and Vaccination History
            var vaccinationAntiViralTherapies = jsonObject["vaccionationAntiViralTherapies"].ToString();
            var parsedVaccinationAntiViralTherapiesModel = JObject.Parse(vaccinationAntiViralTherapies);

            request.idfsYNAntimicrobialTherapy = !string.IsNullOrEmpty(parsedVaccinationAntiViralTherapiesModel["idfsYNAntimicrobialTherapy"].ToString()) && long.Parse(parsedVaccinationAntiViralTherapiesModel["idfsYNAntimicrobialTherapy"].ToString()) != 0 ? long.Parse(parsedVaccinationAntiViralTherapiesModel["idfsYNAntimicrobialTherapy"].ToString()) : null;
            request.idfsYNSpecIFicVaccinationAdministered = !string.IsNullOrEmpty(parsedVaccinationAntiViralTherapiesModel["idfsYNSpecificVaccinationAdministered"].ToString()) && long.Parse(parsedVaccinationAntiViralTherapiesModel["idfsYNSpecificVaccinationAdministered"].ToString()) != 0 ? long.Parse(parsedVaccinationAntiViralTherapiesModel["idfsYNSpecificVaccinationAdministered"].ToString()) : null;
            request.strClinicalNotes = parsedVaccinationAntiViralTherapiesModel["additionalInforMation"].ToString();

            //Vaccination List
            var vaccinationList = parsedVaccinationAntiViralTherapiesModel["vaccinationHistory"];
            var serVaccinationList = JsonConvert.SerializeObject(vaccinationList);
            if (serVaccinationList == "[]")
            {
                request.VaccinationsParameters = null;
            }
            else
            {
                request.VaccinationsParameters = serVaccinationList;
            }

            //Antiviral Therapies List
            var antibioticsHistory = parsedVaccinationAntiViralTherapiesModel["antibioticsHistory"];
            var serAntibioticsHistory = JsonConvert.SerializeObject(antibioticsHistory);
            if (serAntibioticsHistory == "[]")
            {
                request.AntiviralTherapiesParameters = null;
            }
            else
            {
                request.AntiviralTherapiesParameters = serAntibioticsHistory;
            }

            //Samples
            //where Local Identifier Goes
            var sampleModel = jsonObject["sampleModel"].ToString();
            var parsedSamples = JObject.Parse(sampleModel);
            request.idfsYNSpecimenCollected = !string.IsNullOrEmpty(parsedSamples["samplesCollectedYN"].ToString()) && long.Parse(parsedSamples["samplesCollectedYN"].ToString()) != 0 ? long.Parse(parsedSamples["samplesCollectedYN"].ToString()) : null;
            request.idfsNotCollectedReason = !string.IsNullOrEmpty(parsedSamples["reasonID"].ToString()) && long.Parse(parsedSamples["reasonID"].ToString()) != 0 ? long.Parse(parsedSamples["reasonID"].ToString()) : null;

            //Sample List
            var sampleDetails = parsedSamples["samplesDetails"];
            List<SampleSaveRequestModel> samples = new();

            foreach (var item in sampleDetails)
            {
                SampleSaveRequestModel Sample = new()
                {
                    SampleTypeID = !string.IsNullOrEmpty(item["sampleTypeID"].ToString()) && long.Parse(item["sampleTypeID"].ToString()) != 0 ? long.Parse(item["sampleTypeID"].ToString()) : null
                };
                var blnNumberingSchema = !string.IsNullOrEmpty(item["blnNumberingSchema"].ToString()) && int.Parse(item["blnNumberingSchema"].ToString()) != 0 ? int.Parse(item["blnNumberingSchema"].ToString()) : 0;
                if (blnNumberingSchema == 1 || blnNumberingSchema == 2)
                {
                    Sample.EIDSSLocalOrFieldSampleID = "";
                }
                else
                {
                    Sample.EIDSSLocalOrFieldSampleID = !string.IsNullOrEmpty(item["localSampleId"].ToString()) ? item["localSampleId"].ToString() : null;
                }
                if (!string.IsNullOrEmpty(item["collectionDate"].ToString()))
                {
                    Sample.CollectionDate = DateTime.Parse(item["collectionDate"].ToString());
                }
                Sample.CollectedByOrganizationID = !string.IsNullOrEmpty(item["collectedByOrganizationID"].ToString()) && long.Parse(item["collectedByOrganizationID"].ToString()) != 0 ? long.Parse(item["collectedByOrganizationID"].ToString()) : null;
                Sample.CollectedByPersonID = !string.IsNullOrEmpty(item["collectedByOfficerID"].ToString()) && long.Parse(item["collectedByOfficerID"].ToString()) != 0 ? long.Parse(item["collectedByOfficerID"].ToString()) : null;
                if (!string.IsNullOrEmpty(item["sentDate"].ToString()))
                {
                    Sample.SentDate = DateTime.Parse(item["sentDate"].ToString());
                }
                Sample.SentToOrganizationID = !string.IsNullOrEmpty(item["sentToOrganizationID"].ToString()) && long.Parse(item["sentToOrganizationID"].ToString()) != 0 ? long.Parse(item["sentToOrganizationID"].ToString()) : null;

                Sample.SiteID = !string.IsNullOrEmpty(item["idfsSiteSentToOrg"].ToString()) ? long.Parse(item["idfsSiteSentToOrg"].ToString()) : 1;

                Sample.DiseaseID = request.idfsFinalDiagnosis;
                Sample.SampleID = !string.IsNullOrEmpty(item["idfMaterial"].ToString()) && long.Parse(item["idfMaterial"].ToString()) != 0 ? long.Parse(item["idfMaterial"].ToString()) : 0;
                if (Sample.SampleID == 0)
                    Sample.SampleID = item["newRecordId"] != null ? long.Parse(item["newRecordId"].ToString()) : 1;
                Sample.RowStatus = !string.IsNullOrEmpty(item["intRowStatus"].ToString()) && int.Parse(item["intRowStatus"].ToString()) != 0 ? int.Parse(item["intRowStatus"].ToString()) : 0;
                Sample.CurrentSiteID = null;
                Sample.HumanMasterID = request.idfHumanActual;
                Sample.HumanID = request.idfHuman;
                Sample.HumanDiseaseReportID = request.idfHumanCase;
                Sample.RowAction = item["rowAction"] != null ? int.Parse(item["rowAction"].ToString()) : 2;
                Sample.ReadOnlyIndicator = false;
                samples.Add(Sample);
            }

            var strSamplesNew = System.Text.Json.JsonSerializer.Serialize(samples);

            if (strSamplesNew == "[]")
            {
                request.SamplesParameters = null;
            }
            else
            {
                request.SamplesParameters = strSamplesNew;
            }

            //Test

            var testModel = jsonObject["testModel"].ToString();
            var parsedTests = JObject.Parse(testModel);

            var parsedtestNotifications = parsedTests["notifications"];

            foreach (var item in parsedtestNotifications)
            {
                EventSaveRequestModel testNotification = new()
                {
                    EventId = Common.GetDataForlongJsonToken(item["notificationID"]),
                    LoginSiteId = Convert.ToInt64(authenticatedUser.SiteId),
                    ObjectId = Common.GetDataForEmptyOrNullLongJsonToken(item["notificationObjectID"]),
                    DiseaseId = Common.GetDataForlongJsonToken(item["idfsDiagnosis"]),
                    EventTypeId = !string.IsNullOrEmpty(item["notificationTypeID"].ToString()) && long.Parse(item["notificationTypeID"].ToString()) != 0 ? long.Parse(item["notificationTypeID"].ToString()) : null,
                    InformationString = !string.IsNullOrEmpty(item["payload"].ToString()) ? item["payload"].ToString() : null,
                    SiteId = Common.GetDataForEmptyOrNullLongJsonToken(item["targetSiteID"]), //site id of where the record was created.
                    UserId = Common.GetDataForEmptyOrNullLongJsonToken(item["userID"])
                };

                DesNotifications.Add(testNotification);
            }
            //Test List
            var testDetails = parsedTests["testDetails"];

            List<LaboratoryTestSaveRequestModel> tests = new();
            List<LaboratoryTestInterpretationSaveRequestModel> testInterpretations = new();
            var count = 0;
            foreach (var item in testDetails)
            {
                LaboratoryTestSaveRequestModel testRequest = new();
                LaboratoryTestInterpretationSaveRequestModel interpretationRequest = new();
                testRequest.SampleID = !string.IsNullOrEmpty(item["idfMaterial"].ToString()) && long.Parse(item["idfMaterial"].ToString()) != 0 ? long.Parse(item["idfMaterial"].ToString()) : null;

                testRequest.TestID = !string.IsNullOrEmpty(item["idfTesting"].ToString()) && long.Parse(item["idfTesting"].ToString()) != 0 ? long.Parse(item["idfTesting"].ToString()) : 0;
                if (testRequest.TestID == 0)
                {
                    count++;
                    testRequest.TestID = count;
                }
                testRequest.HumanDiseaseReportID = !string.IsNullOrEmpty(item["idfHumanCase"].ToString()) && long.Parse(item["idfHumanCase"].ToString()) != 0 ? long.Parse(item["idfHumanCase"].ToString()) : null;
                testRequest.TestCategoryTypeID = !string.IsNullOrEmpty(item["idfsTestCategory"].ToString()) && long.Parse(item["idfsTestCategory"].ToString()) != 0 ? long.Parse(item["idfsTestCategory"].ToString()) : null;
                testRequest.TestNameTypeID = !string.IsNullOrEmpty(item["idfsTestName"].ToString()) && long.Parse(item["idfsTestName"].ToString()) != 0 ? long.Parse(item["idfsTestName"].ToString()) : null;
                testRequest.TestResultTypeID = !string.IsNullOrEmpty(item["idfsTestResult"].ToString()) && long.Parse(item["idfsTestResult"].ToString()) != 0 ? long.Parse(item["idfsTestResult"].ToString()) : null;
                testRequest.TestStatusTypeID = !string.IsNullOrEmpty(item["idfsTestStatus"].ToString()) && long.Parse(item["idfsTestStatus"].ToString()) != 0 ? long.Parse(item["idfsTestStatus"].ToString()) : 0;
                if (!string.IsNullOrEmpty(item["datSampleStatusDate"].ToString()))
                {
                    testRequest.ResultDate = DateTime.Parse(item["datSampleStatusDate"].ToString());
                }
                if (!string.IsNullOrEmpty(item["datFieldCollectionDate"].ToString()))
                {
                    testRequest.ReceivedDate = DateTime.Parse(item["datFieldCollectionDate"].ToString());
                }
                testRequest.TestedByPersonID = !string.IsNullOrEmpty(item["idfTestedByPerson"].ToString()) && long.Parse(item["idfTestedByPerson"].ToString()) != 0 ? long.Parse(item["idfTestedByPerson"].ToString()) : null;
                testRequest.TestedByOrganizationID = !string.IsNullOrEmpty(item["idfTestedByOffice"].ToString()) && long.Parse(item["idfTestedByOffice"].ToString()) != 0 ? long.Parse(item["idfTestedByOffice"].ToString()) : null;
                testRequest.RowStatus = !string.IsNullOrEmpty(item["intRowStatus"].ToString()) && int.Parse(item["intRowStatus"].ToString()) != 0 ? int.Parse(item["intRowStatus"].ToString()) : 0;

                testRequest.HumanDiseaseReportID = request.idfHumanCase;
                testRequest.RowAction = item["rowAction"] != null ? int.Parse(item["rowAction"].ToString()) : 2;
                testRequest.ReadOnlyIndicator = false;
                testRequest.DiseaseID = !string.IsNullOrEmpty(item["idfsDiagnosis"].ToString()) && long.Parse(item["idfsDiagnosis"].ToString()) != 0 ? long.Parse(item["idfsDiagnosis"].ToString()) : 0;
                testRequest.NonLaboratoryTestIndicator = !string.IsNullOrEmpty(item["blnNonLaboratoryTest"].ToString()) && Convert.ToBoolean(item["blnNonLaboratoryTest"].ToString());

                interpretationRequest.TestID = testRequest.TestID;
                interpretationRequest.TestInterpretationID = !string.IsNullOrEmpty(item["idfTestValidation"].ToString()) && long.Parse(item["idfTestValidation"].ToString()) != 0 ? long.Parse(item["idfTestValidation"].ToString()) : 0;
                interpretationRequest.InterpretedByPersonID = !string.IsNullOrEmpty(item["idfInterpretedByPerson"].ToString()) && long.Parse(item["idfInterpretedByPerson"].ToString()) != 0 ? long.Parse(item["idfInterpretedByPerson"].ToString()) : null;
                interpretationRequest.InterpretedStatusTypeID = !string.IsNullOrEmpty(item["idfsInterpretedStatus"].ToString()) && long.Parse(item["idfsInterpretedStatus"].ToString()) != 0 ? long.Parse(item["idfsInterpretedStatus"].ToString()) : null;
                if (!string.IsNullOrEmpty(item["datInterpretedDate"].ToString()))
                {
                    interpretationRequest.InterpretedDate = DateTime.Parse(item["datInterpretedDate"].ToString());
                }
                interpretationRequest.InterpretedComment = item["strInterpretedComment"].ToString();
                interpretationRequest.ValidatedByPersonID = !string.IsNullOrEmpty(item["idfValidatedByPerson"].ToString()) && long.Parse(item["idfValidatedByPerson"].ToString()) != 0 ? long.Parse(item["idfValidatedByPerson"].ToString()) : null;

                if (!string.IsNullOrEmpty(item["datValidationDate"].ToString()))
                {
                    interpretationRequest.ValidatedDate = DateTime.Parse(item["datValidationDate"].ToString());
                }
                interpretationRequest.ValidatedComment = item["strValidateComment"].ToString();
                interpretationRequest.RowStatus = !string.IsNullOrEmpty(item["intRowStatus"].ToString()) && int.Parse(item["intRowStatus"].ToString()) != 0 ? int.Parse(item["intRowStatus"].ToString()) : 0;
                interpretationRequest.ValidatedStatusIndicator = !string.IsNullOrEmpty(item["blnValidateStatus"].ToString()) && Convert.ToBoolean(item["blnValidateStatus"].ToString());
                interpretationRequest.DiseaseID = request.idfHumanCase;
                interpretationRequest.RowAction = item["rowAction"] != null ? int.Parse(item["rowAction"].ToString()) : 2;
                interpretationRequest.ReadOnlyIndicator = false;
                interpretationRequest.DiseaseID = !string.IsNullOrEmpty(item["idfsDiagnosis"].ToString()) && long.Parse(item["idfsDiagnosis"].ToString()) != 0 ? long.Parse(item["idfsDiagnosis"].ToString()) : 0;
                tests.Add(testRequest);
                testInterpretations.Add(interpretationRequest);
            }

            var strTestNew = System.Text.Json.JsonSerializer.Serialize(tests);

            if (strTestNew == "[]")
            {
                request.TestsParameters = null;
            }
            else
            {
                request.TestsParameters = strTestNew;
            }

            var strTestInterpretation = System.Text.Json.JsonSerializer.Serialize(testInterpretations);

            if (strTestInterpretation == "[]")
            {
                request.TestsInterpretationParameters = null;
            }
            else
            {
                request.TestsInterpretationParameters = strTestInterpretation;
            }
            //Case Investigation Details

            request.StartDateofInvestigation = string.IsNullOrEmpty(jsonObject["StartDateofInvestigation"].ToString()) ? null : DateTime.Parse(jsonObject["StartDateofInvestigation"].ToString());
            request.datExposureDate = string.IsNullOrEmpty(jsonObject["datExposureDate"].ToString()) ? null : DateTime.Parse(jsonObject["datExposureDate"].ToString());

            request.idfInvestigatedByOffice = !string.IsNullOrEmpty(jsonObject["idfInvestigatedByOffice"].ToString()) && long.Parse(jsonObject["idfInvestigatedByOffice"].ToString()) != 0 ? long.Parse(jsonObject["idfInvestigatedByOffice"].ToString()) : null;
            request.idfOutbreak = !string.IsNullOrEmpty(jsonObject["idfOutbreak"].ToString()) && long.Parse(jsonObject["idfOutbreak"].ToString()) != 0 ? long.Parse(jsonObject["idfOutbreak"].ToString()) : null;
            request.strNote = !string.IsNullOrEmpty(jsonObject["strNote"].ToString()) ? jsonObject["strNote"].ToString() : null;

            request.idfsYNExposureLocationKnown = jsonObject["idfsYNExposureLocationKnown"] != null && !string.IsNullOrEmpty(jsonObject["idfsYNExposureLocationKnown"].ToString()) ? long.Parse(jsonObject["idfsYNExposureLocationKnown"].ToString()) : null;
            request.idfsGeoLocationType = jsonObject["idfsGeoLocationType"] != null && long.Parse(jsonObject["idfsGeoLocationType"].ToString()) != 0 ? long.Parse(jsonObject["idfsGeoLocationType"].ToString()) : null;
            request.idfPointGeoLocation = jsonObject["idfPointGeoLocation"] != null && jsonObject["idfPointGeoLocation"].ToString() != "" ? long.Parse(jsonObject["idfPointGeoLocation"].ToString()) : null;

            if (request.idfsGeoLocationType != null && request.idfsGeoLocationType != 0 && (request.idfsGeoLocationType == EIDSSConstants.GeoLocationTypes.ExactPoint ||
                request.idfsGeoLocationType == EIDSSConstants.GeoLocationTypes.RelativePoint)
                )
            {
                request.idfsLocationCountry = long.Parse(CountryId);
            }

            request.idfsLocationRegion = jsonObject["idfsLocationRegion"] != null && !string.IsNullOrEmpty(jsonObject["idfsLocationRegion"].ToString()) && long.Parse(jsonObject["idfsLocationRegion"].ToString()) != 0 ? long.Parse(jsonObject["idfsLocationRegion"].ToString()) : null;
            request.idfsLocationRayon = jsonObject["idfsLocationRayon"] != null && !string.IsNullOrEmpty(jsonObject["idfsLocationRayon"].ToString()) && long.Parse(jsonObject["idfsLocationRayon"].ToString()) != 0 ? long.Parse(jsonObject["idfsLocationRayon"].ToString()) : null;
            request.idfsLocationSettlement = jsonObject["idfsLocationSettlement"] != null && !string.IsNullOrEmpty(jsonObject["idfsLocationSettlement"].ToString()) && long.Parse(jsonObject["idfsLocationSettlement"].ToString()) != 0 ? long.Parse(jsonObject["idfsLocationSettlement"].ToString()) : null;

            request.intLocationLatitude = jsonObject["intLocationLatitude"] != null && !string.IsNullOrEmpty(jsonObject["intLocationLatitude"].ToString()) && double.Parse(jsonObject["intLocationLatitude"].ToString()) != 0 ? double.Parse(jsonObject["intLocationLatitude"].ToString()) : null;
            request.intLocationLongitude = jsonObject["intLocationLongitude"] != null && !string.IsNullOrEmpty(jsonObject["intLocationLongitude"].ToString()) && double.Parse(jsonObject["intLocationLongitude"].ToString()) != 0 ? double.Parse(jsonObject["intLocationLongitude"].ToString()) : null;
            request.intElevation = !string.IsNullOrEmpty(jsonObject["intElevation"].ToString()) && long.Parse(jsonObject["intElevation"].ToString()) != 0 ? long.Parse(jsonObject["intElevation"].ToString()) : null;
            request.idfsLocationGroundType = jsonObject["idfsLocationGroundType"] != null && !string.IsNullOrEmpty(jsonObject["idfsLocationGroundType"].ToString()) && double.Parse(jsonObject["idfsLocationGroundType"].ToString()) != 0 ? long.Parse(jsonObject["idfsLocationGroundType"].ToString()) : null;

            request.intLocationDistance = jsonObject["intLocationDistance"] != null && !string.IsNullOrEmpty(jsonObject["intLocationDistance"].ToString()) && double.Parse(jsonObject["intLocationDistance"].ToString()) != 0 ? double.Parse(jsonObject["intLocationDistance"].ToString()) : null;
            request.intLocationDirection = jsonObject["intLocationDirection"] != null && !string.IsNullOrEmpty(jsonObject["intLocationDirection"].ToString()) && double.Parse(jsonObject["intLocationDirection"].ToString()) != 0 ? double.Parse(jsonObject["intLocationDirection"].ToString()) : null;

            request.strForeignAddress = !string.IsNullOrEmpty(jsonObject["strForeignAddress"].ToString()) ? jsonObject["strForeignAddress"].ToString() : null;
            if (request.idfsGeoLocationType == EIDSSConstants.GeoLocationTypes.Foreign)
            {
                request.idfsLocationCountry = jsonObject["idfsLocationCountry"] != null && double.Parse(jsonObject["idfsLocationCountry"].ToString()) != 0 ? long.Parse(jsonObject["idfsLocationCountry"].ToString()) : null;
            }
            // Risk Factors
            request.idfEpiObservation = jsonObject["idfEpiObservation"] != null && !string.IsNullOrEmpty(jsonObject["idfEpiObservation"].ToString()) && long.Parse(jsonObject["idfEpiObservation"].ToString()) != 0 ? long.Parse(jsonObject["idfEpiObservation"].ToString()) : null;

            //Contact List
            if (jsonObject["contactsModel"] != null)
            {
                var contactModel = jsonObject["contactsModel"].ToString();
                var parsedContactModel = JObject.Parse(contactModel);
                if (parsedContactModel != null && parsedContactModel["contactDetails"] != null)
                {
                    var contactDetails = parsedContactModel["contactDetails"];
                    List<DiseaseReportContactSaveRequestModel> contactList = new();
                    var serContactModel = JsonConvert.SerializeObject(contactDetails);
                    request.ContactsParameters = serContactModel;
                    foreach (var item in contactDetails)
                    {
                        DiseaseReportContactSaveRequestModel contactItem = new()
                        {
                            HumanId = !string.IsNullOrEmpty(item["idfHuman"].ToString()) && long.Parse(item["idfHuman"].ToString()) != 0 ? long.Parse(item["idfHuman"].ToString()) : null,
                            HumanMasterId = !string.IsNullOrEmpty(item["idfHumanActual"].ToString()) && long.Parse(item["idfHumanActual"].ToString()) != 0 ? long.Parse(item["idfHumanActual"].ToString()) : null,
                            ContactTypeId = (long?)OutbreakContactTypeEnum.Human,
                            ContactedCasePersonId = !string.IsNullOrEmpty(item["idfContactedCasePerson"].ToString()) && long.Parse(item["idfContactedCasePerson"].ToString()) != 0 ? long.Parse(item["idfContactedCasePerson"].ToString()) : null,
                            DateOfLastContact = string.IsNullOrEmpty(item["datDateOfLastContact"].ToString()) ? null : DateTime.Parse(item["datDateOfLastContact"].ToString()),
                            PlaceOfLastContact = !string.IsNullOrEmpty(item["strPlaceInfo"].ToString()) ? item["strPlaceInfo"].ToString() : null,
                            ContactRelationshipTypeId = !string.IsNullOrEmpty(item["idfsPersonContactType"].ToString()) && long.Parse(item["idfsPersonContactType"].ToString()) != 0 ? long.Parse(item["idfsPersonContactType"].ToString()) : null,
                            Comments = !string.IsNullOrEmpty(item["strComments"].ToString()) ? item["strComments"].ToString() : null,
                            FirstName = !string.IsNullOrEmpty(item["strFirstName"].ToString()) ? item["strFirstName"].ToString() : null,
                            SecondName = !string.IsNullOrEmpty(item["strSecondName"].ToString()) ? item["strSecondName"].ToString() : null,
                            LastName = !string.IsNullOrEmpty(item["strLastName"].ToString()) ? item["strLastName"].ToString() : null,
                            DateOfBirth = string.IsNullOrEmpty(item["datDateofBirth"].ToString()) ? null : DateTime.Parse(item["datDateofBirth"].ToString()),
                            GenderTypeId = !string.IsNullOrEmpty(item["idfsHumanGender"].ToString()) && long.Parse(item["idfsHumanGender"].ToString()) != 0 ? long.Parse(item["idfsHumanGender"].ToString()) : null,
                            CitizenshipTypeId = !string.IsNullOrEmpty(item["idfCitizenship"].ToString()) && long.Parse(item["idfCitizenship"].ToString()) != 0 ? long.Parse(item["idfCitizenship"].ToString()) : null,
                            ContactPhone = !string.IsNullOrEmpty(item["strContactPhone"].ToString()) ? item["strContactPhone"].ToString() : null,
                            ContactPhoneTypeId = !string.IsNullOrEmpty(item["idfContactPhoneType"].ToString()) && long.Parse(item["idfContactPhoneType"].ToString()) != 0 ? long.Parse(item["idfContactPhoneType"].ToString()) : null
                        };

                        var isForiegnAddress = !string.IsNullOrEmpty(item["blnForeignAddress"].ToString()) && Convert.ToBoolean(item["blnForeignAddress"].ToString());

                        if (isForiegnAddress)
                        {
                            contactItem.ForeignAddressString = !string.IsNullOrEmpty(item["strPatientAddressString"].ToString()) ? item["strPatientAddressString"].ToString() : null;
                            contactItem.LocationId = !string.IsNullOrEmpty(item["idfsCountry"].ToString()) && long.Parse(item["idfsCountry"].ToString()) != 0 ? long.Parse(item["idfsCountry"].ToString()) : null;
                        }
                        else
                        {
                            contactItem.Street = !string.IsNullOrEmpty(item["strStreetName"].ToString()) ? item["strStreetName"].ToString() : null;
                            contactItem.PostalCode = !string.IsNullOrEmpty(item["strPostCode"].ToString()) ? item["strPostCode"].ToString() : null;
                            contactItem.House = !string.IsNullOrEmpty(item["strHouse"].ToString()) ? item["strHouse"].ToString() : null;
                            contactItem.Building = !string.IsNullOrEmpty(item["strBuilding"].ToString()) ? item["strBuilding"].ToString() : null;
                            contactItem.Apartment = !string.IsNullOrEmpty(item["strApartment"].ToString()) ? item["strApartment"].ToString() : null;
                            contactItem.LocationId = !string.IsNullOrEmpty(item["idfsSettlement"].ToString()) && long.Parse(item["idfsSettlement"].ToString()) != 0 ? long.Parse(item["idfsSettlement"].ToString()) : null;

                            if (contactItem.LocationId == null || contactItem.LocationId == 0)
                            {
                                contactItem.LocationId = !string.IsNullOrEmpty(item["idfsRayon"].ToString()) && long.Parse(item["idfsRayon"].ToString()) != 0 ? long.Parse(item["idfsRayon"].ToString()) : null;
                            }

                            if (contactItem.LocationId == null || contactItem.LocationId == 0)
                            {
                                contactItem.LocationId = !string.IsNullOrEmpty(item["idfsRegion"].ToString()) && long.Parse(item["idfsRegion"].ToString()) != 0 ? long.Parse(item["idfsRegion"].ToString()) : null;
                            }

                            if (contactItem.LocationId == null || contactItem.LocationId == 0)
                            {
                                contactItem.LocationId = !string.IsNullOrEmpty(item["idfsCountry"].ToString()) && long.Parse(item["idfsCountry"].ToString()) != 0 ? long.Parse(item["idfsCountry"].ToString()) : null;
                            }
                        }
                        if (contactItem.RowAction == 2)
                            contactItem.AddressId = !string.IsNullOrEmpty(item["addressID"].ToString()) && long.Parse(item["addressID"].ToString()) != 0 ? long.Parse(item["addressID"].ToString()) : null;

                        contactItem.RowStatus = !string.IsNullOrEmpty(item["rowStatus"].ToString()) && int.Parse(item["rowStatus"].ToString()) != 0 ? int.Parse(item["rowStatus"].ToString()) : 0;

                        contactItem.RowAction = item["rowAction"] != null ? int.Parse(item["rowAction"].ToString()) : 2;
                        contactItem.AuditUserName = _authenticatedUser.UserName;
                        contactList.Add(contactItem);
                    }

                    var serContactModelNew = JsonConvert.SerializeObject(contactList);
                    request.ContactsParameters = serContactModelNew;
                }
            }

            //Final Outcome
            var finalOutcomeModel = jsonObject["finalOutcomeModel"].ToString();
            if (finalOutcomeModel != null && finalOutcomeModel != "")
            {
                var parsedFinalOutcomeModel = JObject.Parse(finalOutcomeModel);
                request.idfsFinalCaseStatus = !string.IsNullOrEmpty(parsedFinalOutcomeModel["idfsFinalCaseStatus"].ToString()) && long.Parse(parsedFinalOutcomeModel["idfsFinalCaseStatus"].ToString()) != 0 ? long.Parse(parsedFinalOutcomeModel["idfsFinalCaseStatus"].ToString()) : null;
                request.idfsOutcome = !string.IsNullOrEmpty(parsedFinalOutcomeModel["idfsOutCome"].ToString()) && long.Parse(parsedFinalOutcomeModel["idfsOutCome"].ToString()) != 0 ? long.Parse(parsedFinalOutcomeModel["idfsOutCome"].ToString()) : null;

                //date
                request.DateofClassification = string.IsNullOrEmpty(parsedFinalOutcomeModel["datFinalCaseClassificationDate"].ToString()) ? null : DateTime.Parse(parsedFinalOutcomeModel["datFinalCaseClassificationDate"].ToString());
                request.datDateofDeath = string.IsNullOrEmpty(parsedFinalOutcomeModel["datDateOfDeath"].ToString()) ? null : DateTime.Parse(parsedFinalOutcomeModel["datDateOfDeath"].ToString());
				request.datDischargeDate = string.IsNullOrEmpty(parsedFinalOutcomeModel["datDateOfDischarge"].ToString()) ? null : DateTime.Parse(parsedFinalOutcomeModel["datDateOfDischarge"].ToString());
				//boolean
				request.blnClinicalDiagBasis = !string.IsNullOrEmpty(parsedFinalOutcomeModel["blnClinicalDiagBasis"].ToString()) && Convert.ToBoolean(parsedFinalOutcomeModel["blnClinicalDiagBasis"].ToString());
                request.blnEpiDiagBasis = !string.IsNullOrEmpty(parsedFinalOutcomeModel["blnEpiDiagBasis"].ToString()) && Convert.ToBoolean(parsedFinalOutcomeModel["blnEpiDiagBasis"].ToString());
                request.blnLabDiagBasis = !string.IsNullOrEmpty(parsedFinalOutcomeModel["blnLabDiagBasis"].ToString()) && Convert.ToBoolean(parsedFinalOutcomeModel["blnLabDiagBasis"].ToString());

                request.idfInvestigatedByPerson = !string.IsNullOrEmpty(parsedFinalOutcomeModel["idfInvestigatedByPerson"].ToString()) && long.Parse(parsedFinalOutcomeModel["idfInvestigatedByPerson"].ToString()) != 0 ? long.Parse(parsedFinalOutcomeModel["idfInvestigatedByPerson"].ToString()) : null;
                request.strEpidemiologistsName = !string.IsNullOrEmpty(parsedFinalOutcomeModel["strEpidemiologistsName"].ToString()) ? parsedFinalOutcomeModel["strEpidemiologistsName"].ToString() : null;
                request.strSummaryNotes = !string.IsNullOrEmpty(parsedFinalOutcomeModel["comments"].ToString()) ? parsedFinalOutcomeModel["comments"].ToString() : null;
                var BlazerNotification = parsedFinalOutcomeModel["notifications"];

                foreach (var item in BlazerNotification)
                {
                    EventSaveRequestModel notification = new()
                    {
                        EventId = Common.GetDataForlongJsonToken(item["notificationID"]),
                        LoginSiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        ObjectId = Common.GetDataForEmptyOrNullLongJsonToken(item["notificationObjectID"]),
                        DiseaseId = Common.GetDataForlongJsonToken(item["idfsDiagnosis"]),
                        EventTypeId = !string.IsNullOrEmpty(item["notificationTypeID"].ToString()) && long.Parse(item["notificationTypeID"].ToString()) != 0 ? long.Parse(item["notificationTypeID"].ToString()) : null,
                        InformationString = !string.IsNullOrEmpty(item["payload"].ToString()) ? item["payload"].ToString() : null,
                        SiteId = Common.GetDataForEmptyOrNullLongJsonToken(item["targetSiteID"]), //site id of where the record was created.
                        UserId = Common.GetDataForEmptyOrNullLongJsonToken(item["userID"])
                    };

                    DesNotifications.Add(notification);
                }
            }

            request.AuditUser = _authenticatedUser.UserName;
            request.Notifications = JsonConvert.SerializeObject(DesNotifications);

            return Ok(response);
        }
    }
}