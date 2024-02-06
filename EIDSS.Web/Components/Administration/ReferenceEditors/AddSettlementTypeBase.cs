using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Administration.ReferenceEditors
{
    public class AddSettlementTypeBase : BaseComponent, IDisposable
    {
        #region Dependencies        

        [Inject] private ISettlementClient SettlementClient { get; set; }
        [Inject] private ILogger<AddSettlementType> Logger { get; set; }
        //[Inject] protected DialogService DiagServiceForDuplicationWarning { get; set; }

        #endregion

        #region Properties

        public SettlementTypeModel SettlementTypeToAdd { get; set; } = new();
        public RadzenTemplateForm<SettlementTypeModel> Form { get; set; }

        #endregion

        #region Member Variables

        #endregion

        #region Methods

        #region Life Cycle Events

        protected override void OnInitialized()
        {
            _logger = Logger;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            DiagService.OnOpen += Open;
            DiagService.OnClose += Close;

            base.OnInitialized();
        }

        public void Dispose()
        {
            DiagService.OnOpen -= Open;
            DiagService.OnClose -= Close;
        }

        void Open(string title, Type type, Dictionary<string, object> parameters, DialogOptions options)
        {
            //console.Log("Dialog opened");
        }

        void Close(dynamic result)
        {
            //console.Log($"Dialog closed");
        }

        #endregion

        #region Save Button Click Event

        public async Task OnSubmitClick()
        {
            try
            {
                if (!Form.EditContext.Validate()) return;

                SettlementTypeSaveRequestModel request = new SettlementTypeSaveRequestModel();
                request.IdfsGISBaseReference = null;
                request.LangID = GetCurrentLanguage();
                request.StrDefault = SettlementTypeToAdd.strDefault;
                request.StrNationalName = SettlementTypeToAdd.name;
                request.IntOrder = SettlementTypeToAdd.intOrder;
                request.RowStatus = 0;
                request.UserID = authenticatedUser.UserName;                

                SettlementTypeSaveRequestResponseModel response = await SettlementClient.SaveSettlementType(request);
                dynamic result;

                switch (response.ReturnMessage)
                {
                    case EIDSSConstants.DatabaseResponses.Success:
                        result = await ShowInformationalDialog(MessageResourceKeyConstants.RecordSavedSuccessfullyMessage, null);

                        if (result is DialogReturnResult)
                            DiagService.Close(response);
                        break;
                    case EIDSSConstants.DatabaseResponses.DoesExist:
                        response.StrDuplicateField = SettlementTypeToAdd.strDefault;
                        var duplicateMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateReferenceValueMessage), response.StrDuplicateField);

                        //result = await ShowWarningDialog(null, duplicateMessage);
                        result = await ShowDuplicateMessage(null, duplicateMessage);

                        if (result is DialogReturnResult returnResult)
                        {
                            if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                                DiagService.Close(null);
                        }
                        break;
                }

                //DiagService.Close(response);
                //DiagService.Close(Form.EditContext);        
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Cancel Button Click Event

        protected async Task OnCancel()
        {
            try
            {
                await InvokeAsync(StateHasChanged);

                if (Form.EditContext.IsModified())
                {
                    var result = await ShowWarningDialog(MessageResourceKeyConstants.DoYouWantToCancelChangesMessage, null);

                    if (result is DialogReturnResult returnResult)
                        if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                            DiagService.Close(null);
                }
                else
                    DiagService.Close();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        #endregion

        #region Duplicate Message

        protected async Task<dynamic> ShowDuplicateMessage(string message, string localizedMessage)
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

            return await DiagService.OpenAsync<EIDSSDialog>(null, dialogParams);
        }

        #endregion

        #endregion
    }
}
