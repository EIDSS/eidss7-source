using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Areas.Administration.ViewModels.Administration;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using EIDSS.Web.Components.Shared;
using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.AspNetCore.WebUtilities;
using System.Web;
using static System.String;

namespace EIDSS.Web.Components.Administration.AdministrativeUnits
{
    public class SearchAdministrativeUnitsBase : BaseComponent, IDisposable
    {

        #region Dependency Injectiion

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ILogger<SearchAdministrativeUnitsBase> Logger { get; set; }

        [Inject]
        private ISiteClient SiteClient { get; set; }

        [Inject]
        private IAdministrativeUnitsClient AdministrativeUnitsClient { get; set; }

        #endregion

        #region Parameters

        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public long? CallbackKey { get; set; }


        #endregion

        #region Protected and Public Fields

        protected RadzenDataGrid<AdministrativeUnitsGetListViewModel> Grid;
        protected RadzenTemplateForm<AdministrativeUnitsPageViewModel> Form;
        protected AdministrativeUnitsPageViewModel Model;
        protected IEnumerable<BaseReferenceViewModel> AdminLevelUnits;
        protected IEnumerable<BaseReferenceViewModel> AdminLevelUnits1;

        protected IEnumerable<AdministrativeUnitsGetListViewModel> SearchResults { get; set; }
        protected int SearchResultCount;
        protected LocationViewModel SearchLocationViewModel { get; set; }
        protected bool shouldRender = true;
        protected int AdminLevelCount;
        protected int AdminLevelCount1;
        protected bool IsLoading;
        protected bool ShowCancelButton;
        protected bool ShowAddButton;
        protected bool DisableAddButton;
        protected bool DisableEditButton;
        protected bool DisableDeleteButton;


        protected bool ShowClearButton;
        protected bool ShowSearchButton;
        protected bool showSearchResults;

        protected bool ExpandSearchCriteria;
        protected bool ExpandSearchResults;
        protected bool ShowCriteria;
        protected bool ShowResults;
        protected UserPermissions Permissions;

        public LocationViewBase LocationViewComponent;

        #endregion

        #region Private Fields and Properties

        private bool _searchSubmitted;
        private CancellationTokenSource _source;
        private CancellationToken _token;


        #endregion

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            try
            {
                await base.OnInitializedAsync();
                _logger = Logger;

                Model = new AdministrativeUnitsPageViewModel()
                {
                    SearchCriteria = new AdministrativeUnitsSearchRequestModel(),
                    Permissions = Permissions,
                    RecordSelectionIndicator = true,
                    SearchLocationViewModel = new LocationViewModel()
                };

                Permissions = GetUserPermissions(ClientLibrary.Enumerations.PagePermission.CanManageGISReferenceTables);
                DisableAddButton = !Permissions.Create;
                DisableEditButton = !Permissions.Write;
                DisableDeleteButton = !Permissions.Delete;

                AdminLevelUnits1 = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    EIDSSConstants.BaseReferenceConstants.AdministrativeLevel, EIDSSConstants.HACodeList.NoneHACode);
                AdminLevelUnits1 = AdminLevelUnits1.OrderBy(a => a.IntOrder);
                var baseReferenceViewModels = AdminLevelUnits1.ToList();
                AdminLevelCount1 = baseReferenceViewModels.ToList().Count;

                //reset the cancellation token
                _source = new();
                _token = _source.Token;

                showSearchResults = false;

                //wire up dialog events
                DiagService.OnClose += DialogClose;

                SearchLocationViewModel = new LocationViewModel
                {
                    ShowAdminLevel0 = false,
                    ShowAdminLevel1 = false,
                    ShowAdminLevel2 = false,
                    ShowAdminLevel3 = false,
                    ShowAdminLevel4 = false,
                    ShowAdminLevel5 = false,
                    ShowAdminLevel6 = false,
                    ShowStreet = false,
                    ShowPostalCode = false,
                    ShowLatitude = false,
                    ShowLongitude = false,
                    ShowElevation = false,
                    ShowMap = false
                };

