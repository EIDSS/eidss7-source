#region Usings

using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Leaflet;
using EIDSS.Web.Components.Leaflet.Data;
using EIDSS.Web.Components.Leaflet.Models;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Components.Shared
{
    public class LocationViewBase : BaseComponent, IDisposable
    {
    
        #region Dependency Injection

        [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject] private ISettlementClient SettlementClient { get; set; }

        [Inject] private ILogger<LocationViewBase> Logger { get; set; }

        [Inject] private IJSRuntime JsRuntime { get; set; }

        [Inject] private HttpClient Http { get; set; }

        [Inject] DialogService DialogService { get; set; }

        #endregion Dependency Injection

        #region Parameters

        [Parameter] public EventCallback<LocationViewModel> LocationViewModelChanged { get; set; }

        [Parameter] public LocationViewModel ParmLocationViewModel { get; set; }

        [Inject]
        private IAdministrativeUnitsClient AdministrativeUnitsClient { get; set; }

        [Parameter] public bool Refresh { get; set; } = false;

        #endregion Parameaters

        #region Properties

        protected bool ShowAddStreet { get; set; } = true;
        protected bool ShowAddPostalCode { get; set; } = true;
        protected bool ShouldSubmit { get; set; } = false;
        protected List<GisLocationChildLevelModel> SelectedBottomLevelList { get; set; }
        protected int SelectedBottomLevelNumber { get; set; }
        protected RadzenTemplateForm<LocationViewModel> LocationForm { get; set; }
        protected List<StreetModel> StreetList { get; set; }
        protected string SelectedStreet { get; set; }
        protected string SelectedPostalCode { get; set; }
        protected bool DialogOpen { get; set; }
        public LocationViewModel LocationViewModel { get; set; }
        protected List<GisLocationLevelModel> LocationControlLevels { get; set; }
        protected List<GisLocationCurrentLevelModel> CountryList { get; set; }

        #endregion Properties

        #region Member Variables

        private string _photonUrl;
        private string _defaultPhotonUrl;
        private float lat;
        private float lan;
        private Map _map;
        private LatLong _latLong;
        private const string OTHER_RAYONS = "other rayons";
        private CancellationTokenSource source;
        private CancellationToken token;
        private int AdminHierarchyLevel;
        private int DetailAdminHierarchyLevel;
        private DrawHandler _drawHandler;
        private readonly LatLng _markerLatLng = new() { Lat = 47.5574007f, Lng = 16.3918687f };
        private JsInteropClasses jsClass;

        #endregion Member Variables

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            await base.OnInitializedAsync();

            jsClass = new(JsRuntime);

            //var marker = new Marker(_markerLatLng)
            //{
            //    Draggable = false,
            //    Title = "Marker 1",
            //    Popup = new Popup { Content = string.Format("I am at {0:0.00}° lat, {1:0.00}° lng", _markerLatLng.Lat, _markerLatLng.Lng) },
            //    Tooltip = new Leaflet.Models.Tooltip { Content = "Click and drag to move me" }
            //};

            //_map = new Map(JsRuntime)
            //{
            //    Center = _markerLatLng,
            //    Zoom = 4.8f
            //};

            //_map.OnInitialized += () =>
            //{
            //    _map.AddLayer(new TileLayer
            //    {
            //        UrlTemplate = "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
            //        Attribution = "&copy; <a href=\"https://www.openstreetmap.org/copyright\">OpenStreetMap</a> contributors",
            //    });

            //    _map.AddLayer(marker);
            //};

            //_drawHandler = new DrawHandler(_map, JsRuntime);

            //marker.OnMove += OnDrag;
            //marker.OnMoveEnd += OnDragEnd;


            _logger = Logger;
            SelectedBottomLevelList = null;
            SelectedBottomLevelNumber = 0;
            ShowAddStreet = true;

            //reset the cancellation token
            source = new ();
            token = source.Token;

            authenticatedUser = _tokenService.GetAuthenticatedUser();
            //LocationViewModel = ParmLocationViewModel;
            if (ParmLocationViewModel != null)
            {
                LocationViewModel = ParmLocationViewModel;
                await InitializeAsync();
            }
            //initialize Control
          //  await InitializeAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {

                //var lDotNetReference = DotNetObjectReference.Create(this);
                //await JsRuntime.InvokeVoidAsync("GLOBAL.SetDotnetReference", token, lDotNetReference);

                //await JsRuntime.InvokeVoidAsync("addInputElement", "divPostalCode");
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        //protected override async Task OnParametersSetAsync()
        //{
          
        //    await base.OnParametersSetAsync();
        //}

        public async Task RefreshComponent(LocationViewModel locationViewModel)
        {
            if (locationViewModel != null)
            {
                LocationViewModel = locationViewModel;
                await InitializeAsync();
            }
        }

        public void Dispose()
        {
            source?.Cancel();
            source?.Dispose();
            jsClass?.Dispose();
        }

        #endregion

        #region Protected Methods and Delegates

        private async Task InitializeAsync()
        {
            if (LocationViewModel != null)
            {
                LocationViewModel.DefaultCountry = Configuration.GetValue<string>("EIDSSGlobalSettings:DefaultCountry");
                LocationViewModel.LeafletAPIUrl = Configuration.GetValue<string>("EIDSSGlobalSettings:LeafletAPIUrl");
                LocationViewModel.DefaultLatitude = Configuration.GetValue<string>("EIDSSGlobalSettings:DefaultLatitude");
                LocationViewModel.DefaultLongitude = Configuration.GetValue<string>("EIDSSGlobalSettings:DefaultLongitude");

                LocationViewModel.AdjustControlForLocationType();

                if (LocationViewModel.ShowAdminTopLevelsOnly)
                    LocationViewModel.SetupRequiredFieldsForAdminLevel0();
                else
                    LocationViewModel.SetupRequiredFields();

                await SetupLocationHierarchyAsync();

                await PopulateDataAsync();

            }
        }

   
        //Setting up the Location Level Hierarchy
        private async Task SetupLocationHierarchyAsync()
        {
            LocationControlLevels ??= await CrossCuttingClient.GetGisLocationLevels(GetCurrentLanguage());
            var maxLevel = LocationControlLevels.Max(l => l.Level);
            for (var i = 1; i <= maxLevel; i++)
            {
                switch (i)
                {
                    case 1:
                        LocationViewModel.ShowAdminLevel0 = LocationViewModel.ShowAdminLevel0;
                        break;
                    case 2:
                        LocationViewModel.ShowAdminLevel1 = LocationViewModel.ShowAdminLevel1;
                        break;
                    case 3:
                        LocationViewModel.ShowAdminLevel2 = LocationViewModel.ShowAdminLevel2;
                        break;
                    case 4:
                        LocationViewModel.ShowAdminLevel3 = LocationViewModel.ShowAdminLevel3;
                        break;
                    case 5:
                        LocationViewModel.ShowAdminLevel4 = LocationViewModel.ShowAdminLevel4;
                        break;
                    case 6:
                        LocationViewModel.ShowAdminLevel5 = LocationViewModel.ShowAdminLevel5;
                        break;
                    case 7:
                        LocationViewModel.ShowAdminLevel6 = LocationViewModel.ShowAdminLevel6;
                        break;
                }
            }

            AdminHierarchyLevel = 0;
            DetailAdminHierarchyLevel = -1;

            switch (LocationViewModel.OperationType)
            {
                case null or LocationViewOperationType.Search:
                {
                    if (LocationViewModel.AdministrativeLevelId != null)
                    {
                        if (LocationViewModel.AdministrativeLevelId == (long?)AdministrativeLevelReferenceIds.AdminLevel1Id)
                        {
                            AdminHierarchyLevel = 1;
                        }
                        if (LocationViewModel.AdministrativeLevelId == (long?)AdministrativeLevelReferenceIds.AdminLevel2Id)
                        {
                            AdminHierarchyLevel = 2;

                        }
                        if (LocationViewModel.AdministrativeLevelId == (long?)AdministrativeLevelReferenceIds.AdminLevel3Id)
                        {
                            AdminHierarchyLevel = 3;

                        }
                    }

                    break;
                }
                case LocationViewOperationType.Add or LocationViewOperationType.Edit or LocationViewOperationType.ReadOnly:
                {
                    if (LocationViewModel.AdministrativeLevelId != null)
                    {
                        if (LocationViewModel.AdministrativeLevelId == (long?)AdministrativeLevelReferenceIds.AdminLevel1Id)
                        {
                            DetailAdminHierarchyLevel = 0;
                        }
                        if (LocationViewModel.AdministrativeLevelId == (long?)AdministrativeLevelReferenceIds.AdminLevel2Id)
                        {
                            DetailAdminHierarchyLevel = 1;

                        }
                        if (LocationViewModel.AdministrativeLevelId == (long?)AdministrativeLevelReferenceIds.AdminLevel3Id)
                        {
                            DetailAdminHierarchyLevel = 2;

                        }
                    }

                    break;
                }
            }
        }

        private async Task PopulateDataAsync()
        {
            await FillAdminLevel0();
            await FillAdminLevel1();
            await FillAdminLevel2();
            await FillAdminLevel3();
            await FillAdminLevel4();
            await FillAdminLevel5();
            await FillAdminLevel6();
            await FillStreetAsync();
            await FillPostalCode();

            //await RefreshAtAdminLevel0();
        }

        //Fill Admin Level0 and Enable/Disable based on parameter properties
        protected async Task FillAdminLevel0()
        {
            if (LocationViewModel.AdminLevel0Value != null)
            {
                CountryList ??= await CrossCuttingClient.GetGisLocationCurrentLevel(GetCurrentLanguage(), 0,true);
                if (CountryList != null)
                {
                    var filteredCountryList =
                        CountryList.Where(l => l.strHASC != null).OrderBy(l => l.strHASC).ToList();
                    LocationViewModel.AdminLevel0List = CountryList;

                    LocationViewModel.AdminLevel0Text = LocationViewModel.AdminLevel0List
                        .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel0Value)?.Name;
                }

                if (LocationViewModel.ShowAdminLevel0)
                {
                    if (LocationViewModel.OperationType != LocationViewOperationType.Edit && LocationViewModel.OperationType != LocationViewOperationType.ReadOnly)
                    {
                    }

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
            await UpdateForEditAdminHierarchyLevelAsync();
        }

        protected async Task RefreshAtAdminLevel0()
        {
            LocationViewModel.BottomAdminLevel = null;
            LocationViewModel.AdminLevel1Value = null;

            
            if (LocationViewModel.AdminLevel0Value != null && LocationViewModel.AdminLevel0List != null)
            {
                LocationViewModel.AdminLevel0Text = LocationViewModel.AdminLevel0List
                    .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel0Value)?.Name;

                LocationViewModel.AdminLevel0LevelType = null;
                if (LocationViewModel.AdminLevel0LevelType != null)
                {
                    LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel0Value;
                    SelectedBottomLevelList = null;
                    SelectedBottomLevelNumber = 0;
                    await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel1List,
                        LocationViewModel.AdminLevel1Value);
                    RefreshAtBottom();
                    await FillStreetAsync();
                    await FillPostalCode();
                    await LocationViewModelChanged.InvokeAsync(LocationViewModel);
                }
            }

            if (LocationViewModel.BottomAdminLevel == null)
            {
                await FillAdminLevel1();
                await RefreshAtAdminLevel1();
            }

        }

        protected async Task FillAdminLevel1()
        {
            if (LocationViewModel.AdminLevel0Value != null)
            {
                LocationViewModel.AdminLevel1List =
                    await CrossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(),
                        Convert.ToString(LocationViewModel.AdminLevel0Value));
                if (LocationViewModel.AdminLevel1List is {Count: > 0})
                {
                    if (LocationViewModel.OperationType != LocationViewOperationType.Edit && LocationViewModel.OperationType != LocationViewOperationType.ReadOnly)
                        LocationViewModel.EnableAdminLevel1 = true;

                    if (LocationViewModel.AdminLevel1List.FirstOrDefault()?.idfsGISReferenceType ==
                        authenticatedUser.BottomAdminLevel && LocationViewModel.AdminLevel1Value == null)
                    {
                        LocationViewModel.UserAdministrativeLevel1 = authenticatedUser.RegionId;

                        if (LocationViewModel.SetUserDefaultLocations &&
                            authenticatedUser.Preferences.DefaultRegionInSearchPanels)
                            LocationViewModel.AdminLevel1Value = authenticatedUser.RegionId;
                    }
                    else if (LocationViewModel.AdminLevel1Value == null && LocationViewModel.SetUserDefaultLocations &&
                             authenticatedUser.Preferences.DefaultRegionInSearchPanels)
                    {
                        LocationViewModel.UserAdministrativeLevel1 = authenticatedUser.RegionId;
                        LocationViewModel.AdminLevel1Value = authenticatedUser.RegionId;
                    }

                    LocationViewModel.AdminLevel1List.Insert(0,
                        new GisLocationChildLevelModel {idfsReference = null, idfsGISReferenceType = null, Name = ""});
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel1 = LocationViewModel.AdminLevel1Value != null;
            }

            if (LocationViewModel.OperationType is null or LocationViewOperationType.Search)
            { 
                UpdateForSearchAdminHierarchyLevel(); 
            }

            if (LocationViewModel.OperationType is LocationViewOperationType.Add or LocationViewOperationType.Edit or LocationViewOperationType.ReadOnly)
            {
                await UpdateForEditAdminHierarchyLevelAsync();
            }
        }

        protected async Task RefreshAtAdminLevel1()
        {
            LocationViewModel.BottomAdminLevel = null;
            LocationViewModel.AdminLevel2Value = null;

            if (LocationViewModel.AdminLevel1Value != null && LocationViewModel.AdminLevel1List != null)
            {
                LocationViewModel.AdminLevel1Text = LocationViewModel.AdminLevel1List
                    .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel1Value)?.Name;

                LocationViewModel.AdminLevel1LevelType =
                    LocationViewModel.AdminLevel1List.FirstOrDefault(l =>
                        l.idfsReference == LocationViewModel.AdminLevel1Value) != null
                        ? LocationViewModel.AdminLevel1List
                            .FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel1Value)
                            ?.LevelType
                        : null;
                if (LocationViewModel.AdminLevel1LevelType != null)
                {
                    LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel1Value;
                    SelectedBottomLevelList = LocationViewModel.AdminLevel1List;
                    SelectedBottomLevelNumber = 1;
                    await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel1List,
                        LocationViewModel.AdminLevel1Value);
                    RefreshAtBottom();
                    await FillStreetAsync();
                    await FillPostalCode();
                    await LocationViewModelChanged.InvokeAsync(LocationViewModel);
                }
            }

            if (LocationViewModel.BottomAdminLevel == null)
            {
                await FillAdminLevel2();
                await RefreshAtAdminLevel2();
            }
        }

        protected async Task FillAdminLevel2()
        {
            if (LocationViewModel.AdminLevel1Value != null)
            {
                LocationViewModel.AdminLevel2List =
                    await CrossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(),
                        Convert.ToString(LocationViewModel.AdminLevel1Value));
                if (LocationViewModel.AdminLevel2List != null)
                {
                    LocationViewModel.AdminLevel2List = LocationViewModel.AdminLevel2List.OrderBy(x => x.Name).ToList();

                    if (LocationViewModel.OperationType != LocationViewOperationType.Edit && LocationViewModel.OperationType != LocationViewOperationType.ReadOnly)
                        LocationViewModel.EnableAdminLevel2 = true;

                    if (LocationViewModel.AdminLevel2List.FirstOrDefault()?.idfsGISReferenceType ==
                        authenticatedUser.BottomAdminLevel && LocationViewModel.AdminLevel2Value == null)
                    {
                        LocationViewModel.UserAdministrativeLevel2 = authenticatedUser.RayonId;

                        if (LocationViewModel.SetUserDefaultLocations &&
                            authenticatedUser.Preferences.DefaultRayonInSearchPanels)
                            LocationViewModel.AdminLevel2Value = authenticatedUser.RayonId;
                    }
                    else if (LocationViewModel.AdminLevel2Value == null && LocationViewModel.SetUserDefaultLocations &&
                             authenticatedUser.Preferences.DefaultRayonInSearchPanels)
                    {
                        LocationViewModel.UserAdministrativeLevel2 = authenticatedUser.RayonId;
                        LocationViewModel.AdminLevel2Value = authenticatedUser.RayonId;
                    }

                    LocationViewModel.AdminLevel2LevelType =
                        LocationViewModel.AdminLevel2List.FirstOrDefault(l => l.LevelType != null) != null
                            ? LocationViewModel.AdminLevel2List.FirstOrDefault(l => l.LevelType != null)?.LevelType
                            : null;
                    if (LocationViewModel.AdminLevel2LevelType != null)
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel2List,
                            LocationViewModel.AdminLevel1Value);

                    LocationViewModel.AdminLevel2List.Insert(0,
                        new GisLocationChildLevelModel { idfsReference = null, idfsGISReferenceType = null, Name = "" });
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel2 = LocationViewModel.AdminLevel2Value != null;
            }

            if (LocationViewModel.OperationType is null or LocationViewOperationType.Search)
            {
                UpdateForSearchAdminHierarchyLevel();
            }

            if (LocationViewModel.OperationType is LocationViewOperationType.Add or LocationViewOperationType.Edit or LocationViewOperationType.ReadOnly)
            {
                await UpdateForEditAdminHierarchyLevelAsync(); 
            }
        }

        private void UpdateForSearchAdminHierarchyLevel()
        {
            if (AdminHierarchyLevel == 1)
            {
                LocationViewModel.AdminLevel2Value = null;
                LocationViewModel.EnableAdminLevel2 = false;
                LocationViewModel.AdminLevel3Value = null;
                LocationViewModel.EnableAdminLevel3 = false;
                LocationViewModel.SettlementType = null;
                LocationViewModel.EnableSettlementType = false;
            }

            if (AdminHierarchyLevel == 2)
            {
                LocationViewModel.AdminLevel3Value = null;
                LocationViewModel.EnableAdminLevel3 = false;
                LocationViewModel.SettlementType = null;
                LocationViewModel.EnableSettlementType = false;
            }
        }

        private async Task UpdateForEditAdminHierarchyLevelAsync()
        {
            var selectedAdminLevel = LocationViewModel.AdministrativeLevelId;
            if (DetailAdminHierarchyLevel == 0)
            {
                if (LocationViewModel.OperationType ==LocationViewOperationType.Add)
                {
                    LocationViewModel.AdminLevel1Value = null;
                    LocationViewModel.AdminLevel2Value = null;
                    LocationViewModel.AdminLevel3Value = null;
                    LocationViewModel.SettlementType = null;
                }

                LocationViewModel.EnableAdminLevel1 = false;
                LocationViewModel.EnableAdminLevel2 = false;
                LocationViewModel.EnableAdminLevel3 = false;
                LocationViewModel.EnableSettlementType = false;
            }

            if (DetailAdminHierarchyLevel == 1)
            {
                if (LocationViewModel.OperationType == LocationViewOperationType.Add)
                {
                    LocationViewModel.AdminLevel2Value = null;
                    LocationViewModel.AdminLevel3Value = null;
                    LocationViewModel.SettlementType = null;
                }

                LocationViewModel.EnableAdminLevel2 = false;
                LocationViewModel.EnableAdminLevel3 = false;
                LocationViewModel.EnableSettlementType = false;
            }

            if (DetailAdminHierarchyLevel == 2)
            {
                if (LocationViewModel.OperationType == LocationViewOperationType.Add)
                {
                    LocationViewModel.AdminLevel3Value = null;
                    LocationViewModel.EnableSettlementType = true;

                }
                else if (LocationViewModel.OperationType is LocationViewOperationType.Edit or LocationViewOperationType.ReadOnly)
                {
                    LocationViewModel.EnableSettlementType = false;
                }

                //LocationViewModel.SettlementType = null;
                await FillSettlementType();
                if (LocationViewModel.SettlementTypeList is {Count: > 0})
                {
                    LocationViewModel.SettlementType = LocationViewModel.SettlementTypeList.FirstOrDefault().idfsReference;
                }
            }

            switch (selectedAdminLevel)
            {
                case (long)AdministrativeLevelReferenceIds.AdminLevel2Id: //If Rayon
                    {
                        LocationViewModel.EnableAdminLevel0 = true;
                        LocationViewModel.EnableAdminLevel1 = true;
                        LocationViewModel.EnableAdminLevel2 = false;
                        LocationViewModel.AdminLevel2Text = String.Empty;
                        //LocationViewModel.AdminLevel2Value = null;
                        LocationViewModel.EnableSettlementType = false;
                        LocationViewModel.SettlementType = null;

                        LocationViewModel.ShowAdminLevel4 = false;
                        break;
                    }
                case (long)AdministrativeLevelReferenceIds.AdminLevel1Id: //If Region
                    {
                        LocationViewModel.EnableAdminLevel0 = true;
                        LocationViewModel.AdminLevel1Text = String.Empty;
                        //LocationViewModel.AdminLevel1Value = null;
                        LocationViewModel.EnableAdminLevel1 = false;
                        LocationViewModel.ShowAdminLevel4 = false;
                        break;
                    }
                case (long)AdministrativeLevelReferenceIds.AdminLevel3Id: //If Settlement
                    {
                        LocationViewModel.EnableAdminLevel0 = true;
                        LocationViewModel.EnableAdminLevel1 = true;
                        LocationViewModel.EnableAdminLevel2 = true;
                        LocationViewModel.EnableSettlementType = true;

                        LocationViewModel.EnableSettlement = false;
                        LocationViewModel.SettlementText = String.Empty;
                        //LocationViewModel.Settlement = null;
                        LocationViewModel.EnableAdminLevel3 = false;
                        LocationViewModel.ShowAdminLevel4 = false;
                        break;
                    }
            }

        }

        protected async Task RefreshAtAdminLevel2()
        {
            LocationViewModel.BottomAdminLevel = null;
            LocationViewModel.AdminLevel3Value = null;
            if (LocationViewModel.AdminLevel2Value != null && LocationViewModel.AdminLevel2List != null)
            {
                LocationViewModel.AdminLevel2Text = LocationViewModel.AdminLevel2List
                    .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel2Value)?.Name;

                LocationViewModel.AdminLevel2LevelType =
                    LocationViewModel.AdminLevel2List.FirstOrDefault(l =>
                        l.idfsReference == LocationViewModel.AdminLevel2Value) != null
                        ? LocationViewModel.AdminLevel2List.FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel2Value)
                            ?.LevelType
                        : null;
                if (LocationViewModel.AdminLevel2LevelType != null)
                {
                    LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel2Value;
                    SelectedBottomLevelList = LocationViewModel.AdminLevel2List;
                    SelectedBottomLevelNumber = 2;
                    await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel2List,
                        LocationViewModel.AdminLevel2Value);
                    RefreshAtBottom();
                    await FillStreetAsync();
                    await FillPostalCode();
                    await LocationViewModelChanged.InvokeAsync(LocationViewModel);
                }
            }

            if (LocationViewModel.BottomAdminLevel == null)
            {
                await FillAdminLevel3();
                await RefreshAtAdminLevel3();
                await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel3List,
                    LocationViewModel.AdminLevel2Value);
            }
        }

        protected async Task FillAdminLevel3()
        {
            if (LocationViewModel.AdminLevel2Value != null)
            {
                LocationViewModel.AdminLevel3List =
                    await CrossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(),
                        Convert.ToString(LocationViewModel.AdminLevel2Value));
                if (LocationViewModel.AdminLevel3List != null)
                {
                    LocationViewModel.AdminLevel3List = LocationViewModel.AdminLevel3List.OrderBy(x => x.Name).ToList();

                    if (LocationViewModel.OperationType != LocationViewOperationType.Edit && LocationViewModel.OperationType != LocationViewOperationType.ReadOnly)
                        LocationViewModel.EnableAdminLevel3 = true;


                    if (LocationViewModel.AdminLevel3List.FirstOrDefault()?.idfsGISReferenceType ==
                        authenticatedUser.BottomAdminLevel && LocationViewModel.AdminLevel3Value == null)
                        LocationViewModel.BottomAdminLevel =
                            LocationViewModel.AdminLevel3List.FirstOrDefault()?.idfsReference;
                    else if (LocationViewModel.SettlementId != null)
                        LocationViewModel.AdminLevel3Value = LocationViewModel.SettlementId;
                    else if (LocationViewModel.Settlement != null)
                        LocationViewModel.AdminLevel3Value = LocationViewModel.Settlement;

                    //LocationViewModel.AdminLevel3LevelType =
                    //    LocationViewModel.AdminLevel3List.FirstOrDefault(l => l.LevelType != null) != null
                    //        ? LocationViewModel.AdminLevel3List.FirstOrDefault(l => l.LevelType != null)?.LevelType
                    //        : null;
                    if (LocationViewModel.AdminLevel3List != null)
                    {
                        LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel3Value;
                        SelectedBottomLevelList = LocationViewModel.AdminLevel3List;
                        SelectedBottomLevelNumber = 3;
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel3List,
                            LocationViewModel.AdminLevel2Value);
                    }

                    LocationViewModel.AdminLevel3List ??= new List<GisLocationChildLevelModel>();
                    LocationViewModel.AdminLevel3List.Insert(0,
                        new GisLocationChildLevelModel {idfsReference = null, idfsGISReferenceType = null, Name = ""});
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel3 = LocationViewModel.AdminLevel3Value != null;
                LocationViewModel.AdminLevel3LevelType = null;
            }

            if (LocationViewModel.OperationType is null or LocationViewOperationType.Search)
            {
                UpdateForSearchAdminHierarchyLevel();
            }

            if (LocationViewModel.OperationType is LocationViewOperationType.Add or LocationViewOperationType.Edit or LocationViewOperationType.ReadOnly)
            {
                await UpdateForEditAdminHierarchyLevelAsync();
            }

        }

        protected async Task RefreshAtAdminLevel3()
        {
            LocationViewModel.BottomAdminLevel = null;
            LocationViewModel.AdminLevel4Value = null;

            if (LocationViewModel.AdminLevel3Value != null && LocationViewModel.AdminLevel3List != null)
            {
                LocationViewModel.AdminLevel3Text = LocationViewModel.AdminLevel3List
                    .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel3Value)?.Name;
                LocationViewModel.AdminLevel3LevelType =
                    LocationViewModel.AdminLevel3List.FirstOrDefault(l =>
                        l.idfsReference == LocationViewModel.AdminLevel3Value) != null
                        ? LocationViewModel.AdminLevel3List
                            .FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel3Value)
                            ?.LevelType
                        : null;
                if (LocationViewModel.AdminLevel3LevelType != null)
                {
                    LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel3Value;
                    SelectedBottomLevelList = LocationViewModel.AdminLevel3List;
                    SelectedBottomLevelNumber = 3;
                    //await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel3List,
                    //    LocationViewModel.AdminLevel3Value);
                    RefreshAtBottom();
                    await FillStreetAsync();
                    await FillPostalCode();
                    await LocationViewModelChanged.InvokeAsync(LocationViewModel);
                }
            }
            else
            {
                LocationViewModel.AdminLevel3LevelType = null;

            }

            if (LocationViewModel.BottomAdminLevel == null)
            {
                await FillAdminLevel4();
                await RefreshAtAdminLevel4();
            }
        }

        protected async Task FillAdminLevel4()
        {
            if (LocationViewModel.AdminLevel3Value != null)
            {
                LocationViewModel.AdminLevel4List =
                    await CrossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(),
                        Convert.ToString(LocationViewModel.AdminLevel3Value));

                if (LocationViewModel.AdminLevel4List != null)
                {
                    LocationViewModel.AdminLevel4List = LocationViewModel.AdminLevel4List.OrderBy(x => x.Name).ToList();

                    if (LocationViewModel.OperationType != LocationViewOperationType.Edit && LocationViewModel.OperationType != LocationViewOperationType.ReadOnly)
                        LocationViewModel.EnableAdminLevel4 = true;

                    LocationViewModel.AdminLevel4LevelType =
                        LocationViewModel.AdminLevel4List.FirstOrDefault(l => l.LevelType != null)?.LevelType;
                    if (LocationViewModel.AdminLevel4LevelType != null)
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel4List,
                            LocationViewModel.AdminLevel3Value);

                    LocationViewModel.AdminLevel4List.Insert(0,
                        new GisLocationChildLevelModel {idfsReference = null, idfsGISReferenceType = null, Name = ""});
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel4 = LocationViewModel.AdminLevel5Value != null;
            }
        }

        protected async Task RefreshAtAdminLevel4()
        {
            LocationViewModel.BottomAdminLevel = null;
            LocationViewModel.AdminLevel5Value = null;
            if (LocationViewModel.AdminLevel4Value != null && LocationViewModel.AdminLevel4List != null)
            {
                LocationViewModel.AdminLevel3Text = LocationViewModel.AdminLevel4List
                    .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel4Value)?.Name;

                LocationViewModel.AdminLevel4LevelType =
                    LocationViewModel.AdminLevel5List.FirstOrDefault(l =>
                        l.idfsReference == LocationViewModel.AdminLevel4Value) != null
                        ? LocationViewModel.AdminLevel4List
                            .FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel4Value)
                            ?.LevelType
                        : null;
                if (LocationViewModel.AdminLevel4LevelType != null)
                {
                    LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel4Value;
                    SelectedBottomLevelList = LocationViewModel.AdminLevel4List;
                    SelectedBottomLevelNumber = 4;
                    await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel4List,
                        LocationViewModel.AdminLevel4Value);
                    RefreshAtBottom();
                    await FillStreetAsync();
                    await FillPostalCode();
                    await LocationViewModelChanged.InvokeAsync(LocationViewModel);
                }
            }

            if (LocationViewModel.BottomAdminLevel == null)
            {
                await FillAdminLevel5();
                await RefreshAtAdminLevel5();
            }
        }

        protected async Task FillAdminLevel5()
        {
            if (LocationViewModel.AdminLevel4Value != null)
            {
                LocationViewModel.AdminLevel5List =
                    await CrossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(),
                        Convert.ToString(LocationViewModel.AdminLevel4Value));
                if (LocationViewModel.AdminLevel5List != null)
                {
                    LocationViewModel.AdminLevel5List = LocationViewModel.AdminLevel5List.OrderBy(x => x.Name).ToList();
                    if (LocationViewModel.OperationType != LocationViewOperationType.Edit && LocationViewModel.OperationType != LocationViewOperationType.ReadOnly)
                        LocationViewModel.EnableAdminLevel5 = true;
                    LocationViewModel.AdminLevel5LevelType =
                        LocationViewModel.AdminLevel5List.FirstOrDefault(l => l.LevelType != null) != null
                            ? LocationViewModel.AdminLevel5List.FirstOrDefault(l => l.LevelType != null)?.LevelType
                            : null;
                    if (LocationViewModel.AdminLevel5LevelType != null)
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel5List,
                            LocationViewModel.AdminLevel4Value);

                    LocationViewModel.AdminLevel5List.Insert(0,
                        new GisLocationChildLevelModel {idfsReference = null, idfsGISReferenceType = null, Name = ""});
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel5 = LocationViewModel.AdminLevel5Value != null;
            }
        }

        protected async Task RefreshAtAdminLevel5()
        {
            LocationViewModel.BottomAdminLevel = null;
            LocationViewModel.AdminLevel6Value = null;
            if (LocationViewModel.AdminLevel5Value != null && LocationViewModel.AdminLevel5List != null)
            {
                LocationViewModel.AdminLevel5Text = LocationViewModel.AdminLevel5List
                    .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel5Value)?.Name;


                LocationViewModel.AdminLevel5LevelType =
                    LocationViewModel.AdminLevel5List.FirstOrDefault(l =>
                        l.idfsReference == LocationViewModel.AdminLevel5Value) != null
                        ? LocationViewModel.AdminLevel5List
                            .FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel5Value)
                            ?.LevelType
                        : null;
                if (LocationViewModel.AdminLevel5LevelType != null)
                {
                    LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel5Value;
                    SelectedBottomLevelList = LocationViewModel.AdminLevel5List;
                    SelectedBottomLevelNumber = 5;
                    await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel5List,
                        LocationViewModel.AdminLevel5Value);
                    RefreshAtBottom();
                    await FillStreetAsync();
                    await FillPostalCode();
                    await LocationViewModelChanged.InvokeAsync(LocationViewModel);
                }
            }

            if (LocationViewModel.BottomAdminLevel == null)
            {
                await FillAdminLevel6();
                await RefreshAtAdminLevel6();
            }
        }

        protected async Task FillAdminLevel6()
        {
            if (LocationViewModel.AdminLevel5Value != null)
            {
                LocationViewModel.AdminLevel6List =
                    await CrossCuttingClient.GetGisLocationChildLevel(GetCurrentLanguage(),
                        Convert.ToString(LocationViewModel.AdminLevel5Value));
                if (LocationViewModel.AdminLevel6List != null && LocationViewModel.AdminLevel6List.Count > 0)
                {
                    LocationViewModel.AdminLevel6List = LocationViewModel.AdminLevel6List.OrderBy(x => x.Name).ToList();

                    if (LocationViewModel.OperationType != LocationViewOperationType.Edit && LocationViewModel.OperationType != LocationViewOperationType.ReadOnly)
                        LocationViewModel.EnableAdminLevel6 = true;
                    LocationViewModel.AdminLevel6LevelType =
                        LocationViewModel.AdminLevel6List.FirstOrDefault(l => l.LevelType != null)?.LevelType;
                    if (LocationViewModel.AdminLevel6LevelType != null)
                        await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel6List,
                            LocationViewModel.AdminLevel5Value);

                    LocationViewModel.AdminLevel6List.Insert(0,
                        new GisLocationChildLevelModel {idfsReference = null, idfsGISReferenceType = null, Name = ""});
                }
            }
            else
            {
                LocationViewModel.EnableAdminLevel6 = LocationViewModel.AdminLevel6Value != null;
            }
        }

        protected async Task RefreshAtAdminLevel6()
        {
            LocationViewModel.BottomAdminLevel = null;
            if (LocationViewModel.AdminLevel6Value != null && LocationViewModel.AdminLevel6List != null)
            {
                LocationViewModel.AdminLevel5Text = LocationViewModel.AdminLevel6List
                    .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel6Value)?.Name;


                LocationViewModel.AdminLevel6LevelType =
                    LocationViewModel.AdminLevel6List.FirstOrDefault(l =>
                        l.idfsReference == LocationViewModel.AdminLevel6Value) != null
                        ? LocationViewModel.AdminLevel6List
                            .FirstOrDefault(l => l.idfsReference == LocationViewModel.AdminLevel6Value)
                            ?.LevelType
                        : null;
                if (LocationViewModel.AdminLevel6LevelType != null)
                {
                    LocationViewModel.BottomAdminLevel = LocationViewModel.AdminLevel6Value;
                    SelectedBottomLevelList = LocationViewModel.AdminLevel6List;
                    SelectedBottomLevelNumber = 6;
                    await UpdateSettlementTypeAsync(LocationViewModel.AdminLevel6List,
                        LocationViewModel.AdminLevel6Value);
                    await FillStreetAsync();
                    await FillPostalCode();
                    RefreshAtBottom();
                    await LocationViewModelChanged.InvokeAsync(LocationViewModel);
                }
            }

            if (LocationViewModel.BottomAdminLevel == null) RefreshAtBottom();

            await LocationViewModelChanged.InvokeAsync(LocationViewModel);
        }

        private void RefreshAtBottom()
        {
            if (LocationViewModel.BottomAdminLevel != null)
            {
                LocationViewModel.EnableApartment = true;
                LocationViewModel.EnableBuilding = true;
                LocationViewModel.EnableHouse = true;
                LocationViewModel.EnableStreet = true;
                LocationViewModel.EnablePostalCode = true;
                LocationViewModel.EnableSettlementType = true;
            }
            else
            {
                LocationViewModel.StreetList = new List<StreetModel>();
                LocationViewModel.StreetText = null;
                LocationViewModel.EnableStreet = false;
                LocationViewModel.PostalCodeList = null;
                LocationViewModel.PostalCodeList = new List<PostalCodeViewModel>();
                LocationViewModel.PostalCodeText = null;
                LocationViewModel.EnablePostalCode = false;
                LocationViewModel.EnableApartment = false;
                LocationViewModel.EnableBuilding = false;
                LocationViewModel.EnableHouse = false;
                LocationViewModel.EnableSettlementType = false;
                LocationViewModel.SettlementType = null;
            }
        }

        protected async Task RefreshSettlementType()
        {
            LocationViewModel.BottomAdminLevel = null;
            LocationViewModel.AdminLevel3Value = null;
            //if (SelectedBottomLevelList != null)
            //{
            switch (SelectedBottomLevelNumber)
                {
                    case 0:
                        break;
                    case 1:
                        break;
                    case 2:
                        break;
                    case 3:
                        var filteredSettlementList = SelectedBottomLevelList;
                        if (LocationViewModel.SettlementType != -1 && LocationViewModel.SettlementType != null)
                            filteredSettlementList = SelectedBottomLevelList
                                .Where(s => s.LevelType == LocationViewModel.SettlementType).ToList();
                        LocationViewModel.AdminLevel3List = filteredSettlementList;
                        //if (LocationViewModel.SettlementType == null)
                            

                        //LocationViewModel.AdminLevel3List.Insert(0,
                        //    new GisLocationChildLevelModel
                        //    { idfsReference = null, idfsGISReferenceType = null, Name = "" });
                        if (DetailAdminHierarchyLevel ==0)
                        { 
                            await UpdateSettlementTypeAsync(filteredSettlementList, LocationViewModel.AdminLevel2Value);
                        }
                        
                        break;
                    case 4:
                        break;
                    case 5:
                        break;
                    case 6:
                        break;
                }
            //}
            //else
            //{
            //    //LocationViewModel.SettlementType
            //}
        }

        protected async Task FillSettlementType()
        {
            LocationViewModel.SettlementTypeList = await SettlementClient.GetSettlementTypeList(GetCurrentLanguage());
            if (LocationViewModel.SettlementTypeList != null)
            {
                if (LocationViewModel.ShowSettlementType || LocationViewModel.DivSettlementType)
                {
                    if (LocationViewModel.SettlementTypeList.Count > 1)
                    {
                        LocationViewModel.ShowSettlementType = true;
                        LocationViewModel.DivSettlementType = true;
                        LocationViewModel.DivSettlementGroup = true;
                    }
                    else
                    {
                        LocationViewModel.ShowSettlementType = false;
                        LocationViewModel.DivSettlementType = false;
                        LocationViewModel.DivSettlementGroup = false;
                    }
                }
            }
        }

        protected async Task UpdateSettlementTypeAsync(List<GisLocationChildLevelModel> bottomAdminLevelList,
            long? parentAdminLevelValue)
        {
            if (parentAdminLevelValue != null)
            {
                await FillSettlementType();

                if (bottomAdminLevelList.Count > 0 && LocationViewModel.SettlementTypeList != null)
                {
                    if (!LocationViewModel.AlwaysDisabled)
                        LocationViewModel.EnableSettlementType = true;

                    if (!bottomAdminLevelList.Any(s =>
                            s.LevelType.HasValue && s.LevelType.Value == Convert.ToInt64(SettlementTypes.Settlement)))
                        LocationViewModel.SettlementTypeList.RemoveAll(s =>
                            s.idfsReference == Convert.ToInt64(SettlementTypes.Settlement));
                    if (!bottomAdminLevelList.Any(s =>
                            s.LevelType.HasValue && s.LevelType.Value == Convert.ToInt64(SettlementTypes.Town)))
                        LocationViewModel.SettlementTypeList.RemoveAll(s =>
                            s.idfsReference == Convert.ToInt64(SettlementTypes.Town));
                    if (!bottomAdminLevelList.Any(s =>
                            s.LevelType.HasValue && s.LevelType.Value == Convert.ToInt64(SettlementTypes.Village)))
                        LocationViewModel.SettlementTypeList.RemoveAll(s =>
                            s.idfsReference == Convert.ToInt64(SettlementTypes.Village));
                    LocationViewModel.SettlementTypeList.Insert(0,
                        new SettlementTypeModel {idfsReference = -1, name =@Localizer.GetString(FieldLabelResourceKeyConstants.LocationAllFieldLabel) });
                    LocationViewModel.SettlementType = -1;

                    if (LocationViewModel.SettlementTypeList.Count < 2)
                    {
                        //LocationViewModel.EnableSettlementType = false;
                        //LocationViewModel.EnableSettlementType = false;

                        if (LocationViewModel.BottomAdminLevel != null)
                        {
                            var bAdminList = bottomAdminLevelList.FirstOrDefault(s =>
                                s.idfsReference == LocationViewModel.BottomAdminLevel);
                            if (bAdminList != null)
                            {
                                LocationViewModel.SettlementType = bottomAdminLevelList
                                    .FirstOrDefault(s => s.idfsReference == LocationViewModel.BottomAdminLevel)
                                    .LevelType;
                            }
                        }
                    }
                    else
                    {
                        if (!LocationViewModel.AlwaysDisabled)
                            LocationViewModel.EnableSettlementType = true;
                        if (LocationViewModel.SettlementType != -1)
                        {
                            if (LocationViewModel.BottomAdminLevel != null)
                                LocationViewModel.SettlementType = bottomAdminLevelList
                                    .FirstOrDefault(s => s.idfsReference == LocationViewModel.BottomAdminLevel)
                                    ?.LevelType;

                            LocationViewModel.Settlement =
                                LocationViewModel.SettlementId == null ? null : LocationViewModel.SettlementId;
                        }
                        else
                        {
                            //LocationViewModel.BottomAdminLevel = -1;
                        }
                    }
                }
                else
                {
                    LocationViewModel.SettlementType = null;
                    //LocationViewModel.DivSettlementType = false;
                    LocationViewModel.EnableSettlementType = false;
                }
            }
            else
            {
                LocationViewModel.SettlementType = null;
                //LocationViewModel.DivSettlementType = false;
                LocationViewModel.EnableSettlementType = false;

            }

            await InvokeAsync(StateHasChanged);
        }

        protected async Task RefreshAtStreet(object value)
        {
            if (value != null &&  value.ToString() != SelectedStreet)
            {
                var addedStreet = LocationViewModel.StreetList?.FirstOrDefault(s => s.StreetName == SelectedStreet);
                if (addedStreet != null)
                {
                    LocationViewModel.StreetList.Remove(addedStreet);
                }
            }
            await LocationViewModelChanged.InvokeAsync(LocationViewModel);
        }

        protected async Task RefreshAtPostalCode(object value)
        {
            if (value != null && value.ToString() != SelectedPostalCode)
            {
                var addedPostalCode = LocationViewModel.PostalCodeList.FirstOrDefault(s => s.PostalCodeString == SelectedPostalCode);
                if (addedPostalCode != null)
                {
                    LocationViewModel.PostalCodeList.Remove(addedPostalCode);
                }
            }
            await LocationViewModelChanged.InvokeAsync(LocationViewModel);
        }

        protected void OnFocusOut(FocusEventArgs args)
        {
        }

        protected void OnBlur(MouseEventArgs args)
        {
        }

        protected Task OnFilterKeyPress(KeyboardEventArgs args)
        {
            var key = args.Code ?? args.Key;
            if (args.Key == "Enter")
            {
                //call login or what ever you want when user pressed Enter
            }

            return Task.CompletedTask;
        }

        protected  async Task AddStreet()
        {
            var dialogParams = new Dictionary<string, object>
            {
                { "BottomAdminLevel", LocationViewModel.BottomAdminLevel }
            };

            var result = await DialogService.OpenAsync<AddStreetModal>(Localizer.GetString(HeadingResourceKeyConstants.PersonAddressModalHeading), 
               dialogParams,
               new DialogOptions() { Width = "700px", Height = "370px", Resizable = true, Draggable = false });

            if (LocationViewModel.BottomAdminLevel != null)
            {
                LocationViewModel.StreetList = await CrossCuttingClient.GetStreetList(LocationViewModel.BottomAdminLevel.Value);
            }

            return;
        }

        protected async Task AddPostalCode()
        {

            var dialogParams = new Dictionary<string, object>
            {
                { "BottomAdminLevel", LocationViewModel.BottomAdminLevel }
            };

            var result = await DialogService.OpenAsync<AddPostalCodeModal>(Localizer.GetString(HeadingResourceKeyConstants.PersonPostalCodeModalHeading),
               dialogParams,
               new DialogOptions() { Width = "700px", Height = "370px", Resizable = true, Draggable = false });

            if (LocationViewModel.BottomAdminLevel != null)
            {
                //LocationViewModel.PostalCodeList = await CrossCuttingClient.GetPostalCodeList(LocationViewModel.BottomAdminLevel.Value);
                await LoadPostalCode(new LoadDataArgs());
            }
        }

        protected void preventDefault(KeyboardEventArgs args)
        {
            if (args.Key == "Enter")
            {
                ShouldSubmit = false;
            }
        }

        protected async Task LoadStreet(LoadDataArgs args)
        {
            if (LocationViewModel.BottomAdminLevel != null)
            {
                LocationViewModel.StreetList =await CrossCuttingClient.GetStreetList(LocationViewModel.BottomAdminLevel.Value);
            }
            else
            {
                LocationViewModel.StreetList = new List<StreetModel>();
            }
                
            var query = LocationViewModel.StreetList;

            if (!string.IsNullOrEmpty(args.Filter))
            {
                //SelectedStreet = args.Filter;
                //query = query.Where(c => c.StreetName.ToLower()== args.Filter.ToLower()).ToList();
               query = query.Where(c => c.StreetName.ToLower().Contains(args.Filter.ToLower())).ToList();

                if (query.Count ==0 )
                {
                    ShowAddStreet = false;
                    SelectedStreet = args.Filter;

                    LocationViewModel.StreetList = query;
                }
                else
                {
                    LocationViewModel.StreetList = query;
                    ShowAddStreet = true;
                }
            }
            else
            {
                ShowAddStreet = true;
                LocationViewModel.StreetList = query;
            }

            await InvokeAsync(StateHasChanged);
        }

        protected async Task LoadPostalCode(LoadDataArgs args)
        {
            if (LocationViewModel.BottomAdminLevel != null)
            {
                LocationViewModel.PostalCodeList = await CrossCuttingClient.GetPostalCodeList(LocationViewModel.BottomAdminLevel.Value);
            }
            else
            {
                LocationViewModel.PostalCodeList = new List<PostalCodeViewModel>();
            }

            var query = LocationViewModel.PostalCodeList;

            if (!string.IsNullOrEmpty(args.Filter))
            {
                query = query.Where(c => c.PostalCodeString.ToLower().Contains(args.Filter.ToLower())).ToList();

                if (query.Count == 0)
                {
                    ShowAddPostalCode = false;
                    SelectedPostalCode = args.Filter;
                    LocationViewModel.PostalCodeList = query;
                }
                else
                {
                    LocationViewModel.PostalCodeList = query;
                }
            }
            else
            {
                ShowAddPostalCode = true;
                LocationViewModel.PostalCodeList = query;
            }

            await InvokeAsync(StateHasChanged);
        }

        protected void StreetOnEnter(EventArgs e)
        {
            Console.WriteLine("Firstname Component Focus In Handler" + e.ToString());
        }

        private async Task FillStreetAsync()
        {
            if (LocationViewModel.BottomAdminLevel != null)
            {
                LocationViewModel.StreetList =
                    await CrossCuttingClient.GetStreetList(LocationViewModel.BottomAdminLevel.Value);
                if (LocationViewModel.StreetList != null)
                {
                    if (LocationViewModel.StreetList.FirstOrDefault(s =>
                            s.StreetName == LocationViewModel.StreetText) ==
                        null)
                    {
                        LocationViewModel.StreetList = LocationViewModel.StreetList.OrderBy(x => x.StreetName).ToList();

                        LocationViewModel.StreetList.Insert(0,
                            new StreetModel {StreetID = "-1", StreetName = "", idfsLocation = -1});
                    }

                    StreetList = LocationViewModel.StreetList;
                }

                if (!LocationViewModel.AlwaysDisabled)
                    LocationViewModel.EnableStreet = true;

                // LocationViewModel.EnableStreet = true; // Enable the street drop down even when no streets exist in case the user wants to add a new street.
                LocationViewModel.StreetText ??= null;
            }
            else
            {
                LocationViewModel.StreetList = new List<StreetModel>();
                LocationViewModel.StreetText = null;
                LocationViewModel.EnableStreet = false;
                StreetList = LocationViewModel.StreetList;
            }
        }

        protected async Task RefreshAtHouse(object value)
        {
            await LocationViewModelChanged.InvokeAsync(LocationViewModel);
        }

        protected async Task RefreshAtBuilding(object value)
        {
            await LocationViewModelChanged.InvokeAsync(LocationViewModel);
        }

        protected async Task RefreshAtApartment(object value)
        {
            await LocationViewModelChanged.InvokeAsync(LocationViewModel);
        }

        private async Task FillPostalCode()
        {
            if (LocationViewModel.BottomAdminLevel != null)
            {
                LocationViewModel.PostalCodeList =
                    await CrossCuttingClient.GetPostalCodeList(LocationViewModel.BottomAdminLevel.Value);
                if (LocationViewModel.PostalCodeList.FirstOrDefault(s => s.PostalCodeString == LocationViewModel.StreetText) ==
                     null)
                {
                    LocationViewModel.PostalCodeList = LocationViewModel.PostalCodeList.OrderBy(x => x.PostalCodeString).ToList();

                    LocationViewModel.PostalCodeList.Insert(0, new PostalCodeViewModel { PostalCodeID = "-1", PostalCodeString = "", idfsLocation = -1 });
                }

                // Enable the postal code drop down even when no postal codes exist in case the user wants to add a new postal code.
                if (!LocationViewModel.AlwaysDisabled)
                    LocationViewModel.EnablePostalCode = true;
                LocationViewModel.PostalCodeText ??= null;
            }
            else
            {
                LocationViewModel.PostalCodeList = new List<PostalCodeViewModel>();
                LocationViewModel.PostalCodeText = null;
                LocationViewModel.EnablePostalCode = false;
            }
        }

        protected async Task<LatLong> GetParentLatLon(long adminLevel,bool checkForParentLevel=false)
        {
            try
            {
                var request = new AdministrativeUnitsSearchRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    Page = 1,
                    PageSize = 1,
                    SortColumn = "strNationalCountryName",
                    SortOrder = "asc",
                    idfsCountry = LocationViewModel.AdminLevel0Value,
                    idfsRegion = LocationViewModel.AdminLevel1Value,
                    idfsRayon = LocationViewModel.AdminLevel2Value,
                    idfsSettlement = LocationViewModel.AdminLevel3Value
                };

                if (LocationViewModel.AdminLevel3Value != null)
                {
                    request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel3Id;
                    if (checkForParentLevel)
                    {
                        //request.idfsSettlement = null;
                        //request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel2Id;
                    }
                    //request.idfsCountry = LocationViewModel.AdminLevel0Value;
                    //request.idfsRegion = LocationViewModel.AdminLevel1Value;
                    //request.idfsRayon = LocationViewModel.AdminLevel2Value;
                } else if (LocationViewModel.AdminLevel2Value != null)
                {
                    request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel2Id;

                    if (checkForParentLevel)
                    {
                        request.idfsSettlement = null;
                        //request.idfsRayon = null;
                        //request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel1Id;
                    }
                    request.idfsCountry = LocationViewModel.AdminLevel0Value;
                    request.idfsRegion = LocationViewModel.AdminLevel1Value;
                    request.idfsRayon = LocationViewModel.AdminLevel2Value;
                }
                else if (LocationViewModel.AdminLevel1Value != null)
                {
                    request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel1Id;
                    if (checkForParentLevel)
                    {
                        request.idfsSettlement = null;
                        request.idfsRayon = null;
                        //request.idfsRegion = null;
                        //request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel0Id;
                    }
                    request.idfsCountry = LocationViewModel.AdminLevel0Value;
                }
                else if (LocationViewModel.AdminLevel0Value != null)
                {
                    request.idfsSettlement = null;
                    request.idfsRayon = null;
                    request.idfsRegion = null;
                    request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel0Id;

                    //request.idfsCountry = LocationViewModel.AdminLevel0Value;
                }

                var latLon = new LatLong();
                
                var result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);

                if (result == null) return null;
                if (result.FirstOrDefault()?.Latitude == null || result.FirstOrDefault()?.Longitude == null)
                    return null;
                        

                if (result.FirstOrDefault()?.Latitude != null)
                {
                    latLon.lat = (float) result.FirstOrDefault()?.Latitude;
                }
                if (result.FirstOrDefault()?.Longitude != null)
                {
                    latLon.lon = (float) result.FirstOrDefault()?.Longitude;
                }

                return latLon;
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
                throw;

            }

           
        }

        protected async Task OnLongitudeChange(object value)
        {
            //var longitude = (double?)value;

            //if(longitude is not null && longitude >= 180)
            //{
            //    LocationViewModel.Longitude = 180;
            //}
            //else if(longitude is not null && longitude <= -180)
            //{
            //    LocationViewModel.Longitude = -180;
            //}
            //else
            //{
            //    LocationViewModel.Longitude = longitude;
            //}
            
            //await InvokeAsync(StateHasChanged);
        }

        protected async Task OnLatitudeChange(object value)
        {
            //var latitude = (double?)value;

            //if (latitude is not null && latitude >= 85)
            //{
            //    LocationViewModel.Latitude = 85;
            //}
            //else if (latitude is not null && latitude <= -85)
            //{
            //    LocationViewModel.Latitude = -85;
            //}
            //else
            //{
            //    LocationViewModel.Latitude = latitude;
            //}

            await InvokeAsync(StateHasChanged);
        }

        private async Task SetMapUrl()
        {
            var query = "";
            var zoom = "";
            LatLong latLong = null;
            var languageCulture = new CultureInfo(GetCurrentLanguage());
            var enLanguageCulture = new CultureInfo("en-US");

            if (LocationViewModel.Longitude == null || LocationViewModel.Latitude == null)
            {
                // Look up by location.
                query = $"{LocationViewModel.LeafletAPIUrl}api/?q=";
                if (LocationViewModel.AdminLevel3Value != null)
                {
                    latLong = await GetParentLatLon((long) AdministrativeLevelReferenceIds.AdminLevel3Id, true);
                    if (latLong == null)
                    {
                        if (LocationViewModel.AdminLevel3List.FirstOrDefault(a =>
                                a.idfsReference == LocationViewModel.AdminLevel3Value) != null)
                        {
                            LocationViewModel.AdminLevel3Text = LocationViewModel.AdminLevel3List
                                .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel3Value)
                                ?.Name;
                            query += LocationViewModel.AdminLevel3Text;
                            zoom = "12";
                        }
                    }
                    else
                    {
                        zoom = "12";
                        query = $"{LocationViewModel.LeafletAPIUrl}reverse?lat={latLong.lat.ToString(enLanguageCulture)}&lon={latLong.lon.ToString(enLanguageCulture)}";
                        lat = latLong.lat;
                        lan = latLong.lon;
                        LocationViewModel.MapUrl = query;
                        return;
                    }
                }

                if (LocationViewModel.AdminLevel2Value != null)
                {
                    latLong = await GetParentLatLon((long) AdministrativeLevelReferenceIds.AdminLevel2Id, true);
                    if (latLong == null)
                    {
                        if (LocationViewModel.AdminLevel2List.FirstOrDefault(a =>
                                a.idfsReference == LocationViewModel.AdminLevel2Value) != null)
                        {
                            LocationViewModel.AdminLevel2Text = LocationViewModel.AdminLevel2List
                                .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel2Value)
                                ?.Name;
                            if (query != $"{LocationViewModel.LeafletAPIUrl}api/?q=")
                                query += "+";

                            query += LocationViewModel.AdminLevel2Text;
                            zoom = "10";
                        }
                    }
                    else
                    {
                        zoom = "10";
                        query = LocationViewModel.LeafletAPIUrl + "reverse?lat=" +
                                 latLong.lat.ToString(enLanguageCulture) + "&lon=" +
                                 latLong.lon.ToString(enLanguageCulture);
                        LocationViewModel.MapUrl = query;
                        lat = latLong.lat;
                        lan = latLong.lon;
                        return;
                    }
                }


                if (LocationViewModel.AdminLevel1Value != null)
                {
                    latLong = await GetParentLatLon((long) AdministrativeLevelReferenceIds.AdminLevel1Id, true);
                    if (latLong == null)
                    {
                        if (LocationViewModel.AdminLevel1List.FirstOrDefault(a =>
                                a.idfsReference == LocationViewModel.AdminLevel1Value) != null)
                        {
                            LocationViewModel.AdminLevel1Text = LocationViewModel.AdminLevel1List
                                .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel1Value)
                                ?.Name;
                            // Do not include "Other Rayons" as the mapping API will not recognize it.
                            if (LocationViewModel.AdminLevel1Text?.ToLower() != OTHER_RAYONS)
                            {
                                if (query != $"{LocationViewModel.LeafletAPIUrl}api/?q=")
                                    query += "+";
                                query += LocationViewModel.AdminLevel1Text;
                                zoom = "8";
                            }
                        }
                    }
                    else
                    {
                        zoom = "8";
                        query = LocationViewModel.LeafletAPIUrl + "reverse?lat=" +
                                 latLong.lat.ToString(enLanguageCulture) + "&lon=" +
                                 latLong.lon.ToString(enLanguageCulture);
                        lat = latLong.lat;
                        lan = latLong.lon;

                        LocationViewModel.MapUrl = query;
                        return;
                    }
                }

                if (LocationViewModel.AdminLevel0Value != null)
                {

                    latLong = await GetParentLatLon((long) AdministrativeLevelReferenceIds.AdminLevel0Id, true);
                    if (latLong == null)
                    {

                        LocationViewModel.AdminLevel0Text = LocationViewModel.AdminLevel0List
                            .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel0Value)
                            ?.Name;
                        if (query != $"{LocationViewModel.LeafletAPIUrl}api/?q=")
                            query += "+";
                        query += LocationViewModel.AdminLevel0Text;
                        if (query == $"{LocationViewModel.LeafletAPIUrl}api/?q="+ LocationViewModel.AdminLevel0Text)
                        {
                            query += query + "&osm_tag=place:country";
                        }
                    }
                    else
                    {
                        zoom = "6";
                        query = LocationViewModel.LeafletAPIUrl + "reverse?lat=" +
                                 latLong.lat.ToString(enLanguageCulture) + "&lon=" +
                                 latLong.lon.ToString(enLanguageCulture);
                        LocationViewModel.MapUrl = query;
                        lat = latLong.lat;
                        lan = latLong.lon;

                        return;
                    }

                }
            }
            else
            {
                // Reverse look up by latitude and longitude
                zoom = "12";
                if (LocationViewModel.Longitude != null)
                    if (LocationViewModel.Latitude != null)
                        query += LocationViewModel.LeafletAPIUrl + "reverse?lat=" +
                                 LocationViewModel.Latitude.Value.ToString(enLanguageCulture) + "&lon=" +
                                 LocationViewModel.Longitude.Value.ToString(enLanguageCulture);
                lat = (float) LocationViewModel.Latitude;
                lan = (float) LocationViewModel.Longitude;

                LocationViewModel.MapUrl = query;
                return;
            }

            LocationViewModel.MapUrl = query;
            LocationViewModel.Zoom = zoom;
        }

        private void SetDefaultMapUrl()
        {
            var zoom = "";

            // Look up by location.
            var query = $"{LocationViewModel.LeafletAPIUrl}api/?q=";
            //if (LocationViewModel.AdminLevel3Value != null)
            //    if (LocationViewModel.AdminLevel3List.FirstOrDefault(a =>
            //            a.idfsReference == LocationViewModel.AdminLevel3Value) != null)
            //    {
            //        LocationViewModel.AdminLevel3Text = LocationViewModel.AdminLevel3List
            //            .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel3Value)
            //            ?.Name;
            //        query += LocationViewModel.AdminLevel3Text;
            //        zoom = "12";
            //    }

            //if (LocationViewModel.AdminLevel3Value != null)
            //    if (LocationViewModel.AdminLevel2List.FirstOrDefault(a =>
            //            a.idfsReference == LocationViewModel.AdminLevel2Value) != null)
            //    {
            //        LocationViewModel.AdminLevel2Text = LocationViewModel.AdminLevel2List
            //            .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel2Value)
            //            ?.Name;
            //        if (query != "")
            //            query += "+";

            //        query += LocationViewModel.AdminLevel2Text;

            //        if (zoom == "")
            //            zoom = "10";
            //    }

            //if (LocationViewModel.AdminLevel1Value != null)
            //    if (LocationViewModel.AdminLevel1List.FirstOrDefault(a =>
            //            a.idfsReference == LocationViewModel.AdminLevel1Value) != null)
            //    {
            //        LocationViewModel.AdminLevel1Text = LocationViewModel.AdminLevel1List
            //            .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel1Value)
            //            ?.Name;
            //        // Do not include "Other Rayons" as the mapping API will not recognize it.
            //        if (LocationViewModel.AdminLevel1Text?.ToLower() != OTHER_RAYONS)
            //        {
            //            if (query != "")
            //                query += "+";

            //            query += LocationViewModel.AdminLevel1Text;

            //            if (zoom == "")
            //                zoom = "8";
            //        }
            //    }

            if (query == $"{LocationViewModel.LeafletAPIUrl}api/?q=")
                if (LocationViewModel.AdminLevel0Value != null)
                {
                    LocationViewModel.AdminLevel0Text = LocationViewModel.AdminLevel0List
                        .FirstOrDefault(a => a.idfsReference == LocationViewModel.AdminLevel0Value)
                        ?.Name;
                    query += LocationViewModel.AdminLevel0Text + "&osm_tag=place:country&zoom=16&location_bias_scale=0.5";
                    zoom = "8";
                }

            // Close out JavaScript variable for query and add the zoom variable.

            _defaultPhotonUrl = query;
            LocationViewModel.Zoom = zoom;
        }

        internal void OnChangeAdmin1(object value)
        {
            var str = value is IEnumerable<object> objects ? string.Join(", ", objects) : value;
        }

        protected async Task ShowMapAsync()
        {
            await SetMapUrl();
            SetDefaultMapUrl();

            _photonUrl = LocationViewModel.MapUrl;
            
            
             var flag = await JsRuntime.InvokeAsync<bool>("GetLatLongForLeaflet", token, _photonUrl, _defaultPhotonUrl, lat, lan, DotNetObjectReference.Create(this));

            //var response= await Http.GetAsync(_photonUrl).hea;

            //var result = await jsClass.GetLatLongForLeaflet(_photonUrl,js);
        }

        [JSInvokable]
        public async Task<bool> SetMessage(string latlong)
        {
            _latLong = System.Text.Json.JsonSerializer.Deserialize<LatLong>(latlong);

            var dialogParams = new Dictionary<string, object>
            {
                { nameof(_photonUrl), _photonUrl },
                { nameof(LatLong), _latLong },
                { "UpdateLatLong", UpdateLatLongHandler }
            };

            //LocationViewModel.Latitude = _latLong.lat;
            //LocationViewModel.Longitude = _latLong.lon;
            await InvokeAsync(StateHasChanged);

            //await DiagService.OpenAsync<EIDSS.Web.Components.Leaflet.LeafletMapBase>("Show Map", dialogParams);

            await DiagService.OpenAsync<LeafletMap>(Localizer.GetString(HeadingResourceKeyConstants.LocationSetLocationHeading), 
                dialogParams, new DialogOptions() { Width = "650px", Resizable = false, Draggable = false });
          
            return true;
        }

        private EventCallback UpdateLatLongHandler => new(this, (Action<LatLong>)((LatLong latLong) =>
        {
            UpdateLong(latLong);
        }));

        public void UpdateLong(LatLong latLong)
        {
            LocationViewModel.Latitude = latLong.lat;
            LocationViewModel.Longitude = latLong.lon;
        }

        private EventCallback ReloadEventWrapper => new(null, (Action)(async () =>
        {
            await InvokeAsync(StateHasChanged);
        }));

        public async Task Save()
        {
            LocationViewModel.AdminLevel3Value = null;
            LocationViewModel.EnableAdminLevel3 = false;
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #endregion 
    }
}