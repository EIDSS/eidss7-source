#region Usings

using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.CrossCutting;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

#endregion

namespace EIDSS.Web.Components.Veterinary.Farm
{
    public class FarmSectionsBase : FarmBaseComponent, IDisposable
    {
        #region Globals

        #region Dependencies

        [Inject] private ILogger<FarmSectionsBase> Logger { get; set; }
        [Inject] private IJSRuntime JsRuntime { get; set; }

        #endregion

        #region Properties

        protected FarmAddressSection FarmAddressSectionComponent;

        #endregion

        #region Member Variables

        protected bool IsProcessing;
        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion

        #endregion

        #region Methods

        #region Lifecycle Events

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            StateContainer.OnChange += async _ => await OnStateContainerChangeAsync();

            InitializeModel();

            if (FarmMasterID != null)
            {
                StateContainer.FarmMasterID = FarmMasterID.Value;
                StateContainer.IsReadOnly = IsReadOnly;
            }

            await base.OnInitializedAsync();
        }

        /// <summary>
        /// </summary>
        /// <param name="firstRender"></param>
        /// <returns></returns>
        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                if (FarmMasterID is null)
                {
                    SetLocation(new FarmMasterGetDetailViewModel());

                    await FarmAddressSectionComponent.RefreshComponent();
                }
                else
                    await GetFarmDetails();

                var dotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("FarmReviewSection.SetDotNetReference", _token, dotNetReference);

