using EIDSS.Web.Abstracts;
using Microsoft.AspNetCore.Components;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using EIDSS.Web.Areas.Administration.ViewModels.Administration;
using Radzen.Blazor;
using Microsoft.Extensions.Logging;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using Microsoft.JSInterop;
using EIDSS.ClientLibrary.ApiClients.Admin;
using System.Threading;
using EIDSS.Domain.ViewModels;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.ClientLibrary;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.AspNetCore.Components.Forms;
using EIDSS.Web.Enumerations;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion.Internal;
using Microsoft.Extensions.Localization;

namespace EIDSS.Web.Components.Administration.AdministrativeUnits
{
    public class AdministrativeUnitsDetailsBase : BaseComponent, IDisposable
    {

        #region Dependencies

        [Inject]
        ILogger<AdministrativeUnitsDetailsBase> Logger { get; set; }
        [Inject]
        protected ICrossCuttingClient CrossCuttingClient  { get; set; }

        [Inject]
        private IAdministrativeUnitsClient AdministrativeUnitsClient { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }


        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion


        #region Private Member Variables

        private CancellationTokenSource source;
        private CancellationToken token;
        private object _localizer;

        #endregion

        #region Protected and Public Fields
        protected UserPermissions userPermissions;
        protected bool canAddAdminUnits { get; set; }
        protected int AdminLevelCount;
        protected LocationViewModel DetailLocationViewModel { get; set; }

        protected IEnumerable<BaseReferenceViewModel> AdminLevelUnits;
        private dynamic dialogResult;


        #endregion

        public RadzenTemplateForm<AdministrativeUnitsPageDetailViewModel> Form { get; set; }
        public EditContext EditContext { get; set; }

