#region Usings

using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Web.Components.Veterinary.SearchFarm;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Components.Outbreak.Case.Veterinary
{
    /// <summary>
    /// </summary>
    public class CaseBase : OutbreakBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<CaseBase> Logger { get; set; }

        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Parameters

        [Parameter] public CaseGetDetailViewModel Model { get; set; }

        #endregion

        #region Properties

        protected SearchFarm SearchFarmComponent { get; set; }

        #endregion

        #region Member Variables

        private CancellationTokenSource _source;
        private CancellationToken _token;
        private bool _disposedValue;

        #endregion

        #endregion

        #region Constructors

        public CaseBase(CancellationToken token) : base(token)
        {
        }

        protected CaseBase() : base(CancellationToken.None)
        {
        }

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="disposing"></param>
        protected virtual void Dispose(bool disposing)
        {
            if (_disposedValue) return;
            if (disposing)
            {
                _source?.Cancel();
                _source?.Dispose();
            }

            // TODO: free unmanaged resources (unmanaged objects) and override finalizer
            // TODO: set large fields to null
            _disposedValue = true;
        }

        // // TODO: override finalizer only if 'Dispose(bool disposing)' has code to free unmanaged resources
        // ~CaseBase()
        // {
        //     // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
        //     Dispose(disposing: false);
        // }
        public void Dispose()
        {
            // Do not change this code. Put cleanup code in 'Dispose(bool disposing)' method
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            try
            {
                if (firstRender)
                {
                    var lDotNetReference = DotNetObjectReference.Create(this);
                    await JsRuntime.InvokeVoidAsync("Case.SetDotNetReference", _token,
                        lDotNetReference);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Select Farm Event

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected void OnSelectFarm()
        {
            try
            {
                var record = SearchFarmComponent.SelectedFarm;

                if (record.FarmMasterID != null)
                    Model.VeterinaryDiseaseReport.FarmMasterID = (long) record.FarmMasterID;
                Model.VeterinaryDiseaseReport.EIDSSFarmID = record.EIDSSFarmID;
                Model.VeterinaryDiseaseReport.FarmOwnerName = record.FarmOwnerName;
                Model.VeterinaryDiseaseReport.EIDSSFarmID = record.EIDSSFarmID;
                Model.VeterinaryDiseaseReport.FarmName = record.FarmName;
                Model.VeterinaryDiseaseReport.FarmOwnerFirstName = record.FarmOwnerFirstName;
                Model.VeterinaryDiseaseReport.FarmOwnerID = record.FarmOwnerID;
                Model.VeterinaryDiseaseReport.FarmOwnerLastName = record.FarmOwnerLastName;
                Model.VeterinaryDiseaseReport.FarmOwnerSecondName = record.FarmOwnerSecondName;
                Model.VeterinaryDiseaseReport.EIDSSFarmOwnerID = record.EIDSSFarmOwnerID;
                Model.VeterinaryDiseaseReport.Phone = record.Phone;
                Model.VeterinaryDiseaseReport.Email = record.Email;
                if (record.CountryID != null)
                {
                    Model.CaseAddressAdministrativeLevel0ID =
                        (long) record.CountryID;
                    Model.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel0ID =
                        (long) record.CountryID;
                }
                Model.CaseAddressAdministrativeLevel1ID =
                    record.RegionID;
                Model.CaseAddressAdministrativeLevel1Name =
                    record.RegionName;
                Model.CaseAddressAdministrativeLevel2ID =
                    record.RayonID;
                Model.CaseAddressAdministrativeLevel2Name =
                    record.RayonName;
                Model.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel1ID =
                    record.RegionID;
                Model.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel1Name =
                    record.RegionName;
                Model.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel2ID =
                    record.RayonID;
                Model.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel2Name =
                    record.RayonName;
                Model.CaseAddressSettlementID = record.SettlementID;
                Model.CaseAddressSettlementName = record.SettlementName;
                Model.VeterinaryDiseaseReport.FarmAddressSettlementID = record.SettlementID;
                Model.VeterinaryDiseaseReport.FarmAddressSettlementName = record.SettlementName;
                Model.CaseAddressApartment = record.Apartment;
                Model.VeterinaryDiseaseReport.FarmAddressApartment = record.Apartment;
                Model.CaseAddressBuilding = record.Building;
                Model.VeterinaryDiseaseReport.FarmAddressBuilding = record.Building;
                Model.CaseAddressHouse = record.House;
                Model.VeterinaryDiseaseReport.FarmAddressHouse = record.House;
                Model.CaseAddressLatitude = record.Latitude;
                Model.VeterinaryDiseaseReport.FarmAddressLatitude = record.Latitude;
                Model.CaseAddressLongitude = record.Longitude;
                Model.VeterinaryDiseaseReport.FarmAddressLongitude = record.Longitude;
                Model.CaseAddressPostalCode = record.PostalCode;
                Model.VeterinaryDiseaseReport.FarmAddressPostalCode = record.PostalCode;
                Model.CaseAddressStreetName = record.Street;
                Model.VeterinaryDiseaseReport.FarmAddressStreetName = record.Street;
                Model.VeterinaryDiseaseReport.FarmLocation = new LocationViewModel
                {
                    IsHorizontalLayout = true,
                    AlwaysDisabled = true,
                    EnableAdminLevel1 = false,
                    EnableAdminLevel2 = false,
                    EnableAdminLevel3 = false,
                    EnableApartment = false,
                    EnableBuilding = false,
                    EnableHouse = false,
                    EnabledLatitude = true,
                    EnabledLongitude = true,
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
                    AdminLevel0Value = Convert.ToInt64(CountryID)
                };
                Model.VeterinaryDiseaseReport.FarmLocation.AdminLevel0Value =
                    Model.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel0ID;
                Model.VeterinaryDiseaseReport.FarmLocation.AdminLevel1Value =
                    Model.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel1ID;
                Model.VeterinaryDiseaseReport.FarmLocation.AdminLevel2Value =
                    Model.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel2ID;
                Model.VeterinaryDiseaseReport.FarmLocation.AdminLevel3Value =
                    Model.VeterinaryDiseaseReport.FarmAddressAdministrativeLevel3ID;
                Model.VeterinaryDiseaseReport.FarmLocation.SettlementType =
                    Model.VeterinaryDiseaseReport.FarmAddressSettlementTypeID;
                Model.VeterinaryDiseaseReport.FarmLocation.SettlementText =
                    Model.VeterinaryDiseaseReport.FarmAddressSettlementName;
                Model.VeterinaryDiseaseReport.FarmLocation.SettlementId =
                    Model.VeterinaryDiseaseReport.FarmAddressSettlementID;
                Model.VeterinaryDiseaseReport.FarmLocation.Settlement =
                    Model.VeterinaryDiseaseReport.FarmAddressSettlementID;
                Model.VeterinaryDiseaseReport.FarmLocation.Apartment =
                    Model.VeterinaryDiseaseReport.FarmAddressApartment;
                Model.VeterinaryDiseaseReport.FarmLocation.Building = Model.VeterinaryDiseaseReport.FarmAddressBuilding;
                Model.VeterinaryDiseaseReport.FarmLocation.House = Model.VeterinaryDiseaseReport.FarmAddressHouse;
                Model.VeterinaryDiseaseReport.FarmLocation.Latitude = Model.VeterinaryDiseaseReport.FarmAddressLatitude;
                Model.VeterinaryDiseaseReport.FarmLocation.Longitude =
                    Model.VeterinaryDiseaseReport.FarmAddressLongitude;
                Model.VeterinaryDiseaseReport.FarmLocation.PostalCode =
                    Model.VeterinaryDiseaseReport.FarmAddressPostalCodeID;
                Model.VeterinaryDiseaseReport.FarmLocation.PostalCodeText =
                    Model.VeterinaryDiseaseReport.FarmAddressPostalCode;
                if (Model.VeterinaryDiseaseReport.FarmAddressPostalCodeID != null)
                    Model.VeterinaryDiseaseReport.FarmLocation.PostalCodeList = new List<PostalCodeViewModel>
                    {
                        new()
                        {
                            PostalCodeID = Model.VeterinaryDiseaseReport.FarmAddressPostalCodeID.ToString(),
                            PostalCodeString = Model.VeterinaryDiseaseReport.FarmAddressPostalCode
                        }
                    };

                Model.VeterinaryDiseaseReport.FarmLocation.StreetText =
                    Model.VeterinaryDiseaseReport.FarmAddressStreetName;
                Model.VeterinaryDiseaseReport.FarmLocation.Street = Model.VeterinaryDiseaseReport.FarmAddressStreetID;
                if (Model.VeterinaryDiseaseReport.FarmAddressStreetID != null)
                    Model.VeterinaryDiseaseReport.FarmLocation.StreetList = new List<StreetModel>
                    {
                        new()
                        {
                            StreetID = Model.VeterinaryDiseaseReport.FarmAddressStreetID.ToString(),
                            StreetName = Model.VeterinaryDiseaseReport.FarmAddressStreetName
                        }
                    };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #endregion
    }
}