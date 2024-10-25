#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Components.Outbreak
{
    public class OutbreakBaseComponent : BaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject] protected ICrossCuttingClient CrossCuttingClient { get; set; }
        [Inject] protected IOrganizationClient OrganizationClient { get; set; }
        [Inject] protected IOutbreakClient OutbreakClient { get; set; }
        [Inject] protected IVeterinaryClient VeterinaryClient { get; set; }

        #endregion

        #region Properties

        #endregion

        #region Member Variables

        private readonly CancellationToken _token;

        public bool CreateDisabled { get; set; } = true;
        public bool ImportDisabled { get; set; } = true;

        #endregion

        #endregion

        #region Constructors

        public OutbreakBaseComponent(CancellationToken token)
        {
            _token = token;
        }

        #endregion

        #region Methods

        #region Case Location Section Methods

        /// <summary>
        /// </summary>
        /// <param name="outbreakCase"></param>
        public LocationViewModel SetCaseLocation(CaseGetDetailViewModel outbreakCase)
        {
            outbreakCase.CaseLocation = new LocationViewModel
            {
                IsHorizontalLayout = true,
                EnableAdminLevel1 = false,
                EnableAdminLevel2 = false,
                EnableAdminLevel3 = true,
                EnableApartment = false,
                EnableBuilding = false,
                EnableHouse = false,
                EnabledLatitude = true,
                EnabledLongitude = true,
                EnablePostalCode = false,
                EnableSettlement = true,
                EnableSettlementType = true,
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
                AdminLevel0Value = Convert.ToInt64(CountryID)
            };

            outbreakCase.CaseLocation.AdminLevel0Value = outbreakCase.CaseAddressAdministrativeLevel0ID;
            outbreakCase.CaseLocation.AdminLevel1Value = outbreakCase.CaseAddressAdministrativeLevel1ID;
            outbreakCase.CaseLocation.AdminLevel2Value = outbreakCase.CaseAddressAdministrativeLevel2ID;
            outbreakCase.CaseLocation.AdminLevel3Value = outbreakCase.CaseAddressAdministrativeLevel3ID;
            outbreakCase.CaseLocation.SettlementType = outbreakCase.CaseAddressSettlementTypeID;
            outbreakCase.CaseLocation.SettlementText = outbreakCase.CaseAddressSettlementName;
            outbreakCase.CaseLocation.SettlementId = outbreakCase.CaseAddressSettlementID;
            outbreakCase.CaseLocation.Settlement = outbreakCase.CaseAddressSettlementID;
            outbreakCase.CaseLocation.Apartment = outbreakCase.CaseAddressApartment;
            outbreakCase.CaseLocation.Building = outbreakCase.CaseAddressBuilding;
            outbreakCase.CaseLocation.House = outbreakCase.CaseAddressHouse;
            outbreakCase.CaseLocation.Latitude = outbreakCase.CaseAddressLatitude;
            outbreakCase.CaseLocation.Longitude = outbreakCase.CaseAddressLongitude;
            outbreakCase.CaseLocation.PostalCode = outbreakCase.CaseAddressPostalCodeID;
            outbreakCase.CaseLocation.PostalCodeText = outbreakCase.CaseAddressPostalCode;
            if (outbreakCase.CaseAddressPostalCodeID != null)
                outbreakCase.CaseLocation.PostalCodeList = new List<PostalCodeViewModel>
                {
                    new()
                    {
                        PostalCodeID = outbreakCase.CaseAddressPostalCodeID.ToString(),
                        PostalCodeString = outbreakCase.CaseAddressPostalCode
                    }
                };

            outbreakCase.CaseLocation.StreetText = outbreakCase.CaseAddressStreetName;
            outbreakCase.CaseLocation.Street = outbreakCase.CaseAddressStreetID;
            if (outbreakCase.CaseAddressStreetID != null)
                outbreakCase.CaseLocation.StreetList = new List<StreetModel>
                {
                    new()
                    {
                        StreetID = outbreakCase.CaseAddressStreetID.ToString(),
                        StreetName = outbreakCase.CaseAddressStreetName
                    }
                };

            return outbreakCase.CaseLocation;
        }

        #endregion

        #region Case Methods

        /// <summary>
        /// </summary>
        /// <param name="outbreakId"></param>
        /// <param name="searchTerm"></param>
        /// <param name="todaysFollowupsIndicator"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<CaseGetListViewModel>> GetCases(long? outbreakId, string searchTerm,
            bool todaysFollowupsIndicator, int page, int pageSize, string sortColumn, string sortOrder)
        {
            var request = new OutbreakCaseListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                OutbreakID = outbreakId,
                SearchTerm = searchTerm,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder,
                TodaysFollowUpsIndicator = todaysFollowupsIndicator
            };

            return await OutbreakClient.GetCasesList(request).ConfigureAwait(false);
        }

        /// <summary>
        /// </summary>
        /// <param name="outbreakId"></param>
        /// <param name="outbreakType"></param>
        /// <returns></returns>
        public async Task DetermineDisabledObjects(long outbreakId, OutbreakTypeEnum outbreakType)
        {
            var request = new OutbreakSessionDetailRequestModel
            {
                LanguageID = GetCurrentLanguage(),
                idfsOutbreak = outbreakId
            };

            var response = await OutbreakClient.GetSessionParametersList(request);
            
            if (response.Any())
            {
                CreateDisabled = outbreakType switch
                {
                    OutbreakTypeEnum.Human => (response
                        .First(x => x.OutbreakSpeciesTypeID == (long) OutbreakSpeciesTypeEnum.Human)
                        .CaseQuestionaireTemplateID == null),
                    OutbreakTypeEnum.Veterinary => (response
                        .First(x => x.OutbreakSpeciesTypeID is (long) OutbreakSpeciesTypeEnum.Avian
                            or (long) OutbreakSpeciesTypeEnum.Livestock)
                        .CaseQuestionaireTemplateID == null),
                    OutbreakTypeEnum.Zoonotic => false,
                    _ => true
                };
            }

            var responseSession = await OutbreakClient.GetSessionDetail(request);

            if (!CreateDisabled && response.Count > 0)
            {
                CreateDisabled = (responseSession.First().idfsOutbreakStatus == (long)OutbreakSessionStatus.Closed);
                ImportDisabled = CreateDisabled;
            }
            else
            {
                ImportDisabled = (responseSession.First().idfsOutbreakStatus == (long)OutbreakSessionStatus.Closed);
            }
        }

        #endregion

        #region Case Monitoring Section Methods

        /// <summary>
        /// </summary>
        /// <param name="caseId"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<CaseMonitoringGetListViewModel>> GetCaseMonitorings(long caseId, int page, int pageSize,
            string sortColumn, string sortOrder)
        {
            var request = new CaseMonitoringGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                CaseId = caseId,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder
            };

            return await OutbreakClient.GetCaseMonitoringList(request, _token).ConfigureAwait(false);
        }

        #endregion

        #region Contact Section Methods

        /// <summary>
        /// </summary>
        /// <param name="caseId"></param>
        /// <param name="outbreakId"></param>
        /// <param name="searchTerm"></param>
        /// <param name="todaysFollowUpsIndicator"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <returns></returns>
        public async Task<List<ContactGetListViewModel>> GetContacts(long? caseId, long? outbreakId, string searchTerm,
            bool todaysFollowUpsIndicator, int page, int pageSize, string sortColumn, string sortOrder)
        {
            var request = new ContactGetListRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                CaseId = caseId,
                OutbreakId = outbreakId,
                SearchTerm = searchTerm,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder,
                TodaysFollowUpsIndicator = todaysFollowUpsIndicator
            };

            return await OutbreakClient.GetContactList(request, _token).ConfigureAwait(false);
        }

        #endregion

        #endregion
    }
}