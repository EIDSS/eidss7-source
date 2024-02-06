#region Usings

using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Veterinary;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using static System.String;

#endregion

namespace EIDSS.Web.Components.Veterinary
{
    public class VeterinaryBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] private IUserConfigurationService ConfigurationService { get; set; }
        [Inject] protected ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] protected IOrganizationClient OrganizationClient { get; set; }
        [Inject] protected IVeterinaryClient VeterinaryClient { get; set; }

        #endregion

        #region Properties

        public IEnumerable<BaseReferenceViewModel> SpeciesTypes { get; set; }

        #endregion

        #region Member Variables

        private readonly CancellationToken _token;

        public VeterinaryBaseComponent(CancellationToken token)
        {
            _token = token;
        }

        #endregion

        #endregion

        #region Methods

        #region Common Methods

        /// <summary>
        /// </summary>
        /// <param name="reportCategoryTypeId">Specifies avian or livestock disease report.</param>
        /// <returns></returns>
        public async Task GetSpeciesTypes(long? reportCategoryTypeId)
        {
            try
            {
                if (SpeciesTypes == null)
                {
                    if (reportCategoryTypeId is null)
                        SpeciesTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.SpeciesList, HACodeList.NoneHACode).ConfigureAwait(false);
                    else
                        SpeciesTypes = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                            BaseReferenceConstants.SpeciesList,
                            reportCategoryTypeId == (long) CaseTypeEnum.Avian
                                ? HACodeList.AvianHACode
                                : HACodeList.LivestockHACode).ConfigureAwait(false);

                    SpeciesTypes = SpeciesTypes.Where(x => x.Name is not null);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Disease Report Methods

        #region Farm Details Section Methods

        /// <summary>
        /// </summary>
        /// <param name="diseaseReport"></param>
        public LocationViewModel SetFarmLocation(DiseaseReportGetDetailViewModel diseaseReport)
        {
            diseaseReport.FarmLocation = new LocationViewModel
            {
                IsHorizontalLayout = true,
                AlwaysDisabled = true,
                EnableAdminLevel1 = false,
                EnableAdminLevel2 = false,
                EnableAdminLevel3 = false,
                EnableApartment = false,
                EnableBuilding = false,
                EnableHouse = false,
                EnabledLatitude = !diseaseReport.ReportDisabledIndicator,
                EnabledLongitude = !diseaseReport.ReportDisabledIndicator,
                EnablePostalCode = false,
                EnableSettlement = false,
                EnableSettlementType = false,
                EnableStreet = false,
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
                AdminLevel0Value = Convert.ToInt64(CountryID),
                OperationType = diseaseReport.ReportDisabledIndicator ? LocationViewOperationType.ReadOnly : LocationViewOperationType.Edit
            };

            diseaseReport.FarmLocation.AdminLevel0Value = diseaseReport.FarmAddressAdministrativeLevel0ID;
            diseaseReport.FarmLocation.AdminLevel1Value = diseaseReport.FarmAddressAdministrativeLevel1ID;
            diseaseReport.FarmLocation.AdminLevel2Value = diseaseReport.FarmAddressAdministrativeLevel2ID;
            diseaseReport.FarmLocation.AdminLevel3Value = diseaseReport.FarmAddressAdministrativeLevel3ID;
            diseaseReport.FarmLocation.SettlementType = diseaseReport.FarmAddressSettlementTypeID;
            diseaseReport.FarmLocation.SettlementText = diseaseReport.FarmAddressSettlementName;
            diseaseReport.FarmLocation.SettlementId = diseaseReport.FarmAddressSettlementID;
            diseaseReport.FarmLocation.Settlement = diseaseReport.FarmAddressSettlementID;
            diseaseReport.FarmLocation.Apartment = diseaseReport.FarmAddressApartment;
            diseaseReport.FarmLocation.Building = diseaseReport.FarmAddressBuilding;
            diseaseReport.FarmLocation.House = diseaseReport.FarmAddressHouse;
            diseaseReport.FarmLocation.Latitude = diseaseReport.FarmAddressLatitude;
            diseaseReport.FarmLocation.Longitude = diseaseReport.FarmAddressLongitude;
            diseaseReport.FarmLocation.PostalCode = diseaseReport.FarmAddressPostalCodeID;
            diseaseReport.FarmLocation.PostalCodeText = diseaseReport.FarmAddressPostalCode;
            if (diseaseReport.FarmAddressPostalCodeID != null)
                diseaseReport.FarmLocation.PostalCodeList = new List<PostalCodeViewModel>
                {
                    new()
                    {
                        PostalCodeID = diseaseReport.FarmAddressPostalCodeID.ToString(),
                        PostalCodeString = diseaseReport.FarmAddressPostalCode
                    }
                };

            diseaseReport.FarmLocation.StreetText = diseaseReport.FarmAddressStreetName;
            diseaseReport.FarmLocation.Street = diseaseReport.FarmAddressStreetID;
            if (diseaseReport.FarmAddressStreetID != null)
                diseaseReport.FarmLocation.StreetList = new List<StreetModel>
                {
                    new()
                    {
                        StreetID = diseaseReport.FarmAddressStreetID.ToString(),
                        StreetName = diseaseReport.FarmAddressStreetName
                    }
                };

            return diseaseReport.FarmLocation;
        }

        #endregion

        #region Notification Section Methods

        public bool ValidateNotificationSection()
        {
            return true;
        }

        #endregion

        #region Farm Inventory Section Methods

        /// <summary>
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="farmMasterId"></param>
        /// <param name="farmId"></param>
        /// <returns></returns>
        public async Task<List<FarmInventoryGetListViewModel>> GetFarmInventory(long diseaseReportId, long farmMasterId, long? farmId)
        {
            var request = new FarmInventoryGetListRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    DiseaseReportID = diseaseReportId,
                    FarmID = diseaseReportId > 0 ? farmId : null, // For existing disease reports.
                    FarmMasterID =
                        diseaseReportId == 0 ? farmMasterId : null, // For disease reports that have not been saved.
                    Page = 1,
                    PageSize = int.MaxValue - 1,
                    SortColumn = "RecordID",
                    SortOrder = SortConstants.Ascending
                };

                return await VeterinaryClient.GetFarmInventoryList(request, _token);
        }

        protected IList<FarmInventoryGetListViewModel> AddSurveillanceSessionInventory(DiseaseReportGetDetailViewModel diseaseReport)
        {
            if (diseaseReport.SessionModel == null) return diseaseReport.FarmInventory;
            
            var sessionInventory = diseaseReport.SessionModel.FarmInventory.ToList();
            foreach (var item in sessionInventory)
            {
                
                item.RecordID = (diseaseReport.FarmInventory.Count + 1) * -1;
                item.FarmID = diseaseReport.FarmID;
                item.EIDSSFlockOrHerdID = item.EIDSSFlockOrHerdID.Replace("Herd", Empty).Replace("Flock", Empty).Trim();
                item.RowAction = (int)RowActionTypeEnum.Insert;
                item.RowStatus = (int)RowStatusTypeEnum.Active;
                if (diseaseReport.FarmInventory.All(x => x.RecordID != item.RecordID))
                    diseaseReport.FarmInventory.Add(item);
            }

            return diseaseReport.FarmInventory;

        }

        /// <summary>
        /// </summary>
        /// <param name="diseaseReport"></param>
        /// <returns></returns>
        public async Task<bool> ValidateDiseaseReportFarmInventory(DiseaseReportGetDetailViewModel diseaseReport)
        {
            try
            {
                var flocksOrHerds = diseaseReport.FarmInventory.Where(x => x.RecordType == RecordTypeConstants.Herd);
                var validIndicator = true;

                foreach (var flockOrHerd in flocksOrHerds)
                {
                    if (validIndicator != true) continue;
                    string message;
                    if (!diseaseReport.FarmInventory.Any(x =>
                            (x.FlockOrHerdMasterID == flockOrHerd.FlockOrHerdMasterID) &
                            (x.RecordType == RecordTypeConstants.Species)))
                    {
                        validIndicator = false;
                        message = diseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                            ? Localizer.GetString(MessageResourceKeyConstants
                                .AvianDiseaseReportFarmFlockSpeciesThereAreNoFlocksLivestockAssociatedWithThisFarmDoYouWishToContinueMessage)
                            : MessageResourceKeyConstants
                                .LivestockDiseaseReportFarmHerdSpeciesThereAreNoFlocksLivestockAssociatedWithThisFarmDoYouWishToContinueMessage;
                        await ShowErrorDialog(message, null);
                        break;
                    }

                    var species = diseaseReport.FarmInventory.Where(x =>
                        x.RecordType == RecordTypeConstants.Species &&
                        x.FlockOrHerdMasterID == flockOrHerd.FlockOrHerdMasterID);

                    foreach (var speciesItem in species)
                    {
                        if (speciesItem.SpeciesTypeID is null)
                        {
                            validIndicator = false;

                            message = Localizer.GetString(
                                diseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                    ? MessageResourceKeyConstants
                                        .AvianDiseaseReportFarmFlockSpeciesSpeciesIsRequiredMessage
                                    : MessageResourceKeyConstants
                                        .LivestockDiseaseReportFarmHerdSpeciesSpeciesIsRequiredMessage);
                            await ShowErrorDialog(message, null);
                            break;
                        }

                        if (species.Count(x =>
                                (x.SpeciesTypeID != null) & (x.SpeciesTypeID == speciesItem.SpeciesTypeID)) > 1)
                        {
                            validIndicator = false;

                            message = Localizer.GetString(
                                diseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                    ? MessageResourceKeyConstants
                                        .AvianDiseaseReportFarmFlockSpeciesTheSpeciesTypeSelectedHasAlreadyBeenAddedToTheSelectedFlockMessage
                                    : MessageResourceKeyConstants
                                        .LivestockDiseaseReportFarmHerdSpeciesTheSpeciesTypeSelectedHasAlreadyBeenAddedToTheSelectedHerdMessage);
                            await ShowErrorDialog(message, null);
                            break;
                        }

                        if (speciesItem.TotalAnimalQuantity < speciesItem.SickAnimalQuantity)
                        {
                            validIndicator = false;
                            message = diseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                ? Localizer.GetString(MessageResourceKeyConstants
                                      .AvianDiseaseReportFarmFlockSpeciesTotalNumberOfAnimalsMessage) + " " +
                                  speciesItem.TotalAnimalQuantity + " " +
                                  Localizer.GetString(MessageResourceKeyConstants
                                      .AvianDiseaseReportFarmFlockSpeciesCantBeLessThanTheNumberOfSickAnimalsMessage) +
                                  " " + speciesItem.SickAnimalQuantity + "."
                                : Localizer.GetString(MessageResourceKeyConstants
                                      .LivestockDiseaseReportFarmHerdSpeciesTotalNumberOfAnimalsMessage) + " " +
                                  speciesItem.TotalAnimalQuantity + " " +
                                  Localizer.GetString(MessageResourceKeyConstants
                                      .LivestockDiseaseReportFarmHerdSpeciesCantBeLessThanTheNumberOfSickAnimalsMessage) +
                                  " " + speciesItem.SickAnimalQuantity + ".";
                            await ShowErrorDialog(message, null);
                            speciesItem.SickAnimalQuantity = 0;
                            break;
                        }

                        if (speciesItem.TotalAnimalQuantity < speciesItem.DeadAnimalQuantity)
                        {
                            validIndicator = false;
                            message = diseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                ? Localizer.GetString(MessageResourceKeyConstants
                                      .AvianDiseaseReportFarmFlockSpeciesTotalNumberOfAnimalsMessage) + " " +
                                  speciesItem.TotalAnimalQuantity + " " +
                                  Localizer.GetString(MessageResourceKeyConstants
                                      .AvianDiseaseReportFarmFlockSpeciesCantBeLessThanTheNumberOfDeadAnimalsMessage) +
                                  " " + speciesItem.DeadAnimalQuantity + "."
                                : Localizer.GetString(MessageResourceKeyConstants
                                      .LivestockDiseaseReportFarmHerdSpeciesTotalNumberOfAnimalsMessage) + " " +
                                  speciesItem.TotalAnimalQuantity + " " +
                                  Localizer.GetString(MessageResourceKeyConstants
                                      .LivestockDiseaseReportFarmHerdSpeciesCantBeLessThanTheNumberOfDeadAnimalsMessage) +
                                  " " + speciesItem.DeadAnimalQuantity + ".";
                            await ShowErrorDialog(message, null);
                            speciesItem.DeadAnimalQuantity = 0;
                            break;
                        }

                        if (speciesItem.TotalAnimalQuantity <
                            speciesItem.SickAnimalQuantity + speciesItem.DeadAnimalQuantity)
                        {
                            validIndicator = false;
                            message = diseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                                ? Localizer.GetString(MessageResourceKeyConstants
                                      .AvianDiseaseReportFarmFlockSpeciesTheSumOfDeadMessage) + " " +
                                  speciesItem.DeadAnimalQuantity + " " +
                                  Localizer.GetString(MessageResourceKeyConstants
                                      .AvianDiseaseReportFarmFlockSpeciesAndSickMessage) + " " +
                                  speciesItem.SickAnimalQuantity + " " +
                                  Localizer.GetString(MessageResourceKeyConstants
                                      .AvianDiseaseReportFarmFlockSpeciesCantBeMoreThanTotalMessage) + " " +
                                  speciesItem.TotalAnimalQuantity + "."
                                : Localizer.GetString(MessageResourceKeyConstants
                                      .LivestockDiseaseReportFarmHerdSpeciesTheSumOfDeadMessage) + " " +
                                  speciesItem.DeadAnimalQuantity + " " +
                                  Localizer.GetString(MessageResourceKeyConstants
                                      .LivestockDiseaseReportFarmHerdSpeciesAndSickMessage) + " " +
                                  speciesItem.SickAnimalQuantity + " " +
                                  Localizer.GetString(MessageResourceKeyConstants
                                      .LivestockDiseaseReportFarmHerdSpeciesCantBeMoreThanTotalMessage) + " " +
                                  speciesItem.TotalAnimalQuantity + ".";
                            await ShowErrorDialog(message, null);
                            speciesItem.DeadAnimalQuantity = 0;
                            speciesItem.SickAnimalQuantity = 0;
                            break;
                        }

                        if (!(speciesItem.StartOfSignsDate > DateTime.Today)) continue;
                        validIndicator = false;

                        message = Localizer.GetString(diseaseReport.ReportCategoryTypeID == (long) CaseTypeEnum.Avian
                            ? MessageResourceKeyConstants
                                .AvianDiseaseReportFarmFlockSpeciesStartOfSignsMustBeTheSameOrEarlierThanCurrentDateMessage
                            : MessageResourceKeyConstants
                                .LivestockDiseaseReportFarmHerdSpeciesStartOfSignsMustBeTheSameOrEarlierThanCurrentDateMessage);
                        await ShowErrorDialog(message, null);
                        speciesItem.StartOfSignsDate = null;
                        break;
                    }
                }

                RollUpDiseaseReportFarmInventory(diseaseReport);

                return validIndicator;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// </summary>
        public void RollUpDiseaseReportFarmInventory(DiseaseReportGetDetailViewModel diseaseReport)
        {
            foreach (var herd in diseaseReport.FarmInventory
                         .Where(x => (x.RecordType == RecordTypeConstants.Herd) & (x.RowStatus == 0)).ToList())
            {
                var intSick = 0;
                var intDead = 0;
                var intTotal = 0;

                if (herd.RecordType == HerdSpeciesConstants.Farm) continue;
                foreach (var species in diseaseReport.FarmInventory.Where(x =>
                             (x.FlockOrHerdID == herd.FlockOrHerdID) & (x.RowStatus == 0) &
                             (x.RecordType == RecordTypeConstants.Species)).ToList())
                {
                    if (species.SickAnimalQuantity != null)
                        intSick += (int) species.SickAnimalQuantity;

                    if (species.DeadAnimalQuantity != null)
                        intDead += (int) species.DeadAnimalQuantity;

                    if (species.TotalAnimalQuantity != null)
                        intTotal += (int) species.TotalAnimalQuantity;
                }

                diseaseReport.FarmInventory.First(x => x.RecordID == herd.RecordID).SickAnimalQuantity = intSick;
                diseaseReport.FarmInventory.First(x => x.RecordID == herd.RecordID).DeadAnimalQuantity = intDead;
                diseaseReport.FarmInventory.First(x => x.RecordID == herd.RecordID).TotalAnimalQuantity = intTotal;
            }

            switch (diseaseReport.FarmInventory.Count)
            {
                case 1:
                    diseaseReport.FarmInventory.First(x => x.RecordType == HerdSpeciesConstants.Farm)
                        .TotalAnimalQuantity = 0;
                    diseaseReport.FarmInventory.First(x => x.RecordType == HerdSpeciesConstants.Farm)
                        .DeadAnimalQuantity = 0;
                    diseaseReport.FarmInventory.First(x => x.RecordType == HerdSpeciesConstants.Farm)
                        .SickAnimalQuantity = 0;
                    break;
                case > 0:
                    diseaseReport.FarmInventory.First(x => x.RecordType == HerdSpeciesConstants.Farm)
                        .TotalAnimalQuantity = diseaseReport.FarmInventory
                        .Where(x => (x.RecordType == HerdSpeciesConstants.Herd) & (x.RowStatus == 0))
                        .Sum(x => x.TotalAnimalQuantity);
                    diseaseReport.FarmInventory.First(x => x.RecordType == HerdSpeciesConstants.Farm)
                        .DeadAnimalQuantity = diseaseReport.FarmInventory
                        .Where(x => (x.RecordType == HerdSpeciesConstants.Herd) & (x.RowStatus == 0))
                        .Sum(x => x.DeadAnimalQuantity);
                    diseaseReport.FarmInventory.First(x => x.RecordType == HerdSpeciesConstants.Farm)
                        .SickAnimalQuantity = diseaseReport.FarmInventory
                        .Where(x => (x.RecordType == HerdSpeciesConstants.Herd) & (x.RowStatus == 0))
                        .Sum(x => x.SickAnimalQuantity);
                    break;
            }
        }

        #endregion

        #region Vaccination Section Methods

        /// <summary>
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<VaccinationGetListViewModel>> GetVaccinations(long diseaseReportId, int page,
            int pageSize, string sortColumn, string sortOrder)
        {
            var request = new VaccinationGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetVaccinationList(request, _token).ConfigureAwait(false);
        }

        #endregion

        #region Animals Section Methods

        /// <summary>
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<AnimalGetListViewModel>> GetAnimals(long diseaseReportId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new AnimalGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetAnimalList(request, _token).ConfigureAwait(false);
        }

        #endregion

        #region Samples Section Methods

        /// <summary>
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<SampleGetListViewModel>> GetSamples(long diseaseReportId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new SampleGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            var list = await VeterinaryClient.GetSampleList(request, _token).ConfigureAwait(false);

            for (var index = 0; index < list.Count; index++)
                if (IsNullOrEmpty(list[index].EIDSSLocalOrFieldSampleID))
                    list[index].EIDSSLocalOrFieldSampleID = "(" +
                                                            Localizer.GetString(FieldLabelResourceKeyConstants
                                                                .CommonLabelsNewFieldLabel) + " " + (index + 1) + ")";

            return list;
        }

        #endregion

        #region Penside Tests Section Methods

        /// <summary>
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<PensideTestGetListViewModel>> GetPensideTests(long diseaseReportId, int page,
            int pageSize, string sortColumn, string sortOrder)
        {
            if (diseaseReportId <= 0) return new List<PensideTestGetListViewModel>();

            var request = new PensideTestGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetPensideTestList(request, _token).ConfigureAwait(false);
        }

        #endregion

        #region Laboratory Tests and Results Summary and Interpretations Section Methods

        /// <summary>
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<LaboratoryTestGetListViewModel>> GetLaboratoryTests(long diseaseReportId, int page,
            int pageSize, string sortColumn, string sortOrder)
        {
            if (diseaseReportId <= 0) return new List<LaboratoryTestGetListViewModel>();

            var request = new LaboratoryTestGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetLaboratoryTestList(request, _token).ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<LaboratoryTestInterpretationGetListViewModel>> GetLaboratoryTestInterpretations(
            long diseaseReportId, int page, int pageSize, string sortColumn, string sortOrder)
        {
            if (diseaseReportId <= 0) return new List<LaboratoryTestInterpretationGetListViewModel>();

            var request = new LaboratoryTestInterpretationGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetLaboratoryTestInterpretationList(request, _token).ConfigureAwait(false);
        }

        #endregion

        #region Case Logs Methods

        /// <summary>
        /// </summary>
        /// <param name="diseaseReportId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<CaseLogGetListViewModel>> GetCaseLogs(long diseaseReportId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new CaseLogGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                DiseaseReportID = diseaseReportId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await VeterinaryClient.GetCaseLogList(request, _token).ConfigureAwait(false);
        }

        #endregion

        #region Save Disease Report Methods

        /// <summary>
        /// </summary>
        /// <param name="diseaseReport"></param>
        /// <param name="outbreakCase"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <param name="connectedDiseaseReportDiseaseId"></param>
        /// <param name="connectedDiseaseReportTestId"></param>
        /// <returns></returns>
        protected async Task<DiseaseReportSaveRequestResponseModel> SaveDiseaseReport(
            DiseaseReportGetDetailViewModel diseaseReport, CaseGetDetailViewModel outbreakCase,
            bool createConnectedDiseaseReportIndicator, long? connectedDiseaseReportDiseaseId,
            long? connectedDiseaseReportTestId)
        {
            try
            {
                bool permission;

                if (diseaseReport.DiseaseReportID > 0)
                {
                    if (diseaseReport.SiteID != Convert.ToInt64(authenticatedUser.SiteId) &&
                        authenticatedUser.SiteTypeId >= (long) SiteTypes.ThirdLevel)
                        permission = diseaseReport.WritePermissionIndicator;
                    else
                    {
                        var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);
                        permission = permissions.Write;
                    }
                }
                else
                {
                    {
                        var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);
                        permission = permissions.Create;
                    }
                }

                if (permission)
                {
                    Events = new List<EventSaveRequestModel>();
                    var systemPreferences = ConfigurationService.SystemPreferences;

                    if (diseaseReport.DiseaseReportSummaryValidIndicator &&
                        diseaseReport.FarmDetailsSectionValidIndicator &&
                        diseaseReport.NotificationSectionValidIndicator &&
                        ((outbreakCase is not null && outbreakCase.OutbreakInvestigationSectionValidIndicator) ||
                         outbreakCase is null))
                    {
                        foreach (var eventRecord in diseaseReport.PendingSaveEvents)
                            Events.Add(eventRecord);

                        if (diseaseReport.DiseaseID != null)
                        {
                            var request = new DiseaseReportSaveRequestModel
                            {
                                DiseaseReportID = diseaseReport.DiseaseReportID,
                                EIDSSReportID = diseaseReport.EIDSSReportID,
                                FarmID = diseaseReport.FarmID,
                                FarmMasterID = diseaseReport.FarmMasterID,
                                FarmOwnerID = diseaseReport.FarmOwnerID,
                                MonitoringSessionID = diseaseReport.ParentMonitoringSessionID,
                                OutbreakID = diseaseReport.OutbreakID,
                                RelatedToDiseaseReportID = diseaseReport.RelatedToVeterinaryDiseaseReportID,
                                EIDSSFieldAccessionID = diseaseReport.EIDSSFieldAccessionID,
                                DiseaseID = connectedDiseaseReportDiseaseId ?? (long) diseaseReport.DiseaseID,
                                EnteredByPersonID = diseaseReport.EnteredByPersonID,
                                ReportedByOrganizationID = outbreakCase is null
                                    ? diseaseReport.ReportedByOrganizationID
                                    : outbreakCase.NotificationSentByOrganizationId,
                                ReportedByPersonID = outbreakCase is null
                                    ? diseaseReport.ReportedByPersonID
                                    : outbreakCase.NotificationSentByPersonId,
                                InvestigatedByOrganizationID = outbreakCase is null
                                    ? diseaseReport.InvestigatedByOrganizationID
                                    : outbreakCase.InvestigatedByOrganizationId,
                                InvestigatedByPersonID = outbreakCase is null
                                    ? diseaseReport.InvestigatedByPersonID
                                    : outbreakCase.InvestigatedByPersonId,
                                ReceivedByOrganizationID = outbreakCase?.NotificationReceivedByOrganizationId,
                                ReceivedByPersonID = outbreakCase?.NotificationReceivedByPersonId,
                                SiteID = diseaseReport.SiteID,
                                DiagnosisDate = diseaseReport.DiagnosisDate,
                                EnteredDate = diseaseReport.EnteredDate,
                                ReportDate =
                                    outbreakCase is null ? diseaseReport.ReportDate : outbreakCase.NotificationDate,
                                AssignedDate = diseaseReport.AssignedDate,
                                InvestigationDate = outbreakCase is null
                                    ? diseaseReport.InvestigationDate
                                    : outbreakCase.InvestigationDate,
                                RowStatus = diseaseReport.RowStatus,
                                ReportTypeID = diseaseReport.ReportTypeID,
                                ClassificationTypeID = outbreakCase is null
                                    ? diseaseReport.ClassificationTypeID
                                    : outbreakCase.ClassificationTypeId,
                                StatusTypeID = diseaseReport.ReportStatusTypeID,
                                ReportCategoryTypeID = diseaseReport.ReportCategoryTypeID,
                                FarmTotalAnimalQuantity = diseaseReport.FarmInventory.Any()
                                    ? diseaseReport.FarmInventory.First(x => x.RecordType == HerdSpeciesConstants.Farm)
                                        .TotalAnimalQuantity
                                    : 0,
                                FarmSickAnimalQuantity = diseaseReport.FarmInventory.Any()
                                    ? diseaseReport.FarmInventory.First(x => x.RecordType == HerdSpeciesConstants.Farm)
                                        .SickAnimalQuantity
                                    : 0,
                                FarmDeadAnimalQuantity = diseaseReport.FarmInventory.Any()
                                    ? diseaseReport.FarmInventory.First(x => x.RecordType == HerdSpeciesConstants.Farm)
                                        .DeadAnimalQuantity
                                    : 0,
                                FarmLatitude = diseaseReport.FarmLocation.Latitude,
                                FarmLongitude = diseaseReport.FarmLocation.Longitude,
                                FarmEpidemiologicalObservationID = diseaseReport.FarmEpidemiologicalObservationID,
                                ControlMeasuresObservationID = diseaseReport.ControlMeasuresObservationID,
                                TestsConductedIndicator = diseaseReport.TestsConductedIndicator,
                                User = authenticatedUser.UserName,
                                FlocksOrHerds = JsonConvert.SerializeObject(BuildFlocksOrHerdsParameters(
                                    diseaseReport.FarmInventory.Where(x => x.RecordType == RecordTypeConstants.Herd)
                                        .ToList(),
                                    createConnectedDiseaseReportIndicator)),
                                Species = JsonConvert.SerializeObject(BuildSpeciesParameters(
                                    diseaseReport.FarmInventory.Where(x => x.RecordType == RecordTypeConstants.Species)
                                        .ToList(), createConnectedDiseaseReportIndicator)),
                                Animals = JsonConvert.SerializeObject(BuildAnimalParameters(
                                    diseaseReport.PendingSaveAnimals,
                                    createConnectedDiseaseReportIndicator)),
                                Vaccinations = JsonConvert.SerializeObject(
                                    BuildVaccinationParameters(diseaseReport.PendingSaveVaccinations,
                                        createConnectedDiseaseReportIndicator)),
                                Samples = JsonConvert.SerializeObject(BuildSampleParameters(
                                    diseaseReport.PendingSaveSamples,
                                    createConnectedDiseaseReportIndicator)),
                                PensideTests = JsonConvert.SerializeObject(await BuildPensideTestParameters(
                                    diseaseReport,
                                    diseaseReport.PendingSavePensideTests, createConnectedDiseaseReportIndicator)),
                                LaboratoryTests = JsonConvert.SerializeObject(await BuildLaboratoryTestParameters(
                                    diseaseReport,
                                    diseaseReport.PendingSaveLaboratoryTests, connectedDiseaseReportDiseaseId)),
                                LaboratoryTestInterpretations = JsonConvert.SerializeObject(
                                    await BuildLaboratoryTestInterpretationParameters(diseaseReport,
                                        diseaseReport.PendingSaveLaboratoryTestInterpretations,
                                        connectedDiseaseReportTestId)),
                                CaseLogs = JsonConvert.SerializeObject(BuildCaseLogParameters(
                                    diseaseReport.PendingSaveCaseLogs,
                                    createConnectedDiseaseReportIndicator)),
                                CaseMonitorings = outbreakCase == null
                                    ? null
                                    : JsonConvert.SerializeObject(
                                        BuildCaseMonitoringParameters(outbreakCase.PendingSaveCaseMonitorings)),
                                Contacts = outbreakCase == null
                                    ? null
                                    : JsonConvert.SerializeObject(
                                        BuildContactParameters(outbreakCase.PendingSaveContacts)),
                                Events = JsonConvert.SerializeObject(Events),
                                UserID = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                                LinkLocalOrFieldSampleIDToReportID =
                                    systemPreferences.LinkLocalSampleIdToReportSessionId,
                                OutbreakCaseIndicator = outbreakCase != null,
                                OutbreakCaseReportUID = outbreakCase?.CaseId,
                                OutbreakCaseQuestionnaireObservationID = outbreakCase?.CaseQuestionnaireObservationId,
                                OutbreakCaseStatusTypeID = outbreakCase?.StatusTypeId,
                                PrimaryCaseIndicator = outbreakCase is {PrimaryCaseIndicator: true},
                                Comments = diseaseReport.Comments
                            };

                            var response = await VeterinaryClient.SaveDiseaseReport(request, _token);

                            return response;
                        }
                    }
                }
                else
                {
                    var buttons = new List<DialogButton>();
                    var okButton = new DialogButton
                    {
                        ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                        ButtonType = DialogButtonType.OK
                    };
                    buttons.Add(okButton);
                    var dialogParams = new Dictionary<string, object>
                    {
                        {nameof(EIDSSDialog.DialogButtons), buttons},
                        {
                            nameof(EIDSSDialog.Message),
                            Localizer.GetString(MessageResourceKeyConstants
                                .WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage)
                        }
                    };
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSErrorModalHeading), dialogParams);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return new DiseaseReportSaveRequestResponseModel();
        }

        /// <summary>
        /// </summary>
        /// <param name="farmInventory"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private static List<FarmInventoryGroupSaveRequestModel> BuildFlocksOrHerdsParameters(
            IList<FarmInventoryGetListViewModel> farmInventory, bool createConnectedDiseaseReportIndicator)
        {
            List<FarmInventoryGroupSaveRequestModel> requests = new();

            if (farmInventory is null)
                return new List<FarmInventoryGroupSaveRequestModel>();

            foreach (var farmInventoryModel in farmInventory)
            {
                var request = new FarmInventoryGroupSaveRequestModel();
                {
                    request.DeadAnimalQuantity = farmInventoryModel.DeadAnimalQuantity;
                    request.EIDSSFlockOrHerdID = farmInventoryModel.EIDSSFlockOrHerdID;
                    request.FarmID = farmInventoryModel.FarmID;
                    if (farmInventoryModel.FlockOrHerdID != null)
                        request.FlockOrHerdID = (long) farmInventoryModel.FlockOrHerdID;
                    request.FlockOrHerdMasterID = farmInventoryModel.FlockOrHerdMasterID;
                    if (farmInventoryModel.RowAction != null)
                        request.RowAction = createConnectedDiseaseReportIndicator
                            ? (int) RowActionTypeEnum.Insert
                            : (int) farmInventoryModel.RowAction;
                    request.RowStatus = farmInventoryModel.RowStatus;
                    request.SickAnimalQuantity = farmInventoryModel.SickAnimalQuantity;
                    request.TotalAnimalQuantity = farmInventoryModel.TotalAnimalQuantity;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="farmInventory"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private static List<FarmInventorySpeciesSaveRequestModel> BuildSpeciesParameters(
            IList<FarmInventoryGetListViewModel> farmInventory, bool createConnectedDiseaseReportIndicator)
        {
            List<FarmInventorySpeciesSaveRequestModel> requests = new();

            if (farmInventory is null)
                return new List<FarmInventorySpeciesSaveRequestModel>();

            foreach (var farmInventoryModel in farmInventory)
            {
                var request = new FarmInventorySpeciesSaveRequestModel();
                {
                    request.AverageAge = farmInventoryModel.AverageAge;
                    request.DeadAnimalQuantity = farmInventoryModel.DeadAnimalQuantity;
                    if (farmInventoryModel.FlockOrHerdID != null)
                        request.FlockOrHerdID = (long) farmInventoryModel.FlockOrHerdID;
                    request.ObservationID = farmInventoryModel.ObservationID;
                    request.RelatedToSpeciesID = createConnectedDiseaseReportIndicator == false
                        ? null
                        : farmInventoryModel.SpeciesID;
                    request.RelatedToObservationID = createConnectedDiseaseReportIndicator == false
                        ? null
                        : farmInventoryModel.ObservationID;
                    if (farmInventoryModel.RowAction != null)
                        request.RowAction = createConnectedDiseaseReportIndicator
                            ? (int) RowActionTypeEnum.Insert
                            : (int) farmInventoryModel.RowAction;
                    request.RowStatus = farmInventoryModel.RowStatus;
                    request.SickAnimalQuantity = farmInventoryModel.SickAnimalQuantity;
                    if (farmInventoryModel.SpeciesID != null) request.SpeciesID = (long) farmInventoryModel.SpeciesID;
                    request.SpeciesMasterID = farmInventoryModel.SpeciesMasterID;
                    if (farmInventoryModel.SpeciesTypeID != null)
                        request.SpeciesTypeID = (long) farmInventoryModel.SpeciesTypeID;
                    request.StartOfSignsDate = farmInventoryModel.StartOfSignsDate;
                    request.TotalAnimalQuantity = farmInventoryModel.TotalAnimalQuantity;
                    request.Comments = farmInventoryModel.Note;
                    request.OutbreakCaseStatusTypeID = farmInventoryModel.OutbreakCaseStatusTypeID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="animals"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private List<AnimalSaveRequestModel> BuildAnimalParameters(IList<AnimalGetListViewModel> animals,
            bool createConnectedDiseaseReportIndicator)
        {
            List<AnimalSaveRequestModel> requests = new();

            if (animals is null)
                return new List<AnimalSaveRequestModel>();

            foreach (var animalModel in animals)
            {
                var request = new AnimalSaveRequestModel();
                {
                    request.AgeTypeID = animalModel.AgeTypeID;
                    request.AnimalDescription = animalModel.AnimalDescription;
                    request.AnimalID = animalModel.AnimalID;
                    request.AnimalName = animalModel.AnimalName;
                    request.ClinicalSignsIndicator = animalModel.ClinicalSignsIndicator;
                    request.Color = animalModel.Color;
                    request.ConditionTypeID = animalModel.ConditionTypeID;
                    request.EIDSSAnimalID =
                        animalModel.EIDSSAnimalID.Contains(
                            Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel))
                            ? Empty
                            : animalModel.EIDSSAnimalID;
                    request.SexTypeID = animalModel.SexTypeID;
                    request.ObservationID = animalModel.ObservationID;
                    request.RelatedToAnimalID =
                        createConnectedDiseaseReportIndicator == false ? null : animalModel.AnimalID;
                    request.RelatedToObservationID = createConnectedDiseaseReportIndicator == false
                        ? null
                        : animalModel.ObservationID;
                    request.RowAction = createConnectedDiseaseReportIndicator
                        ? (int) RowActionTypeEnum.Insert
                        : animalModel.RowAction;
                    request.RowStatus = animalModel.RowStatus;
                    request.SpeciesID = animalModel.SpeciesID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="vaccinations"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private static List<VaccinationSaveRequestModel> BuildVaccinationParameters(
            IList<VaccinationGetListViewModel> vaccinations, bool createConnectedDiseaseReportIndicator)
        {
            List<VaccinationSaveRequestModel> requests = new();

            if (vaccinations is null)
                return new List<VaccinationSaveRequestModel>();

            foreach (var vaccinationModel in vaccinations)
            {
                var request = new VaccinationSaveRequestModel();
                {
                    request.Comments = vaccinationModel.Comments;
                    request.DiseaseID = vaccinationModel.DiseaseID;
                    request.LotNumber = vaccinationModel.LotNumber;
                    request.Manufacturer = vaccinationModel.Manufacturer;
                    request.NumberVaccinated = vaccinationModel.NumberVaccinated;
                    request.RouteTypeID = vaccinationModel.RouteTypeID;
                    request.RowAction = createConnectedDiseaseReportIndicator
                        ? (int) RowActionTypeEnum.Insert
                        : vaccinationModel.RowAction;
                    request.RowStatus = vaccinationModel.RowStatus;
                    request.SpeciesID = vaccinationModel.SpeciesID;
                    request.VaccinationDate = vaccinationModel.VaccinationDate;
                    request.VaccinationID = vaccinationModel.VaccinationID;
                    request.VaccinationTypeID = vaccinationModel.VaccinationTypeID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="samples"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private List<SampleSaveRequestModel> BuildSampleParameters(IList<SampleGetListViewModel> samples,
            bool createConnectedDiseaseReportIndicator)
        {
            List<SampleSaveRequestModel> requests = new();

            if (samples is null)
                return new List<SampleSaveRequestModel>();

            foreach (var sampleModel in samples)
            {
                var request = new SampleSaveRequestModel();
                {
                    request.AnimalID = sampleModel.AnimalID;
                    request.BirdStatusTypeID = sampleModel.BirdStatusTypeID;
                    request.CurrentSiteID = sampleModel.CurrentSiteID;
                    request.DiseaseID = sampleModel.DiseaseID;

                    if (sampleModel.EIDSSLocalOrFieldSampleID is null)
                    {
                        request.EIDSSLocalOrFieldSampleID = sampleModel.EIDSSLaboratorySampleID;
                    }
                    else if (sampleModel.EIDSSLocalOrFieldSampleID.Contains(
                                Localizer.GetString(FieldLabelResourceKeyConstants.CommonLabelsNewFieldLabel)))
                    {
                        request.EIDSSLocalOrFieldSampleID = Empty;
                    }
                    else
                    {
                        request.EIDSSLocalOrFieldSampleID = sampleModel.EIDSSLocalOrFieldSampleID;
                    }

                    request.EnteredDate = sampleModel.EnteredDate;
                    request.CollectedByOrganizationID = sampleModel.CollectedByOrganizationID;
                    request.CollectedByPersonID = sampleModel.CollectedByPersonID;
                    request.CollectionDate = sampleModel.CollectionDate;
                    request.SentDate = sampleModel.SentDate;
                    request.SentToOrganizationID = sampleModel.SentToOrganizationID;
                    request.HumanDiseaseReportID = sampleModel.HumanDiseaseReportID;
                    request.HumanMasterID = sampleModel.HumanMasterID;
                    request.HumanID = sampleModel.HumanID;
                    request.MonitoringSessionID = sampleModel.MonitoringSessionID;
                    request.LabModuleSourceIndicator = sampleModel.LabModuleSourceIndicator;
                    request.Comments = sampleModel.Comments;
                    request.ParentSampleID = sampleModel.ParentSampleID;
                    request.ReadOnlyIndicator = sampleModel.ReadOnlyIndicator;
                    request.RootSampleID = sampleModel.RootSampleID;
                    request.RowAction = createConnectedDiseaseReportIndicator
                        ? (int) RowActionTypeEnum.Insert
                        : sampleModel.RowAction;
                    request.RowStatus = sampleModel.RowStatus;
                    request.SampleID = sampleModel.SampleID;
                    request.SampleStatusTypeID = sampleModel.SampleStatusTypeID;
                    request.SampleTypeID = sampleModel.SampleTypeID;
                    request.SiteID = sampleModel.SiteID;
                    request.SpeciesID = sampleModel.SpeciesID;
                    request.VectorID = sampleModel.VectorID;
                    request.VectorSessionID = sampleModel.VectorSessionID;
                    request.VeterinaryDiseaseReportID = sampleModel.VeterinaryDiseaseReportID;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="diseaseReport"></param>
        /// <param name="pensideTests"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private async Task<List<PensideTestSaveRequestModel>> BuildPensideTestParameters(
            DiseaseReportGetDetailViewModel diseaseReport, IList<PensideTestGetListViewModel> pensideTests,
            bool createConnectedDiseaseReportIndicator)
        {
            List<PensideTestSaveRequestModel> requests = new();

            if (pensideTests is null)
                return new List<PensideTestSaveRequestModel>();

            foreach (var pensideTestModel in pensideTests)
            {
                var request = new PensideTestSaveRequestModel();
                {
                    request.DiseaseID = pensideTestModel.DiseaseID;
                    request.PensideTestCategoryTypeID = pensideTestModel.PensideTestCategoryTypeID;
                    request.PensideTestID = pensideTestModel.PensideTestID;
                    request.PensideTestNameTypeID = pensideTestModel.PensideTestNameTypeID;
                    request.PensideTestResultTypeID = pensideTestModel.PensideTestResultTypeID;
                    request.RowAction = createConnectedDiseaseReportIndicator
                        ? (int) RowActionTypeEnum.Insert
                        : pensideTestModel.RowAction;
                    request.RowStatus = pensideTestModel.RowStatus;
                    if (pensideTestModel.SampleID != null) request.SampleID = (long) pensideTestModel.SampleID;
                    request.TestDate = pensideTestModel.TestDate;
                    request.TestedByOrganizationID = pensideTestModel.TestedByOrganizationID;
                    request.TestedByPersonID = pensideTestModel.TestedByPersonID;
                }

                if (pensideTestModel.OriginalPensideTestResultTypeID != pensideTestModel.PensideTestResultTypeID)
                    if (pensideTestModel.OriginalPensideTestResultTypeID is null)
                    {
                        var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == diseaseReport.SiteID
                            ? SystemEventLogTypes.NewFieldTestResultForVeterinaryDiseaseReportWasRegisteredAtYourSite
                            : SystemEventLogTypes.NewFieldTestResultForVeterinaryDiseaseReportWasRegisteredAtAnotherSite;
                        Events.Add(await CreateEvent(diseaseReport.DiseaseReportID,
                            diseaseReport.DiseaseID, eventTypeId, diseaseReport.SiteID, null));
                    }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="diseaseReport"></param>
        /// <param name="laboratoryTests"></param>
        /// <param name="connectedDiseaseReportDiseaseId"></param>
        /// <returns></returns>
        private async Task<List<LaboratoryTestSaveRequestModel>> BuildLaboratoryTestParameters(
            DiseaseReportGetDetailViewModel diseaseReport, IList<LaboratoryTestGetListViewModel> laboratoryTests,
            long? connectedDiseaseReportDiseaseId)
        {
            List<LaboratoryTestSaveRequestModel> requests = new();
            LaboratoryTestSaveRequestModel request;

            if (laboratoryTests is null)
                return new List<LaboratoryTestSaveRequestModel>();

            if (connectedDiseaseReportDiseaseId is null)
            {
                foreach (var laboratoryTestModel in laboratoryTests)
                {
                    request = new LaboratoryTestSaveRequestModel();
                    {
                        request.BatchTestID = laboratoryTestModel.BatchTestID;
                        request.Comments = laboratoryTestModel.Comments;
                        request.ContactPersonName = laboratoryTestModel.ContactPersonName;
                        request.DiseaseID = (long) laboratoryTestModel.DiseaseID;
                        request.ExternalTestIndicator = laboratoryTestModel.ExternalTestIndicator;
                        request.HumanDiseaseReportID = laboratoryTestModel.HumanDiseaseReportID;
                        request.MonitoringSessionID = laboratoryTestModel.MonitoringSessionID;
                        request.NonLaboratoryTestIndicator = laboratoryTestModel.NonLaboratoryTestIndicator;
                        request.ObservationID = laboratoryTestModel.ObservationID;
                        request.PerformedByOrganizationID = laboratoryTestModel.PerformedByOrganizationID;
                        request.ReadOnlyIndicator = laboratoryTestModel.ReadOnlyIndicator;
                        request.ReceivedDate = laboratoryTestModel.ReceivedDate;
                        request.ResultDate = laboratoryTestModel.ResultDate;
                        request.ResultEnteredByOrganizationID = laboratoryTestModel.ResultEnteredByOrganizationID;
                        request.ResultEnteredByPersonID = laboratoryTestModel.ResultEnteredByPersonID;
                        request.RowAction = laboratoryTestModel.RowAction;
                        request.RowStatus = laboratoryTestModel.RowStatus;
                        request.SampleID = laboratoryTestModel.SampleID;
                        request.StartedDate = laboratoryTestModel.StartedDate;
                        request.TestCategoryTypeID = laboratoryTestModel.TestCategoryTypeID;
                        request.TestedByOrganizationID = laboratoryTestModel.TestedByOrganizationID;
                        request.TestedByPersonID = laboratoryTestModel.TestedByPersonID;
                        request.TestID = laboratoryTestModel.TestID;
                        request.TestNameTypeID = laboratoryTestModel.TestNameTypeID;
                        request.TestNumber = laboratoryTestModel.TestNumber;
                        request.TestResultTypeID = laboratoryTestModel.TestResultTypeID;
                        request.TestStatusTypeID = laboratoryTestModel.TestStatusTypeID;
                        request.ValidatedByOrganizationID = laboratoryTestModel.ValidatedByOrganizationID;
                        request.ValidatedByPersonID = laboratoryTestModel.ValidatedByPersonID;
                        request.VectorID = laboratoryTestModel.VectorID;
                        request.VectorSessionID = laboratoryTestModel.VectorSessionID;
                        request.VeterinaryDiseaseReportID = laboratoryTestModel.VeterinaryDiseaseReportID;
                    }

                    if (laboratoryTestModel.OriginalTestResultTypeID != laboratoryTestModel.TestResultTypeID)
                    {
                        SystemEventLogTypes eventTypeId;

                        if (laboratoryTestModel.OriginalTestResultTypeID is null)
                        {
                            if (diseaseReport.OutbreakCaseIndicator)
                            {
                                eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == diseaseReport.SiteID
                                    ? SystemEventLogTypes
                                        .NewLaboratoryTestResultForVeterinaryOutbreakCaseWasRegisteredAtYourSite
                                    : SystemEventLogTypes
                                        .NewLaboratoryTestResultForVeterinaryOutbreakCaseWasRegisteredAtAnotherSite;
                                Events.Add(await CreateEvent(diseaseReport.DiseaseReportID,
                                    laboratoryTestModel.DiseaseID, eventTypeId, diseaseReport.SiteID, null));
                            }
                            else
                            {
                                eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == diseaseReport.SiteID
                                    ? SystemEventLogTypes
                                        .NewLaboratoryTestResultForVeterinaryDiseaseReportWasRegisteredAtYourSite
                                    : SystemEventLogTypes
                                        .NewLaboratoryTestResultForVeterinaryDiseaseReportWasRegisteredAtAnotherSite;
                                Events.Add(await CreateEvent(diseaseReport.DiseaseReportID,
                                    laboratoryTestModel.DiseaseID, eventTypeId, diseaseReport.SiteID, null));
                            }
                        }
                        else
                        {
                            if (diseaseReport.OutbreakCaseIndicator)
                            {
                                eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == diseaseReport.SiteID
                                    ? SystemEventLogTypes
                                        .LaboratoryTestResultForVeterinaryOutbreakCaseWasAmendedAtYourSite
                                    : SystemEventLogTypes
                                        .LaboratoryTestResultForVeterinaryOutbreakCaseWasAmendedAtAnotherSite;
                                Events.Add(await CreateEvent(diseaseReport.DiseaseReportID,
                                    laboratoryTestModel.DiseaseID, eventTypeId, diseaseReport.SiteID, null));
                            }
                            else
                            {
                                eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == diseaseReport.SiteID
                                    ? SystemEventLogTypes
                                        .LaboratoryTestResultForVeterinaryDiseaseReportWasAmendedAtYourSite
                                    : SystemEventLogTypes
                                        .LaboratoryTestResultForVeterinaryDiseaseReportWasAmendedAtAnotherSite;
                                Events.Add(await CreateEvent(diseaseReport.DiseaseReportID,
                                    laboratoryTestModel.DiseaseID, eventTypeId, diseaseReport.SiteID, null));
                            }
                        }
                    }

                    requests.Add(request);
                }
            }
            else
            {
                if (laboratoryTests.All(x => x.DiseaseID != connectedDiseaseReportDiseaseId)) return requests;
                {
                    foreach (var laboratoryTestModel in laboratoryTests)
                    {
                        if (laboratoryTestModel.DiseaseID != connectedDiseaseReportDiseaseId) continue;
                        request = new LaboratoryTestSaveRequestModel();
                        {
                            request.BatchTestID = laboratoryTestModel.BatchTestID;
                            request.Comments = laboratoryTestModel.Comments;
                            request.ContactPersonName = laboratoryTestModel.ContactPersonName;
                            if (laboratoryTestModel.DiseaseID != null)
                                request.DiseaseID = (long) laboratoryTestModel.DiseaseID;
                            request.ExternalTestIndicator = laboratoryTestModel.ExternalTestIndicator;
                            request.HumanDiseaseReportID = laboratoryTestModel.HumanDiseaseReportID;
                            request.MonitoringSessionID = laboratoryTestModel.MonitoringSessionID;
                            request.NonLaboratoryTestIndicator = laboratoryTestModel.NonLaboratoryTestIndicator;
                            request.ObservationID = laboratoryTestModel.ObservationID;
                            request.PerformedByOrganizationID = laboratoryTestModel.PerformedByOrganizationID;
                            request.ReadOnlyIndicator = laboratoryTestModel.ReadOnlyIndicator;
                            request.ReceivedDate = laboratoryTestModel.ReceivedDate;
                            request.ResultDate = laboratoryTestModel.ResultDate;
                            request.ResultEnteredByOrganizationID =
                                laboratoryTestModel.ResultEnteredByOrganizationID;
                            request.ResultEnteredByPersonID = laboratoryTestModel.ResultEnteredByPersonID;
                            request.RowAction = (int) RowActionTypeEnum.Update;
                            request.RowStatus = laboratoryTestModel.RowStatus;
                            request.SampleID = laboratoryTestModel.SampleID;
                            request.StartedDate = laboratoryTestModel.StartedDate;
                            request.TestCategoryTypeID = laboratoryTestModel.TestCategoryTypeID;
                            request.TestedByOrganizationID = laboratoryTestModel.TestedByOrganizationID;
                            request.TestedByPersonID = laboratoryTestModel.TestedByPersonID;
                            request.TestID = laboratoryTestModel.TestID;
                            request.TestNameTypeID = laboratoryTestModel.TestNameTypeID;
                            request.TestNumber = laboratoryTestModel.TestNumber;
                            request.TestResultTypeID = laboratoryTestModel.TestResultTypeID;
                            request.TestStatusTypeID = laboratoryTestModel.TestStatusTypeID;
                            request.ValidatedByOrganizationID = laboratoryTestModel.ValidatedByOrganizationID;
                            request.ValidatedByPersonID = laboratoryTestModel.ValidatedByPersonID;
                            request.VectorID = laboratoryTestModel.VectorID;
                            request.VectorSessionID = laboratoryTestModel.VectorSessionID;
                            request.VeterinaryDiseaseReportID = laboratoryTestModel.VeterinaryDiseaseReportID;
                        }

                        requests.Add(request);
                    }
                }
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="diseaseReport"></param>
        /// <param name="laboratoryTestInterpretations"></param>
        /// <param name="connectedDiseaseReportTestId"></param>
        /// <returns></returns>
        private async Task<List<LaboratoryTestInterpretationSaveRequestModel>>
            BuildLaboratoryTestInterpretationParameters(DiseaseReportGetDetailViewModel diseaseReport,
                IList<LaboratoryTestInterpretationGetListViewModel> laboratoryTestInterpretations,
                long? connectedDiseaseReportTestId)
        {
            List<LaboratoryTestInterpretationSaveRequestModel> requests = new();
            LaboratoryTestInterpretationSaveRequestModel request;

            if (laboratoryTestInterpretations is null)
                return new List<LaboratoryTestInterpretationSaveRequestModel>();

            if (connectedDiseaseReportTestId is null)
            {
                foreach (var laboratoryTestInterpretationModel in laboratoryTestInterpretations)
                {
                    request = new LaboratoryTestInterpretationSaveRequestModel();
                    {
                        request.DiseaseID = laboratoryTestInterpretationModel.DiseaseID;
                        request.InterpretedByOrganizationID =
                            laboratoryTestInterpretationModel.InterpretedByOrganizationID;
                        request.InterpretedByPersonID = laboratoryTestInterpretationModel.InterpretedByPersonID;
                        request.InterpretedComment = laboratoryTestInterpretationModel.InterpretedComment;
                        request.InterpretedDate = laboratoryTestInterpretationModel.InterpretedDate;
                        request.InterpretedStatusTypeID = laboratoryTestInterpretationModel.InterpretedStatusTypeID;
                        request.ReadOnlyIndicator = laboratoryTestInterpretationModel.ReadOnlyIndicator;
                        request.ReportSessionCreatedIndicator =
                            laboratoryTestInterpretationModel.ReportSessionCreatedIndicator;
                        request.RowAction = laboratoryTestInterpretationModel.RowAction;
                        request.RowStatus = laboratoryTestInterpretationModel.RowStatus;
                        request.TestID = laboratoryTestInterpretationModel.TestID;
                        request.TestInterpretationID = laboratoryTestInterpretationModel.TestInterpretationID;
                        request.ValidatedByOrganizationID = laboratoryTestInterpretationModel.ValidatedByOrganizationID;
                        request.ValidatedByPersonID = laboratoryTestInterpretationModel.ValidatedByPersonID;
                        request.ValidatedComment = laboratoryTestInterpretationModel.ValidatedComment;
                        request.ValidatedDate = laboratoryTestInterpretationModel.ValidatedDate;
                        request.ValidatedStatusIndicator = laboratoryTestInterpretationModel.ValidatedStatusIndicator;
                    }

                    if (laboratoryTestInterpretationModel.RowAction == (int) RowActionTypeEnum.Insert)
                    {
                        if (diseaseReport.OutbreakCaseIndicator)
                        {
                            var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == diseaseReport.SiteID
                                ? SystemEventLogTypes
                                    .LaboratoryTestResultForVeterinaryOutbreakCaseWasInterpretedAtYourSite
                                : SystemEventLogTypes
                                    .LaboratoryTestResultForVeterinaryOutbreakCaseWasInterpretedAtAnotherSite;
                            Events.Add(await CreateEvent(diseaseReport.DiseaseReportID,
                                laboratoryTestInterpretationModel.DiseaseID, eventTypeId, diseaseReport.SiteID, null));
                        }
                        else
                        {
                            var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == diseaseReport.SiteID
                                ? SystemEventLogTypes
                                    .LaboratoryTestResultForVeterinaryDiseaseReportWasInterpretedAtYourSite
                                : SystemEventLogTypes
                                    .LaboratoryTestResultForVeterinaryDiseaseReportWasInterpretedAtAnotherSite;
                            Events.Add(await CreateEvent(diseaseReport.DiseaseReportID,
                                laboratoryTestInterpretationModel.DiseaseID, eventTypeId, diseaseReport.SiteID, null));
                        }
                    }

                    requests.Add(request);
                }
            }
            else
            {
                var laboratoryTestInterpretationModel =
                    laboratoryTestInterpretations.First(x => x.TestID == connectedDiseaseReportTestId);
                request = new LaboratoryTestInterpretationSaveRequestModel();
                {
                    request.DiseaseID = laboratoryTestInterpretationModel.DiseaseID;
                    request.InterpretedByOrganizationID = laboratoryTestInterpretationModel.InterpretedByOrganizationID;
                    request.InterpretedByPersonID = laboratoryTestInterpretationModel.InterpretedByPersonID;
                    request.InterpretedComment = laboratoryTestInterpretationModel.InterpretedComment;
                    request.InterpretedDate = laboratoryTestInterpretationModel.InterpretedDate;
                    request.InterpretedStatusTypeID = laboratoryTestInterpretationModel.InterpretedStatusTypeID;
                    request.ReadOnlyIndicator = laboratoryTestInterpretationModel.ReadOnlyIndicator;
                    request.ReportSessionCreatedIndicator =
                        laboratoryTestInterpretationModel.ReportSessionCreatedIndicator;
                    request.RowAction = (int) RowActionTypeEnum.Update;
                    request.RowStatus = laboratoryTestInterpretationModel.RowStatus;
                    request.TestID = laboratoryTestInterpretationModel.TestID;
                    request.TestInterpretationID = laboratoryTestInterpretationModel.TestInterpretationID;
                    request.ValidatedByOrganizationID = laboratoryTestInterpretationModel.ValidatedByOrganizationID;
                    request.ValidatedByPersonID = laboratoryTestInterpretationModel.ValidatedByPersonID;
                    request.ValidatedComment = laboratoryTestInterpretationModel.ValidatedComment;
                    request.ValidatedDate = laboratoryTestInterpretationModel.ValidatedDate;
                    request.ValidatedStatusIndicator = laboratoryTestInterpretationModel.ValidatedStatusIndicator;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="caseLogs"></param>
        /// <param name="createConnectedDiseaseReportIndicator"></param>
        /// <returns></returns>
        private static List<CaseLogSaveRequestModel> BuildCaseLogParameters(IList<CaseLogGetListViewModel> caseLogs,
            bool createConnectedDiseaseReportIndicator)
        {
            List<CaseLogSaveRequestModel> requests = new();

            if (caseLogs is null)
                return new List<CaseLogSaveRequestModel>();

            foreach (var caseLogModel in caseLogs)
            {
                var request = new CaseLogSaveRequestModel();
                {
                    request.CaseLogID = caseLogModel.DiseaseReportLogID;
                    request.ActionRequired = caseLogModel.ActionRequired;
                    request.Comments = caseLogModel.Comments;
                    request.LogDate = caseLogModel.LogDate;
                    request.LoggedByPersonID = caseLogModel.EnteredByPersonID;
                    request.LogStatusTypeID = caseLogModel.LogStatusTypeID;
                    request.RowAction = createConnectedDiseaseReportIndicator
                        ? (int) RowActionTypeEnum.Insert
                        : caseLogModel.RowAction;
                    request.RowStatus = caseLogModel.RowStatus;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="contacts"></param>
        /// <returns></returns>
        private static List<ContactSaveRequestModel> BuildContactParameters(IList<ContactGetListViewModel> contacts)
        {
            List<ContactSaveRequestModel> requests = new();

            if (contacts is null)
                return new List<ContactSaveRequestModel>();

            foreach (var contact in contacts)
            {
                var request = new ContactSaveRequestModel();
                {
                    request.CaseContactID = contact.CaseContactID;
                    request.OutbreakCaseReportUID = contact.CaseID;
                    request.ContactTypeID = contact.ContactTypeID;
                    request.ContactRelationshipTypeID = contact.ContactRelationshipTypeID;
                    request.ContactStatusID = contact.ContactStatusID;
                    request.HumanMasterID = contact.HumanMasterID;
                    request.HumanID = contact.HumanID;
                    request.FarmMasterID = contact.FarmMasterID;
                    request.FirstName = contact.FirstName;
                    request.SecondName = contact.SecondName;
                    request.LastName = contact.LastName;
                    request.PersonalID = contact.PersonalID;
                    request.DateOfBirth = contact.DateOfBirth;
                    request.GenderTypeID = contact.GenderTypeID;
                    request.CitizenshipTypeID = contact.CitizenshipTypeID;
                    request.AddressID = contact.AddressID;
                    request.LocationID = contact.LocationID;
                    request.Apartment = contact.Apartment;
                    request.Building = contact.Building;
                    request.House = contact.House;
                    request.Street = contact.Street;
                    request.PostalCode = contact.PostalCode;
                    request.Comment = contact.Comment;
                    request.ContactPhoneTypeID = contact.ContactPhoneTypeID;
                    request.ContactPhone = contact.ContactPhone;
                    request.ContactPhoneCountryCode = contact.ContactPhoneCountryCode;
                    request.DateOfLastContact = contact.DateOfLastContact;
                    request.PlaceOfLastContact = contact.PlaceOfLastContact;
                    request.ContactTracingObservationID = contact.ContactTracingObservationID;
                    request.RowAction = contact.RowAction;
                    request.RowStatus = contact.RowStatus;
                }

                requests.Add(request);
            }

            return requests;
        }

        /// <summary>
        /// </summary>
        /// <param name="caseMonitorings"></param>
        /// <returns></returns>
        private static List<CaseMonitoringSaveRequestModel> BuildCaseMonitoringParameters(
            IList<CaseMonitoringGetListViewModel> caseMonitorings)
        {
            List<CaseMonitoringSaveRequestModel> requests = new();

            if (caseMonitorings is null)
                return new List<CaseMonitoringSaveRequestModel>();

            foreach (var caseMonitoring in caseMonitorings)
            {
                var request = new CaseMonitoringSaveRequestModel();
                {
                    if (caseMonitoring.CaseMonitoringId != null)
                        request.CaseMonitoringID = (long) caseMonitoring.CaseMonitoringId;
                    request.VeterinaryDiseaseReportID = caseMonitoring.VeterinaryCaseId;
                    request.AdditionalComments = caseMonitoring.AdditionalComments;
                    request.InvestigatedByOrganizationID = caseMonitoring.InvestigatedByOrganizationId;
                    request.InvestigatedByPersonID = caseMonitoring.InvestigatedByPersonId;
                    request.MonitoringDate = caseMonitoring.MonitoringDate;
                    request.ObservationID = caseMonitoring.ObservationId;
                    request.RowStatus = caseMonitoring.RowStatus;
                }

                requests.Add(request);
            }

            return requests;
        }

        #endregion

        #region Delete Disease Report Method

        /// <summary>
        /// </summary>
        /// <param name="diseaseReport"></param>
        /// <param name="diseaseReportId"></param>
        /// <param name="reportCategoryTypeId"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteDiseaseReport(DiseaseReportGetDetailViewModel diseaseReport, long diseaseReportId, long reportCategoryTypeId)
        {
            try
            {
                bool permission;

                if (diseaseReport.SiteID != Convert.ToInt64(authenticatedUser.SiteId) &&
                    authenticatedUser.SiteTypeId >= (long) SiteTypes.ThirdLevel)
                    permission = diseaseReport.DeletePermissionIndicator;
                else
                {
                    var permissions = GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);
                    permission = permissions.Delete;
                }

                if (permission)
                {
                    var response = await VeterinaryClient.DeleteDiseaseReport(diseaseReportId, false, null,
                        authenticatedUser.UserName);

                    switch (response.ReturnCode)
                    {
                        case 0:
                            await ShowInformationalDialog(MessageResourceKeyConstants.RecordDeletedSuccessfullyMessage,
                                null);
                            break;
                        case 1:
                            await ShowErrorDialog(MessageResourceKeyConstants.UnableToDeleteContainsChildObjectsMessage,
                                null);
                            break;
                        case 2:
                            if (reportCategoryTypeId == (long) CaseTypeEnum.Avian)
                                await ShowErrorDialog(
                                    MessageResourceKeyConstants
                                        .AvianDiseaseReportUnableToDeleteDependentOnAnotherObjectMessage, null);
                            else
                                await ShowErrorDialog(
                                    MessageResourceKeyConstants
                                        .LivestockDiseaseReportUnableToDeleteDependentOnAnotherObjectMessage, null);

                            break;
                    }

                    return response;
                }

                var buttons = new List<DialogButton>();
                var okButton = new DialogButton
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);
                var dialogParams = new Dictionary<string, object>
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants
                            .WarningMessagesYourPermissionsAreInsufficientToPerformThisFunctionMessage)
                    }
                };
                await DiagService.OpenAsync<EIDSSDialog>(
                    Localizer.GetString(HeadingResourceKeyConstants.EIDSSErrorModalHeading), dialogParams);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }

            return null;
        }

        #endregion

        #endregion

        #endregion
    }
}