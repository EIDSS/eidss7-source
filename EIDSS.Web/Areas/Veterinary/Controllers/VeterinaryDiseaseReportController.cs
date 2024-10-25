#region Usings

using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Veterinary.ViewModels.VeterinaryDiseaseReport;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.Int32;

#endregion

namespace EIDSS.Web.Areas.Veterinary.Controllers
{
    [Area("Veterinary")]
    [Controller]
    public class VeterinaryDiseaseReportController : BaseController
    {
        #region Globals

        private readonly IVeterinaryClient _veterinaryClient;
        private new readonly ILogger<VeterinaryDiseaseReportController> _logger;
        private readonly IConfiguration _configuration;

        #region Member Variables

        private readonly CancellationToken _token;
        private UserPermissions _userPermissions;

        #endregion

        #endregion

        #region Constructors

        /// <summary>
        /// </summary>
        /// <param name="veterinaryClient"></param>
        /// <param name="logger"></param>
        /// <param name="configuration"></param>
        /// <param name="tokenService"></param>
        public VeterinaryDiseaseReportController(IVeterinaryClient veterinaryClient,
            ILogger<VeterinaryDiseaseReportController> logger, IConfiguration configuration, ITokenService tokenService)
            : base(logger, tokenService)
        {
            // Reset the cancellation token
            var source = new CancellationTokenSource();
            _token = source.Token;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            _veterinaryClient = veterinaryClient;
            _logger = logger;
            _configuration = configuration;
        }

        #endregion

        #region Methods

        /// <summary>
        /// </summary>
        /// <param name="refreshResultsIndicator"></param>
        /// <returns></returns>
        public IActionResult AvianDiseaseReport(bool refreshResultsIndicator = false)
        {
            SearchVeterinaryDiseaseReportPageViewModel model = new()
            {
                ReportType = VeterinaryReportTypeEnum.Avian,
                RefreshResultsIndicator = refreshResultsIndicator
            };
            return View("Index", model);
        }

        /// <summary>
        /// </summary>
        /// <param name="refreshResultsIndicator"></param>
        /// <returns></returns>
        public IActionResult LivestockDiseaseReport(bool refreshResultsIndicator = false)
        {
            SearchVeterinaryDiseaseReportPageViewModel model = new()
            {
                ReportType = VeterinaryReportTypeEnum.Livestock,
                RefreshResultsIndicator = refreshResultsIndicator
            };
            return View("Index", model);
        }