        [Parameter]
        //public AggregateDiseaseReportGetDetailViewModel Model { get; set; }
        //public ReportDetailsSectionViewModel Model { get; set; }
        public AdministrativeUnitsPageDetailViewModel Model { get; set; }


        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                //var lDotNetReference = DotNetObjectReference.Create(this);
               // await JsRuntime.InvokeVoidAsync("GLOBAL.SetDotnetReference", token, lDotNetReference);
            }
        }

        /// 
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
           
            try
            {
                Logger.LogError("OnInitializedAsync started");
                _logger = Logger;
                Model ??= new AdministrativeUnitsPageDetailViewModel()
                {
                    AdministrativeUnitsDetails = new()
                    {
                        EditLocationViewModel = new()
                        {
                            OperationType = LocationViewOperationType.Add
                        }
                    }
                };

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                userPermissions = GetUserPermissions(PagePermission.CanManageGISReferenceTables);

                canAddAdminUnits = userPermissions.Create;

                await GetAdminLevelUnitsAsync();


                DetailLocationViewModel = Model.AdministrativeUnitsDetails.EditLocationViewModel;

                DetailLocationViewModel.ShowAdminLevel0 = false;
                DetailLocationViewModel.ShowAdminLevel1 = false;
                DetailLocationViewModel.ShowAdminLevel2 = false;
                DetailLocationViewModel.ShowAdminLevel3 = false;
                DetailLocationViewModel.ShowAdminLevel4 = false;
                DetailLocationViewModel.ShowAdminLevel5 = false;
                DetailLocationViewModel.ShowAdminLevel6 = false;
                DetailLocationViewModel.ShowStreet = false;
                DetailLocationViewModel.ShowPostalCode = false;
                DetailLocationViewModel.ShowLatitude = false;
                DetailLocationViewModel.ShowLongitude = false;
                DetailLocationViewModel.ShowElevation = false;
                DetailLocationViewModel.ShowMap = false;

                for (int i = 1; i <= AdminLevelCount + 1; i++)
                {
                    switch (i)
                    {
                        case 1:
                            DetailLocationViewModel.ShowAdminLevel0 = true;
                            break;
                        case 2:
                            DetailLocationViewModel.ShowAdminLevel1 = true;
                            break;
                        case 3:
                            DetailLocationViewModel.ShowAdminLevel2 = true;
                            break;
                        case 4:
                            DetailLocationViewModel.ShowAdminLevel3 = true;
                            break;
                        case 5:
                            DetailLocationViewModel.ShowAdminLevel4 = true;
                            break;
                        case 6:
                            DetailLocationViewModel.ShowAdminLevel5 = true;
                            break;
                        case 7:
                            DetailLocationViewModel.ShowAdminLevel6 = true;
                            break;
                    }
                }

                DetailLocationViewModel.ShowSettlement = true;
                DetailLocationViewModel.ShowSettlementType = true;
                DetailLocationViewModel.ShowStreet = false;
                DetailLocationViewModel.ShowPostalCode = false;
                DetailLocationViewModel.ShowLatitude = true;
                DetailLocationViewModel.ShowLongitude = true;
                DetailLocationViewModel.ShowElevation = true;
                DetailLocationViewModel.IsDbRequiredLatitude = true;
                DetailLocationViewModel.IsDbRequiredLongitude = true;



                switch (Model.AdministrativeUnitsDetails.EditLocationViewModel.OperationType)
                {
                    case LocationViewOperationType.Add:
                        Model.AdministrativeUnitsDetails.AdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel3Id;
                        Model.AdministrativeUnitsDetails.EditLocationViewModel.AdministrativeLevelId = (long)AdministrativeLevelReferenceIds.AdminLevel3Id;
                        //initialize model
                        InitializeModelAsync(Convert.ToInt64(base.CountryID), (long)AdministrativeLevelReferenceIds.AdminLevel3Id);
                        DetailLocationViewModel.ShowMap = true;

                        break;
                    default:
                        Model.AdministrativeUnitsDetails.AdminLevel = Model.AdministrativeUnitsDetails.AdminLevel;
                        Model.AdministrativeUnitsDetails.EditLocationViewModel.AdministrativeLevelId = Model.AdministrativeUnitsDetails.AdminLevel;

                        DetailLocationViewModel.ShowMap = true;
                        //initialize model
                        InitializeModelAsync(Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel0Value.Value, Model.AdministrativeUnitsDetails.AdminLevel);
                        switch (Model.AdministrativeUnitsDetails.AdminLevel)
                        {
                            //Validate
                            case (long)AdministrativeLevelReferenceIds.AdminLevel1Id:
                                {
                                    Model.AdministrativeUnitsDetails.IdfsLocation = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel1Value.Value;
                                    break;
                                }
                            case (long)AdministrativeLevelReferenceIds.AdminLevel2Id:
                                {
                                    Model.AdministrativeUnitsDetails.IdfsLocation = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel2Value.Value;
                                    break;
                                }
                            case (long)AdministrativeLevelReferenceIds.AdminLevel3Id:
                                {
                                    Model.AdministrativeUnitsDetails.IdfsLocation = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel3Value.Value;
                                    break;
                                }
                        }
                        break;
                }
                EditContext = new(Model);

                await base.OnInitializedAsync();

                Logger.LogError("OnInitializedAsync completed");


            }

            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }
       
        }

        #region Protected Methods and Delegates

        protected void RefreshLocationViewModelHandlerAsync(LocationViewModel locationViewModel)
        {
            //Model.DetailLocationViewModel = locationViewModel;


            //Model.SearchCriteria.idfsCountry = Model.DetailLocationViewModel.AdminLevel0Value;
            //Model.SearchCriteria.idfsRegion = Model.DetailLocationViewModel.AdminLevel1Value;
            //Model.SearchCriteria.idfsRayon = Model.DetailLocationViewModel.AdminLevel2Value;
            //Model.SearchCriteria.idfsSettlement = Model.DetailLocationViewModel.AdminLevel3Value;
            //Model.SearchCriteria.idfsAdminLevel = Model.DetailLocationViewModel.AdministrativeLevelId;

        }

        protected async Task GetAdminLevelUnitsAsync()
        {
            try
            {
                AdminLevelUnits = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                    EIDSSConstants.BaseReferenceConstants.AdministrativeLevel, EIDSSConstants.HACodeList.NoneHACode);
                AdminLevelUnits = AdminLevelUnits
                    .Where(r => r.IdfsBaseReference != (long)AdministrativeLevelReferenceIds.AdminLevel0Id).OrderBy(r => r.IntOrder);
                AdminLevelCount = AdminLevelUnits.Count();
            }
            catch (Exception e)
            {
                Logger.LogError(e.Message);
                throw;
            }
            

        }

        protected void RefreshAdminUnits(object value)
        {
            try
            {
                Model.AdministrativeUnitsDetails.AdminLevel = Convert.ToInt64(value);
                Model.AdministrativeUnitsDetails.EditLocationViewModel.AdministrativeLevelId = Convert.ToInt64(value);
                FillSettingsAsync(Convert.ToInt64(Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel0Value), Convert.ToInt64(value));
            }
            catch (Exception e)
            {
                Logger.LogError(e.Message);
                throw;
            }
            
        }

        protected bool DisableByAdminLevel()
        {
            return Model.AdministrativeUnitsDetails.AdminLevel == (long)AdministrativeLevelReferenceIds.AdminLevel3Id;
        }

        #endregion

        private void InitializeModelAsync(long countryId,long adminLevel)
        {

            FillSettingsAsync(countryId, adminLevel);
        }

        private void FillSettingsAsync(long countryId,long adminLevel)
        {
            DetailLocationViewModel.IsDbRequiredLatitude = true;
            DetailLocationViewModel.IsDbRequiredLongitude = true;
            Model.AdministrativeUnitsDetails.UniqueCodeRequired = false;

            DetailLocationViewModel.AdminLevel0Value = countryId;
            switch (Model.AdministrativeUnitsDetails.AdminLevel)
            {
                case (long)AdministrativeLevelReferenceIds.AdminLevel0Id:
                    DetailLocationViewModel.ShowAdminLevel0 = true;
                    DetailLocationViewModel.IsHorizontalLayout = true;
                    DetailLocationViewModel.EnableAdminLevel0 = true;
                    DetailLocationViewModel.EnableAdminLevel1 = false;
                    DetailLocationViewModel.EnableAdminLevel2 = false;
                    DetailLocationViewModel.EnableAdminLevel3 = false;
                    DetailLocationViewModel.EnabledLatitude = true;
                    DetailLocationViewModel.EnabledLongitude = true;
                    DetailLocationViewModel.EnabledElevation = true;
                    DetailLocationViewModel.EnabledElevation = true;
                    Model.AdministrativeUnitsDetails.HascCodeRequired = false;
                    break;

                case (long)AdministrativeLevelReferenceIds.AdminLevel1Id:
                    DetailLocationViewModel.ShowAdminLevel0 = true;
                    DetailLocationViewModel.IsHorizontalLayout = true;
                    DetailLocationViewModel.EnableAdminLevel0 = true;
                    DetailLocationViewModel.IsDbRequiredAdminLevel0 = true;
                    DetailLocationViewModel.EnableAdminLevel1 = false;
                    DetailLocationViewModel.IsDbRequiredAdminLevel1 = false;
                    DetailLocationViewModel.EnableAdminLevel2 = false;
                    DetailLocationViewModel.IsDbRequiredAdminLevel2 = false;
                    DetailLocationViewModel.EnableAdminLevel3 = false;
                    DetailLocationViewModel.IsDbRequiredAdminLevel3 = false;
                    DetailLocationViewModel.EnableSettlementType = false;
                    DetailLocationViewModel.IsDbRequiredSettlementType = false;
                    DetailLocationViewModel.EnabledLatitude = true;
                    DetailLocationViewModel.EnabledLongitude = true;
                    DetailLocationViewModel.EnabledElevation = true;
                    Model.AdministrativeUnitsDetails.HascCodeRequired = true;
                    break;

                case (long)AdministrativeLevelReferenceIds.AdminLevel2Id:
                    DetailLocationViewModel.ShowAdminLevel0 = true;
                    DetailLocationViewModel.EnableAdminLevel0 = true;
                    DetailLocationViewModel.IsDbRequiredAdminLevel0 = true;
                    DetailLocationViewModel.EnableAdminLevel1 = true;
                    DetailLocationViewModel.IsDbRequiredAdminLevel1 = true;
                    DetailLocationViewModel.EnableAdminLevel2 = false;
                    DetailLocationViewModel.IsDbRequiredAdminLevel2 = false;
                    DetailLocationViewModel.EnableAdminLevel3 = false;
                    DetailLocationViewModel.IsDbRequiredAdminLevel3 = false;
                    DetailLocationViewModel.EnableSettlementType = false;
                    DetailLocationViewModel.IsDbRequiredSettlementType = false;
                    DetailLocationViewModel.EnabledLatitude = true;
                    DetailLocationViewModel.EnabledLongitude = true;
                    DetailLocationViewModel.EnabledElevation = true;
                    Model.AdministrativeUnitsDetails.HascCodeRequired = true;

                    break;

                case (long)AdministrativeLevelReferenceIds.AdminLevel3Id:
                    DetailLocationViewModel.ShowAdminLevel0 = true;
                    DetailLocationViewModel.EnableAdminLevel0 = true;
                    DetailLocationViewModel.IsDbRequiredAdminLevel0 = true;
                    DetailLocationViewModel.EnableAdminLevel1 = true;
                    DetailLocationViewModel.IsDbRequiredAdminLevel1 = true;
                    DetailLocationViewModel.EnableAdminLevel2 = true;
                    DetailLocationViewModel.IsDbRequiredAdminLevel2 = true;
                    DetailLocationViewModel.EnableAdminLevel3 = true;
                    DetailLocationViewModel.IsDbRequiredAdminLevel3 = false;
                    DetailLocationViewModel.EnableSettlementType = true;
                    DetailLocationViewModel.IsDbRequiredSettlementType = true;
                    DetailLocationViewModel.EnabledLatitude = true;
                    DetailLocationViewModel.EnabledLongitude = true;
                    DetailLocationViewModel.EnabledElevation = true;
                    Model.AdministrativeUnitsDetails.HascCodeRequired = false;
                    break;

            }
            
            if (Model.AdministrativeUnitsDetails.EditLocationViewModel.OperationType == LocationViewOperationType.Edit)
            {
                Model.AdministrativeUnitsDetails.DisableAdminLevel = true;
                DetailLocationViewModel.ShowMap = true;

            }

            Model.AdministrativeUnitsDetails.EditLocationViewModel = DetailLocationViewModel;
        }

        protected async Task CancelSaveAdminUnitAsync()
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
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                   // _source?.Cancel();
                    //shouldRender = false;
                    var uri = $"{NavManager.BaseUri}Administration/AdministrativeUnits";
                    NavManager.NavigateTo(uri, true);
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                   // _source?.Cancel();
                }

            }
            catch (Exception)
            {
                throw;
            }
        }

        protected async Task SaveAdminUnitAsync()
        {
            try
            {
                var settlementType = Model.AdministrativeUnitsDetails.EditLocationViewModel.SettlementType;
                if (Form.EditContext.Validate())
                {
                    switch (Model.AdministrativeUnitsDetails.AdminLevel)
                    {
                        //Validate
                        case (long)AdministrativeLevelReferenceIds.AdminLevel1Id:
                        {
                            if (Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel0Value == null)
                            {
                                Model.AdministrativeUnitsDetails.EditLocationViewModel.IsDbRequiredAdminLevel0 = true;

                            }

                            break;
                        }
                        case (long)AdministrativeLevelReferenceIds.AdminLevel2Id:
                        {
                            if (Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel1Value == null)
                            {
                                Model.AdministrativeUnitsDetails.EditLocationViewModel.IsDbRequiredAdminLevel1 = true;

                            }

                            break;
                        }
                        case (long)AdministrativeLevelReferenceIds.AdminLevel3Id:
                        {
                            if (Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel2Value == null)
                            {
                                Model.AdministrativeUnitsDetails.EditLocationViewModel.IsDbRequiredAdminLevel2 = true;
                                if (Model.AdministrativeUnitsDetails.EditLocationViewModel.SettlementType == null)
                                {
                                    Model.AdministrativeUnitsDetails.EditLocationViewModel.IsDbRequiredSettlementType = true;
                                }
                            }

                            break;
                        }
                    }

                    //Find the record exists
                    var result = await CheckAdminRecordExistsAsync();
                    Model.AdministrativeUnitsDetails.EditLocationViewModel.SettlementType = settlementType;
                    if (!result)
                    {

                            // add record
                            AdministrativeUnitSaveRequestModel administrativeUnitSaveRequest = new();
                        if (Model.AdministrativeUnitsDetails.AdminLevel == (long)AdministrativeLevelReferenceIds.AdminLevel1Id)
                        {
                            administrativeUnitSaveRequest.StrHASC = Model.AdministrativeUnitsDetails.UniqueCode;
                            administrativeUnitSaveRequest.IdfsParent = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel0Value.Value;
                            administrativeUnitSaveRequest.IdfsType = null;
                            if (Model.AdministrativeUnitsDetails.EditLocationViewModel.OperationType == LocationViewOperationType.Edit)
                            {
                                administrativeUnitSaveRequest.IdfsLocation = Model.AdministrativeUnitsDetails.IdfsLocation;
                                //administrativeUnitSaveRequest.IdfsLocation = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel1Value.Value;
                            }
                        }
                        if (Model.AdministrativeUnitsDetails.AdminLevel == (long)AdministrativeLevelReferenceIds.AdminLevel2Id)
                        {
                            administrativeUnitSaveRequest.StrHASC = Model.AdministrativeUnitsDetails.UniqueCode;
                            administrativeUnitSaveRequest.IdfsParent = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel1Value.Value;
                            administrativeUnitSaveRequest.IdfsType = null;
                            var adminLevel2Value = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel2Value;
                            if (Model.AdministrativeUnitsDetails.EditLocationViewModel.OperationType == LocationViewOperationType.Edit)
                            {
                                administrativeUnitSaveRequest.IdfsLocation = Model.AdministrativeUnitsDetails.IdfsLocation;
                                //administrativeUnitSaveRequest.IdfsLocation = (adminLevel2Value.HasValue == true) ? adminLevel2Value.Value : null;
                            }
                        }
                        if (Model.AdministrativeUnitsDetails.AdminLevel == (long)AdministrativeLevelReferenceIds.AdminLevel3Id)
                        {
                            administrativeUnitSaveRequest.StrHASC = Model.AdministrativeUnitsDetails.UniqueCode; 
                            administrativeUnitSaveRequest.IdfsParent = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel2Value.Value;
                            administrativeUnitSaveRequest.IdfsType = Model.AdministrativeUnitsDetails.EditLocationViewModel.SettlementType;
                            if (Model.AdministrativeUnitsDetails.EditLocationViewModel.OperationType == LocationViewOperationType.Edit)
                            {
                                administrativeUnitSaveRequest.IdfsLocation = Model.AdministrativeUnitsDetails.IdfsLocation;
                                //administrativeUnitSaveRequest.IdfsLocation = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel3Value.Value;
                            }
                        }

                        administrativeUnitSaveRequest.LanguageId = GetCurrentLanguage();
                        administrativeUnitSaveRequest.StrDefaultName = Model.AdministrativeUnitsDetails.DefaultName;
                        administrativeUnitSaveRequest.StrNationalName = Model.AdministrativeUnitsDetails.NationalName;
                        administrativeUnitSaveRequest.User = authenticatedUser.UserName;
                        administrativeUnitSaveRequest.Latitude = Model.AdministrativeUnitsDetails.EditLocationViewModel.Latitude;
                        administrativeUnitSaveRequest.Longitude = Model.AdministrativeUnitsDetails.EditLocationViewModel.Longitude;
                        administrativeUnitSaveRequest.Elevation = Model.AdministrativeUnitsDetails.EditLocationViewModel.Elevation;
                        administrativeUnitSaveRequest.StrCode = Model.AdministrativeUnitsDetails.UniqueCode;
                        administrativeUnitSaveRequest.StrHASC = Model.AdministrativeUnitsDetails.HascCode;

                        var response = await AdministrativeUnitsClient.SaveAdministrativeUnit(administrativeUnitSaveRequest);

                        if (response.ReturnMessage == "SUCCESS")
                        {

                            await SuccessSaveMessagedDialog();
                        }

                    }

                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }
            
        }

        protected async Task<bool> CheckAdminRecordExistsAsync()
        {
            try
            {
                string dialogMessage = null;
                bool returnValue;
                string message = null;
                AdministrativeUnitsGetListViewModel returnRec = new AdministrativeUnitsGetListViewModel();

                var request = new AdministrativeUnitsSearchRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    DefaultName = Model.AdministrativeUnitsDetails.DefaultName,
                    NationalName = Model.AdministrativeUnitsDetails.NationalName,
                    idfsAdminLevel = Model.AdministrativeUnitsDetails.AdminLevel,
                    idfsCountry = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel0Value,
                    idfsRegion = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel1Value,
                    idfsRayon = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel2Value,
                    idfsSettlement = Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel3Value,
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "NationalCountryName",
                    SortOrder = "asc"
                };

                var result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);

                if (result.Count == 0) 
                    returnValue = false;
                else
                {
                    returnValue = true;
                    if (Model.AdministrativeUnitsDetails.EditLocationViewModel.OperationType == LocationViewOperationType.Edit || Model.AdministrativeUnitsDetails.EditLocationViewModel.OperationType == LocationViewOperationType.Add)
                    {
                        switch (request.idfsAdminLevel)
                        {
                            case (long)AdministrativeLevelReferenceIds.AdminLevel1Id:
                                returnRec = result.FirstOrDefault(r =>
                                    r.idfsRegion != Model.AdministrativeUnitsDetails.EditLocationViewModel
                                        .AdminLevel1Value &&
                                    (r.NationalRegionName == Model.AdministrativeUnitsDetails.NationalName ||
                                     r.DefaultRegionName == Model.AdministrativeUnitsDetails.DefaultName));
                                if (returnRec != null)
                                {
                                    message =
                                        $"{Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel0Text}, {Model.AdministrativeUnitsDetails.NationalName}";
                                    dialogMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), message);
                                }
                                else
                                    returnValue = false;
                                break;
                            case (long)AdministrativeLevelReferenceIds.AdminLevel2Id:
                                returnRec = result.FirstOrDefault(r =>
                                    r.idfsRayon != Model.AdministrativeUnitsDetails.EditLocationViewModel
                                        .AdminLevel2Value &&
                                    (r.NationalRayonName == Model.AdministrativeUnitsDetails.NationalName ||
                                     r.DefaultRayonName == Model.AdministrativeUnitsDetails.DefaultName));
                                if (returnRec != null)
                                {
                                    message =
                                        $"{Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel0Text}, {Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel1Text}, {Model.AdministrativeUnitsDetails.NationalName}";
                                    dialogMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), message);
                                }
                                else
                                    returnValue = false;

                                break;
                            case (long)AdministrativeLevelReferenceIds.AdminLevel3Id:
                                returnRec = result.FirstOrDefault(r =>
                                    Convert.ToInt64(r.idfsSettlement) != Model.AdministrativeUnitsDetails
                                        .EditLocationViewModel.AdminLevel3Value &&
                                    (r.NationalSettlementName == Model.AdministrativeUnitsDetails.NationalName ||
                                     r.DefaultSettlementName == Model.AdministrativeUnitsDetails.DefaultName));
                                if (returnRec != null)
                                {
                                     message =
                                        $"{Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel0Text}, {Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel1Text}, {Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel2Text}, {Model.AdministrativeUnitsDetails.NationalName}";
                                    dialogMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), message);
                                }
                                else
                                    returnValue = false;

                                break;
                        }
                    }
                    if (returnValue)
                        await ShowWarningMessage(dialogMessage);

                }

                if (!returnValue)
                {
                    if (!string.IsNullOrEmpty(Model.AdministrativeUnitsDetails.UniqueCode))
                        returnValue = false;
                    else
                    {
                        returnValue = await CheckUniqueCodeExists();
                        if (returnValue)
                        {
                            message =
                                $"{Localizer.GetString(FieldLabelResourceKeyConstants.AdministrativeUnitDetailsUniqueCodeFieldLabel)} {Model.AdministrativeUnitsDetails.UniqueCode}";
                            dialogMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage), message);
                            await ShowWarningMessage(dialogMessage);
                        }
                    }

                    if (!returnValue)
                    {
                        if (string.IsNullOrEmpty(Model.AdministrativeUnitsDetails.HascCode))
                            returnValue = false;
                        else
                        {
                            returnValue = await CheckHascExists();
                            if (!returnValue) return false;
                            message =
                                $"{Localizer.GetString(FieldLabelResourceKeyConstants.AdministrativeUnitDetailsHASCCodeFieldLabel)} {Model.AdministrativeUnitsDetails.HascCode}";
                            dialogMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateValueMessage),message);
                            await ShowWarningMessage(dialogMessage);
                        }
                    }
                }

                return returnValue;
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }
           
        }

        private async Task ShowWarningMessage(string dialogMessage)
        {
            dialogResult = await ShowOkWarningDialog(null, dialogMessage);
            if (dialogResult is DialogReturnResult returnResult)
            {
                if (returnResult.ButtonResultText ==
                    Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                    DiagService.Close(dialogResult);
            }

        }

        private async Task<bool> CheckUniqueCodeExists()
        {
            try
            {
                var returnValue = true;
                if (string.IsNullOrEmpty(Model.AdministrativeUnitsDetails.UniqueCode)) return false;
                var request = new AdministrativeUnitsSearchRequestModel
                {
                    LanguageId = GetCurrentLanguage(),
                    StrCode = Model.AdministrativeUnitsDetails.UniqueCode,
                    idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel0Id,
                    Page = 1,
                    PageSize = 10,
                    SortColumn = "NationalCountryName",
                    SortOrder = "asc"
                };
                var result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);
                if (result.FirstOrDefault(r =>
                        r.idfsCountry != Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel0Value) == null)
                {
                    request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel1Id;
                    result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);
                    if (result.FirstOrDefault(r =>
                            r.idfsRegion != Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel1Value) == null)
                    {
                        request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel2Id;
                        result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);
                        if (result.FirstOrDefault(r =>
                                r.idfsRayon != Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel2Value) == null)
                        {
                            request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel3Id;
                            result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);
                            returnValue = result.FirstOrDefault(r =>
                                r.idfsSettlement !=
                                Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel3Value.ToString()) != null;
                        }
                    }
                }


                return returnValue;
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message);
                throw;
            }

        }

        private async Task<bool> CheckHascExists()
        {
            var returnValue = true;
            if (string.IsNullOrEmpty(Model.AdministrativeUnitsDetails.HascCode)) return false;
            var request = new AdministrativeUnitsSearchRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                StrHASC = Model.AdministrativeUnitsDetails.HascCode,
                idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel0Id,
                Page = 1,
                PageSize = 10,
                SortColumn = "NationalCountryName",
                SortOrder = "asc"
            };
            var result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);
            if (result.FirstOrDefault(r =>
                    r.idfsCountry != Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel0Value) == null)
            {
                request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel1Id;
                result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);
                if (result.FirstOrDefault(r =>
                        r.idfsRegion != Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel1Value) == null)
                {
                    request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel2Id;
                    result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);
                    if (result.FirstOrDefault(r =>
                            r.idfsRayon != Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel2Value) == null)
                    {
                        request.idfsAdminLevel = (long)AdministrativeLevelReferenceIds.AdminLevel3Id;
                        result = await AdministrativeUnitsClient.GetAdministrativeUnitsList(request);
                        returnValue = result.FirstOrDefault(r =>
                            r.idfsSettlement !=
                            Model.AdministrativeUnitsDetails.EditLocationViewModel.AdminLevel3Value.ToString()) != null;
                    }
                }
            }

            return returnValue;
        }

        protected async Task SuccessSaveMessagedDialog()
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
                //dialogParams.Add("DialogName", "Duplicate Record");
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage));
                var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSSuccessModalHeading), dialogParams);
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    NavManager.NavigateTo($"Administration/AdministrativeUnits", true);

                    //do nothing, just informing the user.
                }

            }
            catch (Exception)
            {
                throw;
            }

        }
        public void Dispose()
        {
            
        }
    }
}
