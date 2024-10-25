using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Administration.ReferenceEditors
{
    public class SettlementTypesBase : BaseComponent, IDisposable
    {
        #region Dependencies

        [Inject] private ILogger<SettlementTypes> Logger { get; set; }
        [Inject] private ISettlementClient SettlementClient { get; set; }

        #endregion

        #region Properties

        public List<SettlementTypeModel> SettlementTypes;
        public RadzenDataGrid<SettlementTypeModel> SettlementTypesGrid;
        public SettlementTypeModel SettlementTypeToInsert;
        public string SettlementTypeOriginalJSON;
        public int Count { get; set; }
        public string SearchTerm { get; set; }
        protected bool CanAddSettlementType { get; set; }
        protected bool CanDeleteSettlementType { get; set; }
        protected bool CanEditSettlementType { get; set; }

        #endregion

        #region Member Variables        

        private UserPermissions userPermissions;

        #endregion

        #region Methods

        #region Life Cycle Events

        protected async override Task OnInitializedAsync()
        {
            _logger = Logger;

            userPermissions = GetUserPermissions(PagePermission.CanManageReferencesAndConfigurations);

            CanAddSettlementType = userPermissions.Create;
            CanEditSettlementType = userPermissions.Write;
            CanDeleteSettlementType = userPermissions.Delete;

            authenticatedUser = _tokenService.GetAuthenticatedUser();

            base.OnInitialized();

            DiagService.OnOpen += Open;
            DiagService.OnClose += Close;

            SettlementTypes = await SettlementClient.GetSettlementTypeList(GetCurrentLanguage());
            SettlementTypes = SettlementTypes.Where(x => x.intRowStatus == 0).ToList();
            int rowCount = 0;
            foreach (var s in SettlementTypes)
            {
                s.RowCount = rowCount + 1;
                rowCount++;
            }
            Count = SettlementTypes.Count;
        }

        public void Dispose()
        {
            //throw new NotImplementedException();
        }

        #endregion

        #region DataGrid Events

        void Open(string title, Type type, Dictionary<string, object> parameters, DialogOptions options)
        {
            //console.Log("Dialog opened");
        }

        void Close(dynamic result)
        {
            //console.Log($"Dialog closed");
        }

        public async Task AddSettlementType()
        {
            dynamic result = await DiagService.OpenAsync<AddSettlementType>(Localizer.GetString(HeadingResourceKeyConstants.SettlementTypeReferenceEditorSettlementTypeDetailsHeading),
                null,
                new DialogOptions() { Width = "700px", Resizable = true, Draggable = false });

            if (result != null)
            {
                var response = (SettlementTypeSaveRequestResponseModel)result;

                if (response.ReturnMessage == EIDSSConstants.DatabaseResponses.Success)
                {
                    //var uri = $"{NavManager.BaseUri}Administration/SettlementTypes";
                    //NavManager.NavigateTo(uri, true);

                    SettlementTypes = await SettlementClient.GetSettlementTypeList(GetCurrentLanguage());
                    await SettlementTypesGrid.Reload();
                }

                //todo: refresh grid or page?
                //await settlementTypesGrid.Reload();

                //if (response.ReturnMessage == "SUCCESS")
                //{
                //    var uri = $"{NavManager.BaseUri}Administration/SettlementTypes";
                //    NavManager.NavigateTo(uri, true);
                //}
                //else if (response.ReturnMessage == "DOES EXIST")
                //{
                //    await ShowDuplicateMessage();
                //}
                //await settlementTypesGrid.InsertRow(newSettlementType);
            }           
        }

        protected async Task EditRow(SettlementTypeModel settlementType)
        {
            SettlementTypeOriginalJSON = JsonConvert.SerializeObject(settlementType);
            await SettlementTypesGrid.EditRow(settlementType);
        }

        protected async Task OnUpdateRow(SettlementTypeModel settlementType)
        {
            try
            {
                if (settlementType == SettlementTypeToInsert)
                {
                    SettlementTypeToInsert = null;
                }

                SettlementTypeSaveRequestModel request = new SettlementTypeSaveRequestModel();
                request.IdfsGISBaseReference = settlementType.idfsReference;
                request.LangID = GetCurrentLanguage();
                request.StrDefault = settlementType.strDefault;
                request.StrNationalName = settlementType.name;
                request.IntOrder = settlementType.intOrder;
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
                        response.StrDuplicateField = settlementType.strDefault;
                        var duplicateMessage = string.Format(Localizer.GetString(MessageResourceKeyConstants.DuplicateReferenceValueMessage), response.StrDuplicateField);

                        //result = await ShowWarningDialog(null, duplicateMessage);
                        result = await ShowDuplicateMessage(null, duplicateMessage);

                        if (result is DialogReturnResult returnResult)
                        {
                            if (returnResult.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.OKButton))
                            {
                                int index = SettlementTypes.FindIndex(x => x == settlementType);

                                if (index != -1)
                                {
                                    SettlementTypes[index] = JsonConvert.DeserializeObject<SettlementTypeModel>(SettlementTypeOriginalJSON);
                                    await SettlementTypesGrid.Reload();
                                }

                                DiagService.Close(null);
                            }
                        }
                        break;
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }

        }

        protected async Task SaveRow(SettlementTypeModel settlementType)
        {
            if (settlementType == SettlementTypeToInsert)
            {
                SettlementTypeToInsert = null;
            }

            await SettlementTypesGrid.UpdateRow(settlementType);
        }

        protected void CancelEdit(SettlementTypeModel settlementType)
        {
            SettlementTypesGrid.CancelEditRow(settlementType);

            int index = SettlementTypes.FindIndex(x => x == settlementType);

            if (index != -1)
            {
                SettlementTypes[index] = JsonConvert.DeserializeObject<SettlementTypeModel>(SettlementTypeOriginalJSON);
                SettlementTypesGrid.Reload();
            }

        }        

        protected async Task DeleteRow(SettlementTypeModel settlementType)
        {
            if (settlementType == SettlementTypeToInsert)
            {
                SettlementTypeToInsert = null;
            }

            if (SettlementTypes.Contains(settlementType))
            {
                await ShowConfirmDeleteMessage(settlementType);

                //FIRE DATABASE CALL
                //dbContext.Remove<SettlementType>(settlementType);

                // For demo purposes only
                //settlementTypes.Remove(settlementType);

                // For production
                //dbContext.SaveChanges();

                await SettlementTypesGrid.Reload();
            }
            else
            {
                SettlementTypesGrid.CancelEditRow(settlementType);
            }
        }
        async Task InsertRow()
        {
            SettlementTypeToInsert = new SettlementTypeModel();
            await SettlementTypesGrid.InsertRow(SettlementTypeToInsert);
        }

        protected void OnCreateRow(SettlementTypeModel settlementType)
        {
            //FIRE DATABASE CALL
            //dbContext.Add(settlementType);

            // For demo purposes only
            //order.Customer = dbContext.Customers.Find(order.CustomerID);
            //order.Employee = dbContext.Employees.Find(order.EmployeeID);

            // For production
            //dbContext.SaveChanges();
        }

        #endregion

        #region Delete Confirmation Diaglog

        protected async Task ShowConfirmDeleteMessage(SettlementTypeModel settlementType)
        {
            try
            {
                var buttons = new List<DialogButton>();

                var yesButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.YesButton),
                    ButtonType = DialogButtonType.Yes
                };
                buttons.Add(yesButton);

                var noButton = new DialogButton()
                {
                    ButtonText = Localizer.GetString(ButtonResourceKeyConstants.NoButton),
                    ButtonType = DialogButtonType.No
                };
                buttons.Add(noButton);

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add(nameof(EIDSSDialog.DialogButtons), buttons);
                dialogParams.Add(nameof(EIDSSDialog.Message), Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage));

                dynamic result = await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);

                if (result.GetType() == typeof(DialogReturnResult))
                {
                    var confirmation = (DialogReturnResult)result;
                    if (confirmation.ButtonResultText == "Yes")
                    {
                        SettlementTypeSaveRequestModel request = new SettlementTypeSaveRequestModel();
                        request.IdfsGISBaseReference = settlementType.idfsReference;
                        request.LangID = GetCurrentLanguage();
                        request.StrDefault = settlementType.strDefault;
                        request.StrNationalName = settlementType.name;
                        request.IntOrder = settlementType.intOrder;
                        request.RowStatus = 1;
                        request.UserID = authenticatedUser.UserName;
                        SettlementTypeSaveRequestResponseModel response = await SettlementClient.SaveSettlementType(request);

                        SettlementTypes.Remove(settlementType);
                    }
                    else
                    {
                        SettlementTypesGrid.CancelEditRow(settlementType);
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

        #region 

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

        #region Search Event

        protected async Task Search()
        {
            if (!string.IsNullOrEmpty(SearchTerm))
            {
                SettlementTypes = SettlementTypes.Where(x => x.strDefault.ToLower().Contains(SearchTerm.ToLower())).ToList();
            }
            else
            {
                SettlementTypes = await SettlementClient.GetSettlementTypeList(GetCurrentLanguage());
            }

            await SettlementTypesGrid.Reload();
        }

        #endregion

        #region Clear Search

        protected async Task ClearSearch()
        {
            SettlementTypes = await SettlementClient.GetSettlementTypeList(GetCurrentLanguage());
            await SettlementTypesGrid.Reload();
        }

        #endregion

        #endregion
    }
}
