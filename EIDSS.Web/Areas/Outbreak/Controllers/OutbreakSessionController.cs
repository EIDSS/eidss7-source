using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.Outbreak;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Outbreak.ViewModels;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Outbreak.Controllers
{
    [Area("Outbreak")]
    [Controller]
    public class OutbreakSessionController : BaseController
    {
        private readonly OutbreakSessionViewModel _outbreakSessionViewModel;
        private readonly ISiteClient _siteClient;
        private readonly AuthenticatedUser _authenticatedUser;
        private readonly IOutbreakClient _outbreakClient;
        private readonly IConfigurationClient _configurationClient;
        private readonly IStringLocalizer _localizer;
        private readonly UserPreferences _userPreferences;
        private readonly INotificationSiteAlertService _notificationService;

        public OutbreakSessionController(IOutbreakClient outbreakClient, ISiteClient siteClient, 
            IConfigurationClient configurationClient, IStringLocalizer localizer, ICrossCuttingClient crossCuttingClient, 
            INotificationSiteAlertService notificationSiteAlertService,
            ITokenService tokenService, ILogger<OutbreakSessionController> logger) : base(logger, tokenService)
        {
            _outbreakClient = outbreakClient;
            _siteClient = siteClient;
            _configurationClient = configurationClient;
            _localizer = localizer;
            _notificationService = notificationSiteAlertService;
            _authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = _authenticatedUser.Preferences;
            GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);

            _outbreakSessionViewModel = new OutbreakSessionViewModel
            {
                CurrentLanguage = GetCurrentLanguage(),
                SessionLocationViewModel = new LocationViewModel(),
                SessionDetails = new OutbreakSessionDetailsResponseModel
                {
                    datStartDate = DateTime.Today,
                    Today = DateTime.Today.ToShortDateString()
                },
                DefaultOutbreakStatus = Common.GetBaseReferenceTranslation(GetCurrentLanguage(), OutbreakStatus.InProgress, crossCuttingClient)
            };
        }

        public async Task<IActionResult> Index(long queryData)
        {
            await BuildSessionLocationControl(null);
            return View(_outbreakSessionViewModel);
        }

        public IActionResult AdvancedSearch()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Edit([FromForm] OutbreakSessionCreateRequestModel request)
        {
            var outbreakParametersList = new List<OutbreakSessionParameters>();
            var outbreakParameters = new OutbreakSessionParameters();

            request.PendingSaveEvents ??= new List<Domain.RequestModels.Administration.EventSaveRequestModel>();

            if (request.SessionDetails.bHuman)
            {
                outbreakParameters.OutbreakSpeciesParameterUID = request.SessionDetails.HumanOutbreakSpeciesParameterUID;
                outbreakParameters.intRowStatus = DBRecordStatus.Active;
                outbreakParameters.OutbreakSpeciesTypeID = OutbreakSpeciesGroup.Human; //Human
                outbreakParameters.CaseMonitoringDuration = request.SessionDetails.txtHumanCaseMonitoringDuration;
                outbreakParameters.CaseMonitoringFrequency = request.SessionDetails.txtHumanCaseMonitoringFrequency;
                outbreakParameters.ContactTracingDuration = request.SessionDetails.txtHumanContactTracingDuration;
                outbreakParameters.ContactTracingFrequency = request.SessionDetails.txtHumanContactTracingFrequency;
                outbreakParametersList.Add(outbreakParameters);
            }

            if (request.SessionDetails.bAvian)
            {
                outbreakParameters = new OutbreakSessionParameters
                {
                    OutbreakSpeciesParameterUID = request.SessionDetails.AvianOutbreakSpeciesParameterUID,
                    intRowStatus = DBRecordStatus.Active,
                    OutbreakSpeciesTypeID = OutbreakSpeciesGroup.Avian, //Avian
                    CaseMonitoringDuration = request.SessionDetails.txtAvianCaseMonitoringDuration,
                    CaseMonitoringFrequency = request.SessionDetails.txtAvianCaseMonitoringFrequency,
                    ContactTracingDuration = request.SessionDetails.txtAvianContactTracingDuration,
                    ContactTracingFrequency = request.SessionDetails.txtAvianContactTracingFrequency
                };
                outbreakParametersList.Add(outbreakParameters);
            }

            if (request.SessionDetails.bLivestock)
            {
                outbreakParameters = new OutbreakSessionParameters
                {
                    OutbreakSpeciesParameterUID = request.SessionDetails.LivestockOutbreakSpeciesParameterUID,
                    intRowStatus = DBRecordStatus.Active,
                    OutbreakSpeciesTypeID = OutbreakSpeciesGroup.Livestock, //Livestock
                    CaseMonitoringDuration = request.SessionDetails.txtLivestockCaseMonitoringDuration,
                    CaseMonitoringFrequency = request.SessionDetails.txtLivestockCaseMonitoringFrequency,
                    ContactTracingDuration = request.SessionDetails.txtLivestockContactTracingDuration,
                    ContactTracingFrequency = request.SessionDetails.txtLivestockContactTracingFrequency
                };
                outbreakParametersList.Add(outbreakParameters);
            }

            if (request.SessionDetails.bVector)
            {
                outbreakParameters = new OutbreakSessionParameters
                {
                    intRowStatus = DBRecordStatus.Active,
                    OutbreakSpeciesTypeID = OutbreakSpeciesGroup.Vector,
                    CaseMonitoringDuration = null,
                    CaseMonitoringFrequency = null,
                    ContactTracingDuration = null,
                    ContactTracingFrequency = null
                };
                outbreakParametersList.Add(outbreakParameters);
            }

            request.OutbreakParameters = JsonConvert.SerializeObject(outbreakParametersList);

            request.LangID = GetCurrentLanguage();
            request.AdminLevel0Value ??= request.SessionDetails.AdminLevel0Value;

            if (request.AdminLevel3Value != null)
            {
                request.idfsLocation = request.AdminLevel3Value;
            }
            else if (request.AdminLevel2Value != null)
            {
                request.idfsLocation = request.AdminLevel2Value;
            }
            else if (request.AdminLevel1Value != null)
            {
                request.idfsLocation = request.AdminLevel1Value;
            }
            else if (request.AdminLevel0Value != null)
            {
                request.idfsLocation = request.AdminLevel0Value;
            }

            request.idfOutbreak = request.SessionDetails.idfOutbreak;
            request.idfsSite = long.Parse(_authenticatedUser.SiteId);
            request.datStartDate = (DateTime)request.SessionDetails.datStartDate;
            request.datCloseDate = request.SessionDetails.datCloseDate;
            request.User = _authenticatedUser.UserName;

            if (request.idfsOutbreakStatus != request.SessionDetails.OriginalOutbreakStatusTypeId)
            {
                var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == request.idfsSite
                    ? SystemEventLogTypes.OutbreakSessionStatusWasChangedAtYourSite
                    : SystemEventLogTypes.OutbreakSessionStatusWasChangedAtAnotherSite;
                request.PendingSaveEvents.Add(await _notificationService.CreateEvent(0,
                        request.idfsDiagnosisOrDiagnosisGroup, eventTypeId, request.idfsSite, null)
                    .ConfigureAwait(false));
            }

            request.SessionDetails = null;

            if (request.idfOutbreak is null)
            {
                var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == request.idfsSite
                    ? SystemEventLogTypes.NewOutbreakSessionWasCreatedAtYourSite
                    : SystemEventLogTypes.NewOutbreakSessionWasCreatedAtAnotherSite;
                request.PendingSaveEvents.Add(await _notificationService.CreateEvent(0,
                        request.idfsDiagnosisOrDiagnosisGroup, eventTypeId, request.idfsSite, null)
                    .ConfigureAwait(false));
            }

            request.Events = JsonConvert.SerializeObject(request.PendingSaveEvents);

            var response = await _outbreakClient.SetSession(request);

            return RedirectToAction("Edit", "OutbreakSession", new { queryData = response.idfOutbreak, bShowSuccessMessage = true, bShowOutbreakId = request.idfOutbreak == null });
        }

        public async Task<IActionResult> Edit(long queryData, bool bShowSuccessMessage = false, bool bShowOutbreakId = false)
        {
            var request = new OutbreakSessionDetailRequestModel
            {
                LanguageID = GetCurrentLanguage(),
                idfsOutbreak = queryData
            };

            _outbreakSessionViewModel.SessionDetails = _outbreakClient.GetSessionDetail(request).Result.FirstOrDefault();

            _outbreakSessionViewModel.IsSessionClosed = (_outbreakSessionViewModel.SessionDetails?.idfsOutbreakStatus == (long)OutbreakSessionStatus.Closed);

            if (_outbreakSessionViewModel.SessionDetails == null) return View(_outbreakSessionViewModel);
            _outbreakSessionViewModel.SessionDetails.OriginalOutbreakStatusTypeId =
                _outbreakSessionViewModel.SessionDetails.idfsOutbreakStatus;
            if (_outbreakSessionViewModel.SessionDetails?.datStartDate != null)
            {
                var dtStartDate = (DateTime) _outbreakSessionViewModel.SessionDetails.datStartDate;
                _outbreakSessionViewModel.SessionDetails.Today = DateTime.Today.ToShortDateString();
                _outbreakSessionViewModel.SessionDetails.datStartDate = dtStartDate.Date;
            }

            await BuildSessionLocationControl(null);

            _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel0Value =
                _outbreakSessionViewModel.SessionDetails?.AdminLevel0Value;
            _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel1Value =
                _outbreakSessionViewModel.SessionDetails?.AdminLevel1Value;
            _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel2Value =
                _outbreakSessionViewModel.SessionDetails?.AdminLevel2Value;
            _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel3Value =
                _outbreakSessionViewModel.SessionDetails?.AdminLevel3Value;
            _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel1Text =
                _outbreakSessionViewModel.SessionDetails?.AdminLevel1Text;
            _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel2Text =
                _outbreakSessionViewModel.SessionDetails?.AdminLevel2Text;
            _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel3Text =
                _outbreakSessionViewModel.SessionDetails?.AdminLevel3Text;
            _outbreakSessionViewModel.SessionLocationViewModel.IsLocationDisabled =
                _outbreakSessionViewModel.IsSessionClosed;

            var sessionParameters = await _outbreakClient.GetSessionParametersList(request);

            foreach (var sessionParameter in sessionParameters)
            {
                string strAttributes;
                switch (sessionParameter.OutbreakSpeciesTypeID)
                {
                    case OutbreakSpeciesGroup.Human:
                        if (_outbreakSessionViewModel.SessionDetails is
                            {OutbreakTypeId: OutbreakTypes.Human or OutbreakTypes.Zoonotic})
                        {
                            _outbreakSessionViewModel.SessionDetails.txtHumanCaseMonitoringDuration =
                                sessionParameter.CaseMonitoringDuration;
                            _outbreakSessionViewModel.SessionDetails.txtHumanCaseMonitoringFrequency =
                                sessionParameter.CaseMonitoringFrequency;
                            _outbreakSessionViewModel.SessionDetails.txtHumanContactTracingDuration =
                                sessionParameter.ContactTracingDuration;
                            _outbreakSessionViewModel.SessionDetails.txtHumanContactTracingFrequency =
                                sessionParameter.ContactTracingFrequency;
                            _outbreakSessionViewModel.SessionDetails.HumanOutbreakSpeciesParameterUID =
                                sessionParameter.OutbreakSpeciesParameterUID;
                            _outbreakSessionViewModel.SessionDetails.HumanCaseQuestionaireTemplateID =
                                sessionParameter.CaseQuestionaireTemplateID;
                            _outbreakSessionViewModel.SessionDetails.HumanCaseMonitoringTemplateID =
                                sessionParameter.CaseMonitoringTemplateID;
                            _outbreakSessionViewModel.SessionDetails.HumanContactTracingTemplateID =
                                sessionParameter.ContactTracingTemplateID;

                            strAttributes = "checked ";

                            if (_outbreakSessionViewModel.SessionDetails.bHasHumanCases)
                            {
                                strAttributes += "disabled";
                            }

                            _outbreakSessionViewModel.HumanSpecies =
                                _outbreakSessionViewModel.HumanSpecies.Replace("[ATTRIBUTES]", strAttributes);
                        }

                        break;
                    case OutbreakSpeciesGroup.Avian:
                        if (_outbreakSessionViewModel.SessionDetails is
                            {OutbreakTypeId: OutbreakTypes.Veterinary or OutbreakTypes.Zoonotic})
                        {
                            _outbreakSessionViewModel.SessionDetails.txtAvianCaseMonitoringDuration =
                                sessionParameter.CaseMonitoringDuration;
                            _outbreakSessionViewModel.SessionDetails.txtAvianCaseMonitoringFrequency =
                                sessionParameter.CaseMonitoringFrequency;
                            _outbreakSessionViewModel.SessionDetails.txtAvianContactTracingDuration =
                                sessionParameter.ContactTracingDuration;
                            _outbreakSessionViewModel.SessionDetails.txtAvianContactTracingFrequency =
                                sessionParameter.ContactTracingFrequency;
                            _outbreakSessionViewModel.SessionDetails.AvianOutbreakSpeciesParameterUID =
                                sessionParameter.OutbreakSpeciesParameterUID;
                            _outbreakSessionViewModel.SessionDetails.AvianCaseQuestionaireTemplateID =
                                sessionParameter.CaseQuestionaireTemplateID;
                            _outbreakSessionViewModel.SessionDetails.AvianCaseMonitoringTemplateID =
                                sessionParameter.CaseMonitoringTemplateID;
                            _outbreakSessionViewModel.SessionDetails.AvianContactTracingTemplateID =
                                sessionParameter.ContactTracingTemplateID;
                            _outbreakSessionViewModel.AvianSpecies =
                                _outbreakSessionViewModel.AvianSpecies.Replace("[ATTRIBUTES]", "checked");

                            strAttributes = "checked ";

                            if (_outbreakSessionViewModel.SessionDetails.bHasVetCases)
                            {
                                strAttributes += "disabled";
                            }

                            _outbreakSessionViewModel.AvianSpecies =
                                _outbreakSessionViewModel.AvianSpecies.Replace("[ATTRIBUTES]", strAttributes);
                        }

                        break;
                    case OutbreakSpeciesGroup.Livestock:
                        if (_outbreakSessionViewModel.SessionDetails is
                            {OutbreakTypeId: OutbreakTypes.Veterinary or OutbreakTypes.Zoonotic})
                        {
                            _outbreakSessionViewModel.SessionDetails.txtLivestockCaseMonitoringDuration =
                                sessionParameter.CaseMonitoringDuration;
                            _outbreakSessionViewModel.SessionDetails.txtLivestockCaseMonitoringFrequency =
                                sessionParameter.CaseMonitoringFrequency;
                            _outbreakSessionViewModel.SessionDetails.txtLivestockContactTracingDuration =
                                sessionParameter.ContactTracingDuration;
                            _outbreakSessionViewModel.SessionDetails.txtLivestockContactTracingFrequency =
                                sessionParameter.ContactTracingFrequency;
                            _outbreakSessionViewModel.SessionDetails.LivestockOutbreakSpeciesParameterUID =
                                sessionParameter.OutbreakSpeciesParameterUID;
                            _outbreakSessionViewModel.SessionDetails.LivestockCaseQuestionaireTemplateID =
                                sessionParameter.CaseQuestionaireTemplateID;
                            _outbreakSessionViewModel.SessionDetails.LivestockCaseMonitoringTemplateID =
                                sessionParameter.CaseMonitoringTemplateID;
                            _outbreakSessionViewModel.SessionDetails.LivestockContactTracingTemplateID =
                                sessionParameter.ContactTracingTemplateID;

                            strAttributes = "checked ";

                            if (_outbreakSessionViewModel.SessionDetails.bHasVetCases)
                            {
                                strAttributes += "disabled";
                            }

                            _outbreakSessionViewModel.LivestockSpecies =
                                _outbreakSessionViewModel.LivestockSpecies.Replace("[ATTRIBUTES]", strAttributes);
                        }

                        break;
                    case OutbreakSpeciesGroup.Vector:
                        strAttributes = "checked ";

                        if (_outbreakSessionViewModel.SessionDetails is {bHasVetCases: true})
                        {
                            strAttributes += "disabled";
                        }

                        _outbreakSessionViewModel.VectorSepceis =
                            _outbreakSessionViewModel.VectorSepceis.Replace("[ATTRIBUTES]", strAttributes);
                        break;
                }
            }

            if (_outbreakSessionViewModel.SessionDetails == null) return View(_outbreakSessionViewModel);
            switch (_outbreakSessionViewModel.SessionDetails.OutbreakTypeId)
            {
                case OutbreakTypes.Human:
                    _outbreakSessionViewModel.AvianSpecies =
                        _outbreakSessionViewModel.AvianSpecies.Replace("[ATTRIBUTES]", "disabled");
                    _outbreakSessionViewModel.LivestockSpecies =
                        _outbreakSessionViewModel.LivestockSpecies.Replace("[ATTRIBUTES]", "disabled");
                    break;
                case OutbreakTypes.Veterinary:
                    _outbreakSessionViewModel.HumanSpecies =
                        _outbreakSessionViewModel.HumanSpecies.Replace("[ATTRIBUTES]", "disabled");
                    break;
            }

            _outbreakSessionViewModel.SessionDetails.bShowSuccessMessage = bShowSuccessMessage;
            _outbreakSessionViewModel.SessionDetails.bShowOutbreakID = bShowOutbreakId;

            return View(_outbreakSessionViewModel);
        }

        public IActionResult FlexFormDesigner(OutbreakFlexFormDesignerModel request)
        {
            TempData["OutbreakDetails"] = System.Text.Json.JsonSerializer.Serialize(request);
            return RedirectToAction("Index", "Configuration/FlexFormDesignerPage");
        }

        private async Task BuildSessionLocationControl(long? administrativeUnitType)
        {
            var sessionLocationViewModel = new LocationViewModel();

            var siteDetails = await _siteClient.GetSiteDetails(_outbreakSessionViewModel.CurrentLanguage, Convert.ToInt64(_authenticatedUser.SiteId), Convert.ToInt64(_authenticatedUser.EIDSSUserId));

            if (siteDetails != null)
            {
                var aggregateSettingsGetRequestModel = new AggregateSettingsGetRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    IdfCustomizationPackage = siteDetails.CustomizationPackageID,
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "idfsAggrCaseType",
                    SortOrder = "asc"
                };

                var aggregateSettings = await _configurationClient.GetAggregateSettings(aggregateSettingsGetRequestModel);

                //Set AggregateDiseaseReportViewModel Search Properties
                if (aggregateSettings != null)
                {
                    if (administrativeUnitType != null)
                    {
                        _outbreakSessionViewModel.SearchAdministrativeUnitTypeID = administrativeUnitType.Value;
                    }
                    else
                    {
                        _outbreakSessionViewModel.SearchAdministrativeUnitTypeID = (long)GISAdministrativeLevels.AdminLevel1;
                    }
                }
                else
                {
                    _outbreakSessionViewModel.SearchAdministrativeUnitTypeID = (long)GISAdministrativeLevels.AdminLevel1;
                }

                _outbreakSessionViewModel.SessionLocationViewModel = new LocationViewModel
                {
                    AdminLevel0Value = siteDetails.CountryID
                };
                sessionLocationViewModel.AdminLevel0Value = siteDetails.CountryID;

                _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel1Value = _userPreferences.DefaultRegionInSearchPanels ? siteDetails.AdministrativeLevel2ID : null;
                _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel2Value = _userPreferences.DefaultRayonInSearchPanels ? siteDetails.AdministrativeLevel3ID : null;

                // Location Control
                sessionLocationViewModel.IsHorizontalLayout = true;
                sessionLocationViewModel.ShowAdminLevel0 = false;
                sessionLocationViewModel.ShowAdminLevel1 = true;
                sessionLocationViewModel.ShowAdminLevel2 = true;
                sessionLocationViewModel.ShowAdminLevel3 = true;
                sessionLocationViewModel.ShowAdminLevel4 = false;
                sessionLocationViewModel.ShowAdminLevel5 = false;
                sessionLocationViewModel.ShowAdminLevel6 = false;
                sessionLocationViewModel.ShowSettlement = true;
                sessionLocationViewModel.ShowSettlementType = true;
                sessionLocationViewModel.ShowStreet = false;
                sessionLocationViewModel.ShowApartment = false;
                sessionLocationViewModel.ShowPostalCode = false;
                sessionLocationViewModel.ShowCoordinates = false;
                sessionLocationViewModel.ShowBuildingHouseApartmentGroup = false;

                sessionLocationViewModel.AdminLevel1Text = _localizer.GetString(FieldLabelResourceKeyConstants.Region1FieldLabel);
                sessionLocationViewModel.AdminLevel2Text = _localizer.GetString(FieldLabelResourceKeyConstants.Rayon1FieldLabel);
                sessionLocationViewModel.AdminLevel3Text = _localizer.GetString(FieldLabelResourceKeyConstants.SettlementTypeFieldLabel);
                sessionLocationViewModel.AdminLevel4Text = _localizer.GetString(FieldLabelResourceKeyConstants.SettlementFieldLabel);

                _outbreakSessionViewModel.SearchAdministrativeUnitTypeID = (long)GISAdministrativeLevels.AdminLevel1;

                switch (_outbreakSessionViewModel.SearchAdministrativeUnitTypeID)
                {
                    case (long)GISAdministrativeLevels.AdminLevel1:
                        sessionLocationViewModel.AdminLevel1Value = _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel1Value;
                        sessionLocationViewModel.IsDbRequiredAdminLevel1 = false;
                        sessionLocationViewModel.ShowAdminLevel1 = true;
                        sessionLocationViewModel.EnableAdminLevel1 = true;
                        break;
                    case (long)GISAdministrativeLevels.AdminLevel2:
                        sessionLocationViewModel.AdminLevel1Value = _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel1Value;
                        sessionLocationViewModel.AdminLevel2Value = _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel2Value;
                        sessionLocationViewModel.IsDbRequiredAdminLevel1 = false;
                        sessionLocationViewModel.ShowAdminLevel1 = true;
                        sessionLocationViewModel.IsDbRequiredAdminLevel2 = false;
                        sessionLocationViewModel.ShowAdminLevel2 = true;
                        break;
                    case (long)GISAdministrativeLevels.AdminLevel3:
                        sessionLocationViewModel.AdminLevel1Value = _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel1Value;
                        sessionLocationViewModel.AdminLevel2Value = _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel2Value;
                        sessionLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        sessionLocationViewModel.ShowAdminLevel1 = true;
                        sessionLocationViewModel.EnableAdminLevel1 = true;
                        sessionLocationViewModel.IsDbRequiredAdminLevel2 = true;
                        sessionLocationViewModel.ShowAdminLevel2 = true;
                        sessionLocationViewModel.EnableAdminLevel2 = true;
                        break;
                    default:
                        sessionLocationViewModel.AdminLevel1Value = _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel1Value;
                        sessionLocationViewModel.AdminLevel2Value = _outbreakSessionViewModel.SessionLocationViewModel.AdminLevel2Value;
                        sessionLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        sessionLocationViewModel.ShowAdminLevel1 = true;
                        sessionLocationViewModel.EnableAdminLevel1 = true;
                        sessionLocationViewModel.IsDbRequiredAdminLevel2 = true;
                        sessionLocationViewModel.ShowAdminLevel2 = true;
                        sessionLocationViewModel.EnableAdminLevel2 = true;
                        break;
                }
            }
            _outbreakSessionViewModel.SessionLocationViewModel = sessionLocationViewModel;
        }
    }
}
