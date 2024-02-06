#region Usings

using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Outbreak.ViewModels;
using EIDSS.Web.Areas.Outbreak.ViewModels.Case;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Areas.Outbreak.Controllers
{
    [Area("Outbreak")]
    [Controller]
    public class OutbreakCasesController : BaseController
    {
        private readonly OutbreakCasesViewModel _outbreakCasesViewModel;
        private readonly AuthenticatedUser _authenticatedUser;
        private readonly IOutbreakClient _outbreakClient;
        private readonly IVeterinaryClient _veterinaryClient;
        private UserPermissions _userPermissions;
        private readonly CancellationTokenSource _source;
        private readonly CancellationToken _token;
        private readonly IConfiguration _configuration;
        private readonly INotificationSiteAlertService _notificationService;
        private long _idfOutbreak;

        public OutbreakCasesController(IOutbreakClient outbreakClient,
            IVeterinaryClient veterinaryClient, INotificationSiteAlertService notificationSiteAlertService,
            ITokenService tokenService, ILogger<OutbreakPageController> logger, IConfiguration configuration, IStringLocalizer localizer) : base(logger, tokenService)
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _outbreakClient = outbreakClient;
            _veterinaryClient = veterinaryClient;
            _configuration = configuration;
            _notificationService = notificationSiteAlertService;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();

            _outbreakCasesViewModel = new OutbreakCasesViewModel
            {
                CurrentLanguage = GetCurrentLanguage(),
                ReportName = localizer.GetString(HeadingResourceKeyConstants.OutbreakManagementListOutbreakManagementListHeading),
                User = _authenticatedUser,
                SessionDetails = new OutbreakSessionDetailsResponseModel(),
                Cases = new List<CaseGetListViewModel>(),
                Update = new OutbreakSessionNoteDetailsViewModel(),
                OutbreakReportPrintViewModel = new OutbreakReportPrintViewModel()
                {
                    ReportHeader = "",
                    ReportName = ""
                }
            };

            _userPermissions = GetUserPermissions(PagePermission.AccessToHumanOutbreakContactsDataPerson);
            _outbreakCasesViewModel.ReadAccessToOutbreakHumanContactsDataPermissionIndicator = _userPermissions.Read;
            _userPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryOutbreakContactsDataPerson);
            _outbreakCasesViewModel.ReadAccessToOutbreakVeterinaryContactsDataPermissionIndicator = _userPermissions.Read;
            _userPermissions = GetUserPermissions(PagePermission.AccessToVectorSurveillanceSession);
            _outbreakCasesViewModel.ReadAccessToVectorSurveillanceSessionDataPermissionIndicator = _userPermissions.Read;

            _userPermissions = GetUserPermissions(PagePermission.AccessToOutbreakSessions);
        }

        public async Task<IActionResult> Index(long queryData, string tab = "", string ReturnMessage= "")
        {
            OutbreakSessionDetailRequestModel request = new()
            {
                LanguageID = GetCurrentLanguage(),
                idfsOutbreak = queryData
            };

            _idfOutbreak = queryData;

            if (!string.IsNullOrEmpty(tab))
            {
                _outbreakCasesViewModel.CasesTabClass = "nav-link";
                _outbreakCasesViewModel.CasesPaneClass = "tab-pane";

                switch (tab.ToLower())
                {
                    case "cases":
                        _outbreakCasesViewModel.CasesTabClass = "nav-link active";
                        _outbreakCasesViewModel.CasesPaneClass = "tab-pane active";
                        break;
                    case "contacts":
                        _outbreakCasesViewModel.ContactsTabClass = "nav-link active";
                        _outbreakCasesViewModel.ContactsPaneClass = "tab-pane active";
                        break;
                    case "analysis":
                        _outbreakCasesViewModel.AnalysisTabClass = "nav-link active";
                        _outbreakCasesViewModel.AnalysisPaneClass = "tab-pane active";
                        break;
                    case "updates":
                        _outbreakCasesViewModel.UpdatesTabClass = "nav-link active";
                        _outbreakCasesViewModel.UpdatesPaneClass = "tab-pane active";
                        break;
                    case "vector":
                        _outbreakCasesViewModel.VectorTabClass = "nav-link active";
                        _outbreakCasesViewModel.VectorPaneClass = "tab-pane active";
                        break;
                }
            }

            _outbreakCasesViewModel.idfOutbreak = queryData;
            _outbreakCasesViewModel.SessionDetails = _outbreakClient.GetSessionDetail(request).Result.FirstOrDefault();
            _outbreakCasesViewModel.OutbreakType = (OutbreakTypeEnum)_outbreakCasesViewModel.SessionDetails.OutbreakTypeId;
            _outbreakCasesViewModel.CancelURL = $"/Outbreak/OutbreakCases?queryData={queryData}";

            var heatMapRequest = new OutbreakHeatMapRequestModel
            {
                OutbreakId = (long)queryData
            };

            _outbreakCasesViewModel.HeatMapData = await _outbreakClient.GetHeatMapData(heatMapRequest);
            _outbreakCasesViewModel.EpiCurveParameters = new List<KeyValuePair<string, string>> {new KeyValuePair<string, string>("LangID", GetCurrentLanguage())};

            if (_outbreakCasesViewModel.SessionDetails.datStartDate != null)
            {
                _outbreakCasesViewModel.EpiCurveParameters.Add(new KeyValuePair<string, string>("SD", _outbreakCasesViewModel.SessionDetails.datStartDate.Value.ToString("d", cultureInfo)));
            }

            _outbreakCasesViewModel.EpiCurveParameters.Add(
                string.IsNullOrEmpty(_outbreakCasesViewModel.SessionDetails.datCloseDate.ToString())
                    ? new KeyValuePair<string, string>("ED", DateTime.Now.AddDays(1).Date.ToString("d", cultureInfo))
                    : new KeyValuePair<string, string>("ED",
                        _outbreakCasesViewModel.SessionDetails.datCloseDate.ToString()));

            _outbreakCasesViewModel.EpiCurveParameters.Add(new KeyValuePair<string, string>("Outbreak", _outbreakCasesViewModel.SessionDetails.idfOutbreak.ToString()));
            _outbreakCasesViewModel.EpiCurveParameters.Add(new KeyValuePair<string, string>("TimeInterval", "10042004"));
            _outbreakCasesViewModel.Culture = new System.Globalization.CultureInfo(GetCurrentLanguage());

            if (_outbreakCasesViewModel.SessionDetails is null) return View(_outbreakCasesViewModel);
            var sessionParameters = await _outbreakClient.GetSessionParametersList(request);
            foreach (var species in sessionParameters)
            {
                switch (species.OutbreakSpeciesTypeID)
                {
                    case OutbreakSpeciesGroup.Human:
                        _outbreakCasesViewModel.SessionDetails.bHuman = true;
                        break;
                    case OutbreakSpeciesGroup.Avian:
                        _outbreakCasesViewModel.SessionDetails.bAvian = true;
                        break;
                    case OutbreakSpeciesGroup.Livestock:
                        _outbreakCasesViewModel.SessionDetails.bLivestock = true;
                        break;
                    case OutbreakSpeciesGroup.Vector:
                        _outbreakCasesViewModel.SessionDetails.bVector = true;
                        break;
                }
            }

            _outbreakCasesViewModel.ReturnMessage = ReturnMessage;

            var searchModel = new OutbreakSearchForOutbreaksPrint()
            {
                LangID = GetCurrentLanguage(),
                ReportTitle = "{Report Title}",
                SiteID = _authenticatedUser.SiteId,
                PersonID = _authenticatedUser.PersonId,
                SortColumn = "datStartDate",
                SortOrder = SortConstants.Descending,
                PageNumber = "1",
                PageSize = (int.MaxValue - 1).ToString()
            };

            _outbreakCasesViewModel.OutbreakReportPrintViewModel = new OutbreakReportPrintViewModel
            {
                ReportName = "EnterOutbreakUpdate",
                ReportHeader = "",
                Parameters = new List<KeyValuePair<string, string>>
                {
                    new KeyValuePair<string, string>("LangID", searchModel.LangID.ToString()),
                    new KeyValuePair<string, string>("ObjID", _idfOutbreak.ToString()),
                    new KeyValuePair<string, string>("UserOrganization", _authenticatedUser.OrganizationFullName),
                    new KeyValuePair<string, string>("PersonID", _authenticatedUser.PersonId.ToString()),
                    new KeyValuePair<string, string>("SiteID", _authenticatedUser.SiteId.ToString()),
                    new KeyValuePair<string, string>("UserFullName", _authenticatedUser.UserName),
                    new KeyValuePair<string, string>("IncludeSignature", "true"),
                    new KeyValuePair<string, string>("PrintDateTime", DateTime.Now.ToShortDateString().ToString(new CultureInfo(GetCurrentLanguage())))
                }
            };

            return View(_outbreakCasesViewModel);
        }

        [HttpPost()]
        public async Task<IActionResult> PrintOutbreakUpdates([FromBody] OutbreakSearchForOutbreaksPrint searchModel)
        {
            try
            {
                return View("_PrintOutbreakSessionsPartial", _outbreakCasesViewModel);
            }
            catch (Exception)
            {
                throw;
            }
        }

        [HttpPost()]
        public JsonResult GetUpdate(long idfOutbreakNote)
        {
            OutbreakSessionNoteDetailsRequestModel request = new()
            {
                LangID = GetCurrentLanguage(),
                idfOutbreakNote = idfOutbreakNote
            };

            var response = _outbreakClient.GetSessionNoteDetails(request).Result;

            return Json(response);
        }

        [HttpPost()]
        public async Task<string> GetUpdates(long idfOutbreak)
        {
            OutbreakSessionNoteListRequestModel request = new()
            {
                LangId = GetCurrentLanguage(),
                idfOutbreak = idfOutbreak
            };

            var updates = await _outbreakClient.GetSessionNoteList(request);

            var strHTML = string.Empty;
            foreach (var update in updates)
            {
                string strView;
                string strDownload;
                if (string.IsNullOrEmpty(update.UploadFileName))
                {
                    strView = string.Empty;
                    strDownload = string.Empty;
                }
                else
                {
                    strView = "View";
                    strDownload = "Download";
                }

                strHTML += "<div class=\"d-flex w-100 p-2 sessionUpdates\">";
                strHTML += "	<div class=\"outbreakNoteAlter" + update.UpdatePriority + "\">&nbsp;</div>";
                strHTML += "	<div class=\"p-1 flex-fill outbreakNoteContainer-left\">";
                strHTML += "		<div class=\"row\">";
                strHTML += "			<label>Record #" + update.NoteRecordUID + "</label>";
                strHTML += "		</div>";
                strHTML += "		<div class=\"row\">";
                strHTML += "			<label>" + update.UserName + "</label><span>| </span><label>" + update.Organization + "</label>";
                strHTML += "		</div>";
                strHTML += "		<div class=\"row\">";
                strHTML += "			<label>" + update.datNoteDate + "</label>";
                strHTML += "		</div>";
                strHTML += "		<div class=\"row\">";
                strHTML += "			<a ID=\"hlView\" href=\"" + Url.Action("Display", "Document", new { Area = "Outbreak" }) + "?idfOutbreakNote=" + update.idfOutbreakNote + "\" target=\"_blank\">" + strView + "</a>";

                if (!string.IsNullOrEmpty(strView))
                {
                    strHTML += " | ";
                }

                strHTML += "			<a ID=\"hlDownload\" href=\"" + Url.Action("Download", "Document", new { Area = "Outbreak" }) + "?idfOutbreakNote=" + update.idfOutbreakNote + "\" target=\"_blank\">" + strDownload + "</a>";
                strHTML += "		</div>";
                strHTML += "	</div>";
                strHTML += "	<div class=\"p-2 divider-panel-outbreak-note\">&nbsp;</div>";
                strHTML += "	<div class=\"p-1 flex-grow-1 outbreakNoteContainer-right\">";
                strHTML += "		<label field=\"UpdateRecordTitle\"></label>" + update.UpdateRecordTitle + "<br />";
                strHTML += "		<label field=\"UpdateRecordDetails\"></label>" + update.strNote + "<br />";
                strHTML += "		<label field=\"UploadFileName\">\"" + update.UploadFileName + "\"</label>";
                strHTML += "		<label field=\"strNote\">" + update.UploadFileDescription + "</label>";
                strHTML += "		<div class=\"text-right\">";
                strHTML += "			<span class=\"fas fa-edit fa-lg\" onclick=\"outbreakCreate.getSessionNote(" + update.idfOutbreakNote + ");\"></span>";
                strHTML += "		</div>";
                strHTML += "	</div>";
                strHTML += "</div>";
            }

            return strHTML;
        }

        [HttpPost()]
        public async Task<IActionResult> SaveUpdate([FromForm] OutbreakSessionNoteCreateRequestModel request)
        {
            byte[] formFileContent = null;

            if (request.FileUpload != null)
            {
                request.FileExtension = request.FileUpload.FileName[(request.FileUpload.FileName.LastIndexOf('.') + 1)..];
            }

            if (request.FileUpload != null)
            {
                formFileContent = await FileHelpers.ProcessFormFile<OutbreakCasesController>(request.FileUpload, ModelState, new[] { "." + request.FileExtension }, 99999999);
            }

            request.LangID = GetCurrentLanguage();
            request.idfPerson = long.Parse(_authenticatedUser.PersonId);
            request.User = _authenticatedUser.UserName;

            if (request.FileUpload != null)
            {
                request.UploadFileObject = formFileContent;
            }

            await _outbreakClient.SetSessionNote(request);
            return RedirectToAction("index", new { queryData = request.idfOutbreak });
        }

        public async Task<IActionResult> ImportHuman(long Id, long callbackkey)
        {
            var returnActionResult = await Import(Id, null, callbackkey);

            return returnActionResult;
        }

        public async Task<IActionResult> ImportVet(long Id, long callbackkey)
        {
            var returnActionResult = await Import(null, Id, callbackkey);

            return returnActionResult;
        }

        public async Task<IActionResult> Import(long? idfHumanCase, long? idfVetCase, long idfOutbreak)
        {
            OutbreakCaseCreateRequestModel request = new()
            {
                LangID = GetCurrentLanguage(),
                idfHumanCase = idfHumanCase,
                idfVetCase = idfVetCase,
                idfOutbreak = idfOutbreak,
                User = _authenticatedUser.UserName,
                Events = null
            };
            _notificationService.Events = new List<EventSaveRequestModel>();

            var eventTypeId = idfHumanCase is not null ? SystemEventLogTypes.NewHumanDiseaseReportWasAddedToOutbreakSessionAtYourSite : SystemEventLogTypes.NewVeterinaryDiseaseReportWasAddedToOutbreakSessionAtYourSite;

            var notification = await _notificationService.CreateEvent(idfOutbreak,
                null, eventTypeId, Convert.ToInt64(_authenticatedUser.SiteId), null);
            _notificationService.Events.Add(notification);
            request.Events = JsonConvert.SerializeObject(_notificationService.Events);

            var response = await _outbreakClient.SetCase(request).ConfigureAwait(true);

            return RedirectToAction("Index", "OutbreakCases", new { Area = "Outbreak", queryData = idfOutbreak, response.ReturnMessage });
        }

        /// <summary>
        /// </summary>
        /// <param name="outbreakId"></param>
        /// <param name="caseId"></param>
        /// <param name="isReview"></param>
        /// <param name="readOnly"></param>
        /// <returns></returns>
        public IActionResult VeterinaryDetails(long outbreakId, long? caseId, bool isReview = false, bool readOnly = false)
        {
            CaseDetailPageViewModel model = new()
            {
                IsReadOnly = readOnly
            };

            dynamic request = new OutbreakSessionDetailRequestModel()
            {
                LanguageID = GetCurrentLanguage(),
                idfsOutbreak = outbreakId
            };
            List<OutbreakSessionDetailsResponseModel> session = _outbreakClient.GetSessionDetail(request).Result;

            var sessionSpeciesParameters = _outbreakClient.GetSessionParametersList(request).Result;
            foreach (var parameter in sessionSpeciesParameters)
            {
                switch (parameter.OutbreakSpeciesTypeID)
                {
                    case (long)OutbreakSpeciesTypeEnum.Avian:
                        session.First().bAvian = true;
                        session.First().AvianCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                        session.First().AvianCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                        session.First().AvianContactTracingTemplateID = parameter.ContactTracingTemplateID;
                        break;
                    case (long)OutbreakSpeciesTypeEnum.Human:
                        session.First().HumanCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                        session.First().HumanCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                        session.First().HumanContactTracingTemplateID = parameter.ContactTracingTemplateID;
                        break;
                    case (long)OutbreakSpeciesTypeEnum.Livestock:
                        session.First().bLivestock = true;
                        session.First().LivestockCaseMonitoringTemplateID = parameter.CaseMonitoringTemplateID;
                        session.First().LivestockCaseQuestionaireTemplateID = parameter.CaseQuestionaireTemplateID;
                        session.First().LivestockContactTracingTemplateID = parameter.ContactTracingTemplateID;
                        break;
                    case (long)OutbreakSpeciesTypeEnum.Vector:
                        session.First().bVector = true;
                        break;
                }
            }

            if (caseId is null)
            {
                model.VeterinaryCase = new CaseGetDetailViewModel
                {
                    CancelURL = $"/Outbreak/OutbreakCases?queryData={outbreakId}", 
                    DateEntered = DateTime.Now,
                    DiseaseId = session.First().idfsDiagnosisOrDiagnosisGroup,
                    DiseaseName = session.First().strDiagnosis,
                    Session = session.First(),
                    VeterinaryDiseaseReport = new DiseaseReportGetDetailViewModel
                    {
                        OutbreakCaseIndicator = true,
                        ReportStatusTypeID = (long)DiseaseReportStatusTypeEnum.InProcess,
                        DiseaseID = session.First().idfsDiagnosisOrDiagnosisGroup,
                        DiseaseName = session.First().strDiagnosis,
                        SiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                        RowStatus = (int)RowStatusTypeEnum.Active,
                        FarmInventory = new List<FarmInventoryGetListViewModel>(),
                        Animals = new List<AnimalGetListViewModel>(),
                        Vaccinations = new List<VaccinationGetListViewModel>(),
                        Samples = new List<SampleGetListViewModel>(),
                        PensideTests = new List<PensideTestGetListViewModel>(),
                        LaboratoryTests = new List<LaboratoryTestGetListViewModel>(),
                        LaboratoryTestInterpretations = new List<LaboratoryTestInterpretationGetListViewModel>(),
                        CaseLogs = new List<CaseLogGetListViewModel>(),
                        PendingSaveEvents = new List<EventSaveRequestModel>(),
                        OutbreakFlexFormTemplates = new FlexFormAssignedTemplatesModel
                        {
                            HumanCaseMonitoringTemplateID = session.First().HumanCaseMonitoringTemplateID,
                            HumanCaseQuestionaireTemplateID = session.First().HumanCaseQuestionaireTemplateID,
                            HumanContactTracingTemplateID = session.First().HumanContactTracingTemplateID,
                            AvianCaseMonitoringTemplateID = session.First().AvianCaseMonitoringTemplateID,
                            AvianCaseQuestionaireTemplateID = session.First().AvianCaseQuestionaireTemplateID,
                            AvianContactTracingTemplateID = session.First().AvianContactTracingTemplateID,
                            LivestockCaseMonitoringTemplateID = session.First().LivestockCaseMonitoringTemplateID,
                            LivestockCaseQuestionaireTemplateID = session.First().LivestockCaseQuestionaireTemplateID,
                            LivestockContactTracingTemplateID = session.First().LivestockContactTracingTemplateID
                        },
                        FarmLocation = new LocationViewModel
                        {
                            IsHorizontalLayout = true,
                            AlwaysDisabled = false,
                            EnableAdminLevel1 = true,
                            EnableAdminLevel2 = true,
                            EnableAdminLevel3 = true,
                            EnableApartment = true,
                            EnableBuilding = true,
                            EnableHouse = true,
                            EnabledLatitude = true,
                            EnabledLongitude = true,
                            EnablePostalCode = true,
                            EnableSettlement = true,
                            EnableSettlementType = true,
                            EnableStreet = true,
                            OperationType = LocationViewOperationType.Edit,
                            ShowAdminLevel0 = true,
                            ShowAdminLevel1 = true,
                            ShowAdminLevel2 = true,
                            ShowAdminLevel3 = true,
                            ShowAdminLevel4 = false,
                            ShowAdminLevel5 = false,
                            ShowAdminLevel6 = false,
                            ShowSettlementType = true,
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
                            IsDbRequiredAdminLevel0 = true,
                            IsDbRequiredAdminLevel1 = true,
                            IsDbRequiredAdminLevel2 = true,
                            IsDbRequiredSettlement = false,
                            IsDbRequiredSettlementType = false,
                            AdminLevel0Value = Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                        },
                        EnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId),
                        EnteredByPersonName = authenticatedUser.LastName + ", " + authenticatedUser.FirstName,
                        EnteredDate = DateTime.Now,
                        SiteName = authenticatedUser.Organization
                    }
                };

                if (model.VeterinaryCase.VeterinaryDiseaseReport.ReportCategoryTypeID == (long)CaseTypeEnum.Avian)
                {
                    FlexFormQuestionnaireGetRequestModel farmEpidemiologicalInfoFlexFormRequest = new()
                    {
                        idfsFormType = (long)FlexibleFormTypeEnum.AvianFarmEpidemiologicalInfo,
                        LangID = GetCurrentLanguage()
                    };
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmEpidemiologicalInfoFlexForm = farmEpidemiologicalInfoFlexFormRequest;
                }
                else
                {
                    FlexFormQuestionnaireGetRequestModel farmEpidemiologicalInfoFlexFormRequest = new()
                    {
                        idfsFormType = (long)FlexibleFormTypeEnum.LivestockFarmFarmEpidemiologicalInfo,
                        LangID = GetCurrentLanguage()
                    };
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmEpidemiologicalInfoFlexForm = farmEpidemiologicalInfoFlexFormRequest;

                    FlexFormQuestionnaireGetRequestModel controlMeasuresFlexFormRequest = new()
                    {
                        idfsFormType = (long)FlexibleFormTypeEnum.LivestockControlMeasures,
                        LangID = GetCurrentLanguage()
                    };
                    model.VeterinaryCase.VeterinaryDiseaseReport.ControlMeasuresFlexForm = controlMeasuresFlexFormRequest;
                }

                FlexFormQuestionnaireGetRequestModel caseQuestionnaireFlexFormRequest = new()
                {
                    idfsFormType = (long)FlexibleFormTypeEnum.AvianOutbreakCaseQuestionnaire,
                    LangID = GetCurrentLanguage(),
                    idfsFormTemplate = (model.VeterinaryCase.VeterinaryDiseaseReport.ReportCategoryTypeID == (long)CaseTypeEnum.Avian) ?
                                        session.First().AvianCaseQuestionaireTemplateID : session.First().LivestockCaseQuestionaireTemplateID
                };

                model.VeterinaryCase.CaseQuestionnaireFlexFormRequest = caseQuestionnaireFlexFormRequest;
            }
            else
            {
                var result = _outbreakClient.GetCaseDetail(GetCurrentLanguage(), (long)caseId, _token).Result;
                if (result.Any())
                {
                    model.VeterinaryCase = result.First();
                    model.VeterinaryCase.Session = session.First();
                    model.VeterinaryCase.CaseDisabledIndicator = model.IsReadOnly;

                    if (model.VeterinaryCase.VeterinaryDiseaseReportId != null)
                        request = new DiseaseReportGetDetailRequestModel()
                        {
                            LanguageId = GetCurrentLanguage(),
                            Page = 1,
                            PageSize = int.MaxValue - 1,
                            SortColumn = "EIDSSReportID",
                            SortOrder = SortConstants.Ascending,
                            DiseaseReportID = (long)model.VeterinaryCase.VeterinaryDiseaseReportId
                        };
                    List<DiseaseReportGetDetailViewModel> diseaseReport =
                        _veterinaryClient.GetDiseaseReportDetail(request, _token).Result;
                    model.VeterinaryCase.VeterinaryDiseaseReport = diseaseReport.First();
                    model.VeterinaryCase.VeterinaryDiseaseReport.OutbreakCaseIndicator = true;
                    model.VeterinaryCase.DiseaseId = model.VeterinaryCase.VeterinaryDiseaseReport.DiseaseID;
                    model.VeterinaryCase.DiseaseName = model.VeterinaryCase.VeterinaryDiseaseReport.DiseaseName;
                    model.VeterinaryCase.InvestigatedByOrganizationId =
                        model.VeterinaryCase.VeterinaryDiseaseReport.InvestigatedByOrganizationID;
                    model.VeterinaryCase.InvestigatedByPersonId =
                        model.VeterinaryCase.VeterinaryDiseaseReport.InvestigatedByPersonID;
                    model.VeterinaryCase.InvestigationDate =
                        model.VeterinaryCase.VeterinaryDiseaseReport.InvestigationDate;
                    model.VeterinaryCase.ClassificationTypeId =
                        model.VeterinaryCase.VeterinaryDiseaseReport.ClassificationTypeID;
                    model.VeterinaryCase.ClassificationTypeName =
                        model.VeterinaryCase.VeterinaryDiseaseReport.ClassificationTypeName;
                    model.VeterinaryCase.NotificationDate = model.VeterinaryCase.VeterinaryDiseaseReport.ReportDate;
                    model.VeterinaryCase.NotificationSentByOrganizationId =
                        model.VeterinaryCase.VeterinaryDiseaseReport.ReportedByOrganizationID;
                    model.VeterinaryCase.NotificationSentByPersonId =
                        model.VeterinaryCase.VeterinaryDiseaseReport.ReportedByPersonID;
                    model.VeterinaryCase.NotificationReceivedByOrganizationId =
                        model.VeterinaryCase.VeterinaryDiseaseReport.ReceivedByOrganizationID;
                    model.VeterinaryCase.NotificationReceivedByPersonId =
                        model.VeterinaryCase.VeterinaryDiseaseReport.ReceivedByPersonID;

                    model.VeterinaryCase.VeterinaryDiseaseReport.PendingSaveEvents =
                        new List<EventSaveRequestModel>();

                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmOwnerName =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmOwnerLastName + ", " +
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmOwnerFirstName;

                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation = new LocationViewModel
                    {
                        IsHorizontalLayout = true,
                        AlwaysDisabled = false,
                        EnableAdminLevel1 = true,
                        EnableAdminLevel2 = true,
                        EnableAdminLevel3 = true,
                        EnableApartment = true,
                        EnableBuilding = true,
                        EnableHouse = true,
                        EnabledLatitude = true,
                        EnabledLongitude = true,
                        EnablePostalCode = true,
                        EnableSettlement = true,
                        EnableSettlementType = true,
                        EnableStreet = true,
                        OperationType = LocationViewOperationType.Edit,
                        ShowAdminLevel0 = true,
                        ShowAdminLevel1 = true,
                        ShowAdminLevel2 = true,
                        ShowAdminLevel3 = true,
                        ShowAdminLevel4 = false,
                        ShowAdminLevel5 = false,
                        ShowAdminLevel6 = false,
                        ShowSettlementType = true,
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
                        IsDbRequiredAdminLevel0 = true,
                        IsDbRequiredAdminLevel1 = true,
                        IsDbRequiredAdminLevel2 = true,
                        IsDbRequiredSettlement = false,
                        IsDbRequiredSettlementType = false,
                        AdminLevel0Value =
                            Convert.ToInt64(_configuration.GetValue<string>("EIDSSGlobalSettings:CountryID"))
                    };
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.AdminLevel0Value = model.VeterinaryCase
                        .VeterinaryDiseaseReport.FarmAddressAdministrativeLevel0ID;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.AdminLevel1Value = model.VeterinaryCase
                        .VeterinaryDiseaseReport.FarmAddressAdministrativeLevel1ID;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.AdminLevel2Value = model.VeterinaryCase
                        .VeterinaryDiseaseReport.FarmAddressAdministrativeLevel2ID;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.AdminLevel3Value = model.VeterinaryCase
                        .VeterinaryDiseaseReport.FarmAddressAdministrativeLevel3ID;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.SettlementType =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressSettlementTypeID;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.SettlementText =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressSettlementName;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.SettlementId =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressSettlementID;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.Settlement =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressSettlementID;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.Apartment =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressApartment;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.Building =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressBuilding;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.House =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressHouse;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.Latitude =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressLatitude;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.Longitude =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressLongitude;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.PostalCode =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressPostalCodeID;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.PostalCodeText =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressPostalCode;
                    if (model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressPostalCodeID != null)
                    {
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.PostalCodeList =
                            new List<PostalCodeViewModel>
                            {
                                new()
                                {
                                    PostalCodeID = model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressPostalCodeID
                                        .ToString(),
                                    PostalCodeString = model.VeterinaryCase.VeterinaryDiseaseReport
                                        .FarmAddressPostalCode
                                }
                            };
                    }

                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.StreetText =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressStreetName;
                    model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.Street =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressStreetID;
                    if (model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressStreetID != null)
                    {
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmLocation.StreetList = new List<StreetModel>
                        {
                            new()
                            {
                                StreetID = model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressStreetID.ToString(),
                                StreetName = model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressStreetName
                            }
                        };
                    }

                    model.VeterinaryCase.CaseAddressAdministrativeLevel0ID =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel0ID;
                    model.VeterinaryCase.CaseAddressAdministrativeLevel1ID =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel1ID;
                    model.VeterinaryCase.CaseAddressAdministrativeLevel1Name =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel1Name;
                    model.VeterinaryCase.CaseAddressAdministrativeLevel2ID =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel2ID;
                    model.VeterinaryCase.CaseAddressAdministrativeLevel2Name =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel2Name;
                    model.VeterinaryCase.CaseAddressSettlementID =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressSettlementID;
                    model.VeterinaryCase.CaseAddressSettlementName =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressSettlementName;
                    model.VeterinaryCase.CaseAddressApartment =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressApartment;
                    model.VeterinaryCase.CaseAddressBuilding =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressBuilding;
                    model.VeterinaryCase.CaseAddressHouse =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressHouse;
                    model.VeterinaryCase.CaseAddressLatitude =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressLatitude;
                    model.VeterinaryCase.CaseAddressLongitude =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressLongitude;
                    model.VeterinaryCase.CaseAddressPostalCode =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressPostalCode;
                    model.VeterinaryCase.CaseAddressStreetName =
                        model.VeterinaryCase.VeterinaryDiseaseReport.FarmAddressStreetName;

                    if (model.VeterinaryCase.VeterinaryDiseaseReport.ReportCategoryTypeID == (long)CaseTypeEnum.Avian)
                    {
                        model.VeterinaryCase.FarmTypeID = (long)FarmTypeEnum.Avian;

                        FlexFormQuestionnaireGetRequestModel caseQuestionnaireFlexFormRequest = new()
                        {
                            idfsDiagnosis = model.VeterinaryCase.VeterinaryDiseaseReport.DiseaseID,
                            idfsFormTemplate = result.First().CaseQuestionnaireTemplateId,
                            idfsFormType = (long)FlexibleFormTypeEnum.AvianOutbreakCaseQuestionnaire,
                            idfObservation = model.VeterinaryCase.CaseQuestionnaireObservationId,
                            LangID = GetCurrentLanguage()
                        };
                        model.VeterinaryCase.CaseQuestionnaireFlexFormRequest = caseQuestionnaireFlexFormRequest;
                    }
                    else
                    {
                        model.VeterinaryCase.FarmTypeID = (long)FarmTypeEnum.Livestock;

                        FlexFormQuestionnaireGetRequestModel caseQuestionnaireFlexFormRequest = new()
                        {
                            idfsDiagnosis = model.VeterinaryCase.VeterinaryDiseaseReport.DiseaseID,
                            idfsFormTemplate = result.First().CaseQuestionnaireTemplateId,
                            idfsFormType = (long)FlexibleFormTypeEnum.LivestockOutbreakCaseQuestionnaire,
                            idfObservation = model.VeterinaryCase.CaseQuestionnaireObservationId,
                            LangID = GetCurrentLanguage()
                        };
                        model.VeterinaryCase.CaseQuestionnaireFlexFormRequest = caseQuestionnaireFlexFormRequest;
                    }

                    model.VeterinaryCase.VeterinaryDiseaseReport.ReportCurrentlyClosedIndicator =
                        model.VeterinaryCase.VeterinaryDiseaseReport.ReportStatusTypeID ==
                        (long)DiseaseReportStatusTypeEnum.Closed;

                    // Edit from outbreak session cases list.
                    model.VeterinaryCase.VeterinaryDiseaseReport.ReportViewModeIndicator = false;
                    model.VeterinaryCase.VeterinaryDiseaseReport.ShowReviewSectionIndicator = isReview;
                }
            }

            _userPermissions = GetUserPermissions(PagePermission.AccessToOutbreakVeterinaryCaseData);
            model.VeterinaryCase.AccessToPersonalDataPermissionIndicator = _userPermissions.AccessToPersonalData;
            model.VeterinaryCase.CreatePermissionIndicator = _userPermissions.Create;
            model.VeterinaryCase.WritePermissionIndicator = _userPermissions.Write;
            model.VeterinaryCase.DeletePermissionIndicator = _userPermissions.Delete;

            model.VeterinaryCase.VeterinaryDiseaseReport.AccessToPersonalDataPermissionIndicator = _userPermissions.AccessToPersonalData;
            model.VeterinaryCase.VeterinaryDiseaseReport.CreatePermissionIndicator = _userPermissions.Create;
            model.VeterinaryCase.VeterinaryDiseaseReport.WritePermissionIndicator = _userPermissions.Write;
            model.VeterinaryCase.VeterinaryDiseaseReport.DeletePermissionIndicator = _userPermissions.Delete;
            
            _userPermissions = GetUserPermissions(PagePermission.CanManageReferenceDataTables);
            model.VeterinaryCase.VeterinaryDiseaseReport.CreateBaseReferencePermissionIndicator =
                _userPermissions.Create;

            return View(model);
        }
    }
}
