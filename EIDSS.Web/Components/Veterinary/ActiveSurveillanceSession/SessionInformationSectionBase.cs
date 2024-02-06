using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Common;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Components.Veterinary.SearchActiveSurveillanceCampaign;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using static System.String;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Veterinary.ActiveSurveillanceSession
{
    public class SessionInformationSectionBase : SurveillanceSessionBaseComponent
    {
        #region Globals

        #region Dependencies

        [Inject]
        private ILogger<SessionInformationSectionBase> Logger { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        #endregion Dependencies

        #region Events

        public EventCallback CampaignLinked;

        #endregion Events

        #region Properties

        private IList<EIDSSValidationMessageStore> MessageStore { get; set; }

        protected RadzenTemplateForm<VeterinaryActiveSurveillanceSessionStateContainerService> Form { get; set; }
        protected RadzenTextBox SessionID { get; set; }
        protected RadzenTextBox LegacySessionID { get; set; }
        protected RadzenDropDown<long?> SessionStatusTypeID { get; set; }
        protected RadzenTextBox CampaignID { get; set; }
        protected RadzenTextBox CampaignName { get; set; }
        protected RadzenTextBox CampaignType { get; set; }
        protected RadzenDatePicker<DateTime?> SessionStartDate { get; set; }
        protected RadzenDatePicker<DateTime?> SessionEndDate { get; set; }
        protected RadzenDropDown<long?> ReportTypeID { get; set; }
        protected RadzenTextBox SiteName { get; set; }
        protected RadzenTextBox OfficerName { get; set; }
        protected RadzenDatePicker<DateTime?> DateEntered { get; set; }

        #endregion Properties

        #region Member Variables

        protected bool ReportTypeDisabled;
        protected int SessionStatusCount;
        private CancellationTokenSource _source;
        private CancellationToken _token;

        #endregion Member Variables

        #endregion Globals

        #region Methods

        #region Lifecycle Methods

        protected override async Task OnInitializedAsync()
        {
            _logger = Logger;

            // reset the cancellation token
            _source = new CancellationTokenSource();
            _token = _source.Token;

            await GetSessionStatusesAsync(new LoadDataArgs()).ConfigureAwait(false);

            MessageStore = new List<EIDSSValidationMessageStore>();

            await base.OnInitializedAsync();
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            if (firstRender)
            {
                await SetDefaults();

                var lDotNetReference = DotNetObjectReference.Create(this);
                await JsRuntime.InvokeVoidAsync("VetSurveillanceSessionInformationSection.SetDotNetReference", _token, lDotNetReference)
                    .ConfigureAwait(false);
            }

            Form.EditContext.OnFieldChanged += OnFormFieldChanged;

            await base.OnAfterRenderAsync(firstRender);
        }

        public void Dispose()
        {
            if (Form.EditContext is not null)
                Form.EditContext.OnFieldChanged -= OnFormFieldChanged;

            _source?.Cancel();
            _source?.Dispose();
        }

        #endregion Lifecycle Methods

        #region Events

        protected void OnReportTypeChange(object value)
        {
            var reportType = Convert.ToInt64(value);

            StateContainer.HACode = reportType == ASSpeciesType.Avian ? HACodeList.AvianHACode : HACodeList.LivestockHACode;

        }

        #endregion Events

        #region Surveillance Campaign Link

        protected async Task OnCampaignSearchClick()
        {
            try
            {
                dynamic result = await DiagService.OpenAsync<SearchVeterinaryActiveSurveillanceCampaign>(@Localizer.GetString(HeadingResourceKeyConstants.VeterinaryActiveSurveillanceCampaignPageHeading),
                    new Dictionary<string, object>()
                    {
                        { "Mode", SearchModeEnum.SelectNoRedirect },
                        { "CampaignCategoryID", Convert.ToInt64(EIDSSConstants.CampaignCategory.Veterinary) }
                    },
                     options: new DialogOptions()
                     {
                         ShowTitle = true,
                         //MJK - Height is set globally for dialogs
                         //Height = CSSClassConstants.LargeDialogHeight,
                         Width = CSSClassConstants.LargeDialogWidth,
                         AutoFocusFirstElement = true,
                         CloseDialogOnOverlayClick = true,
                         Draggable = false,
                         Resizable = true,
                         ShowClose = true
                     });

                switch (result)
                {
                    case ActiveSurveillanceCampaignListViewModel campaign:
                        {
                            if (await IsCampaignValid(campaign.CampaignKey))
                            {
                                StateContainer.HasLinkedCampaign = true;
                                StateContainer.CampaignKey = campaign.CampaignKey;
                                StateContainer.CampaignID = campaign.CampaignID;
                                StateContainer.CampaignType = campaign.CampaignTypeName;
                                StateContainer.CampaignName = campaign.CampaignName;
                                StateContainer.CampaignStartDate= campaign.CampaignStartDate;
                                StateContainer.CampaignEndDate = campaign.CampaignEndDate;
                                await AddDiseaseSpeciesSamplesFromCampaign(campaign.CampaignKey);
                                await InvokeAsync(StateHasChanged);
                                StateContainer.NotifyCampaignLinked();
                            }
                            else
                            {
                                await ShowInvalidCampaignDialog().ConfigureAwait(false);
                            }

                            break;
                        }
                    case string when result == "Cancelled":
                        _source?.Cancel();
                        break;

                    case string when result == "Add":
                        _source?.Cancel();
                        await AddCampaign().ConfigureAwait(false);
                        break;

                    default:
                        DiagService.Close();
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
        }

        protected async Task OnCampaignClearClick()
        {
            StateContainer.HasLinkedCampaign = false;
            StateContainer.CampaignKey = null;
            StateContainer.CampaignID = null;
            StateContainer.CampaignType = null;
            StateContainer.CampaignName = null;
            StateContainer.CampaignEndDate = null;
            StateContainer.CampaignStartDate = null;
            await InvokeAsync(StateHasChanged);
        }

        protected async Task AddCampaign()
        {
            //reset the cancellation token
            var source = new CancellationTokenSource();
            var token = source.Token;

            try
            {
                var result =
                    await DiagService.OpenAsync<ActiveSurveillanceCampaign.ActiveSurveillanceCampaign>(
                    Localizer.GetString(HeadingResourceKeyConstants.VeterinaryActiveSurveillanceCampaignPageHeading),
                    new Dictionary<string, object>()
                    {
                        { "Mode", SearchModeEnum.SelectNoRedirect }
                    },
                    new DialogOptions
                    {
                        Style = CSSClassConstants.DefaultDialogHeight,
                        AutoFocusFirstElement = true,
                        //MJK - Height is set globally for dialogs
                        //Height = CSSClassConstants.LargeDialogHeight,
                        Width = CSSClassConstants.LargeDialogWidth,
                        CloseDialogOnOverlayClick = false,
                        Draggable = false,
                        Resizable = true
                    });

                switch (result)
                {
                    case long campaignId:
                        var request = new ActiveSurveillanceCampaignDetailRequestModel()
                        {
                            LanguageId = GetCurrentLanguage(),
                            CampaignID = campaignId,
                        };
                        var campaignResult = await CrossCuttingClient.GetActiveSurveillanceCampaignGetDetailAsync(request, token);
                        if (campaignResult != null)
                        {
                            var campaign = campaignResult.First();
                            if (await IsCampaignValid(campaign.CampaignID))
                            {
                                StateContainer.HasLinkedCampaign = true;
                                StateContainer.CampaignKey = campaign.CampaignID;
                                StateContainer.CampaignID = campaign.EIDSSCampaignID;
                                StateContainer.CampaignType = campaign.CampaignTypeName;
                                StateContainer.CampaignName = campaign.CampaignName;
                                StateContainer.CampaignEndDate = campaign.CampaignStartDate;
                                StateContainer.CampaignEndDate = campaign.CampaignEndDate;
                                await AddDiseaseSpeciesSamplesFromCampaign(campaign.CampaignID);
                            }
                        }

                        DiagService.Close();

                        await InvokeAsync(StateHasChanged);

                        break;

                    case string when result == "Cancelled":
                        _source?.Cancel();
                        break;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ex.Message);
                throw;
            }
            finally
            {
                source?.Cancel();
                source?.Dispose();
            }
        }

        
        private async Task ShowInvalidCampaignDialog()
        {
            var buttons = new List<DialogButton>();
            var okButton = new DialogButton()
            {
                ButtonText = Localizer.GetString(ButtonResourceKeyConstants.OKButton),
                ButtonType = DialogButtonType.OK
            };
            buttons.Add(okButton);

            var dialogParams = new Dictionary<string, object>
            {
                { "DialogName", "CampaignInvalid" },
                { nameof(EIDSSDialog.DialogButtons), buttons },
                { nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.VeterinarySessionDiseaseSpeciesListMustBeTheSameAsCampaignMessage) }
            };
            var result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSWarningModalHeading), dialogParams);
            if (result is DialogReturnResult dialogResult && dialogResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
            {
                StateContainer.CampaignID = null;
                StateContainer.CampaignKey = null;
                StateContainer.CampaignName = null;
                StateContainer.HasLinkedCampaign = false;
                StateContainer.CampaignType = null;
                StateContainer.CampaignStartDate = null;
                StateContainer.CampaignEndDate = null;
            }
        }
       

        #endregion Surveillance Campaign Link

        #region Data Methods


        protected async Task GetSessionStatusesAsync(LoadDataArgs args)
        {
            StateContainer.SessionStatuses = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(),
                BaseReferenceConstants.ASSessionStatus, HACodeList.LiveStockAndAvian);
            SessionStatusCount = StateContainer.SessionStatuses.Count;
        }

        private string GetDefaultUserName()
        {
            var value = _tokenService.GetAuthenticatedUser();
            return value.FirstName + (IsNullOrEmpty(value.FirstName) ? "" : ", ") + value.LastName;
        }

        private async Task SetDefaults()
        {
            // new surveillance session
            if (StateContainer.SessionKey == null)
            {
                StateContainer.SessionKey = 0;
                StateContainer.OfficerName = GetDefaultUserName();
                StateContainer.SiteName = _tokenService.GetAuthenticatedUser().Organization;
                StateContainer.SiteID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().SiteId);
                StateContainer.DateEntered = System.DateTime.Now;
                StateContainer.OfficerID = Convert.ToInt64(_tokenService.GetAuthenticatedUser().PersonId);
                StateContainer.SessionStatusTypeID = EIDSSConstants.ActiveSurveillanceSessionStatusIds.Open;
                StateContainer.SessionStatusTypeName = StateContainer.SessionStatuses.Find(s => s.IdfsBaseReference == StateContainer.SessionStatusTypeID).Name;
            }

            await InvokeAsync(StateHasChanged);
        }

        #endregion Data Methods

        #region Form Events

        /// <summary>
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void OnFormFieldChanged(object sender, FieldChangedEventArgs e)
        {
            var errorMessages = Form.EditContext.GetValidationMessages(e.FieldIdentifier);

            var tabIndex = e.FieldIdentifier.FieldName switch
            {
                nameof(StateContainer.SessionID) => SessionID.TabIndex,
                nameof(StateContainer.LegacySessionID) => LegacySessionID.TabIndex,
                nameof(StateContainer.SessionStatusTypeID) => SessionStatusTypeID.TabIndex,
                nameof(StateContainer.CampaignID) => CampaignID.TabIndex,
                nameof(StateContainer.CampaignName) => CampaignName.TabIndex,
                nameof(StateContainer.CampaignType) => CampaignType.TabIndex,
                nameof(StateContainer.SessionStartDate) => SessionStartDate.TabIndex,
                nameof(StateContainer.SessionEndDate) => SessionEndDate.TabIndex,
                nameof(StateContainer.ReportTypeID) => ReportTypeID.TabIndex,
                nameof(StateContainer.SiteName) => SiteName.TabIndex,
                nameof(StateContainer.OfficerName) => OfficerName.TabIndex,
                nameof(StateContainer.DateEntered) => DateEntered.TabIndex,
                _ => 0
            };

            var temp = MessageStore.Where(x => x.FieldName == e.FieldIdentifier.FieldName).ToList();
            foreach (var error in temp) MessageStore.Remove(error);

            var enumerable = errorMessages.ToList();
            if (!enumerable.Any()) return;
            foreach (var message in enumerable)
                MessageStore.Add(new EIDSSValidationMessageStore
                { FieldName = e.FieldIdentifier.FieldName, Message = message, TabIndex = tabIndex });
        }

        #endregion Form Events

        #region Validation Methods

        /// <summary>
        /// </summary>
        /// <returns></returns>
        [JSInvokable]
        public async Task<bool> ValidateSectionForSidebar()
        {
            StateContainer.SessionInformationValidIndicator = Form.EditContext.Validate();

            StateContainer.SessionInformationModifiedIndicator = Form.EditContext.IsModified();

            if (StateContainer.SessionHeaderValidIndicator) return StateContainer.SessionHeaderValidIndicator;
            MessageStore = MessageStore.OrderBy(x => x.TabIndex).ToList();

            if (MessageStore.Count > 0)
            {
                switch (MessageStore.First().FieldName)
                {
                    case nameof(StateContainer.SessionID):
                        await SessionID.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.LegacySessionID):
                        await LegacySessionID.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.SessionStatusTypeID):
                        await SessionStatusTypeID.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.CampaignID):
                        await CampaignID.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.CampaignName):
                        await CampaignName.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.CampaignType):
                        await CampaignType.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.SessionStartDate):
                        await SessionStartDate.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.SessionEndDate):
                        await SessionEndDate.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.ReportTypeID):
                        await ReportTypeID.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.SiteName):
                        await SiteName.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.OfficerName):
                        await OfficerName.Element.FocusAsync().ConfigureAwait(false);
                        break;

                    case nameof(StateContainer.DateEntered):
                        await DateEntered.Element.FocusAsync().ConfigureAwait(false);
                        break;
                }
            }

            return StateContainer.SessionInformationValidIndicator;
        }

        #endregion Validation Methods

        #endregion Methods

    }
}