using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Shared
{
    public class SearchComponentBase<TModel> : BaseComponent
    {
        [Inject]
        private ILogger<SearchComponentBase<TModel>> Logger { get; set; }

        [Inject]
        protected ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        protected ProtectedSessionStorage BrowserStorage { get; set; }

        [Parameter]
        public SearchModeEnum Mode { get; set; }

        [Parameter]
        public string CallbackUrl { get; set; }

        [Parameter]
        public string CancelUrl { get; set; }

        [Parameter]
        public long? CallbackKey { get; set; }

        [Parameter]
        public long? DiseaseId { get; set; }

        protected int count;
        protected bool shouldRender = true;
        protected bool isLoading;
        protected bool LoadingComponentIndicator { get; set; }
        protected bool disableAddButton;
        protected bool disableSearchButton;
        protected bool hasCriteria;
        protected bool expandSearchCriteria;
        protected bool expandAdvancedSearchCriteria;
        protected bool showSearchResults;
        protected bool showSearchCriteriaButtons;
        protected bool searchSubmitted;
        protected CancellationTokenSource source;
        protected CancellationToken token;

        protected override void OnInitialized()
        {
            // reset the cancellation token
            source = new CancellationTokenSource();
            token = source.Token;

            base.OnInitialized();
        }

        protected override bool ShouldRender()
        {
            return shouldRender;
        }

        protected async Task CancelSearchByUrlAsync()
        {
            source?.Cancel();
            shouldRender = false;

            if (CancelUrl[..1] == "/")
            {
                CancelUrl = CancelUrl[1..];
            }

            NavManager.NavigateTo($"{NavManager.BaseUri}{CancelUrl}", true);
        }

        protected async Task<dynamic> CancelSearchAsync()
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

                var dialogParams = new Dictionary<string, object>
                {
                    {"DialogType", EIDSSDialogType.Warning},
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToCancelMessage)}
                };
                var dialogOptions = new DialogOptions()
                {
                    ShowTitle = true,
                    ShowClose = false
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(String.Empty, dialogParams, dialogOptions);
                var dialogResult = result as DialogReturnResult;
                if (dialogResult != null && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    //cancel search and user said yes
                    source?.Cancel();
                    shouldRender = false;

                    string uri;

                    if (!string.IsNullOrEmpty(CancelUrl))
                    {
                        if (CancelUrl[..1] == "/")
                        {
                            CancelUrl = CancelUrl[1..];
                        }

                        uri = $"{NavManager.BaseUri}{CancelUrl}";
                        NavManager.NavigateTo(uri, true);                        
                    }
                    else if(Mode == SearchModeEnum.SelectNoRedirect)
                    {
                        source?.Cancel();                        
                    }
                    else
                    {
                        uri = $"{NavManager.BaseUri}Administration/Dashboard";
                        NavManager.NavigateTo(uri, true);                        
                    }                    
                }
                else
                {
                    //cancel search but user said no so leave everything alone and cancel thread
                    source?.Cancel();                    
                }

                return dialogResult;
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, ex.Message);
                throw;
            }
        }

        //protected async Task PrintSearchResults()
        //{
        //    //TODO - need to finish print results
        //    try
        //    {
        //        var buttons = new List<DialogButton>();
        //        var okButton = new DialogButton()
        //        {
        //            ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
        //            ButtonType = DialogButtonType.OK
        //        };
        //        buttons.Add(okButton);

        //        var dialogParams = new Dictionary<string, object>();
        //        dialogParams.Add("DialogType", EIDSSDialogType.Warning);
        //        dialogParams.Add("DialogName", "NoPrint");
        //        dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
        //        dialogParams.Add(nameof(EIDSSDialog.Message), new LocalizedString("NoPrint", "Print not ready yet..."));
        //        DialogOptions dialogOptions = new DialogOptions()
        //        {
        //            ShowTitle = true,
        //            ShowClose = false
        //        };
        //        var result = await DiagService.OpenAsync<EIDSSDialog>(string.Empty, dialogParams, dialogOptions);
        //        var dialogResult = result as DialogReturnResult;
        //        if (dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
        //        {
        //            //do nothing, just informing the user.
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        Logger.LogError(ex, ex.Message);
        //        throw;
        //    }
        //}

        protected async Task ShowNoSearchCriteriaDialog()
        {
            try
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
                    {"DialogType", EIDSSDialogType.Warning},
                    {"DialogName", "NoCriteria"},
                    {nameof(EIDSSDialog.DialogButtons), buttons},
                    {nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.EnterAtLeastOneParameterMessage)}
                };
                var dialogOptions = new DialogOptions
                {
                    ShowTitle = true,
                    ShowClose = false
                };
                var result = await DiagService.OpenAsync<EIDSSDialog>(string.Empty, dialogParams, dialogOptions);
                if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                {
                    //do nothing, just informing the user.
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex, ex.Message);
                throw;
            }
        }
    }
}
