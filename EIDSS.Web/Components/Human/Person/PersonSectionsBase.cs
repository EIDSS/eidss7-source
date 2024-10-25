using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Helpers;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Human.Person
{
    public class PersonSectionsBase : PersonBaseComponent, IDisposable
    {
        [Inject]
        private ILogger<PersonSectionsBase> PersonSectionLogger { get; set; }

        [Parameter]
        public long? HumanMasterID { get; set; }

        [Parameter]
        public bool IsReadOnly { get; set; }

        [Parameter]
        public bool IsReview { get; set; }

        protected bool IsProcessing;
        private CancellationTokenSource _source;
        private CancellationToken _token;

        protected PersonAddressSection PersonAddressSectionComponent;
        protected PersonInformationSection PersonInformationSectionComponent;

        protected override async Task OnInitializedAsync()
        {
            await base.OnInitializedAsync();
            _logger = PersonSectionLogger;

            // Reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            InitializeModel();

            if (HumanMasterID != null)
            {
                StateContainer.HumanMasterID = HumanMasterID.Value;
                StateContainer.IsReadOnly = IsReadOnly;
                StateContainer.IsReview = IsReview;
                StateContainer.IsHeaderVisible = true;
                if (StateContainer.HumanMasterID != null)
                {
                    HumanPersonDetailsRequestModel request = new()
                    {
                        HumanMasterID = (long)StateContainer.HumanMasterID,
                        LangID = GetCurrentLanguage()
                    };

                    var personDetailList = await PersonClient.GetHumanDiseaseReportPersonInfoAsync(request);

                    if (personDetailList is { Count: > 0 })
                    {
                        var personDetail = personDetailList.FirstOrDefault();

                        if (personDetail != null)
                        {
                            InitializeModel(personDetail);;
                            
                            await InvokeAsync(StateHasChanged);
                        }
                    }
                }
            }
            if (PersonAddressSectionComponent != null)
                await PersonAddressSectionComponent.RefreshComponent();
            if (PersonInformationSectionComponent != null)
            {
                await PersonInformationSectionComponent.RefreshComponent();
            }
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                var dotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("PersonAddEdit.SetDotNetReference", _token, dotNetReference);

                await JsRuntime.InvokeAsync<string>("PersonAddEdit.initializePersonSidebar", _token,
                    Localizer.GetString(ButtonResourceKeyConstants.CancelButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.SaveButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.NextButton).ToString(),
                    Localizer.GetString(ButtonResourceKeyConstants.PreviousButton).ToString(),
                    Localizer.GetString(MessageResourceKeyConstants.PleaseWaitWhileWeProcessYourRequestMessage).ToString(),
                    Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage).ToString());

                if (StateContainer.IsReadOnly || StateContainer.IsReview)
                    await JsRuntime.InvokeVoidAsync("PersonAddEdit.navigateToReviewStep", _token);
            }

            await base.OnAfterRenderAsync(firstRender);
        }

        private async Task OnStateContainerChangeAsync()
        {
            await InvokeAsync(StateHasChanged);
        }

        public async Task RefreshChildComponent()
        {
            await PersonAddressSectionComponent.RefreshComponent();
        }

        public void Dispose()
        {
            _source?.Cancel();
            _source?.Dispose();
        }

        private void InitializeModel(DiseaseReportPersonalInformationViewModel? personDetail = null)
        {
            var countryId = Convert.ToInt64(CountryID);
            var userPreferences = ConfigurationService.GetUserPreferences(_tokenService.GetAuthenticatedUser().UserName);
            StateContainer.PersonAddSessionPermissions = GetUserPermissions(PagePermission.AccessToPersonsList);
            StateContainer.HumanDiseaseReportPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);
            long? defaultRegionId = userPreferences.DefaultRegionInSearchPanels ? _tokenService.GetAuthenticatedUser().RegionId : null;
            long? defaultRayonId = userPreferences.DefaultRayonInSearchPanels ? _tokenService.GetAuthenticatedUser().RayonId : null;

            StateContainer.SetupFrom(personDetail, countryId, !ShowInDialog, defaultRegionId, defaultRayonId);
        }

        [JSInvokable("OnSubmit")]
        public async Task OnSubmit()
        {
            try
            {
                IsProcessing = true;

                authenticatedUser = _tokenService.GetAuthenticatedUser();

                var response = await SavePerson();

                Logger.LogInformation("Save Person OnSubmit starts");

                if (response?.ReturnCode == 0)
                {
                    dynamic result;

                    Logger.LogInformation("Save Person OnSubmit ReturnCode 0");

                    if (StateContainer.HumanMasterID is 0 or null)
                    {
                        Logger.LogInformation("Save Person OnSubmit before ShowInDialog");
                        if (ShowInDialog)
                        {
                            Logger.LogInformation("Save Person OnSubmit inside if ShowInDialog");
                            result = new PersonViewModel
                            {
                                HumanMasterID = response.HumanMasterID.GetValueOrDefault(),
                                EIDSSPersonID = response.EIDSSPersonID,
                                PersonalID = StateContainer.PersonalID,
                                FullName = StateContainer.PersonLastName +
                                           (string.IsNullOrEmpty(StateContainer.PersonFirstName)
                                               ? ""
                                               : ", " + StateContainer.PersonFirstName),
                                FirstOrGivenName = StateContainer.PersonFirstName,
                                LastOrSurname = StateContainer.PersonLastName,
                                SecondName = StateContainer.PersonMiddleName

                            };

                            Logger.LogInformation("Save Person OnSubmit inside if before PersonAddEdit.stopProcessing");

                            await JsRuntime.InvokeVoidAsync("PersonAddEdit.stopProcessing", _token);

                            DiagService.Close(result);
                        }
                        else
                        {
                            var message = Localizer.GetString(MessageResourceKeyConstants
                                              .RecordSavedSuccessfullyMessage) +
                                          $"{Localizer.GetString(MessageResourceKeyConstants.MessagesRecordIDisMessage)}: {response.EIDSSPersonID}";

                            Logger.LogInformation("Save Person OnSubmit inside if before ShowSuccessDialog");

                            result = await ShowSuccessDialog(null, message, null,
                                ButtonResourceKeyConstants.ReturnToDashboardButton,
                                ButtonResourceKeyConstants.PersonReturnToPersonRecordButtonText);

                            Logger.LogInformation("Save Person OnSubmit inside if after ShowSuccessDialog");
                        }
                    }
                    else
                    {
                        Logger.LogInformation("Save Person OnSubmit inside if else before ShowSuccessDialog");
                        Logger.LogInformation("Save Person OnSubmit before ShowInDialog else");
                        result = await ShowSuccessDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage,
                            null, null, ButtonResourceKeyConstants.ReturnToDashboardButton,
                            ButtonResourceKeyConstants.PersonReturnToPersonRecordButtonText);
                        Logger.LogInformation("Save Person OnSubmit inside if else after ShowSuccessDialog");
                    }

                    if (result is DialogReturnResult returnResult)
                    {
                        Logger.LogInformation("Save Person OnSubmit inside returnResult");
                        if (returnResult.ButtonResultText ==
                            Localizer.GetString(ButtonResourceKeyConstants.ReturnToDashboardButton))
                        {
                            DiagService.Close();

                            _source?.Cancel();

                            var uri = $"{NavManager.BaseUri}Administration/Dashboard/Index";

                            NavManager.NavigateTo(uri, true);
                        }
                        else
                        {
                            IsProcessing = false;
                            if (StateContainer.HumanMasterID is 0 or null)
                                StateContainer.HumanMasterID = response.HumanMasterID;

                            DiagService.Close();

                            const string path = "Human/Person/Details";
                            var query = $"?id={StateContainer.HumanMasterID}&isReview=true";
                            var uri = $"{NavManager.BaseUri}{path}{query}";

                            NavManager.NavigateTo(uri, true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
            finally
            {
                IsProcessing = false;
                await JsRuntime.InvokeVoidAsync("PersonAddEdit.stopProcessing", _token);
            }
        }

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
                    if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                    {
                        DiagService.Close();

                        _source?.Cancel();

                        if (ShowInDialog == false)
                        {
                            var uri = $"{NavManager.BaseUri}Human/Person";

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

        [JSInvokable("ValidatePersonReviewSection")]
        public bool ValidatePersonReviewSection()
        {
            // nothing to validate on this header
            StateContainer.PersonHeaderSectionValidIndicator = true;

            // validate the entire record before save
            if (ValidateMinimumPersonFields() &&
                StateContainer.PersonHeaderSectionValidIndicator &&
                StateContainer.PersonInformationSectionValidIndicator &&
                StateContainer.PersonAddressSectionValidIndicator)
                StateContainer.PersonReviewSectionValidIndicator = true;

            return StateContainer.PersonReviewSectionValidIndicator;
        }
    }
}