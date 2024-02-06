#region Using Statements

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Security.Cryptography;
using System.Threading;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Components
{
    [ViewComponent(Name = "LocationView")]
    public class LocationViewComponent : ViewComponent
    {
        private readonly ICrossCuttingClient _crossCuttingClient;
        private readonly ISettlementClient _settlementClient;
        private readonly IConfiguration _configuration;
        public IConfiguration Configuration { get { return _configuration; } }
        public LocationViewModel LocationViewModel { get; set; }
        internal CultureInfo uiCultureInfo = Thread.CurrentThread.CurrentUICulture;
        internal CultureInfo cultureInfo = Thread.CurrentThread.CurrentCulture;
        public string CurrentLanguage { get; set; }
        public string CountryId { get; set; }
        private readonly AuthenticatedUser _authenticatedUser;
        private const string OTHER_RAYONS = "other rayons";

        /// <summary>
        /// 
        /// </summary>
        /// <param name="crossCuttingClient"></param>
        /// <param name="settlementClient"></param>
        /// <param name="configuration"></param>
        /// <param name="tokenService"></param>
        public LocationViewComponent(ICrossCuttingClient crossCuttingClient, ISettlementClient settlementClient, IConfiguration configuration,
            ITokenService tokenService)
        {
            _crossCuttingClient = crossCuttingClient;
            _settlementClient = settlementClient;
            _configuration = configuration;
            _authenticatedUser = tokenService.GetAuthenticatedUser();
            CountryId = _configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");

            CurrentLanguage = cultureInfo.Name;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="locationViewModel"></param>
        /// <returns></returns>
        public async Task<IViewComponentResult> InvokeAsync(LocationViewModel locationViewModel)
        {
            LocationViewModel = locationViewModel;
            LocationViewModel.DefaultCountry = _configuration.GetValue<string>("EIDSSGlobalSettings:DefaultCountry");
            LocationViewModel.LeafletAPIUrl = _configuration.GetValue<string>("EIDSSGlobalSettings:LeafletAPIUrl");
            LocationViewModel.DefaultLatitude = _configuration.GetValue<string>("EIDSSGlobalSettings:DefaultLatitude");
            LocationViewModel.DefaultLongitude = _configuration.GetValue<string>("EIDSSGlobalSettings:DefaultLongitude");

            Initialize();

            await SetupLocationHiearchyAsync();

            //Setup Validation 

            await DataBindAsync();

            SetMapUrl();

            return View(LocationViewModel);
        }

        private void Initialize()
        {
            if (LocationViewModel.ShowAdminTopLevelsOnly)
            {
                LocationViewModel.SetupRequiredFieldsForAdminLevel0();
            }
            else
            {
                LocationViewModel.SetupRequiredFields();
            }
        }

        private async Task SetupLocationHiearchyAsync()
        {
            var locationControlLevels = await _crossCuttingClient.GetGisLocationLevels(CurrentLanguage);
            var maxLevel = locationControlLevels.Max(l => l.Level);

            for (var i = 1; i <= maxLevel; i++)
            {
                switch (i)
                {
                    case 1:
                        LocationViewModel.ShowAdminLevel0 = LocationViewModel.ShowAdminLevel0 != false;
                        break;
                    case 2:
                        LocationViewModel.ShowAdminLevel1 = LocationViewModel.ShowAdminLevel1 != false;
                        break;
                    case 3:
                        LocationViewModel.ShowAdminLevel2 = LocationViewModel.ShowAdminLevel2 != false;
                        break;
                    case 4:
                        LocationViewModel.ShowAdminLevel3 = LocationViewModel.ShowAdminLevel3 != false;
                        break;
                    case 5:
                        LocationViewModel.ShowAdminLevel4 = LocationViewModel.ShowAdminLevel4 != false;
                        break;
                    case 6:
                        LocationViewModel.ShowAdminLevel5 = LocationViewModel.ShowAdminLevel5 != false;
                        break;
                    case 7:
                        LocationViewModel.ShowAdminLevel6 = LocationViewModel.ShowAdminLevel6 != false;
                        break;
                }
            }
        }

        private async Task DataBindAsync()
        {
            LocationViewModel.AdminLevel0List = new List<GisLocationCurrentLevelModel>();
            LocationViewModel.AdminLevel1List = new List<GisLocationChildLevelModel>();
            LocationViewModel.AdminLevel2List = new List<GisLocationChildLevelModel>();
            LocationViewModel.AdminLevel3List = new List<GisLocationChildLevelModel>();
            LocationViewModel.AdminLevel4List = new List<GisLocationChildLevelModel>();
            LocationViewModel.AdminLevel5List = new List<GisLocationChildLevelModel>();
            LocationViewModel.AdminLevel6List = new List<GisLocationChildLevelModel>();
            LocationViewModel.SettlementTypeList = new List<SettlementTypeModel>();
            LocationViewModel.SettlementList = new List<SettlementViewModel>();
            LocationViewModel.PostalCodeList = new List<PostalCodeViewModel>();
            LocationViewModel.StreetList = new List<StreetModel>();
            LocationViewModel.BottomAdminLevel = null;
            await FillAdminLevel0();
            await FillAdminLevel1();
            await FillAdminLevel2();
            await FillAdminLevel3();
            await FillAdminLevel4();
            await FillAdminLevel5();
            await FillAdminLevel6();
            await FillStreetAsync();
            await FillPostalCode();
        }

        private async Task FillAdminLevel0()
        {
            if (LocationViewModel.AdminLevel0Value != null)
            {
                var countryList = await _crossCuttingClient.GetGisLocationCurrentLevel(CurrentLanguage, 0, true);
                if (countryList != null)
                {
                    LocationViewModel.EnableAdminLevel0 = LocationViewModel.IsLocationDisabled ? false : true;
                    var filteredCountryList = countryList.Where(l => l.strHASC != null).OrderBy(l => l.strHASC).ToList();
                    LocationViewModel.AdminLevel0List = countryList;
                }

                if (LocationViewModel.ShowAdminLevel0)
                {
                    LocationViewModel.EnableAdminLevel0 = LocationViewModel.IsLocationDisabled ? false : true;
                    if (LocationViewModel.ShowAdminTopLevelsOnly)
                    {
                        LocationViewModel.EnableAdminLevel1 = false;
                        LocationViewModel.EnableAdminLevel2 = false;
                        LocationViewModel.EnableAdminLevel3 = false;
                        LocationViewModel.EnableAdminLevel4 = false;
                        LocationViewModel.EnableAdminLevel5 = false;
                        LocationViewModel.EnableAdminLevel6 = false;
                    }
                }
            }
        }

        private async Task FillAdminLevel1()
        {
            if (LocationViewModel.AdminLevel0Value != null)
            {
                LocationViewModel.AdminLevel1List = await _crossCuttingClient.GetGisLocationChildLevel(CurrentLanguage, Convert.ToString(LocationViewModel.AdminLevel0Value));
                if (LocationViewModel.AdminLevel1List.Count > 0)
                {
                    LocationViewModel.EnableAdminLevel1 = LocationViewModel.IsLocationDisabled ? false : true;

                    if (LocationViewModel.AdminLevel1List.FirstOrDefault()?.idfsGISReferenceType == _authenticatedUser.BottomAdminLevel && LocationViewModel.AdminLevel1Value == null)
                    {
                        LocationViewModel.UserAdministrativeLevel1 = _authenticatedUser.RegionId;

                        if (LocationViewModel.SetUserDefaultLocations && _authenticatedUser.Preferences.DefaultRegionInSearchPanels)
                        {
                            LocationViewModel.AdminLevel1Value = _authenticatedUser.RegionId;
                        }
                    }
                    else if (LocationViewModel.AdminLevel1Value == null && LocationViewModel.SetUserDefaultLocations && _authenticatedUser.Preferences.DefaultRegionInSearchPanels)
                    {
                        LocationViewModel.UserAdministrativeLevel1 = _authenticatedUser.RegionId;
                        LocationViewModel.AdminLevel1Value = _authenticatedUser.RegionId;
                    }


                    LocationViewModel.AdminLevel1LevelType = LocationViewModel.AdminLevel1List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel1Value) != null ?
                                LocationViewModel.AdminLevel1List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel1Value)?.LevelType : null;
                    if (LocationViewModel.AdminLevel1LevelType != null)
                    {
                        LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel1Value;
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel1List, LocationViewModel.AdminLevel1Value);
                    }
                    LocationViewModel.AdminLevel1List.Insert(0, new GisLocationChildLevelModel { idfsReference = null, idfsGISReferenceType = null, Name = "" });
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel1 = LocationViewModel.IsLocationDisabled ? false : LocationViewModel.AdminLevel1Value != null;
            }
        }

        private async Task FillAdminLevel2()
        {
            if (LocationViewModel.AdminLevel1Value != null)
            {
                LocationViewModel.AdminLevel2List = await _crossCuttingClient.GetGisLocationChildLevel(CurrentLanguage, Convert.ToString(LocationViewModel.AdminLevel1Value));
                LocationViewModel.AdminLevel2List = LocationViewModel.AdminLevel2List.OrderBy(x => x.Name).ToList();

                if (LocationViewModel.AdminLevel2List.Count > 0)
                {
                    LocationViewModel.EnableAdminLevel2 = LocationViewModel.IsLocationDisabled ? false : true;

                    if (LocationViewModel.AdminLevel2List.FirstOrDefault()?.idfsGISReferenceType == _authenticatedUser.BottomAdminLevel && LocationViewModel.AdminLevel2Value == null)
                    {
                        LocationViewModel.UserAdministrativeLevel2 = _authenticatedUser.RayonId;

                        if (LocationViewModel.SetUserDefaultLocations && _authenticatedUser.Preferences.DefaultRayonInSearchPanels)
                        {
                            LocationViewModel.AdminLevel2Value = _authenticatedUser.RayonId;
                        }
                    }
                    else if (LocationViewModel.AdminLevel2Value == null && LocationViewModel.SetUserDefaultLocations && _authenticatedUser.Preferences.DefaultRayonInSearchPanels)
                    {
                        LocationViewModel.UserAdministrativeLevel2 = _authenticatedUser.RayonId;
                        LocationViewModel.AdminLevel2Value = _authenticatedUser.RayonId;
                    }

                    LocationViewModel.AdminLevel2LevelType = LocationViewModel.AdminLevel2List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel2Value) != null ?
                              LocationViewModel.AdminLevel2List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel2Value)?.LevelType : null;
                    if (LocationViewModel.AdminLevel2LevelType != null)
                    {
                        LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel1Value;
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel2List, LocationViewModel.AdminLevel2Value);
                    }
                    LocationViewModel.AdminLevel2List.Insert(0, new GisLocationChildLevelModel { idfsReference = null, idfsGISReferenceType = null, Name = "" });
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel2 = LocationViewModel.AdminLevel2Value != null;

            }
        }

        private async Task FillAdminLevel3()
        {
            if (LocationViewModel.AdminLevel2Value != null)
            {
                LocationViewModel.AdminLevel3List = await _crossCuttingClient.GetGisLocationChildLevel(CurrentLanguage, Convert.ToString(LocationViewModel.AdminLevel2Value));
                LocationViewModel.AdminLevel3List = LocationViewModel.AdminLevel3List.OrderBy(x => x.Name).ToList();
                if (LocationViewModel.AdminLevel3List.Count > 0)
                {
                    LocationViewModel.EnableAdminLevel3 = LocationViewModel.IsLocationDisabled ? false : true;

                    if (LocationViewModel.SettlementId != null)
                    {
                        LocationViewModel.AdminLevel3Value = LocationViewModel.SettlementId;
                    }
                    else if (LocationViewModel.Settlement != null)
                    {
                        LocationViewModel.AdminLevel3Value = LocationViewModel.Settlement;

                    }
                    LocationViewModel.AdminLevel3LevelType = LocationViewModel.AdminLevel3List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel3Value) != null ?
                              LocationViewModel.AdminLevel3List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel3Value)?.LevelType : null;
                    if (LocationViewModel.AdminLevel3List != null)
                    {
                        if (LocationViewModel.AdminLevel3Value != null)
                            LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel3Value;
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel3List, LocationViewModel.AdminLevel2Value);
                    }
                    LocationViewModel.AdminLevel3List.Insert(0, new GisLocationChildLevelModel { idfsReference = null, idfsGISReferenceType = null, Name = "" });
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel3 = LocationViewModel.IsLocationDisabled ? false : LocationViewModel.AdminLevel3Value != null;
            }
        }

        private async Task FillAdminLevel4()
        {
            if (LocationViewModel.AdminLevel3Value != null)
            {
                LocationViewModel.AdminLevel4List = await _crossCuttingClient.GetGisLocationChildLevel(CurrentLanguage, Convert.ToString(LocationViewModel.AdminLevel3Value));
                LocationViewModel.AdminLevel4List = LocationViewModel.AdminLevel4List.OrderBy(x => x.Name).ToList();

                if (LocationViewModel.AdminLevel4List.Count > 0)
                {
                    LocationViewModel.EnableAdminLevel4 = LocationViewModel.IsLocationDisabled ? false : true;

                    LocationViewModel.AdminLevel4LevelType = LocationViewModel.AdminLevel4List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel4Value) != null ?
                              LocationViewModel.AdminLevel4List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel4Value)?.LevelType : null;
                    if (LocationViewModel.AdminLevel4LevelType != null)
                    {
                        LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel4Value;
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel4List, LocationViewModel.AdminLevel4Value);
                    }
                    LocationViewModel.AdminLevel4List.Insert(0, new GisLocationChildLevelModel { idfsReference = null, idfsGISReferenceType = null, Name = "" });
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel4 = LocationViewModel.IsLocationDisabled ? false : LocationViewModel.AdminLevel4Value != null;
            }
        }

        private async Task FillAdminLevel5()
        {
            if (LocationViewModel.AdminLevel4Value != null)
            {
                LocationViewModel.AdminLevel5List = await _crossCuttingClient.GetGisLocationChildLevel(CurrentLanguage, Convert.ToString(LocationViewModel.AdminLevel4Value));
                LocationViewModel.AdminLevel5List = LocationViewModel.AdminLevel5List.OrderBy(x => x.Name).ToList();

                if (LocationViewModel.AdminLevel5List.Count > 0)
                {
                    LocationViewModel.EnableAdminLevel5 = LocationViewModel.IsLocationDisabled ? false : true;

                    LocationViewModel.AdminLevel5LevelType = LocationViewModel.AdminLevel5List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel5Value) != null ?
                              LocationViewModel.AdminLevel5List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel5Value)?.LevelType : null;
                    if (LocationViewModel.AdminLevel5LevelType != null)
                    {
                        LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel5Value;
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel5List, LocationViewModel.AdminLevel5Value);
                    }
                    LocationViewModel.AdminLevel5List.Insert(0, new GisLocationChildLevelModel { idfsReference = null, idfsGISReferenceType = null, Name = "" });
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel5 = LocationViewModel.IsLocationDisabled ? false : LocationViewModel.AdminLevel5Value != null;
            }
        }

        private async Task FillAdminLevel6()
        {
            if (LocationViewModel.AdminLevel5Value != null)
            {
                LocationViewModel.AdminLevel6List = await _crossCuttingClient.GetGisLocationChildLevel(CurrentLanguage, Convert.ToString(LocationViewModel.AdminLevel5Value));
                LocationViewModel.AdminLevel6List = LocationViewModel.AdminLevel6List.OrderBy(x => x.Name).ToList();

                if (LocationViewModel.AdminLevel6List.Count > 0)
                {
                    LocationViewModel.EnableAdminLevel6 = LocationViewModel.IsLocationDisabled ? false : true;

                    LocationViewModel.AdminLevel6LevelType = LocationViewModel.AdminLevel6List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel6Value) != null ?
                              LocationViewModel.AdminLevel6List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel6Value)?.LevelType : null;
                    if (LocationViewModel.AdminLevel6LevelType != null)
                    {
                        LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel6Value;
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel6List, LocationViewModel.AdminLevel6Value);
                    }
                    LocationViewModel.AdminLevel6List.Insert(0, new GisLocationChildLevelModel { idfsReference = null, idfsGISReferenceType = null, Name = "" });
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel6 = LocationViewModel.IsLocationDisabled ? false : LocationViewModel.AdminLevel5Value != null;
            }
        }

        private async Task FillSettlementType()
        {
            LocationViewModel.SettlementTypeList = await _settlementClient.GetSettlementTypeList(CurrentLanguage);
            LocationViewModel.EnableSettlementType = LocationViewModel.IsLocationDisabled ? false : true;

            if (LocationViewModel.SettlementTypeList.Count == 1)
            {
                //LocationViewModel.ShowSettlementType = false;
            }
            else
            {
                //LocationViewModel.ShowSettlementType = true;
            }
        }

        private async Task UpdateSettlementTypeAsync(List<GisLocationChildLevelModel> settlementList, long? parentAdminLevelValue)
        {
            LocationViewModel.EnableApartment = LocationViewModel.IsLocationDisabled ? false : true;
            LocationViewModel.EnableBuilding = LocationViewModel.IsLocationDisabled ? false : true;
            LocationViewModel.EnableHouse = LocationViewModel.IsLocationDisabled ? false : true;
            LocationViewModel.EnableStreet = LocationViewModel.IsLocationDisabled ? false : true;
            LocationViewModel.EnablePostalCode = LocationViewModel.IsLocationDisabled ? false : true;
            LocationViewModel.EnabledLatitude = LocationViewModel.IsLocationDisabled ? false : true;
            LocationViewModel.EnabledLongitude = LocationViewModel.IsLocationDisabled ? false : true;

            if (parentAdminLevelValue == null)
            {
                LocationViewModel.EnableSettlementType = false;
                return;
            }

            await FillSettlementType();

            if (settlementList.Count > 0)
            {
                if (!settlementList.Any(s => s.LevelType != null && s.LevelType.Value == Convert.ToInt64(SettlementTypes.Settlement)))
                {
                    LocationViewModel.SettlementTypeList.RemoveAll(s => s.idfsReference == Convert.ToInt64(SettlementTypes.Settlement));
                }
                if (!settlementList.Any(s => s.LevelType != null && s.LevelType.Value == Convert.ToInt64(SettlementTypes.Town)))
                {
                    LocationViewModel.SettlementTypeList.RemoveAll(s => s.idfsReference == Convert.ToInt64(SettlementTypes.Town));
                }
                if (!settlementList.Any(s => s.LevelType != null && s.LevelType.Value == Convert.ToInt64(SettlementTypes.Village)))
                {
                    LocationViewModel.SettlementTypeList.RemoveAll(s => s.idfsReference == Convert.ToInt64(SettlementTypes.Village));
                }

                LocationViewModel.SettlementTypeList.Insert(0, new SettlementTypeModel { idfsReference = null, name = "ALL" });
                LocationViewModel.SettlementType = null;
                LocationViewModel.DivSettlementGroup = true;
                if (!LocationViewModel.ShowSettlement)
                {
                    LocationViewModel.DivSettlementType = false;
                }
                else
                {
                    LocationViewModel.DivSettlementType = true;
                }
                if (LocationViewModel.AdminLevel3Value != null)
                {
                    LocationViewModel.SettlementType = LocationViewModel.AdminLevel3List.FirstOrDefault(s => s.idfsReference == LocationViewModel.AdminLevel3Value)?.LevelType;
                }
            }
            else
            {
                LocationViewModel.DivSettlementType = false;
                LocationViewModel.EnableSettlementType = false;
            }
        }

        private async Task FillStreetAsync()
        {
            if (LocationViewModel.BottomAdminLevel != null)
            {
                LocationViewModel.StreetList = await _crossCuttingClient.GetStreetList(LocationViewModel.BottomAdminLevel.Value);
                if (LocationViewModel.StreetList.FirstOrDefault(s => s.StreetName == LocationViewModel.StreetText) == null)
                {
                    var streetModel = new StreetModel()
                    {
                        StreetID = "-1",
                        StreetName = LocationViewModel.StreetText
                    };
                    LocationViewModel.StreetList.Add(streetModel);
                }

                LocationViewModel.StreetList = LocationViewModel.StreetList.OrderBy(x => x.StreetName).ToList();
                LocationViewModel.StreetList.Insert(0, new StreetModel { StreetID = "", StreetName = "" });

                LocationViewModel.StreetText ??= null;
            }
            else
            {

            }
        }

        private async Task FillPostalCode()
        {
            if (LocationViewModel.BottomAdminLevel != null)
            {
                LocationViewModel.PostalCodeList = await _crossCuttingClient.GetPostalCodeList(LocationViewModel.BottomAdminLevel.Value);
                if (LocationViewModel.PostalCodeList.FirstOrDefault(s => s.PostalCodeString == LocationViewModel.PostalCodeText) == null)
                {
                    var postalCodeModel = new PostalCodeViewModel()
                    {
                        PostalCodeID = "-1",
                        PostalCodeString = LocationViewModel.PostalCodeText
                    };
                    LocationViewModel.PostalCodeList.Add(postalCodeModel);
                }

                LocationViewModel.PostalCodeList = LocationViewModel.PostalCodeList.OrderBy(x => x.PostalCodeString).ToList();
                LocationViewModel.PostalCodeList.Insert(0, new PostalCodeViewModel { PostalCodeID = "", PostalCodeString = "" });

                LocationViewModel.PostalCodeText ??= null;
            }
            else
            {
            }
        }

        private void SetMapUrl()
        {
            string query = "";
            string zoom = "";

            if (LocationViewModel.Latitude == null | LocationViewModel.Longitude == null)
            {
                // Look up by location.
                query = $"{LocationViewModel.LeafletAPIUrl}api/?q=";
                if (LocationViewModel.AdminLevel3Value != null)
                {
                    if (LocationViewModel.AdminLevel3List.FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel3Value) != null)
                    {
                        LocationViewModel.AdminLevel3Text = LocationViewModel.AdminLevel3List.FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel3Value)?.Name;
                        query += LocationViewModel.AdminLevel3Text;
                        zoom = "12";
                    }
                }

                if (LocationViewModel.AdminLevel2Value != null)
                {
                    if (LocationViewModel.AdminLevel2List.FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel2Value) != null)
                    {
                        LocationViewModel.AdminLevel2Text = LocationViewModel.AdminLevel2List.FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel2Value)?.Name;
                        if (query != "")
                            query += "+";

                        query += LocationViewModel.AdminLevel2Text;

                        if (zoom == "")
                            zoom = "10";
                    }
                }

                if (LocationViewModel.AdminLevel1Value != null)
                {
                    if (LocationViewModel.AdminLevel1List.FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel1Value) != null)
                    {
                        LocationViewModel.AdminLevel1Text = LocationViewModel.AdminLevel1List.FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel1Value)?.Name;
                        // Do not include "Other Rayons" as the mapping API will not recognize it.
                        if (LocationViewModel.AdminLevel1Text?.ToLower() != OTHER_RAYONS)
                        {
                            if (query != "")
                                query += "+";

                            query += LocationViewModel.AdminLevel1Text;

                            if (zoom == "")
                                zoom = "8";
                        }
                    }
                }

                if (query == $"'{LocationViewModel.LeafletAPIUrl}api/?q=")
                {
                    if (LocationViewModel.AdminLevel0Value != null)
                    {
                        LocationViewModel.AdminLevel0Text = LocationViewModel.AdminLevel0List.FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel0Value)?.Name;
                        query += LocationViewModel.AdminLevel0Text + "&osm_tag=place:country'";

                    }
                }
            }
            else
            {
                // Reverse look up by latitude and longitude
                zoom = "12";
                CultureInfo englishUsCulture = new CultureInfo("en-US");
                query += LocationViewModel.LeafletAPIUrl + "reverse?lat=" + LocationViewModel.Latitude.Value.ToString(englishUsCulture) + "&lon=" + LocationViewModel.Longitude.Value.ToString(englishUsCulture);
            }
            LocationViewModel.MapUrl = query;
            LocationViewModel.Zoom = zoom;
        }
    }
}