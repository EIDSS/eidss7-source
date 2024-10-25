#region Using Statements

using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Helpers;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;

#endregion

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class LocationViewModel : BaseModel
    {
        /// <summary>
        /// View or component calling the location component.
        /// For instance, the lab module could have 15 different instances 
        /// of the location component.
        /// </summary>
        [HiddenInput]
        public string CallingObjectID { get; set; }

        [HiddenInput] public bool SetUserDefaultLocations { get; set; }
        [HiddenInput] public long? UserAdministrativeLevel1 { get; set; }
        [HiddenInput] public long? UserAdministrativeLevel2 { get; set; }
        [HiddenInput] public long? UserAdministrativeLevel3 { get; set; }
        [HiddenInput] public string DefaultCountry { get; set; }
        [HiddenInput] public string DefaultLongitude { get; set; }
        [HiddenInput] public string DefaultLatitude { get; set; }
        [HiddenInput] public string LeafletAPIUrl { get; set; }
        public bool DefaultMapLoaded { get; set; }

        public string MapUrl { get; set; }
        public string Zoom { get; set; }

        public bool IsHorizontalLayout { get; set; }

        public long? BottomAdminLevel;
        public long? SelectedAdminLevel;

        public string DisableAtElementLevel { get; set; } = "";
        public bool IsLocationDisabled { get; set; } = false;


        public LocationViewOperationType? OperationType { get; set; }

        public LocationType LocationType { get; set; } // set controls based on National,Foreign, Relative, ExactPoint

        public long? SettlementId;

        public bool ShowAdminTopLevelsOnly { get; set; } = false;

        public long? AdministrativeLevelId { get; set; }

        public bool AdministrativeLevelEnabled { get; set; }

        public long? AdministrativeUnitTypeId { get; set; }


        public List<GisLocationCurrentLevelModel> AdminLevel0List { get; set; }
        [HiddenInput] public bool IsDbRequiredAdminLevel0 { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredAdminLevel0), true)]
        public long? AdminLevel0Value { get; set; }

        public string AdminLevel0Text { get; set; }
        public bool ShowAdminLevel0 { get; set; }
        public bool EnableAdminLevel0 { get; set; }
        public bool DivAdminLevel0 { get; set; }
        public long? AdminLevel0LevelType { get; set; }


        public List<GisLocationChildLevelModel> AdminLevel1List { get; set; }
        [HiddenInput] public bool IsDbRequiredAdminLevel1 { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredAdminLevel1), true)]
        public long? AdminLevel1Value { get; set; }

        public string AdminLevel1Text { get; set; }
        public bool ShowAdminLevel1 { get; set; } = true;
        public bool EnableAdminLevel1 { get; set; }
        public bool DivAdminLevel1 { get; set; }
        public long? AdminLevel1LevelType { get; set; }


        public List<GisLocationChildLevelModel> AdminLevel2List { get; set; }
        [HiddenInput] public bool IsDbRequiredAdminLevel2 { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredAdminLevel2), true)]
        public long? AdminLevel2Value { get; set; }

        public string AdminLevel2Text { get; set; }
        public bool ShowAdminLevel2 { get; set; } = true;
        public bool EnableAdminLevel2 { get; set; }
        public bool DivAdminLevel2 { get; set; }
        public long? AdminLevel2LevelType { get; set; }


        public List<GisLocationChildLevelModel> AdminLevel3List { get; set; }
        [HiddenInput] public bool IsDbRequiredAdminLevel3 { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredAdminLevel3), true)]
        public long? AdminLevel3Value { get; set; }

        public string AdminLevel3Text { get; set; }
        public bool ShowAdminLevel3 { get; set; } = true;
        public bool EnableAdminLevel3 { get; set; }
        public bool DivAdminLevel3 { get; set; }
        public long? AdminLevel3LevelType { get; set; }


        public List<GisLocationChildLevelModel> AdminLevel4List { get; set; }
        [HiddenInput] public bool IsDbRequiredAdminLevel4 { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredAdminLevel4), true)]
        public long? AdminLevel4Value { get; set; }

        public string AdminLevel4Text { get; set; }
        public bool ShowAdminLevel4 { get; set; } = true;
        public bool EnableAdminLevel4 { get; set; }
        public bool DivAdminLevel4 { get; set; }
        public long? AdminLevel4LevelType { get; set; }


        public List<GisLocationChildLevelModel> AdminLevel5List { get; set; }
        [HiddenInput] public bool IsDbRequiredAdminLevel5 { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredAdminLevel5), true)]
        public long? AdminLevel5Value { get; set; }

        public string AdminLevel5Text { get; set; }
        public bool ShowAdminLevel5 { get; set; } = true;
        public bool EnableAdminLevel5 { get; set; }
        public bool DivAdminLevel5 { get; set; }
        public long? AdminLevel5LevelType { get; set; }


        public List<GisLocationChildLevelModel> AdminLevel6List { get; set; }
        [HiddenInput] public bool IsDbRequiredAdminLevel6 { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredAdminLevel6), true)]
        public long? AdminLevel6Value { get; set; }

        public string AdminLevel6Text { get; set; }
        public bool ShowAdminLevel6 { get; set; } = true;
        public bool EnableAdminLevel6 { get; set; }
        public bool DivAdminLevel6 { get; set; }
        public long? AdminLevel6LevelType { get; set; }


        public bool DivSettlementGroup { get; set; } = true;

        public List<SettlementTypeModel> SettlementTypeList { get; set; }
        [HiddenInput] public bool IsDbRequiredSettlementType { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredSettlementType), true)]
        public long? SettlementType { get; set; }

        public bool ShowSettlementType { get; set; } = true;
        public bool EnableSettlementType { get; set; }
        public bool DivSettlementType { get; set; }

        public List<SettlementViewModel> SettlementList { get; set; }
        [HiddenInput] public bool IsDbRequiredSettlement { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredSettlement), true)]
        public long? Settlement { get; set; }

        public string SettlementText { get; set; }
        public bool ShowSettlement { get; set; } = true;
        public bool EnableSettlement { get; set; }
        public bool DivSettlement { get; set; }
        public string AdminLevelRefreshJavascriptFunction { get; set; }

        public List<StreetModel> StreetList { get; set; }
        [HiddenInput] public bool IsDbRequiredStreet { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredStreet), true)]
        public long? Street { get; set; }

        public string StreetText { get; set; }
        [HiddenInput] public string NewStreet { get; set; }
        public bool ShowStreet { get; set; } = true;
        public bool EnableStreet { get; set; }
        public bool DivStreet { get; set; }

        public bool ShowBuildingHouseApartmentGroup { get; set; }
        public bool DivBuildingHouseApartmentGroup { get; set; }
        [HiddenInput] public bool IsDbRequiredHouse { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredHouse), true)]
        public string House { get; set; }

        public bool ShowHouse { get; set; } = true;
        public bool EnableHouse { get; set; }
        public bool DivHouse { get; set; }
        [HiddenInput] public bool IsDbRequiredBuilding { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredBuilding), true)]
        public string Building { get; set; }

        public bool ShowBuilding { get; set; } = true;
        public bool EnableBuilding { get; set; }
        public bool DivBuilding { get; set; }
        [HiddenInput] public bool IsDbRequiredApartment { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredApartment), true)]
        public string Apartment { get; set; }

        public bool ShowApartment { get; set; } = true;
        public bool EnableApartment { get; set; }
        public bool DivApartment { get; set; }

        public List<PostalCodeViewModel> PostalCodeList { get; set; }
        [HiddenInput] public bool IsDbRequiredPostalCode { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredPostalCode), true)]
        public long? PostalCode { get; set; }

        public string PostalCodeText { get; set; }
        [HiddenInput] public string NewPostalCode { get; set; }
        public bool ShowPostalCode { get; set; } = true;
        public bool EnablePostalCode { get; set; }
        public bool DivPostalCode { get; set; }

        public bool ShowCoordinates { get; set; } = true;
        public bool DivCoordinates { get; set; }

        [HiddenInput] public bool IsDbRequiredLatitude { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredLatitude), true)]
        public double? Latitude { get; set; }

        public bool ShowLatitude { get; set; } = true;
        public bool EnabledLatitude { get; set; }
        public bool DivLatitude { get; set; }

        [HiddenInput] public bool IsDbRequiredLongitude { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredLongitude), true)]
        public double? Longitude { get; set; }

        public bool ShowLongitude { get; set; } = true;
        public bool EnabledLongitude { get; set; }
        public bool DivLongitude { get; set; }

        [HiddenInput] public bool IsDbRequiredElevation { get; set; }

        [LocalizedRequiredWhenTrue(nameof(IsDbRequiredElevation), true)]
        public int? Elevation { get; set; }

        public bool ShowElevation { get; set; } = true;
        public bool EnabledElevation { get; set; }
        public bool DivElevation { get; set; }

        public bool ShowMap { get; set; } = true;
        public bool DivMap { get; set; }

        public bool ShowLocationDirection { get; set; }
        public bool ShowLocationDistance { get; set; }
        public bool ShowGroundTypes { get; set; }
        public bool ShowLocationDescription { get; set; }
        public bool ShowLocationAddress { get; set; }

        public bool AlwaysDisabled { get; set; }

        public static LocationViewModel DisableTemplate = new LocationViewModel()
        {
            EnableAdminLevel1 = false,
            EnableAdminLevel2 = false,
            EnableAdminLevel3 = false,
            EnableAdminLevel4 = false,
            EnableAdminLevel5 = false,
            EnableAdminLevel6 = false,
            EnableSettlement = false,
            EnableSettlementType = false,
            OperationType = LocationViewOperationType.ReadOnly,
            EnablePostalCode = false,
            EnableStreet = false,
            EnableHouse = false,
            EnableBuilding = false,
            EnableApartment = false,
        };

        public void EnableLatLong()
        {
            this.EnabledLatitude = true;
            this.EnabledLongitude = true;
        }

        public void EnableCountry(bool enabledIndicator)
        {
            this.EnableAdminLevel0 = enabledIndicator;
        }

        public void AdjustControlForLocationType()
        {
            switch (LocationType)
            {
                case LocationType.None:
                    break;
                case LocationType.National:
                    break;
                case LocationType.ExactPoint:
                    break;
                case LocationType.RelativePoint:
                    break;
                case LocationType.ForeignAddress:
                    ShowAdminLevel0 = true;
                    ShowStreet = false;
                    ShowPostalCode = false;
                    break;
                default:
                    break;
            }
        }

        public void SetupRequiredFields()
        {
            DivAdminLevel0 = ShowAdminLevel0;
            DivAdminLevel1 = ShowAdminLevel1;
            DivAdminLevel2 = ShowAdminLevel2;
            DivAdminLevel3 = ShowAdminLevel3;
            DivAdminLevel4 = ShowAdminLevel4;
            DivAdminLevel5 = ShowAdminLevel5;
            DivAdminLevel6 = ShowAdminLevel6;
            DivSettlementGroup = true;
            DivSettlement = ShowSettlement;
            DivSettlementType = ShowSettlementType;
            DivStreet = ShowStreet;
            DivBuildingHouseApartmentGroup = ShowBuildingHouseApartmentGroup;
            DivPostalCode = ShowPostalCode;
            DivCoordinates = ShowCoordinates;
            DivElevation = ShowElevation;
            DivLatitude = ShowLatitude;
            DivLongitude = ShowLongitude;
            DivMap = ShowMap;
            if (OperationType == LocationViewOperationType.ReadOnly)
            {
                EnabledElevation = false;
                EnabledLongitude = false;
                EnabledLatitude = false;
            }
            else
            {
                EnabledElevation = true;
                EnabledLongitude = true;
                EnabledLatitude = true;
            }
        }

        public void SetupRequiredFieldsForAdminLevel0()
        {
            DivAdminLevel0 = true;
            EnableAdminLevel0 = true;
            IsDbRequiredAdminLevel0 = true;
            DivAdminLevel1 = false;
            EnableAdminLevel1 = false;
            IsDbRequiredAdminLevel1 = false;
            DivAdminLevel2 = false;
            EnableAdminLevel2 = false;
            IsDbRequiredAdminLevel2 = false;
            DivAdminLevel3 = false;
            EnableAdminLevel3 = false;
            IsDbRequiredAdminLevel3 = false;
            DivAdminLevel4 = false;
            EnableAdminLevel4 = false;
            IsDbRequiredAdminLevel4 = false;
            DivAdminLevel5 = false;
            EnableAdminLevel5 = false;
            IsDbRequiredAdminLevel5 = false;
            DivAdminLevel6 = false;
            EnableAdminLevel6 = false;
            IsDbRequiredAdminLevel6 = false;
            DivSettlementGroup = false;
            DivSettlement = false;
            DivSettlementType = false;
            DivStreet = false;
            IsDbRequiredStreet = false;
            IsDbRequiredSettlementType = false;
            IsDbRequiredSettlement = false;
            DivBuildingHouseApartmentGroup = false;
            DivApartment = false;
            DivBuilding = false;
            DivHouse = false;
            IsDbRequiredApartment = false;
            IsDbRequiredBuilding = false;
            IsDbRequiredHouse = false;
            DivPostalCode = false;
            IsDbRequiredPostalCode = false;
            DivCoordinates = false;
            DivLatitude = false;
            DivLongitude = false;
            DivElevation = false;
            IsDbRequiredLatitude = false;
            IsDbRequiredLongitude = false;
            IsDbRequiredElevation = false;
            EnabledElevation = true;
            EnabledLongitude = true;
            EnabledLatitude = true;
        }

        public void SetFrom(LocationViewModel model)
        {
            EnableAdminLevel1 = model.EnableAdminLevel1;
            EnableAdminLevel2 = model.EnableAdminLevel2;
            EnableAdminLevel3 = model.EnableAdminLevel3;
            EnableAdminLevel4 = model.EnableAdminLevel4;
            EnableAdminLevel5 = model.EnableAdminLevel5;
            EnableAdminLevel6 = model.EnableAdminLevel6;
            EnableSettlement = model.EnableSettlement;
            EnableSettlementType = model.EnableSettlementType;
            EnablePostalCode = model.EnablePostalCode;
            EnableStreet = model.EnableStreet;
            EnableHouse = model.EnableHouse;
            EnableBuilding = model.EnableBuilding;
            EnableApartment = model.EnableApartment;
            EnabledLongitude = model.EnableApartment;
            EnabledLatitude = model.EnableApartment;
        }
    }

    public enum LocationViewOperationType
    {
        Search = 1,
        Add = 2,
        Edit = 3,
        ReadOnly = 4
    }
}