                for (var i = 1; i <= AdminLevelCount1; i++)
                {
                    switch (i)
                    {
                        case 1:
                            SearchLocationViewModel.ShowAdminLevel0 = true;
                            break;
                        case 2:
                            SearchLocationViewModel.ShowAdminLevel1 = true;
                            break;
                        case 3:
                            SearchLocationViewModel.ShowAdminLevel2 = true;
                            break;
                        case 4:
                            SearchLocationViewModel.ShowAdminLevel3 = true;
                            break;
                        case 5:
                            SearchLocationViewModel.ShowAdminLevel4 = true;
                            break;
                        case 6:
                            SearchLocationViewModel.ShowAdminLevel5 = true;
                            break;
                        case 7:
                            SearchLocationViewModel.ShowAdminLevel6 = true;
                            break;
                    }
                }

                SearchLocationViewModel.ShowSettlement = false;
                SearchLocationViewModel.ShowSettlementType = false;



                InitializeModel(false, baseReferenceViewModels.Last().IdfsBaseReference);

                IsLoading = false;

                //set up the accordions
                ExpandSearchCriteria = true;
                ExpandSearchResults = false;
                showSearchResults = false;
                SetButtonStates();


            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }



        }



        #endregion

        #region Protected Methods and Delegates

        protected async Task GetAdminLevelUnitsAsync(LoadDataArgs args)
        {
            AdminLevelUnits = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                EIDSSConstants.BaseReferenceConstants.AdministrativeLevel, EIDSSConstants.HACodeList.NoneHACode);
            AdminLevelUnits = AdminLevelUnits
                .Where(r => r.IdfsBaseReference != (long)AdministrativeLevelReferenceIds.AdminLevel0Id).OrderBy(r => r.IntOrder);
            var baseReferenceViewModels = AdminLevelUnits.ToList();
            if (!baseReferenceViewModels.Exists(a => a.IdfsBaseReference == 0))
            {
                baseReferenceViewModels.Insert(0, new BaseReferenceViewModel()
                {
                    IdfsBaseReference = 0,
                    IdfsReferenceType = 0,
                    IntRowStatus = 0,
                    IntOrder = -1,
                    StrDefault = ""
                });
            }

            AdminLevelUnits = baseReferenceViewModels;

           if (!IsNullOrEmpty(args.Filter))
                AdminLevelUnits = AdminLevelUnits.Where(c => c.Name != null && c.Name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase));

            await InvokeAsync(StateHasChanged);
        }

        protected void RefreshAdminUnits(object value)
        {
           

            var adminLevelValue = value as long?;

            Model.SearchCriteria.idfsAdminLevel = adminLevelValue == 0 ? null : adminLevelValue;

            SearchLocationViewModel.AdministrativeLevelId = adminLevelValue;

            SearchLocationViewModel.AdministrativeLevelEnabled = true;
            SearchLocationViewModel.IsDbRequiredAdminLevel0 = false;
            SearchLocationViewModel.IsDbRequiredAdminLevel1 = false;
            SearchLocationViewModel.IsDbRequiredAdminLevel2 = false;


            FillSettingsAsync(adminLevelValue);

            switch (Model.SearchCriteria.idfsAdminLevel)
            {
                case (long?)AdministrativeLevelReferenceIds.AdminLevel0Id:
                    SearchLocationViewModel.IsHorizontalLayout = true;
                    SearchLocationViewModel.EnableAdminLevel0 = true;
                    SearchLocationViewModel.EnableAdminLevel1 = false;
                    SearchLocationViewModel.EnableAdminLevel2 = false;
                    SearchLocationViewModel.EnableAdminLevel3 = false;
                    SearchLocationViewModel.AdminLevel0Value = Model.SearchCriteria.idfsCountry;
                    SearchLocationViewModel.AdminLevel1Value = Model.SearchCriteria.idfsRegion;
                    break;

                case (long?)AdministrativeLevelReferenceIds.AdminLevel1Id:
                    SearchLocationViewModel.IsHorizontalLayout = true;
                    SearchLocationViewModel.EnableAdminLevel0 = true;
                    SearchLocationViewModel.EnableAdminLevel1 = true;
                    SearchLocationViewModel.EnableAdminLevel2 = false;
                    SearchLocationViewModel.EnableAdminLevel3 = false;
                    SearchLocationViewModel.AdminLevel2List = null;
                    SearchLocationViewModel.AdminLevel3List = null;
                    SearchLocationViewModel.SettlementType = null;
                    SearchLocationViewModel.EnableSettlementType = false;

                    SearchLocationViewModel.AdminLevel0Value = Model.SearchCriteria.idfsCountry;
                    SearchLocationViewModel.AdminLevel1Value = Model.SearchCriteria.idfsRegion;
                    break;

                case (long?)AdministrativeLevelReferenceIds.AdminLevel2Id:
                    SearchLocationViewModel.IsHorizontalLayout = true;
                    SearchLocationViewModel.EnableAdminLevel0 = true;
                    SearchLocationViewModel.EnableAdminLevel1 = true;
                    SearchLocationViewModel.EnableAdminLevel2 = true;
                    SearchLocationViewModel.EnableAdminLevel3 = false;
                    SearchLocationViewModel.EnableSettlementType = false;
                    SearchLocationViewModel.SettlementType = -1;
                    SearchLocationViewModel.AdminLevel0Value = Model.SearchCriteria.idfsCountry;
                    SearchLocationViewModel.AdminLevel1Value = Model.SearchCriteria.idfsRegion;
                    SearchLocationViewModel.AdminLevel2Value = Model.SearchCriteria.idfsRayon;
                    break;

                case (long?)AdministrativeLevelReferenceIds.AdminLevel3Id:
                case null:
                    SearchLocationViewModel.IsHorizontalLayout = true;
                    SearchLocationViewModel.EnableAdminLevel0 = true;
                    SearchLocationViewModel.EnableAdminLevel1 = true;
                    SearchLocationViewModel.EnableAdminLevel2 = true;
                    SearchLocationViewModel.EnableAdminLevel3 = true;
                    SearchLocationViewModel.ShowSettlementType = true;
                    SearchLocationViewModel.AdminLevel0Value = Model.SearchCriteria.idfsCountry;
                    SearchLocationViewModel.AdminLevel1Value = Model.SearchCriteria.idfsRegion;
                    SearchLocationViewModel.AdminLevel2Value = Model.SearchCriteria.idfsRayon;
                    SearchLocationViewModel.AdminLevel3Value = Model.SearchCriteria.idfsSettlement;
                    break;

            }

        

            Model.SearchLocationViewModel = SearchLocationViewModel;

           // LocationViewComponent.Save();

        }

        protected void ReloadAdministrativeSearch(object value)
        {
            if (value != null)
            {
                InitializeModel(false, null);
            }
        }

        protected async Task LoadData(LoadDataArgs args)
        {
            if (_searchSubmitted)
            {
                try
                {
                    IsLoading = true;
                    showSearchResults = true;

                    var request = new AdministrativeUnitsSearchRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        DefaultName = Model.SearchCriteria.DefaultName,
                        NationalName = Model.SearchCriteria.NationalName
                    };

                    //paging
                    if (args.Skip.HasValue && args.Skip.Value > 0)
                    {
                        request.Page = (args.Skip.Value / Grid.PageSize) + 1;
                    }
                    else
                    {
                        request.Page = 1;
                    }

                    request.PageSize = Grid.PageSize != 0 ? Grid.PageSize : 10;
                    //sorting
                    var sortColumn = "strNationalCountryName";
                    if (Model.SearchCriteria.idfsAdminLevel != null)
                    {
                        switch (Model.SearchCriteria.idfsAdminLevel)
                        {
                            case (long?)AdministrativeLevelReferenceIds.AdminLevel0Id:
                                sortColumn = "strNationalCountryName";
                                break;
                            case (long?)AdministrativeLevelReferenceIds.AdminLevel1Id:
                                sortColumn = "strNationalRegionName";
                                break;
                            case (long?)AdministrativeLevelReferenceIds.AdminLevel2Id:
                                sortColumn = "strNationalRayonName";
                                break;
                            case (long?)AdministrativeLevelReferenceIds.AdminLevel3Id:
                                sortColumn = "strNationalSettlementName";
                                break;
                            default:
                                sortColumn = "strNationalCountryName";
                                break;
                        }
                    }

                    request.SortColumn = !string.IsNullOrEmpty(args.OrderBy) ? args.OrderBy : sortColumn;
                    request.SortOrder = "asc";
                    request.idfsAdminLevel = Model.SearchCriteria.idfsAdminLevel;
                    request.idfsCountry = Model.SearchLocationViewModel.AdminLevel0Value;
                    request.idfsRegion = Model.SearchLocationViewModel.AdminLevel1Value;
                    request.idfsRayon = Model.SearchLocationViewModel.AdminLevel2Value;
                    request.idfsSettlement = Model.SearchLocationViewModel.AdminLevel3Value;

                    if (Model.SearchLocationViewModel.SettlementType == null || Model.SearchLocationViewModel.SettlementType == -1)
                    {
                        request.idfsSettlementType = null;
                    }
                    else
                    {
                        request.idfsSettlementType = Model.SearchLocationViewModel.SettlementType;
                    }

                    request.LatitudeFrom = Model.SearchCriteria.LatitudeFrom;
                    request.LatitudeTo = Model.SearchCriteria.LatitudeTo;
                    request.LongitudeFrom = Model.SearchCriteria.LongitudeFrom;
                    request.LongitudeTo = Model.SearchCriteria.LongitudeTo;
                    request.ElevationFrom = Model.SearchCriteria.ElevationFrom;
                    request.ElevationTo = Model.SearchCriteria.ElevationTo;

                    if (request.idfsAdminLevel != null)
                    {
                        request.AdminstrativeLevelValue = AdminLevelUnits.Where(r => r.IdfsBaseReference == request.idfsAdminLevel.Value).FirstOrDefault().Name;
                    }

                    var result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);
                    if(request.idfsAdminLevel == null)
                    {
                        result.ForEach(x => {
                            x.AdministrativeLevelId = x.idfsSettlement != null ? 10003004 : x.idfsRayon != null ? 10003002
                                : x.idfsRegion != null ? 10003003 : x.idfsCountry != null ? 10003001 : null;
                        });
                        result.ForEach(x => {
                            x.AdministrativeLevelValue = AdminLevelUnits.Where(r => r.IdfsBaseReference == x.AdministrativeLevelId).FirstOrDefault().Name;
                        });
                    }
                    if (result != null)
                    {
                        result.Where(r => r.NationalCountryName != null).ToList().ForEach(r =>
                        {
                            r.NationalName = r.NationalCountryName;
                            r.DefaultName = r.DefaultCountryName;
                        });
                    result.Where(r => r.NationalRegionName != null).ToList().ForEach(r =>
                    {
                        r.NationalName = r.NationalRegionName;
                        r.DefaultName = r.DefaultRegionName;
                    });
                    result.Where(r => r.NationalRayonName != null).ToList().ForEach(r =>
                    {
                        r.NationalName = r.NationalRayonName;
                        r.DefaultName = r.DefaultRayonName;
                    });


                    result.Where(r => r.NationalSettlementName != null).ToList().ForEach(r =>
                        {
                            r.NationalName = r.NationalSettlementName;
                            r.DefaultName = r.DefaultSettlementName;
                        });

                    SearchResults = result;
                    SearchResultCount = SearchResults.FirstOrDefault() != null ? SearchResults.First().TotalRowCount : 0;


                    //switch (request.idfsAdminLevel.Value)
                    //{
                    //    case (long)AdministrativeLevelReferenceIds.AdminLevel0Id:

                    //        result.Where(r => r.AdministrativeLevelId.Value == (long) AdministrativeLevelReferenceIds.AdminLevel0Id).ToList().ForEach(r =>
                    //        {
                    //            r.DefaultName = r.DefaultCountryName;
                    //            r.NationalName = r.NationalCountryName;
                    //         });
                    //        break;

                    //    case (long)AdministrativeLevelReferenceIds.AdminLevel1Id:

                    //        result.Where(r => r.AdministrativeLevelId.Value == (long)AdministrativeLevelReferenceIds.AdminLevel1Id).ToList().ForEach(r =>
                    //        {
                    //            r.DefaultName = r.DefaultRegionName;
                    //            r.NationalName = r.NationalRegionName;
                    //        });
                    //        break;

                    //    case (long)AdministrativeLevelReferenceIds.AdminLevel2Id:

                    //        result.Where(r => r.AdministrativeLevelId.Value == (long)AdministrativeLevelReferenceIds.AdminLevel2Id).ToList().ForEach(r =>
                    //        {
                    //            r.DefaultName = r.DefaultRayonName;
                    //            r.NationalName = r.NationalRayonName;
                    //        });
                    //        break;

                    //    case (long)AdministrativeLevelReferenceIds.AdminLevel3Id:

                    //        result.Where(r => r.AdministrativeLevelId.Value == (long)AdministrativeLevelReferenceIds.AdminLevel3Id).ToList().ForEach(r =>
                    //        {
                    //            r.DefaultName = r.DefaultSettlementName;
                    //            r.NationalName = r.NationalSettlementName;
                    //        });
                    //        break;

                    //    default:
                    //        break;
                    //}
                    }
                }
                catch (Exception e)
                {
                    _logger.LogError(e, e.Message);
                    //catch cancellation or timeout exception
                    if (e.HResult == -2146233088 || _source?.IsCancellationRequested == true)
                    {
                        await ShowNarrowSearchCriteriaDialog();
                    }
                }
                finally
                {
                    IsLoading = false;
                    await InvokeAsync(StateHasChanged);
                }
            }
            else
            {
                //initialize the grid so that it displays 'No records message'
                SearchResults = new List<AdministrativeUnitsGetListViewModel>();
                SearchResultCount = 0;
                IsLoading = false;
            }
        }

        protected async Task HandleValidSearchSubmit(AdministrativeUnitsPageViewModel model)
        {

            if (Form.IsValid && !NoCriteria(model))
            {
                _searchSubmitted = true;
                ShowResults = true;
                ExpandSearchResults = true;
                ExpandSearchCriteria = false;
                ShowCriteria = false;
                SetButtonStates();

                if (Grid != null)
                {
                    await Grid.Reload();
                }
            }
            else
            {
                //no search criteria entered - display the EIDSS dialog component
                _searchSubmitted = false;
                await ShowNoSearchCriteriaDialog();
            }
            
        }

        protected void EnterKeyPress(Microsoft.AspNetCore.Components.Web.KeyboardEventArgs e)
        {
            if ((e.Code == "Enter" || e.Code == "NumpadEnter") && ShowSearchButton)
            {
                Form.EditContext.Validate();
            }
        }

        protected void OpenEdit(AdministrativeUnitsGetListViewModel model)
        {
            //get the unique id based adminlevel
            //add parameter

            var nationalName = "";
            var defaultName = "";
            var strHASC = "";
            var strCode = "";
            long? settlementType = null;

            switch (model.AdministrativeLevelId)
            {
                case (long?)AdministrativeLevelReferenceIds.AdminLevel1Id:
                    nationalName = model.NationalRegionName;
                    defaultName = model.DefaultRegionName;
                    strHASC= model.strRegionHASC;
                    strCode = model.strRegionCode;
                    settlementType = null;

                    break;
                case (long?)AdministrativeLevelReferenceIds.AdminLevel2Id:
                    nationalName = model.NationalRayonName;
                    defaultName = model.DefaultRayonName;
                    strHASC = model.strRayonHASC;
                    strCode = model.strRayonCode;
                    settlementType = null;


                    break;
                case (long?)AdministrativeLevelReferenceIds.AdminLevel3Id:
                    nationalName = model.NationalSettlementName;
                    defaultName = model.DefaultSettlementName;
                    strHASC = model.strSettlementHASC;
                    strCode = model.strSettlementCode;
                    settlementType = model.idfsSettlementType;



                    break;
            }

            var query = new Dictionary<string, string?> { 
                { "adminLevelId", model.AdministrativeLevelId.ToString() },
                { "admin0Id", model.idfsCountry != null ?  model.idfsCountry.ToString() :null},
                { "admin1Id", model.idfsRegion != null ?  model.idfsRegion.ToString() :null},
                { "admin2Id", model.idfsRayon != null ? model.idfsRayon.ToString(): null},
                { "admin3Id", model.idfsSettlement!= null ? model.idfsSettlement.ToString():null },
                { "nationalName",HttpUtility.UrlEncode( nationalName) },
                { "defaultName", HttpUtility.UrlEncode(defaultName) },
                { "latitude", model.Latitude.ToString() },
                { "longitude", model.Longitude.ToString() },
                { "elevation", model.Elevation.ToString() },
                { "strHasc", HttpUtility.UrlEncode(strHASC) },
                { "strCode", HttpUtility.UrlEncode(strCode) },
                { "settlementType", settlementType != null ? settlementType.ToString():null },



            };
            NavManager.NavigateTo(QueryHelpers.AddQueryString("Administration/AdministrativeUnits/Details", query), forceLoad: true);


        }

        protected async Task DeleteAdminUnitAsync(AdministrativeUnitsGetListViewModel model)
        {
            List<DialogButton> buttons = new();
            DialogButton yesButton = new()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                ButtonType = DialogButtonType.Yes
            };
            buttons.Add(yesButton);
            DialogButton noButton = new()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                ButtonType = DialogButtonType.No
            };
            buttons.Add(noButton);

            Dictionary<string, object> dialogParams = new()
            {
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage) }
            };

            dynamic result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

            if (result == null)
                return;

            if (result is DialogReturnResult)
            {
                if (result is DialogReturnResult)
                    if ((result as DialogReturnResult).ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close(result);

                        long? idfsLocatinId = null;

                        switch (model.AdministrativeLevelId)
                        {
                            case (long?)AdministrativeLevelReferenceIds.AdminLevel1Id:
                                idfsLocatinId = model.idfsRegion.Value;

                                break;
                            case (long?)AdministrativeLevelReferenceIds.AdminLevel2Id:
                                idfsLocatinId = model.idfsRayon.Value;
                                break;
                            case (long?)AdministrativeLevelReferenceIds.AdminLevel3Id:
                                idfsLocatinId = Convert.ToInt64(model.idfsSettlement);
                                break;
                        }
                        var delResult = await AdministrativeUnitsClient.DeleteAdministrativeUnit(idfsLocatinId.Value, authenticatedUser.UserName);
                        if (delResult.ReturnCode == 0)
                        {
                            List<DialogButton> dialogbuttons = new();
                            DialogButton okButton = new()
                            {
                                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                                ButtonType = DialogButtonType.OK
                            };
                            dialogbuttons.Add(okButton);

                            Dictionary<string, object> successDialogParams = new()
                            {
                                { nameof(EIDSSDialog.DialogButtons), dialogbuttons },
                                { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.RecordDeletedSuccessfullyMessage) }
                            };
                            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSSuccessModalHeading), successDialogParams);
                            NavManager.NavigateTo($"Administration/AdministrativeUnits", true);
                        }
                        
                        else if (delResult.ReturnCode == -1)
                        {
                            List<DialogButton> dialogbuttons = new();
                            DialogButton okButton = new()
                            {
                                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                                ButtonType = DialogButtonType.OK
                            };
                            dialogbuttons.Add(okButton);

                            Dictionary<string, object> successDialogParams = new()
                            {
                                { nameof(EIDSSDialog.DialogButtons), dialogbuttons },
                                { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.UnableToDeleteBecauseOfChildRecordsMessage) }
                            };
                            await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), successDialogParams);
                        }
                    }
            }
        }

        private bool NoCriteria(AdministrativeUnitsPageViewModel model)
        {
            PropertyInfo[] properties = model.SearchCriteria.GetType().GetProperties().Where(p => p.DeclaringType != typeof(BaseGetRequestModel)).ToArray();

            foreach (var prop in properties)
            {
                if (prop.GetValue(model.SearchCriteria) != null)
                    return false;
            }

            //Check the location
            if (model.SearchLocationViewModel.AdminLevel3Value.HasValue ||
                model.SearchLocationViewModel.AdminLevel2Value.HasValue ||
                model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                return false;

            //Check the location of exposure
            if (model.SearchLocationViewModel.AdminLevel3Value.HasValue ||
                model.SearchLocationViewModel.AdminLevel2Value.HasValue ||
                model.SearchLocationViewModel.AdminLevel1Value.HasValue)
                return false;

            return true;
        }

        protected async Task HandleInvalidSearchSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                //TODO - display the validation Errors on the dialog?  
                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.FieldIsInvalidValidRangeIsMessage));
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception)
            {
                throw;
            }
        }

        #endregion

        #region Protected Methods and Delegates
        protected void RefreshLocationViewModelHandlerAsync(LocationViewModel locationViewModel)
        {
            Model.SearchLocationViewModel = locationViewModel;


            Model.SearchCriteria.idfsCountry = Model.SearchLocationViewModel.AdminLevel0Value;
            Model.SearchCriteria.idfsRegion = Model.SearchLocationViewModel.AdminLevel1Value;
            Model.SearchCriteria.idfsRayon = Model.SearchLocationViewModel.AdminLevel2Value;
            Model.SearchCriteria.idfsSettlement = Model.SearchLocationViewModel.AdminLevel3Value;
            Model.SearchCriteria.idfsAdminLevel = Model.SearchLocationViewModel.AdministrativeLevelId;

        }

        protected void ResetSearch()
        {
            //initialize new model with defaults
            InitializeModel(true, null);

            //set grid for not loaded
            IsLoading = false;

            //reset the cancellation token
            _source = new();
            _token = _source.Token;

            //set up the accordions and buttons
            _searchSubmitted = false;
            ShowCriteria = true;
            ExpandSearchCriteria = true;
            showSearchResults = false;
            ShowResults = false;
            SetButtonStates();
        }

        protected async Task CancelSearch()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var yesButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                var noButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.Yes
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                var dialogResult = result as DialogReturnResult;
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    _source?.Cancel();
                    shouldRender = false;
                    var uri = $"{NavManager.BaseUri}Administration/Dashboard";
                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                    _source?.Cancel();
                }

            }
            catch (Exception)
            {
                throw;
            }
        }

        protected void AddAdminstrativUnit()
        {
            NavManager.NavigateTo($"Administration/AdministrativeUnits/Details", true);
        }


        protected void AccordionClick(int index)
        {
            switch (index)
            {
                //search criteria toggle
                case 0:

                    if (ExpandSearchResults && ExpandSearchCriteria == false)
                    {
                        ExpandSearchResults = !ExpandSearchResults;
                    }
                    ExpandSearchCriteria = !ExpandSearchCriteria;
                    break;

                //search results toggle
                case 1:

                    ExpandSearchResults = !ExpandSearchResults;
                    break;

                default:
                    break;
            }
            SetButtonStates();
        }

        protected async Task ShowNoSearchCriteriaDialog()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("DialogName", "NoCriteria");
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.EnterAtLeastOneParameterMessage));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    //do nothing, just informing the user.
                }

            }
            catch (Exception)
            {
                throw;
            }
        }

        protected async Task ShowNarrowSearchCriteriaDialog()
        {
            try
            {
                var buttons = new List<DialogButton>();
                var okButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("DialogName", "NarrowSearch");
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString("Search timed out, try narrowing your search criteria."));
                await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected void DialogClose(dynamic result)
        {
            if (result is DialogReturnResult)
            {
                var dialogResult = result as DialogReturnResult;

                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    _source?.Cancel();
                    ResetSearch();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.NoButton))
                {
                    //cancel search but user said no
                    _source?.Cancel();
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoPrint")
                {
                    //this is the enter parameter dialog
                    //do nothing, just let the user continue entering search criteria
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NoCriteria")
                {
                    //this is the enter parameter dialog
                    //do nothing, just let the user continue entering search criteria
                }
                if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton) && dialogResult.DialogName == "NarrowSearch")
                {
                    //search timed out, narrow search criteria
                    _source?.Cancel();
                    ShowResults = false;
                    ExpandSearchResults = false;
                    ShowCriteria = true;
                    ExpandSearchCriteria = true;
                    SetButtonStates();
                }
            }
            else
            {
                //DiagService.Close(result);

                _source?.Dispose();
            }

            SetButtonStates();
        }

        #endregion

        #region Private Methods


        private void InitializeModel(bool clearFlag, long? adminLevelId)
        {

            //var siteDetails = await SiteClient.GetSiteDetails(GetCurrentLanguage(), Convert.ToInt64(authenticatedUser.SiteId), Convert.ToInt64(authenticatedUser.EIDSSUserId));
            Model = new AdministrativeUnitsPageViewModel()
            {
                SearchCriteria = new AdministrativeUnitsSearchRequestModel(),
                Permissions = Permissions,
                RecordSelectionIndicator = true
            };

            var userPreferences = ConfigurationService.GetUserPreferences(authenticatedUser.UserName);
            Model.SearchCriteria = new AdministrativeUnitsSearchRequestModel();

            if (!clearFlag)
            {
                Model.SearchCriteria.idfsRegion = userPreferences.DefaultRegionInSearchPanels == true
                    ? _tokenService.GetAuthenticatedUser().RegionId
                    : (long?)null;
                Model.SearchCriteria.idfsRayon = userPreferences.DefaultRayonInSearchPanels == true
                    ? _tokenService.GetAuthenticatedUser().RayonId
                    : (long?)null;
                Model.SearchCriteria.idfsCountry = Convert.ToInt64(base.CountryID);
                Model.SearchCriteria.SortColumn = "NationalCountryName";
                Model.SearchCriteria.SortOrder = "asc";
            }

            Model.SearchCriteria.idfsAdminLevel = adminLevelId;

            FillSettingsAsync(Model.SearchCriteria.idfsAdminLevel);

        }

        private void SetButtonStates()
        {
            if (ExpandSearchResults)
            {
                ShowCancelButton = true;
                ShowSearchButton = false;
                ShowClearButton = false;
                ShowAddButton = true;
            }
            else
            {
                ShowCancelButton = true;
                ShowSearchButton = true;
                ShowClearButton = true;
                ShowAddButton = true;
            }
        }

        private void FillSettingsAsync(long? adminLevel)
        {

            Model.SearchCriteria.idfsAdminLevel = adminLevel == 0 ? null : adminLevel;

            SearchLocationViewModel.AdministrativeLevelId = adminLevel;

            SearchLocationViewModel.AdministrativeLevelEnabled = true;
            SearchLocationViewModel.IsDbRequiredAdminLevel0 = false;
            SearchLocationViewModel.IsDbRequiredAdminLevel1 = false;
            SearchLocationViewModel.IsDbRequiredAdminLevel2 = false;

            switch (Model.SearchCriteria.idfsAdminLevel)
            {
                case (long?)AdministrativeLevelReferenceIds.AdminLevel0Id:
                    SearchLocationViewModel.IsHorizontalLayout = true;
                    SearchLocationViewModel.EnableAdminLevel0 = true;
                    SearchLocationViewModel.EnableAdminLevel1 = false;
                    SearchLocationViewModel.EnableAdminLevel2 = false;
                    SearchLocationViewModel.EnableAdminLevel3 = false;
                    SearchLocationViewModel.AdminLevel0Value = Model.SearchCriteria.idfsCountry;
                    SearchLocationViewModel.AdminLevel1Value = Model.SearchCriteria.idfsRegion;
                    break;

                case (long?)AdministrativeLevelReferenceIds.AdminLevel1Id:
                    SearchLocationViewModel.IsHorizontalLayout = true;
                    SearchLocationViewModel.EnableAdminLevel0 = true;
                    SearchLocationViewModel.EnableAdminLevel1 = true;
                    SearchLocationViewModel.EnableAdminLevel2 = false;
                    SearchLocationViewModel.EnableAdminLevel3 = false;
                    SearchLocationViewModel.EnableSettlementType = false;
                    SearchLocationViewModel.AdminLevel0Value = Model.SearchCriteria.idfsCountry;
                    SearchLocationViewModel.AdminLevel1Value = Model.SearchCriteria.idfsRegion;
                    break;

                case (long?)AdministrativeLevelReferenceIds.AdminLevel2Id:
                    SearchLocationViewModel.IsHorizontalLayout = true;
                    SearchLocationViewModel.EnableAdminLevel0 = true;
                    SearchLocationViewModel.EnableAdminLevel1 = true;
                    SearchLocationViewModel.EnableAdminLevel2 = true;
                    SearchLocationViewModel.EnableAdminLevel3 = false;
                    SearchLocationViewModel.EnableSettlementType = false;
                    SearchLocationViewModel.AdminLevel0Value = Model.SearchCriteria.idfsCountry;
                    SearchLocationViewModel.AdminLevel1Value = Model.SearchCriteria.idfsRegion;
                    SearchLocationViewModel.AdminLevel2Value = Model.SearchCriteria.idfsRayon;
                    break;

                case (long?)AdministrativeLevelReferenceIds.AdminLevel3Id:
                case null:
                    SearchLocationViewModel.IsHorizontalLayout = true;
                    SearchLocationViewModel.EnableAdminLevel0 = true;
                    SearchLocationViewModel.EnableAdminLevel1 = true;
                    SearchLocationViewModel.EnableAdminLevel2 = true;
                    SearchLocationViewModel.EnableAdminLevel3 = true;
                    SearchLocationViewModel.EnableSettlementType = true;
                    SearchLocationViewModel.ShowSettlementType = true;
                    SearchLocationViewModel.AdminLevel0Value = Model.SearchCriteria.idfsCountry;
                    SearchLocationViewModel.AdminLevel1Value = Model.SearchCriteria.idfsRegion;
                    SearchLocationViewModel.AdminLevel2Value = Model.SearchCriteria.idfsRayon;
                    SearchLocationViewModel.AdminLevel3Value = Model.SearchCriteria.idfsSettlement;
                    break;

            }

            Model.SearchLocationViewModel = SearchLocationViewModel;
        }

        #endregion

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
            DiagService.OnClose -= DialogClose;
        }

        protected override bool ShouldRender()
        {
            return shouldRender;
        }
    }
}

