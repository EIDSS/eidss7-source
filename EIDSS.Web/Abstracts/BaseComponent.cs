using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Abstracts
{
    public class BaseComponent : ComponentBase
    {
        [Inject]
        protected ITokenService _tokenService { get; set; }

        [Inject]
        protected IStringLocalizer Localizer { get; set; }

        [Inject]
        protected NavigationManager NavManager { get; set; }

        [Inject]
        protected DialogService DiagService { get; set; }

        [Inject]
        protected IConfiguration Configuration { get; set; }

        [Inject]
        protected ProtectedSessionStorage SessionState { get; set; }

        [Inject]
        protected ISiteAlertsSubscriptionClient SiteAlertsSubscriptionClient { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Parameter]
        public string Id { get; set; }

        public string CountryID => Configuration.GetValue<string>("EIDSSGlobalSettings:CountryID");

        public string XSiteBaseUrl => Configuration.GetValue<string>("EIDSSGlobalSettings:XSITEBaseUrl");

        public DateTime UserDate { get; set; }

        public DateTime UTCDate { get; set; }

        public DateTime ServerDate { get; set; }

        public int TimeZoneOffset { get; set; }

        private IEnumerable<EventSubscriptionTypeModel> _eventTypes;

        protected IList<EventSaveRequestModel> Events { get; set; }

        protected IEnumerable<int> pageSizeOptions = new[] { 10, 25, 50, 100 };
        protected ILogger _logger;
        protected CultureInfo cultureInfo = Thread.CurrentThread.CurrentCulture;
        protected AuthenticatedUser authenticatedUser;

        public UserPermissions GetUserPermissions(PagePermission pageEnum)
        {
            UserPermissions userPermissions = new();

            if (_tokenService == null) return userPermissions;
            authenticatedUser = _tokenService.GetAuthenticatedUser();
            if (authenticatedUser != null)
            {
                userPermissions = _tokenService.GerUserPermissions(pageEnum);
            }

            return userPermissions;
        }

        /// <summary>
        /// Returns the current UI culture code; used primarily for the language ID
        /// parameter on stored procedure calls to get back the appropriate
        /// translated values for reference and resource data.
        /// </summary>
        /// <returns></returns>
        public string GetCurrentLanguage()
        {
            return cultureInfo.Name;
        }

        public async Task GetDates()
        {
            ServerDate = DateTime.Now;
            UserDate = await JsRuntime.InvokeAsync<DateTime>("localDate");
            UTCDate = await JsRuntime.InvokeAsync<DateTime>("utcDate");
            TimeZoneOffset = await JsRuntime.InvokeAsync<int>("timeZoneOffset");
        }

        public async Task<dynamic> ShowSuccessDialog(string message, string localizedMessage, string okButtonConstant, string returnToDashboardButtonConstant, string returnToRecordButtonConstant)
        {
            List<DialogButton> buttons = new();

            if (okButtonConstant is not null)
            {
                DialogButton okButton = new()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(okButton);
            }

            if (returnToDashboardButtonConstant is not null)
            {
                DialogButton returnToDashboardButton = new()
                {
                    ButtonText = Localizer.GetString(returnToDashboardButtonConstant),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(returnToDashboardButton);
            }

            if (returnToRecordButtonConstant is not null)
            {
                DialogButton returnToRecordButton = new()
                {
                    ButtonText = Localizer.GetString(returnToRecordButtonConstant),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(returnToRecordButton);
            }

            Dictionary<string, object> dialogParams = new()
            {
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message) },
                { nameof(EIDSSDialog.LocalizedMessage), localizedMessage },
                { nameof(EIDSSDialog.DialogType), EIDSSDialogType.Success }
            };
            var options = new DialogOptions
            {
                ShowClose = false,
                Height = "auto"
            };

            return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams, options);
        }

        public async Task<dynamic> ShowSuccessDialogWithOutbreak(string message, string localizedMessage, string returnToDashboardButtonConstant, string returnToRecordButtonConstant, string returnToOutbreakSessionConstant)
        {
            List<DialogButton> buttons = new();

            if (returnToDashboardButtonConstant is not null)
            {
                DialogButton returnToDashboardButton = new()
                {
                    ButtonText = Localizer.GetString(returnToDashboardButtonConstant),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(returnToDashboardButton);
            }

            if (returnToOutbreakSessionConstant is not null)
            {
                DialogButton returnToOutbreakSessionButton = new()
                {
                    ButtonText = Localizer.GetString(returnToOutbreakSessionConstant),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(returnToOutbreakSessionButton);
            }

            if (returnToRecordButtonConstant is not null)
            {
                DialogButton returnToRecordButton = new()
                {
                    ButtonText = Localizer.GetString(returnToRecordButtonConstant),
                    ButtonType = DialogButtonType.OK
                };
                buttons.Add(returnToRecordButton);
            }

            Dictionary<string, object> dialogParams = new()
            {
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message) },
                { nameof(EIDSSDialog.LocalizedMessage), localizedMessage },
                { nameof(EIDSSDialog.DialogType), EIDSSDialogType.Success }
            };
            var options = new DialogOptions()
            {
                Height = "auto"
            };

            return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams, options);
        }

        public async Task<dynamic> ShowInformationalDialog(string message, string localizedMessage)
        {
            List<DialogButton> buttons = new();
            DialogButton okButton = new()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            Dictionary<string, object> dialogParams = new()
            {
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message) },
                { nameof(EIDSSDialog.LocalizedMessage), localizedMessage },
                { nameof(EIDSSDialog.DialogType), EIDSSDialogType.Information }
            };
            var options = new DialogOptions
            {
                Height = "auto"
            };

            return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams, options);
        }

        public async Task<dynamic> ShowWarningDialog(string message, string localizedMessage)
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
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message) },
                { nameof(EIDSSDialog.LocalizedMessage), localizedMessage },
                { nameof(EIDSSDialog.DialogType), EIDSSDialogType.Warning }
            };
            var options = new DialogOptions
            {
                Height = "auto"
            };

            return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams, options);
        }

        public async Task<dynamic> ShowOkWarningDialog(string message, string localizedMessage)
        {
            List<DialogButton> buttons = new();
            DialogButton okButton = new()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            Dictionary<string, object> dialogParams = new()
            {
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message) },
                { nameof(EIDSSDialog.LocalizedMessage), localizedMessage },
                { nameof(EIDSSDialog.DialogType), EIDSSDialogType.Warning }
            };
            var options = new DialogOptions
            {
                Height = "auto"
            };

            return await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams, options);
        }

        public async Task<dynamic> ShowErrorDialog(string message, string localizedMessage)
        {
            List<DialogButton> buttons = new();
            DialogButton okButton = new()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            Dictionary<string, object> dialogParams = new()
            {
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.Message), string.IsNullOrEmpty(message) ? null : Localizer.GetString(message) },
                { nameof(EIDSSDialog.LocalizedMessage), localizedMessage },
                { nameof(EIDSSDialog.DialogType), EIDSSDialogType.Error }
            };
            var options = new DialogOptions
            {
                Height = "auto"
            };

            return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams, options);
        }

        public async Task<dynamic> ShowHtmlErrorDialog(MarkupString message)
        {
            List<DialogButton> buttons = new();
            DialogButton okButton = new()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            Dictionary<string, object> dialogParams = new()
            {
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.MarkupMessage), message },
                { nameof(EIDSSDialog.DialogType), EIDSSDialogType.Error }
            };
            var options = new DialogOptions
            {
                Height = "auto"
            };

            return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams, options);
        }

        public async Task<dynamic> InsufficientPermissions()
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

            return await DiagService.OpenAsync<EIDSSDialog>(
                Localizer.GetString(HeadingResourceKeyConstants.EIDSSErrorModalHeading), dialogParams,
                new DialogOptions
                {
                    ShowTitle = false,
                    Style = LaboratoryModuleCSSClassConstants.AccessionCommentDialog,
                    AutoFocusFirstElement = false,
                    CloseDialogOnEsc = false,
                    CloseDialogOnOverlayClick = false,
                    Draggable = false,
                    Resizable = false,
                    ShowClose = false
                });
        }

        public async Task InsufficientPermissionsRedirectAsync(string uri)
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
                 },
                 {nameof(EIDSSDialog.DialogType), EIDSSDialogType.Error}
             };

            var result = await DiagService.OpenAsync<EIDSSDialog>(
                    null, dialogParams,
                    new DialogOptions
                    {
                        ShowTitle = false,
                        Style = LaboratoryModuleCSSClassConstants.AccessionCommentDialog,
                        AutoFocusFirstElement = false,
                        CloseDialogOnEsc = false,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = false,
                        ShowClose = false
                    }).ConfigureAwait(false);

            if (result is DialogReturnResult returnResult)
                if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    DiagService.Close();
                    if (!string.IsNullOrEmpty(uri))
                        NavManager.NavigateTo(uri, true);
                }
        }

        private async Task GetEventTypes()
        {
            try
            {
                if (_eventTypes == null)
                {
                    var requestModel = new EventSubscriptionGetRequestModel()
                    {
                        LanguageId = GetCurrentLanguage(),
                        Page = 1,
                        PageSize = int.MaxValue - 1,
                        SortColumn = "EventTypeName",
                        SortOrder = SortConstants.Ascending,
                        SiteAlertName = "",
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                    };

                    var list = await SiteAlertsSubscriptionClient.GetSiteAlertsSubscriptionList(requestModel);

                    _eventTypes = list;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        /// <summary>
        /// Creates a notification save model to add to a notifications collection for various
        /// events that occur in the EIDSS application.
        /// </summary>
        /// <param name="objectId">Identifier of the parent object; for example a human disease report, veterinary disease report, laboratory test, sample, etc.</param>
        /// <param name="diseaseId"></param>
        /// <param name="eventTypeId"></param>
        /// <param name="siteId">The site identifier that is stored on the parent object/record.</param>
        /// <param name="customMessage">Override the base reference system event type which a more customized alert message.</param>
        /// <returns></returns>
        public async Task<EventSaveRequestModel> CreateEvent(long objectId, long? diseaseId, SystemEventLogTypes eventTypeId, long siteId, string customMessage)
        {
            if (_eventTypes is null)
                await GetEventTypes();

            Events ??= new List<EventSaveRequestModel>();

            var identity = (Events.Count + 1) * -1;

            EventSaveRequestModel eventRecord = new()
            {
                LoginSiteId = Convert.ToInt64(authenticatedUser.SiteId),
                EventId = identity,
                ObjectId = objectId,
                DiseaseId = diseaseId,
                EventTypeId = (long)eventTypeId,
                InformationString = string.IsNullOrEmpty(customMessage) ? null : customMessage,
                SiteId = siteId, //site id of where the record was created.
                UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId),
                LocationId = authenticatedUser.RayonId,
                User = authenticatedUser.UserName
            };

            return eventRecord;
        }
    }
}