        /// <summary>
        /// </summary>
        /// <param name="reportTypeId"></param>
        /// <param name="farmId"></param>
        /// <param name="diseaseReportId"></param>
        /// <param name="diseaseId"></param>
        /// <param name="isEdit"></param>
        /// <param name="isReadOnly"></param>
        /// <param name="isReview"></param>
        /// <param name="isLinkedSurveillanceSession"></param>
        /// <param name="sessionKey"></param>
        /// <param name="sessionId"></param>
        /// <param name="reportCategoryTypeId"></param>
        /// <param name="sampleId"></param>
        /// <returns></returns>
        public async Task<IActionResult> Details(long reportTypeId,
            long? farmId,
            long? diseaseReportId,
            long? diseaseId,
            bool isEdit = false,
            bool isReadOnly = false,
            bool isReview = false,
            bool isLinkedSurveillanceSession = false,
            long? sessionKey = null,
            string sessionId = null,
            long? reportCategoryTypeId = null,
            long? sampleId = null)
        {
            try
            {
                DiseaseReportDetailPageViewModel model = new();

                SurveillanceSessionLinkedDiseaseReportViewModel activeSurveillanceModel = null;
                if (isLinkedSurveillanceSession)
                    activeSurveillanceModel = await CreateSurveillanceSessionModel(
                        farmId.GetValueOrDefault(),
                        sessionKey.GetValueOrDefault(),
                        reportTypeId,
                        diseaseId.GetValueOrDefault(),
                        sessionId,
                        sampleId.GetValueOrDefault());

                if (diseaseReportId == null)
                {
                    if (farmId != null)
                    {
                        model.DiseaseReport = new DiseaseReportGetDetailViewModel
                        {
                            FarmMasterID = (long)farmId,
                            ReportTypeID = reportTypeId == 0 ? null : reportTypeId,
                            ReportCategoryTypeID = reportCategoryTypeId ?? (long)CaseTypeEnum.Livestock,
                            ReportStatusTypeID = (long)DiseaseReportStatusTypeEnum.InProcess,
                            SiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                            RowStatus = (int)RowStatusTypeEnum.Active,
                            Animals = new List<AnimalGetListViewModel>(),
                            Vaccinations = new List<VaccinationGetListViewModel>(),
                            Samples = new List<SampleGetListViewModel>(),
                            PensideTests = new List<PensideTestGetListViewModel>(),
                            LaboratoryTests = new List<LaboratoryTestGetListViewModel>(),
                            LaboratoryTestInterpretations = new List<LaboratoryTestInterpretationGetListViewModel>(),
                            CaseLogs = new List<CaseLogGetListViewModel>(),
                            PendingSaveEvents = new List<EventSaveRequestModel>(),
                            DiseaseID = diseaseId,
                            SessionModel = activeSurveillanceModel,
                            EIDSSParentMonitoringSessionID = sessionId,
                            ParentMonitoringSessionID = sessionKey
                        };

                        _userPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);
                        model.DiseaseReport.AccessToPersonalDataPermissionIndicator =
                            _userPermissions.AccessToPersonalData;
                        model.DiseaseReport.ReadPermissionIndicator = _userPermissions.Read;
                        model.DiseaseReport.CreatePermissionIndicator = _userPermissions.Create;
                        model.DiseaseReport.WritePermissionIndicator = _userPermissions.Write;
                        model.DiseaseReport.DeletePermissionIndicator = _userPermissions.Delete;

                        _userPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);
                        model.DiseaseReport.CreateEmployeePermissionIndicator = _userPermissions.Create;

                        _userPermissions = GetUserPermissions(PagePermission.CanManageReferenceDataTables);
                        model.DiseaseReport.CreateBaseReferencePermissionIndicator = _userPermissions.Create;

                        FarmMasterGetDetailRequestModel farmRequest = new()
                        {
                            LanguageID = GetCurrentLanguage(),
                            FarmMasterID = (long)farmId
                        };
                        var farmMasterDetailModel = _veterinaryClient.GetFarmMasterDetail(farmRequest).Result.First();

                        if (farmMasterDetailModel.FarmMasterID != null)
                            model.DiseaseReport.FarmMasterID = (long)farmMasterDetailModel.FarmMasterID;
                        model.DiseaseReport.EIDSSFarmID = farmMasterDetailModel.EIDSSFarmID;
                        model.DiseaseReport.FarmName = farmMasterDetailModel.FarmName;
                        model.DiseaseReport.FarmOwnerFirstName = farmMasterDetailModel.FarmOwnerFirstName;
                        model.DiseaseReport.FarmOwnerID = farmMasterDetailModel.FarmOwnerID;
                        model.DiseaseReport.FarmOwnerLastName = farmMasterDetailModel.FarmOwnerLastName;
                        model.DiseaseReport.FarmOwnerSecondName = farmMasterDetailModel.FarmOwnerSecondName;
                        model.DiseaseReport.EIDSSFarmOwnerID = farmMasterDetailModel.EIDSSFarmOwnerID;
                        model.DiseaseReport.Phone = farmMasterDetailModel.Phone;
                        model.DiseaseReport.Email = farmMasterDetailModel.Email;
                        if (farmMasterDetailModel.FarmAddressAdministrativeLevel0ID != null)
                            model.DiseaseReport.FarmAddressAdministrativeLevel0ID =
                                (long)farmMasterDetailModel.FarmAddressAdministrativeLevel0ID;
                        model.DiseaseReport.FarmAddressAdministrativeLevel0Name =
                            farmMasterDetailModel.FarmAddressAdministrativeLevel0Name;
                        model.DiseaseReport.FarmAddressAdministrativeLevel1ID =
                            farmMasterDetailModel.FarmAddressAdministrativeLevel1ID;
                        model.DiseaseReport.FarmAddressAdministrativeLevel1Name =
                            farmMasterDetailModel.FarmAddressAdministrativeLevel1Name;
                        model.DiseaseReport.FarmAddressAdministrativeLevel2ID =
                            farmMasterDetailModel.FarmAddressAdministrativeLevel2ID;
                        model.DiseaseReport.FarmAddressAdministrativeLevel2Name =
                            farmMasterDetailModel.FarmAddressAdministrativeLevel2Name;
                        model.DiseaseReport.FarmAddressAdministrativeLevel3ID =
                            farmMasterDetailModel.FarmAddressAdministrativeLevel3ID;
                        model.DiseaseReport.FarmAddressAdministrativeLevel3Name =
                            farmMasterDetailModel.FarmAddressAdministrativeLevel3Name;
                        model.DiseaseReport.FarmAddressSettlementID = farmMasterDetailModel.FarmAddressSettlementID;
                        model.DiseaseReport.FarmAddressSettlementName = farmMasterDetailModel.FarmAddressSettlementName;
                        model.DiseaseReport.FarmAddressSettlementTypeID =
                            farmMasterDetailModel.FarmAddressSettlementTypeID;
                        model.DiseaseReport.FarmAddressSettlementTypeName =
                            farmMasterDetailModel.FarmAddressSettlementTypeName;
                        model.DiseaseReport.FarmAddressApartment = farmMasterDetailModel.FarmAddressApartment;
                        model.DiseaseReport.FarmAddressBuilding = farmMasterDetailModel.FarmAddressBuilding;
                        model.DiseaseReport.FarmAddressHouse = farmMasterDetailModel.FarmAddressHouse;
                        model.DiseaseReport.FarmAddressLatitude = farmMasterDetailModel.FarmAddressLatitude;
                        model.DiseaseReport.FarmAddressLongitude = farmMasterDetailModel.FarmAddressLongitude;
                        model.DiseaseReport.FarmAddressPostalCodeID = farmMasterDetailModel.FarmAddressPostalCodeID;
                        model.DiseaseReport.FarmAddressPostalCode = farmMasterDetailModel.FarmAddressPostalCode;
                        model.DiseaseReport.FarmAddressStreetID = farmMasterDetailModel.FarmAddressStreetID;
                        model.DiseaseReport.FarmAddressStreetName = farmMasterDetailModel.FarmAddressStreetName;
                    }

                    model.DiseaseReport.FarmLocation = new LocationViewModel
                    {
                        IsHorizontalLayout = true,
                        AlwaysDisabled = true,
                        EnableAdminLevel1 = false,
                        EnableAdminLevel2 = false,
                        EnableAdminLevel3 = false,
                        EnableApartment = false,
                        EnableBuilding = false,
                        EnableHouse = false,
                        EnabledLatitude = model.DiseaseReport.CreatePermissionIndicator,
                        EnabledLongitude = model.DiseaseReport.CreatePermissionIndicator,
                        EnablePostalCode = false,
                        EnableSettlement = false,
                        EnableSettlementType = false,
                        EnableStreet = false,
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
                    model.DiseaseReport.FarmLocation.AdminLevel0Value =
                        model.DiseaseReport.FarmAddressAdministrativeLevel0ID;
                    model.DiseaseReport.FarmLocation.AdminLevel1Value =
                        model.DiseaseReport.FarmAddressAdministrativeLevel1ID;
                    model.DiseaseReport.FarmLocation.AdminLevel2Value =
                        model.DiseaseReport.FarmAddressAdministrativeLevel2ID;
                    model.DiseaseReport.FarmLocation.AdminLevel3Value =
                        model.DiseaseReport.FarmAddressAdministrativeLevel3ID;
                    model.DiseaseReport.FarmLocation.SettlementType = model.DiseaseReport.FarmAddressSettlementTypeID;
                    model.DiseaseReport.FarmLocation.SettlementText = model.DiseaseReport.FarmAddressSettlementName;
                    model.DiseaseReport.FarmLocation.SettlementId = model.DiseaseReport.FarmAddressSettlementID;
                    model.DiseaseReport.FarmLocation.Settlement = model.DiseaseReport.FarmAddressSettlementID;
                    model.DiseaseReport.FarmLocation.Apartment = model.DiseaseReport.FarmAddressApartment;
                    model.DiseaseReport.FarmLocation.Building = model.DiseaseReport.FarmAddressBuilding;
                    model.DiseaseReport.FarmLocation.House = model.DiseaseReport.FarmAddressHouse;
                    model.DiseaseReport.FarmLocation.Latitude = model.DiseaseReport.FarmAddressLatitude;
                    model.DiseaseReport.FarmLocation.Longitude = model.DiseaseReport.FarmAddressLongitude;
                    model.DiseaseReport.FarmLocation.PostalCode = model.DiseaseReport.FarmAddressPostalCodeID;
                    model.DiseaseReport.FarmLocation.PostalCodeText = model.DiseaseReport.FarmAddressPostalCode;
                    if (model.DiseaseReport.FarmAddressPostalCodeID != null)
                        model.DiseaseReport.FarmLocation.PostalCodeList = new List<PostalCodeViewModel>
                        {
                            new()
                            {
                                PostalCodeID = model.DiseaseReport.FarmAddressPostalCodeID.ToString(),
                                PostalCodeString = model.DiseaseReport.FarmAddressPostalCode
                            }
                        };

                    model.DiseaseReport.FarmLocation.StreetText = model.DiseaseReport.FarmAddressStreetName;
                    model.DiseaseReport.FarmLocation.Street = model.DiseaseReport.FarmAddressStreetID;
                    if (model.DiseaseReport.FarmAddressStreetID != null)
                        model.DiseaseReport.FarmLocation.StreetList = new List<StreetModel>
                        {
                            new()
                            {
                                StreetID = model.DiseaseReport.FarmAddressStreetID.ToString(),
                                StreetName = model.DiseaseReport.FarmAddressStreetName
                            }
                        };

                    model.DiseaseReport.EnteredByPersonID = Convert.ToInt64(authenticatedUser.PersonId);
                    model.DiseaseReport.EnteredByPersonName =
                        authenticatedUser.LastName + ", " + authenticatedUser.FirstName;
                    model.DiseaseReport.EnteredDate = DateTime.Now;
                    model.DiseaseReport.SiteName = authenticatedUser.Organization;

                    if (model.DiseaseReport.ReportCategoryTypeID == (long)CaseTypeEnum.Avian)
                    {
                        FlexFormQuestionnaireGetRequestModel farmEpidemiologicalInfoFlexFormRequest = new()
                        {
                            idfsFormType = (long)FlexibleFormTypeEnum.AvianFarmEpidemiologicalInfo,
                            LangID = GetCurrentLanguage()
                        };
                        model.DiseaseReport.FarmEpidemiologicalInfoFlexForm = farmEpidemiologicalInfoFlexFormRequest;
                    }
                    else
                    {
                        FlexFormQuestionnaireGetRequestModel farmEpidemiologicalInfoFlexFormRequest = new()
                        {
                            idfsFormType = (long)FlexibleFormTypeEnum.LivestockFarmFarmEpidemiologicalInfo,
                            LangID = GetCurrentLanguage()
                        };
                        model.DiseaseReport.FarmEpidemiologicalInfoFlexForm = farmEpidemiologicalInfoFlexFormRequest;

                        FlexFormQuestionnaireGetRequestModel controlMeasuresFlexFormRequest = new()
                        {
                            idfsFormType = (long)FlexibleFormTypeEnum.LivestockControlMeasures,
                            LangID = GetCurrentLanguage()
                        };
                        model.DiseaseReport.ControlMeasuresFlexForm = controlMeasuresFlexFormRequest;
                    }
                }
                else
                {
                    DiseaseReportGetDetailRequestModel request = new()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = MaxValue - 1,
                        SortColumn = "EIDSSReportID",
                        SortOrder = SortConstants.Ascending,
                        DiseaseReportID = (long) diseaseReportId,
                        ApplyFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >=
                                                   (long) SiteTypes.ThirdLevel,
                        UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                        UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                        UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId)
                    };