                await JsRuntime.InvokeAsync<string>("initializeFarmSidebar", _token,
                    Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.DeleteButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.PrintButton).ToString(),
                    (StateContainer.FarmAddSessionPermissions.Create && StateContainer.FarmMasterID is null) ||
                    (StateContainer.FarmAddSessionPermissions.Write && StateContainer.FarmMasterID > 0),
                    StateContainer.FarmAddSessionPermissions.Delete,
                    Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage)
                        .ToString(),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString());

                if (StateContainer.IsReadOnly) await JsRuntime.InvokeVoidAsync("navigateToReviewStep", _token);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        /// <summary>
        /// </summary>
        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        /// <summary>   
        /// </summary>
        /// <returns></returns>
        private async Task OnStateContainerChangeAsync()
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion

        #region Load Farm Data

        /// <summary>
        /// </summary>
        /// <returns></returns>
        protected async Task GetFarmDetails()
        {
            if (StateContainer.FarmMasterID != null)
            {
                FarmMasterGetDetailRequestModel request = new()
                {
                    FarmMasterID = (long)StateContainer.FarmMasterID,
                    LanguageID = GetCurrentLanguage()
                };

                var farmDetailsList = await VeterinaryClient.GetFarmMasterDetail(request);

                if (farmDetailsList is { Count: > 0 })
                {
                    var farmDetail = farmDetailsList.FirstOrDefault();

                    if (farmDetail != null)
                    {
                        StateContainer.FarmMasterID = farmDetail.FarmMasterID;
                        StateContainer.EidssFarmID = farmDetail.EIDSSFarmID;
                        StateContainer.FarmTypeID = farmDetail.FarmTypeID;
                        StateContainer.FarmName = farmDetail.FarmName;
                        StateContainer.FarmOwner = farmDetail.FarmOwner;
                        StateContainer.FarmOwnerID = farmDetail.FarmOwnerID;
                        StateContainer.FarmOwnerFirstName = farmDetail.FarmOwnerFirstName;
                        StateContainer.FarmOwnerLastName = farmDetail.FarmOwnerLastName;
                        StateContainer.FarmOwnerSecondName = farmDetail.FarmOwnerSecondName;
                        StateContainer.Phone = farmDetail.Phone;
                        StateContainer.Fax = farmDetail.Fax;
                        StateContainer.Email = farmDetail.Email;
                        StateContainer.DateEntered = farmDetail.EnteredDate;
                        StateContainer.DateModified = farmDetail.ModifiedDate;
                        StateContainer.FarmAddressID = farmDetail.FarmAddressID;
                        StateContainer.OwnershipStructureTypeID = farmDetail.OwnershipStructureTypeID;
                        StateContainer.NumberOfBirdsPerBuilding = farmDetail.NumberOfBirdsPerBuilding;
                        StateContainer.NumberOfBuildings = farmDetail.NumberOfBuildings;
                        StateContainer.AvianFarmTypeID = farmDetail.AvianFarmTypeID;
                        StateContainer.AvianProductionTypeID = farmDetail.AvianProductionTypeID;

                        SetLocation(farmDetail);

                        if (farmDetail.FarmTypeID != null)
                            if (StateContainer.SelectedFarmTypes is null)
                            {
                                var selectedFarmTypes = new List<long>();

                                switch (farmDetail.FarmTypeID)
                                {
                                    case HACodeBaseReferenceIds.All:
                                        selectedFarmTypes.Add(HACodeBaseReferenceIds.Avian);
                                        selectedFarmTypes.Add(HACodeBaseReferenceIds.Livestock);
                                        break;

                                    default:
                                        selectedFarmTypes.Add(farmDetail.FarmTypeID.Value);
                                        break;
                                }

                                StateContainer.SelectedFarmTypes = selectedFarmTypes;
                            }

                        if (StateContainer.SelectedFarmTypes != null)
                        {
                            if (StateContainer.SelectedFarmTypes.Contains(HACodeBaseReferenceIds.Avian) &&
                                StateContainer.SelectedFarmTypes.Contains(HACodeBaseReferenceIds.Livestock))
                            {
                                StateContainer.IsAvianDisabled = false;
                                StateContainer.IsOwnershipDisabled = false;
                            }

                            if (StateContainer.SelectedFarmTypes.Any())
                                switch (StateContainer.SelectedFarmTypes.First())
                                {
                                    case HACodeBaseReferenceIds.Avian:
                                        if (!StateContainer.FarmAddSessionPermissions.Create &&
                                            StateContainer.FarmMasterID is null ||
                                            !StateContainer.FarmAddSessionPermissions.Write &&
                                            StateContainer.FarmMasterID > 0)
                                            StateContainer.IsAvianDisabled = true;
                                        else
                                            StateContainer.IsAvianDisabled = false;

                                        StateContainer.IsOwnershipDisabled = true;
                                        break;

                                    case HACodeBaseReferenceIds.Livestock:
                                        StateContainer.IsAvianDisabled = true;
                                        if (!StateContainer.FarmAddSessionPermissions.Create &&
                                            StateContainer.FarmMasterID is null ||
                                            !StateContainer.FarmAddSessionPermissions.Write &&
                                            StateContainer.FarmMasterID > 0)
                                            StateContainer.IsOwnershipDisabled = true;
                                        else
                                            StateContainer.IsOwnershipDisabled = false;
                                        break;
                                }
                        }

                        if (StateContainer.IsReadOnly)
                        {
                            StateContainer.FarmLocationModel.AlwaysDisabled = true;
                            StateContainer.FarmLocationModel.EnableAdminLevel1 = false;
                            StateContainer.FarmLocationModel.EnableAdminLevel2 = false;
                            StateContainer.FarmLocationModel.EnableAdminLevel3 = false;
                            StateContainer.FarmLocationModel.EnableApartment = false;
                            StateContainer.FarmLocationModel.EnableBuilding = false;
                            StateContainer.FarmLocationModel.EnableHouse = false;
                            StateContainer.FarmLocationModel.EnablePostalCode = false;
                            StateContainer.FarmLocationModel.EnableSettlement = false;
                            StateContainer.FarmLocationModel.EnableSettlementType = false;
                            StateContainer.FarmLocationModel.EnableStreet = false;
                            StateContainer.FarmLocationModel.OperationType = LocationViewOperationType.ReadOnly;
                        }

                        await FarmAddressSectionComponent.RefreshComponent();

                        await InvokeAsync(StateHasChanged);
                    }
                }
            }
        }

        #endregion

        #region Initialize Defaults

        /// <summary>
        /// </summary>
        private void InitializeModel()
        {
            StateContainer.FarmAddSessionPermissions = GetUserPermissions(PagePermission.AccessToFarmsData);
            StateContainer.VeterinaryDiseaseResultPermissions =
                GetUserPermissions(PagePermission.AccessToVeterinaryDiseaseReportsData);
        }

        #endregion

        #region Submit Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnSubmit")]
        public async Task OnSubmit()
        {
            try
            {
                IsProcessing = true;

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                // check the required fields based on farm name and farm owner
                var (IsValid, Message) = ValidateRequiredFields();
                if (!IsValid)
                {
                    var result = await ShowErrorDialog(null, Message);

                    if (result is DialogReturnResult returnResult)
                    {
                        if (returnResult.ButtonResultText ==
                            Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                        {
                            DiagService.Close(result);

                            await InvokeAsync(() =>
                            {
                                JsRuntime.InvokeVoidAsync("stopProcessing", _token);
                                StateHasChanged();
                            });

                            return;
                        }
                    }
                }

                if (StateContainer.FarmMasterID is 0 or null)
                {
                    if (await ValidateDuplicateFarm())
                    {
                        var result = await ShowWarningDialog(null,
                            Localizer.GetString(MessageResourceKeyConstants
                                .FarmTheRecordWithTheSameFarmAddressAndSameFarmOwnerIsFoundInTheDatabaseDoYouWantToCreateThisFarmRecordMessage));

                        if (result is DialogReturnResult returnResult)
                        {
                            if (returnResult.ButtonResultText ==
                                Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                            {
                                await ContinueSaveFarm();
                            }
                            else
                            {
                                DiagService.Close(result);

                                await InvokeAsync(() =>
                                {
                                    JsRuntime.InvokeVoidAsync("stopProcessing", _token);
                                    StateHasChanged();
                                });
                            }
                        }
                    }
                    else
                        await ContinueSaveFarm();
                }
                else
                    await ContinueSaveFarm();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                IsProcessing = false;
            }
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task<bool> ValidateDuplicateFarm()
        {
            var request = new FarmMasterSearchRequestModel
            {
                LanguageId = GetCurrentLanguage(),
                SortColumn = "EIDSSFarmID",
                SortOrder = SortConstants.Descending,
                Page = 1,
                PageSize = 10,
                FarmOwnerLastName = StateContainer.FarmOwnerLastName,
                FarmOwnerFirstName = StateContainer.FarmOwnerFirstName
            };
            //Get lowest administrative level for location
            if (StateContainer.FarmLocationModel.AdminLevel3Value.HasValue)
                request.IdfsLocation = StateContainer.FarmLocationModel.AdminLevel3Value.Value;
            else if (StateContainer.FarmLocationModel.AdminLevel2Value.HasValue)
                request.IdfsLocation = StateContainer.FarmLocationModel.AdminLevel2Value.Value;
            else if (StateContainer.FarmLocationModel.AdminLevel1Value.HasValue)
                request.IdfsLocation = StateContainer.FarmLocationModel.AdminLevel1Value.Value;
            var result = await VeterinaryClient.GetFarmMasterListAsync(request, _token);

            return result.Any();
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private (bool IsValid, string Message) ValidateRequiredFields()
        {
            var result = (IsValid: true, Message: string.Empty);

            if (string.IsNullOrEmpty(StateContainer.FarmName) && string.IsNullOrEmpty(StateContainer.FarmOwner))
            {
                if (!(StateContainer.FarmLocationModel.AdminLevel0Value.HasValue
                    && StateContainer.FarmLocationModel.AdminLevel1Value.HasValue
                    && StateContainer.FarmLocationModel.AdminLevel2Value.HasValue
                    && !string.IsNullOrEmpty(StateContainer.FarmLocationModel.StreetText)))
                {
                    result.IsValid = false;
                    result.Message = Localizer.GetString(MessageResourceKeyConstants
                        .FarmStreetRequiredWhenFarmOwnerAndFarmNameLeftBlank);
                    return result;
                }
            }

            if (!string.IsNullOrEmpty(StateContainer.FarmName) && string.IsNullOrEmpty(StateContainer.FarmOwner))
            {
                if (!(StateContainer.FarmLocationModel.AdminLevel0Value.HasValue
                    && StateContainer.FarmLocationModel.AdminLevel1Value.HasValue
                    && StateContainer.FarmLocationModel.AdminLevel2Value.HasValue
                    && StateContainer.FarmLocationModel.ShowAdminLevel3
                    && StateContainer.FarmLocationModel.AdminLevel3Value.HasValue))
                {
                    result.IsValid = false;
                    result.Message = Localizer.GetString(MessageResourceKeyConstants
                        .FarmRegionRayonAndSettlementRequiredWhenFarmOwnerLeftBlank);
                    return result;
                }
            }

            return result;
        }

        /// <summary>
        /// </summary>
        /// <returns></returns>
        private async Task ContinueSaveFarm()
        {
            var response = await SaveFarm();

            if (response.ReturnCode == 0)
            {
                StateContainer.FarmAddressSectionChangedIndicator = false;
                StateContainer.FarmInformationSectionChangedIndicator = false;

                string thirdButton = null;
                if (ShowInDialog)
                {
                    thirdButton = Localizer.GetString(ReturnButtonResourceString);
                }

                dynamic result;
                if (StateContainer.FarmMasterID is 0 or null)
                {
                    var message =
                    $"{Localizer.GetString(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage)} {Localizer.GetString(MessageResourceKeyConstants.MessagesRecordIDisMessage)}: {response.SessionID}.";

                    if (LaboratoryModuleIndicator)
                    {
                        result = new FarmViewModel
                        {
                            EIDSSFarmID = response.SessionID,
                            FarmMasterID = response.SessionKey.GetValueOrDefault(),
                            FarmName = StateContainer.FarmName,
                            FarmOwnerID = StateContainer.FarmOwnerID,
                            FarmOwnerName = StateContainer.FarmOwnerLastName +
                                                       (string.IsNullOrEmpty(StateContainer.FarmOwnerFirstName)
                                                           ? ""
                                                           : ", " + StateContainer.FarmOwnerSecondName)
                        };

                        DiagService.Close(result);
                    }
                    else if (ShowInDialog)
                    {
                        result = await ShowSuccessDialogWithOutbreak(null, message,
                            ButtonResourceKeyConstants.ReturnToDashboardButton,
                            ButtonResourceKeyConstants.ReturnToFarmButtonText,
                            thirdButton);
                    }
                    else
                    {
                        result = await ShowSuccessDialog(null, message, null,
                            ButtonResourceKeyConstants.ReturnToDashboardButton,
                            ButtonResourceKeyConstants.ReturnToFarmButtonText);
                    }
                }
                else
                {
                    if (ShowInDialog)
                    {
                        result = await ShowSuccessDialogWithOutbreak(null, MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                            ButtonResourceKeyConstants.ReturnToDashboardButton,
                            ButtonResourceKeyConstants.ReturnToFarmButtonText,
                            thirdButton);
                    }
                    else
                    {
                        result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                            null, null, ButtonResourceKeyConstants.ReturnToDashboardButton,
                            ButtonResourceKeyConstants.ReturnToFarmButtonText);
                    }
                }

                if (result is DialogReturnResult returnResult)
                {
                    if (returnResult.ButtonResultText ==
                        Localizer.GetString(ButtonResourceKeyConstants.ReturnToDashboardButton))
                    {
                        DiagService.Close();

                        _source?.Cancel();

                        var uri = $"{NavManager.BaseUri}Administration/Dashboard/Index";

                        NavManager.NavigateTo(uri, true);
                    }
                    else if (thirdButton != null
                                && returnResult.ButtonResultText == Localizer.GetString(thirdButton)
                                && Mode == SearchModeEnum.SelectNoRedirect)
                    {
                        DiagService.Close(response.SessionKey);
                    }
                    else if (Mode == SearchModeEnum.SelectEvent)
                    {
                        await FarmAddEditComplete.InvokeAsync(response.SessionKey);
                    }
                    else
                    {
                        IsProcessing = true;
                        if (StateContainer.FarmMasterID is 0 or null)
                            StateContainer.FarmMasterID = response.SessionKey;

                        if (response.SessionKey != null) await GetFarmDetails();

                        //Reset the permissions.
                        StateContainer.FarmAddSessionPermissions = new UserPermissions();
                        StateContainer.FarmAddSessionPermissions =
                            GetUserPermissions(PagePermission.AccessToFarmsData);

                        StateContainer.FarmHeaderSectionValidIndicator = true;
                        StateContainer.FarmInformationSectionValidIndicator = true;
                        StateContainer.FarmAddressSectionValidIndicator = true;
                        StateContainer.FarmReviewSectionValidIndicator = true;

                        DiagService.Close();

                        const string path = "Veterinary/Farm/Details";
                        var query =
                            $"?id={StateContainer.FarmMasterID}&isReadOnly=true";
                        var uri = $"{NavManager.BaseUri}{path}{query}";

                        NavManager.NavigateTo(uri, true);
                    }
                }
            }
        }

        #endregion

        #region Cancel Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnCancel")]
        public async Task OnCancel()
        {
            try
            {
                List<DialogButton> buttons = new();
                DialogButton yesButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                DialogButton noButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                Dictionary<string, object> dialogParams = new()
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)

                    if (Mode == SearchModeEnum.SelectNoRedirect)
                    {
                        DiagService.Close("Cancelled");
                    }
                    else if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        var uri = $"{NavManager.BaseUri}Veterinary/Farm/";

                        DiagService.Close();
                        _source?.Cancel();

                        if (Mode != SearchModeEnum.SelectNoRedirect && ShowInDialog == false)
                        {
                            NavManager.NavigateTo(uri, true);
                        }
                    }

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Delete Click Event

        /// <summary>
        /// </summary>
        [JSInvokable("OnDelete")]
        public async Task OnDelete()
        {
            try
            {
                List<DialogButton> buttons = new();
                DialogButton yesButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                DialogButton noButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(yesButton);
                buttons.Add(noButton);

                Dictionary<string, object> dialogParams = new()
                {
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {
                        nameof(EIDSSDialog.Message),
                        Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage)
                    }
                };

                var result =
                    await DiagService.OpenAsync<EIDSSDialog>(
                        Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result == null)
                    return;

                if (result is DialogReturnResult returnResult)
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();

                        var response = await DeleteFarm();
                        if (response.ReturnCode is 0)
                        {
                            _source?.Cancel();

                            var uri = $"{NavManager.BaseUri}Veterinary/Farm?refresh=true";

                            NavManager.NavigateTo(uri, true);
                        }
                    }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Review Section Validation

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateFarmReviewSection()
        {
            // nothing to validate on this header
            StateContainer.FarmHeaderSectionValidIndicator = true;

            StateContainer.IsReview = false;

            if (StateContainer.IsReview)
            {
                StateContainer.FarmLocationModel.AlwaysDisabled = true;
                StateContainer.FarmLocationModel.EnableAdminLevel1 = false;
                StateContainer.FarmLocationModel.EnableAdminLevel2 = false;
                StateContainer.FarmLocationModel.EnableAdminLevel3 = false;
                StateContainer.FarmLocationModel.EnableApartment = false;
                StateContainer.FarmLocationModel.EnableBuilding = false;
                StateContainer.FarmLocationModel.EnableHouse = false;
                StateContainer.FarmLocationModel.EnablePostalCode = false;
                StateContainer.FarmLocationModel.EnableSettlement = false;
                StateContainer.FarmLocationModel.EnableSettlementType = false;
                StateContainer.FarmLocationModel.EnableStreet = false;
                StateContainer.FarmLocationModel.OperationType = LocationViewOperationType.ReadOnly;
            }
            else
            {
                StateContainer.FarmLocationModel.AlwaysDisabled = false;
                StateContainer.FarmLocationModel.EnableAdminLevel1 = true;
                StateContainer.FarmLocationModel.EnableApartment = StateContainer.FarmLocationModel.AdminLevel3Value != null;
                StateContainer.FarmLocationModel.EnableBuilding = StateContainer.FarmLocationModel.AdminLevel3Value != null;
                StateContainer.FarmLocationModel.EnableHouse = StateContainer.FarmLocationModel.AdminLevel3Value != null;
                StateContainer.FarmLocationModel.EnableStreet = StateContainer.FarmLocationModel.AdminLevel3Value != null;
                StateContainer.FarmLocationModel.EnablePostalCode = StateContainer.FarmLocationModel.AdminLevel3Value != null;
                StateContainer.FarmLocationModel.EnabledLatitude = true;
                StateContainer.FarmLocationModel.EnabledLongitude = true;
                StateContainer.FarmLocationModel.OperationType = null;
            }
            await FarmAddressSectionComponent.RefreshComponent();

            // validate the entire record before save
            if (ValidateMinimumFarmFields() &&
                StateContainer.FarmHeaderSectionValidIndicator &&
                StateContainer.FarmInformationSectionValidIndicator &&
                StateContainer.FarmAddressSectionValidIndicator)
                StateContainer.FarmReviewSectionValidIndicator = true;

            await InvokeAsync(StateHasChanged); 

            return StateContainer.FarmReviewSectionValidIndicator;
        }

        #endregion

        #endregion
    }
}