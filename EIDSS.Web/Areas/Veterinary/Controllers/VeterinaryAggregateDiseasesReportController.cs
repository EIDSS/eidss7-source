using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Helpers;
using EIDSS.Web.ViewModels.CrossCutting;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Areas.Veterinary.Controllers
{
    [Area("Veterinary")]
    [Controller]
    public class VeterinaryAggregateDiseasesReportController : BaseController
    {
        #region Global Values

        private readonly IAggregateReportClient _aggregateDiseaseReportClient;
        private readonly ISiteClient _siteClient;
        private readonly UserPreferences _userPreferences;
        private readonly IConfiguration _configuration;
        private readonly UserPermissions _permissions;
        private readonly IFlexFormClient _flexFormClient;
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly IConfigurationClient _configurationClient;

        #endregion

        #region Constructors/Invocations

        public VeterinaryAggregateDiseasesReportController(IAggregateReportClient aggregateDiseaseReportClient,
            ISiteClient siteClient,
            IFlexFormClient flexFormClient,
            ICrossCuttingClient crossCuttingClient,
            IConfigurationClient configurationClient,
            IConfiguration configuration,
            ITokenService tokenService,
            ILogger<VeterinaryAggregateDiseasesReportController> logger) :
            base(logger, tokenService)
        {
            _aggregateDiseaseReportClient = aggregateDiseaseReportClient;
            _siteClient = siteClient;
            _flexFormClient = flexFormClient;
            _crossCuttingClient = crossCuttingClient;
            _configurationClient = configurationClient;
            _configuration = configuration;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            _userPreferences = authenticatedUser.Preferences;
            _permissions = GetUserPermissions(PagePermission.AccessToVeterinaryAggregateDiseaseReports);
        }

        #endregion

        public IActionResult Index()
        {
            return View();
        }

        public async Task<IActionResult> Details(long? id, bool isReadOnly = false)
        {
            AggregateReportDetailsViewModel model = new()
            {
                ReportDetailsSection = new ReportDetailsSectionViewModel
                {
                    AggregateDiseaseReportDetails = new AggregateReportGetDetailViewModel(),
                    DetailsLocationViewModel = new LocationViewModel
                    {
                        EnableAdminLevel0 = false,
                        IsHorizontalLayout = true,
                        ShowAdminLevel0 = true,
                        ShowAdminLevel1 = true,
                        ShowAdminLevel2 = true,
                        ShowAdminLevel3 = true,
                        ShowAdminLevel4 = false,
                        ShowAdminLevel5 = false,
                        ShowAdminLevel6 = false,
                        EnableAdminLevel1 = !isReadOnly,
                        EnableAdminLevel2 = !isReadOnly,
                        EnableAdminLevel3 = !isReadOnly,
                        EnableAdminLevel4 = !isReadOnly,
                        EnableAdminLevel5 = !isReadOnly,
                        EnableAdminLevel6 = !isReadOnly,
                        ShowSettlement = true,
                        ShowSettlementType = true,
                        EnableSettlement = !isReadOnly,
                        EnableSettlementType = !isReadOnly,
                        ShowStreet = false,
                        ShowBuilding = false,
                        ShowApartment = false,
                        ShowElevation = false,
                        ShowHouse = true,
                        ShowLatitude = false,
                        ShowLongitude = false,
                        ShowMap = false,
                        ShowBuildingHouseApartmentGroup = false,
                        ShowPostalCode = false,
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
                        OperationType = isReadOnly ? LocationViewOperationType.ReadOnly : LocationViewOperationType.Edit
        }
                },
                DiseaseMatrixSection = new DiseaseMatrixSectionViewModel
                {
                    AggregateCase = new FlexFormQuestionnaireGetRequestModel(),
                }
            };

            if (isReadOnly)
                model.StartIndex = 2;

            model.Permissions = _permissions;

            if (id != null)
            {
                var detailRequest = new AggregateReportGetListDetailRequestModel()
                {
                    LanguageID = GetCurrentLanguage(),
                    idfAggrCase = (long)id,
                    idfsAggrCaseType = (long)AggregateDiseaseReportTypes.VeterinaryAggregateDiseaseReport,
                    ApplyFiltrationIndicator = _tokenService.GetAuthenticatedUser().SiteTypeId >= (long)SiteTypes.ThirdLevel,
                    UserSiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId),
                    UserOrganizationID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().OfficeId),
                    UserEmployeeID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId)
                };
                var response = await _aggregateDiseaseReportClient.GetAggregateReportDetail(detailRequest);
                if (response.Any())
                {
                    model.ReportDetailsSection.AggregateDiseaseReportDetails = response[0];
                    model.ReportDetailsSection.AdministrativeLevelID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsAreaType.GetValueOrDefault();
                    model.ReportDetailsSection.TimeIntervalID = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsPeriodType.GetValueOrDefault();

                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel1Value = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsRegion;
                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel2Value = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsRayon;
                    model.ReportDetailsSection.DetailsLocationViewModel.AdminLevel3Value = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSettlement;

                    model.DiseaseMatrixSection.AggregateCase.idfsFormTemplate = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate;
                    model.DiseaseMatrixSection.AggregateCase.idfObservation = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfCaseObservation;
                    model.DiseaseMatrixSection.idfsFormTemplate = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsCaseFormTemplate.GetValueOrDefault();
                    model.DiseaseMatrixSection.idfVersion = model.ReportDetailsSection.AggregateDiseaseReportDetails.idfVersion;

                    if (model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite !=
                        Convert.ToInt64(authenticatedUser.SiteId))
                    {
                        var deletePermissionIndicator = response[0].DeletePermissionIndicator;
                        if (deletePermissionIndicator != null)
                            model.Permissions.Delete = (bool) deletePermissionIndicator;
                        var writePermissionIndicator = response[0].WritePermissionIndicator;
                        if (writePermissionIndicator != null)
                            model.Permissions.Write = (bool) writePermissionIndicator;
                    }
                }
                else
                    model.Permissions.Read = false;
            }
            else
            {
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfEnteredByOffice = authenticatedUser.OfficeId;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfEnteredByPerson = Convert.ToInt64(authenticatedUser.PersonId);
                model.ReportDetailsSection.AggregateDiseaseReportDetails.strEnteredByOffice = authenticatedUser.Organization;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.strEnteredByPerson = authenticatedUser.LastName + ", " + authenticatedUser.FirstName;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.datEnteredByDate = DateTime.Today;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsSite = Convert.ToInt64(authenticatedUser.SiteId);
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfsAggrCaseType = Convert.ToInt64(AggregateDiseaseReportTypes.VeterinaryAggregateDiseaseReport);
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByOffice = null;
                model.ReportDetailsSection.AggregateDiseaseReportDetails.idfSentByPerson = null;
                model.ReportDetailsSection.LegacyIDVisibleIndicator = false;

                FlexFormTemplateGetRequestModel request = new()
                {
                    LanguageId = GetCurrentLanguage(),
                    idfsFormTemplate = null,
                    idfsFormType = (long)FlexibleFormTypes.VeterinaryAggregate
                };
                var templateList = await _flexFormClient.GetTemplateList(request);

                // set template to the one stored with the record or the default template
                long? defaultFormTemplate = null;
                if (templateList is { Count: > 0})
                {
                    defaultFormTemplate = templateList.Find(v => v.blnUNI) == null
                        ? null
                        : templateList.Find(v => v.blnUNI)?.idfsFormTemplate;
                }

                if (defaultFormTemplate != null)
                {
                    model.DiseaseMatrixSection.idfsFormTemplate ??= defaultFormTemplate;
                    model.DiseaseMatrixSection.AggregateCase.idfsFormTemplate ??= defaultFormTemplate;
                }
            }

            await FillConfigurationSettingsAsync(model.ReportDetailsSection);

            model.ReportDetailsSection.DetailsLocationViewModel.CallingObjectID = "ReportDetailsSection_";

            model.DiseaseMatrixSection.AggregateCase.MatrixData = new List<FlexFormMatrixData>();
            model.DiseaseMatrixSection.AggregateCase.MatrixColumns = new List<string>();

            // set version to the one stored with the record or the default version
            long? defaultVersion = null;
            var matrixVersionList = await _crossCuttingClient.GetMatrixVersionsByType(MatrixTypes.VetAggregateCase);
            if (matrixVersionList is { Count: > 0 })
            {
                defaultVersion = matrixVersionList.Find(v => v.BlnIsActive == true) == null ? null : matrixVersionList.Find(v => v.BlnIsActive == true)?.IdfVersion;
            }

            if (defaultVersion != null)
            {
                model.DiseaseMatrixSection.idfVersion ??= defaultVersion;
            }

            //Generate report parameters
            model.ReportPrintViewModel = new DiseaseReportPrintViewModel
            {
                Parameters = new List<KeyValuePair<string, string>>(),
                ReportName = "VeterinaryAggregateDiseaseReport"
            };

            //(long)FlexibleFormTypes.HumanAggregate;
            if (id != null)
            {

                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("idfAggrCaseList", id.Value.ToString()));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("idfsAggrCaseType", ((long)FlexibleFormTypes.VeterinaryAggregate).ToString()));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("LangID", GetCurrentLanguage()));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("SiteID", authenticatedUser.SiteId));
                model.ReportPrintViewModel.Parameters.Add(new KeyValuePair<string, string>("PersonID", authenticatedUser.PersonId));
            }

            return View(model);
        }

        private async Task FillConfigurationSettingsAsync(ReportDetailsSectionViewModel model)
        {
            LocationViewModel searchLocationViewModel = new();

            var siteDetails = await _siteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(authenticatedUser.SiteId), Convert.ToInt64(authenticatedUser.EIDSSUserId));

            if (siteDetails != null)
            {
                AggregateSettingsGetRequestModel aggregateSettingsGetRequestModel = new()
                {
                    IdfCustomizationPackage = siteDetails.CustomizationPackageID,
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "idfsAggrCaseType",
                    SortOrder = SortConstants.Ascending
                };

                var aggregateSettings = await _configurationClient.GetAggregateSettings(aggregateSettingsGetRequestModel);

                var aggregateSetting = aggregateSettings.FirstOrDefault(a => a.idfsAggrCaseType == Convert.ToInt64(AggregateValue.Veterinary));
                if (model.AdministrativeLevelID == null)
                {
                    model.AdministrativeLevelID = aggregateSetting?.idfsStatisticAreaType;
                    model.TimeIntervalID = aggregateSetting?.idfsStatisticPeriodType;
                    model.AggregateDiseaseReportDetails.idfsAreaType = model.AdministrativeLevelID;
                    model.AggregateDiseaseReportDetails.idfsPeriodType = model.TimeIntervalID;
                }

                FillMinimumTimeUnit(model);

                if (model.AggregateDiseaseReportDetails.idfAggrCase == null)
                {
                    model.DetailsLocationViewModel.AdminLevel0Value = siteDetails.CountryID;
                    searchLocationViewModel.AdminLevel0Value = siteDetails.CountryID;
                    model.AggregateDiseaseReportDetails.strCountry = siteDetails.CountryID.ToString();
                    model.DetailsLocationViewModel.AdminLevel1Value = siteDetails.AdministrativeLevel2ID;
                    model.DetailsLocationViewModel.AdminLevel2Value = siteDetails.AdministrativeLevel3ID;

                    model.DetailsLocationViewModel.AdminLevel1Value = _userPreferences.DefaultRegionInSearchPanels ? siteDetails.AdministrativeLevel2ID : null;
                    model.DetailsLocationViewModel.AdminLevel2Value = _userPreferences.DefaultRayonInSearchPanels ? siteDetails.AdministrativeLevel3ID : null;
                }

                // Location Control
                searchLocationViewModel.IsHorizontalLayout = true;
                searchLocationViewModel.EnableAdminLevel1 = true;
                searchLocationViewModel.ShowAdminLevel0 = false;
                searchLocationViewModel.ShowAdminLevel1 = true;
                searchLocationViewModel.ShowAdminLevel2 = true;
                searchLocationViewModel.ShowAdminLevel3 = false;
                searchLocationViewModel.ShowAdminLevel4 = false;
                searchLocationViewModel.ShowAdminLevel5 = false;
                searchLocationViewModel.ShowAdminLevel6 = false;
                searchLocationViewModel.ShowSettlement = true;
                searchLocationViewModel.ShowSettlementType = true;
                searchLocationViewModel.ShowStreet = false;
                searchLocationViewModel.ShowBuilding = false;
                searchLocationViewModel.ShowApartment = false;
                searchLocationViewModel.ShowElevation = false;
                searchLocationViewModel.ShowHouse = false;
                searchLocationViewModel.ShowLatitude = false;
                searchLocationViewModel.ShowLongitude = false;
                searchLocationViewModel.ShowMap = false;
                searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                searchLocationViewModel.ShowPostalCode = false;
                searchLocationViewModel.ShowCoordinates = false;
                searchLocationViewModel.IsDbRequiredAdminLevel1 = false;
                searchLocationViewModel.IsDbRequiredSettlement = false;
                searchLocationViewModel.IsDbRequiredSettlementType = false;
                searchLocationViewModel.AdminLevel0Value = siteDetails.CountryID;

                searchLocationViewModel.ShowBuildingHouseApartmentGroup = true;

                switch (model.AdministrativeLevelID)
                {
                    //case (long)GISAdministrativeLevels.AdminLevel0:
                    case (long)AdministrativeUnitTypes.Country:
                        searchLocationViewModel.IsDbRequiredAdminLevel0 = true;
                        searchLocationViewModel.ShowAdminLevel0 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.ShowAdminLevel1 = false;
                        searchLocationViewModel.EnableAdminLevel1 = false;
                        searchLocationViewModel.ShowAdminLevel2 = false;
                        searchLocationViewModel.EnableAdminLevel2 = false;
                        searchLocationViewModel.ShowSettlement = false;
                        searchLocationViewModel.ShowSettlementType = false;
                        searchLocationViewModel.EnableSettlement = false;
                        searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                        searchLocationViewModel.ShowHouse = false;
                        searchLocationViewModel.ShowBuilding = false;
                        searchLocationViewModel.ShowApartment = false;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel0Value;
                        break;

                    //case (long)GISAdministrativeLevels.AdminLevel1:
                    case (long)AdministrativeUnitTypes.Region:
                        searchLocationViewModel.IsDbRequiredAdminLevel0 = true;
                        searchLocationViewModel.ShowAdminLevel0 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.AdminLevel1Value = model.DetailsLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel2 = false;
                        searchLocationViewModel.EnableAdminLevel2 = false;
                        searchLocationViewModel.ShowSettlement = false;
                        searchLocationViewModel.ShowSettlementType = false;
                        searchLocationViewModel.EnableSettlement = false;
                        searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                        searchLocationViewModel.ShowHouse = false;
                        searchLocationViewModel.ShowBuilding = false;
                        searchLocationViewModel.ShowApartment = false;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel1Value;
                        break;

                    //case (long)GISAdministrativeLevels.AdminLevel2:
                    case (long)AdministrativeUnitTypes.Rayon:
                        searchLocationViewModel.IsDbRequiredAdminLevel0 = true;
                        searchLocationViewModel.ShowAdminLevel0 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.AdminLevel1Value = model.DetailsLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = model.DetailsLocationViewModel.AdminLevel2Value;
                        searchLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.IsDbRequiredAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.ShowSettlement = false;
                        searchLocationViewModel.ShowSettlementType = false;
                        searchLocationViewModel.EnableSettlement = false;
                        searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                        searchLocationViewModel.ShowHouse = false;
                        searchLocationViewModel.ShowBuilding = false;
                        searchLocationViewModel.ShowApartment = false;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel2Value;
                        break;

                    //case (long)GISAdministrativeUnitTypes.Settlement:
                    case (long)AdministrativeUnitTypes.Settlement:
                        searchLocationViewModel.IsDbRequiredAdminLevel0 = true;
                        searchLocationViewModel.ShowAdminLevel0 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.AdminLevel1Value = model.DetailsLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = model.DetailsLocationViewModel.AdminLevel2Value;
                        searchLocationViewModel.AdminLevel3Value = model.DetailsLocationViewModel.AdminLevel3Value;
                        searchLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.IsDbRequiredAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.IsDbRequiredAdminLevel3 = true;
                        searchLocationViewModel.ShowAdminLevel3 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;
                        searchLocationViewModel.ShowSettlementType = true;
                        model.DetailsLocationViewModel.IsDbRequiredSettlementType = true;
                        searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                        searchLocationViewModel.ShowHouse = false;
                        searchLocationViewModel.ShowBuilding = false;
                        searchLocationViewModel.ShowApartment = false;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel3Value ??
                            model.DetailsLocationViewModel.AdminLevel2Value;
                        break;

                    default:
                        searchLocationViewModel.IsDbRequiredAdminLevel0 = true;
                        searchLocationViewModel.ShowAdminLevel0 = true;
                        searchLocationViewModel.EnableAdminLevel0 = false;
                        searchLocationViewModel.AdminLevel1Value = model.DetailsLocationViewModel.AdminLevel1Value;
                        searchLocationViewModel.AdminLevel2Value = model.DetailsLocationViewModel.AdminLevel2Value;
                        searchLocationViewModel.AdminLevel3Value = model.DetailsLocationViewModel.AdminLevel3Value;
                        searchLocationViewModel.IsDbRequiredAdminLevel1 = true;
                        searchLocationViewModel.ShowAdminLevel1 = true;
                        searchLocationViewModel.EnableAdminLevel1 = true;
                        searchLocationViewModel.IsDbRequiredAdminLevel2 = true;
                        searchLocationViewModel.ShowAdminLevel2 = true;
                        searchLocationViewModel.EnableAdminLevel2 = true;
                        searchLocationViewModel.IsDbRequiredAdminLevel3 = true;
                        searchLocationViewModel.ShowAdminLevel3 = true;
                        searchLocationViewModel.EnableAdminLevel3 = true;
                        model.DetailsLocationViewModel.IsDbRequiredSettlementType = true;
                        searchLocationViewModel.ShowBuildingHouseApartmentGroup = false;
                        searchLocationViewModel.ShowHouse = false;
                        searchLocationViewModel.ShowBuilding = false;
                        searchLocationViewModel.ShowApartment = false;
                        model.AggregateDiseaseReportDetails.idfsAdministrativeUnit = model.DetailsLocationViewModel.AdminLevel3Value ??
                            model.DetailsLocationViewModel.AdminLevel2Value;
                        model.OrganizationVisibleIndicator = true;
                        model.OrganizationRequiredIndicator = true;

                        break;
                }

                model.DetailsLocationViewModel = searchLocationViewModel;
            }
        }

        private void FillMinimumTimeUnit(ReportDetailsSectionViewModel model, bool saveDataRangeIndicator = false)
        {
            try
            {
                model.QuarterVisibleIndicator = false;
                model.MonthVisibleIndicator = false;
                model.WeekVisibleIndicator = false;
                model.DayVisibleIndicator = false;

                DateTime startDate;
                if (model.AggregateDiseaseReportDetails.datStartDate != null)
                {
                    startDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                    model.Year = startDate.Year;
                }
                else
                {
                    model.Year = DateTime.Today.Year;
                }

                switch (model.TimeIntervalID.Value)
                {
                    case (long)TimePeriodTypes.Year:
                        if (saveDataRangeIndicator)
                        {
                            //SaveDateRange();
                        }
                        break;
                    case (long)TimePeriodTypes.Quarter:
                        model.QuarterVisibleIndicator = true;
                        if (model.AggregateDiseaseReportDetails.datStartDate != null)
                        {
                            startDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                            model.Quarter = (startDate.Month - 1) / 3 + 1;
                        }
                        break;
                    case (long)TimePeriodTypes.Month:
                        model.MonthVisibleIndicator = true;
                        if (model.AggregateDiseaseReportDetails.datStartDate != null)
                        {
                            startDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                            model.Month = startDate.Month;
                        }
                        break;
                    case (long)TimePeriodTypes.Week:
                        model.WeekVisibleIndicator = true;
                        Common.GetWeekNumberOfDate(DateTime.Now, GetCurrentLanguage()).ToString();
                        Common.GetWeekNumberOfDate(DateTime.Now.AddDays(-7), GetCurrentLanguage()).ToString();
                        Common.GetWeekNumberOfDate(DateTime.Now.AddDays(7), GetCurrentLanguage()).ToString();
                        Common.GetWeekNumberOfDate(new DateTime(DateTime.Now.Year, 12, 31), GetCurrentLanguage()).ToString();

                        if (model.AggregateDiseaseReportDetails.datStartDate != null)
                        {
                            startDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                            var id = Common.GetWeekNumberOfDate(startDate, GetCurrentLanguage()).ToString();
                            model.Week = Convert.ToInt32(id);
                        }
                        break;
                    case (long)TimePeriodTypes.Day:
                        model.MonthVisibleIndicator = true;
                        model.DayVisibleIndicator = true;
                        if (model.AggregateDiseaseReportDetails.datStartDate != null)
                        {
                            startDate = (DateTime)model.AggregateDiseaseReportDetails.datStartDate;
                            model.Month = startDate.Month;
                            model.Day = startDate;
                        }
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }
    }
}