                    if (_veterinaryClient.GetDiseaseReportDetail(request, _token).Result.Any())
                    {
                        model.DiseaseReport = _veterinaryClient.GetDiseaseReportDetail(request, _token).Result.First();
                        
                        if (model.DiseaseReport.SiteID == Convert.ToInt64(authenticatedUser.SiteId))
                        {
                            _userPermissions = GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);
                            model.DiseaseReport.AccessToPersonalDataPermissionIndicator =
                                _userPermissions.AccessToPersonalData;
                            model.DiseaseReport.ReadPermissionIndicator = _userPermissions.Read;
                            model.DiseaseReport.CreatePermissionIndicator = _userPermissions.Create;
                            model.DiseaseReport.WritePermissionIndicator = _userPermissions.Write;
                            model.DiseaseReport.DeletePermissionIndicator = _userPermissions.Delete;
                        }

                        _userPermissions =
                            GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);
                        model.DiseaseReport.CreateEmployeePermissionIndicator = _userPermissions.Create;

                        _userPermissions = GetUserPermissions(PagePermission.CanManageReferenceDataTables);
                        model.DiseaseReport.CreateBaseReferencePermissionIndicator = _userPermissions.Create;

                        model.DiseaseReport.PendingSaveEvents = new List<EventSaveRequestModel>();
                        model.DiseaseReport.FarmLocation = new LocationViewModel
                        {
                            IsHorizontalLayout = true,
                            AlwaysDisabled = true,
                            EnableAdminLevel1 = false,
                            EnableAdminLevel2 = false,
                            EnableAdminLevel3 = false,
                            EnableApartment = false,
                            EnableBuilding = false,
                            EnableHouse = false,
                            EnabledLatitude = model.DiseaseReport.WritePermissionIndicator,
                            EnabledLongitude = model.DiseaseReport.WritePermissionIndicator,
                            EnablePostalCode = false,
                            EnableSettlement = false,
                            EnableSettlementType = false,
                            EnableStreet = false,
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
                        model.DiseaseReport.FarmLocation.AdminLevel0Value =
                            model.DiseaseReport.FarmAddressAdministrativeLevel0ID;
                        model.DiseaseReport.FarmLocation.AdminLevel1Value =
                            model.DiseaseReport.FarmAddressAdministrativeLevel1ID;
                        model.DiseaseReport.FarmLocation.AdminLevel2Value =
                            model.DiseaseReport.FarmAddressAdministrativeLevel2ID;
                        model.DiseaseReport.FarmLocation.AdminLevel3Value =
                            model.DiseaseReport.FarmAddressAdministrativeLevel3ID;
                        model.DiseaseReport.FarmLocation.SettlementType =
                            model.DiseaseReport.FarmAddressSettlementTypeID;
                        model.DiseaseReport.FarmLocation.SettlementText = model.DiseaseReport.FarmAddressSettlementName;
                        model.DiseaseReport.FarmLocation.SettlementId = model.DiseaseReport.FarmAddressSettlementID;
                        model.DiseaseReport.FarmLocation.Settlement = model.DiseaseReport.FarmAddressSettlementID;
                        model.DiseaseReport.FarmLocation.Apartment = model.DiseaseReport.FarmAddressApartment;
                        model.DiseaseReport.FarmLocation.Building = model.DiseaseReport.FarmAddressBuilding;
                        model.DiseaseReport.FarmLocation.House = model.DiseaseReport.FarmAddressHouse;
                        model.DiseaseReport.FarmLocation.Latitude = model.DiseaseReport.FarmAddressLatitude;
                        model.DiseaseReport.FarmLocation.Longitude = model.DiseaseReport.FarmAddressLongitude;
                        model.DiseaseReport.FarmLocation.PostalCode = model.DiseaseReport.FarmAddressPostalCodeID;
                        model.DiseaseReport.FarmLocation.PostalCodeText = model.DiseaseReport.FarmAddressPostalCode;
                        if (model.DiseaseReport.FarmAddressPostalCodeID != null)
                            model.DiseaseReport.FarmLocation.PostalCodeList = new List<PostalCodeViewModel>
                            {
                                new()
                                {
                                    PostalCodeID = model.DiseaseReport.FarmAddressPostalCodeID.ToString(),
                                    PostalCodeString = model.DiseaseReport.FarmAddressPostalCode
                                }
                            };

                        model.DiseaseReport.FarmLocation.StreetText = model.DiseaseReport.FarmAddressStreetName;
                        model.DiseaseReport.FarmLocation.Street = model.DiseaseReport.FarmAddressStreetID;
                        if (model.DiseaseReport.FarmAddressStreetID != null)
                            model.DiseaseReport.FarmLocation.StreetList = new List<StreetModel>
                            {
                                new()
                                {
                                    StreetID = model.DiseaseReport.FarmAddressStreetID.ToString(),
                                    StreetName = model.DiseaseReport.FarmAddressStreetName
                                }
                            };

                        if (model.DiseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian)
                        {
                            FlexFormQuestionnaireGetRequestModel farmEpidemiologicalInfoFlexFormRequest = new()
                            {
                                idfObservation = model.DiseaseReport.FarmEpidemiologicalObservationID,
                                idfsDiagnosis = model.DiseaseReport.DiseaseID,
                                idfsFormType = (long) FlexibleFormTypeEnum.AvianFarmEpidemiologicalInfo,
                                LangID = GetCurrentLanguage()
                            };
                            model.DiseaseReport.FarmEpidemiologicalInfoFlexForm =
                                farmEpidemiologicalInfoFlexFormRequest;
                        }
                        else
                        {
                            FlexFormQuestionnaireGetRequestModel farmEpidemiologicalInfoFlexFormRequest = new()
                            {
                                idfObservation = model.DiseaseReport.FarmEpidemiologicalObservationID,
                                idfsDiagnosis = model.DiseaseReport.DiseaseID,
                                idfsFormType = (long) FlexibleFormTypeEnum.LivestockFarmFarmEpidemiologicalInfo,
                                LangID = GetCurrentLanguage()
                            };
                            model.DiseaseReport.FarmEpidemiologicalInfoFlexForm =
                                farmEpidemiologicalInfoFlexFormRequest;

                            FlexFormQuestionnaireGetRequestModel controlMeasuresFlexFormRequest = new()
                            {
                                idfObservation = model.DiseaseReport.ControlMeasuresObservationID,
                                idfsDiagnosis = model.DiseaseReport.DiseaseID,
                                idfsFormType = (long) FlexibleFormTypeEnum.LivestockControlMeasures,
                                LangID = GetCurrentLanguage()
                            };
                            model.DiseaseReport.ControlMeasuresFlexForm = controlMeasuresFlexFormRequest;
                        }

                        model.DiseaseReport.ReportCurrentlyClosedIndicator = model.DiseaseReport.ReportStatusTypeID ==
                                                                             (long) DiseaseReportStatusTypeEnum.Closed;
                        // View or edit from search or from save.
                        model.DiseaseReport.ReportViewModeIndicator = isReadOnly;
                        model.DiseaseReport.ShowReviewSectionIndicator = isReview;

                        if (model.DiseaseReport.ReportStatusTypeID == (long) DiseaseReportStatusTypeEnum.Closed ||
                            model.DiseaseReport.OutbreakID != null)
                        {
                            model.DiseaseReport.ReportDisabledIndicator = true;
                        }
                        else if (model.DiseaseReport.WritePermissionIndicator == false &&
                                 model.DiseaseReport.DiseaseReportID > 0 ||
                                 model.DiseaseReport.CreatePermissionIndicator == false &&
                                 model.DiseaseReport.DiseaseReportID <= 0)
                            model.DiseaseReport.ReportDisabledIndicator = true;
                    }
                    else
                    {
                        model.DiseaseReport = new DiseaseReportGetDetailViewModel
                        {
                            ReadPermissionIndicator = false
                        };
                    }
                }

                return View("Details", model);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="sessionKey"></param>
        /// <param name="farmMasterId"></param>
        /// <param name="reportTypeId"></param>
        /// <param name="diseaseId"></param>
        /// <param name="sessionId"></param>
        /// <param name="sampleId"></param>
        /// <returns>Task&lt;SurveillanceSessionLinkedDiseaseReportViewModel&gt;</returns>
        private async Task<SurveillanceSessionLinkedDiseaseReportViewModel> CreateSurveillanceSessionModel(long farmMasterId, long sessionKey,
            long reportTypeId, long diseaseId, string sessionId, long sampleId)
        {
            try
            {
                // samples
                var sampleRequest = new SampleGetListRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    MonitoringSessionID = sessionKey,
                    SortColumn = "CollectionDate",
                    SortOrder = SortConstants.Descending,
                    Page = 1,
                    PageSize = MaxValue - 1
                };
                var sampleResult = await _veterinaryClient.GetActiveSurveillanceSessionSamplesListAsync(sampleRequest, _token);
                var samples = sampleResult.Where(x => x.FarmMasterID == farmMasterId).ToList();
                foreach (var sample in samples)
                {
                    sample.SampleIDOriginal = sample.SampleID;
                }
                var reportSample = samples.First(x => x.SampleIDOriginal == sampleId);

                // tests
                var testRequest = new LaboratoryTestGetListRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    MonitoringSessionID = sessionKey,
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = "ResultDate",
                    SortOrder = SortConstants.Descending
                };
                var testResult = await _veterinaryClient.GetActiveSurveillanceSessionTestsListAsync(testRequest, _token);
                var tests = testResult.Where(x => x.FarmMasterID == farmMasterId).ToList();
                foreach (var test in tests)
                {
                    test.TestIDOriginal = test.TestID;
                }

                // farm inventory
                var farmInventoryRequest = new FarmInventoryGetListRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    FarmMasterID = farmMasterId,
                    MonitoringSessionID = sessionKey,
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = "RecordID",
                    SortOrder = SortConstants.Ascending,
                };
                var farmInventoryResult = await _veterinaryClient.GetFarmInventoryList(farmInventoryRequest, _token);
                var flockOrHerdId = farmInventoryResult.First(x => x.FarmMasterID == farmMasterId
                                                                   && x.RecordType != RecordTypeConstants.Farm
                                                                   && x.SpeciesID == reportSample.SpeciesID).FlockOrHerdID;
                var farmInventory = farmInventoryResult.Where(x => x.FarmMasterID == farmMasterId
                                                                   && x.RecordType != RecordTypeConstants.Farm
                                                                   && x.FlockOrHerdID == flockOrHerdId).ToList();

                // animals
                var animals = samples.Where(x => x.AnimalID is not null)
                    .ToList()
                    .Select(animal => new AnimalGetListViewModel()
                    {
                        AnimalID = animal.AnimalID.GetValueOrDefault(),
                        EIDSSAnimalID = animal.EIDSSAnimalID,
                        EIDSSHerdID = farmInventory is { Count: > 0 } ? farmInventory.FirstOrDefault(x => x.RecordType == RecordTypeConstants.Herd)?.EIDSSFlockOrHerdID : string.Empty,
                        SpeciesID = animal.SpeciesID,
                        SpeciesTypeID = animal.SpeciesTypeID,
                        AgeTypeID = animal.AnimalAgeTypeID,
                        AgeTypeName = animal.AnimalAgeTypeName,
                        Species = animal.Species,
                        SexTypeID = animal.AnimalGenderTypeID,
                        SexTypeName = animal.AnimalGenderTypeName,
                        SpeciesTypeName = animal.SpeciesTypeName,
                        AnimalName = animal.AnimalName,
                        Color = animal.AnimalColor
                    })
                    .ToList();

                // get interpretations
                var request = new LaboratoryTestInterpretationGetListRequestModel()
                {
                    LanguageId = GetCurrentLanguage(),
                    MonitoringSessionID = sessionKey,
                    Page = 1,
                    PageSize = MaxValue - 1,
                    SortColumn = "InterpretedDate",
                    SortOrder = SortConstants.Descending
                };
                var interpretationsResult = await _veterinaryClient.GetLaboratoryTestInterpretationList(request, _token);
                var interpretations = interpretationsResult.Where(x => x.FarmMasterID == farmMasterId).ToList();
                foreach (var interpretation in interpretations)
                {
                    interpretation.TestInterpretationIDOriginal = interpretation.TestInterpretationID;
                }

                var model = new SurveillanceSessionLinkedDiseaseReportViewModel
                {
                    SessionKey = sessionKey,
                    ReportTypeId = reportTypeId,
                    FarmMasterId = farmMasterId,
                    DiseaseId = diseaseId,
                    SessionId = sessionId,
                    FarmInventory = farmInventory,
                    Animals = animals,
                    Samples = samples,
                    LaboratoryTests = tests,
                    TestInterpretations = interpretations,
                    IsEdit = true,
                    IsReadOnly = false,
                    IsReview = false
                };

                return model;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion
    }
}