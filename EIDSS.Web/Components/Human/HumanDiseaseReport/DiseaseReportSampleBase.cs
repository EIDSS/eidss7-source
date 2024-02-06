using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using Microsoft.JSInterop;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using System.Linq;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using System.Linq.Dynamic.Core;
using EIDSS.Domain.Enumerations;
using Microsoft.AspNetCore.Mvc;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class DiseaseReportSampleBase : BaseComponent
    {
        #region Grid Column Reorder Picker

        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }

        public CrossCutting.GridExtensionBase gridExtension { get; set; }

        protected override void OnInitialized()
        {
            gridExtension = new GridExtensionBase();
            GridColumnLoad("HumanDiseaseReportSamples");

            base.OnInitialized();
        }

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig = gridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public void GridColumnSave(string columnNameId)
        {
            try
            {
                gridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, _grid.ColumnsCollection.ToDynamicList(), GridContainerServices);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public int FindColumnOrder(string columnName)
        {
            var index = 0;
            try
            {
                index = gridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return index;
        }

        public bool GetColumnVisibility(string columnName)
        {
            bool visible = true;
            try
            {
                visible = gridExtension.GetColumnVisibility(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return visible;
        }

        public void HeaderCellRender(string propertyName)
        {
            try
            {
                GridContainerServices.VisibleColumnList = gridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private async Task StateContainerChangeAsync(string property)
        {
            await InvokeAsync(StateHasChanged);
        }

        #endregion Grid Column Reorder Picker

        [Parameter]
        public DiseaseReportSamplePageViewModel Model { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IHumanDiseaseReportClient HumanDiseaseReportClient { get; set; }

        [Inject]
        private IAdminClient AdminClient { get; set; }

        [Inject]
        private ILogger<DiseaseReportSampleBase> Logger { get; set; }

        [Inject]
        protected ProtectedSessionStorage BrowserStorage { get; set; }

        [Inject]
        protected HumanDiseaseReportSessionStateContainer StateContainer { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        protected bool showSampleGrid;

        protected bool enableAddButton;

        [Parameter]
        public bool isReportClosed { get; set; }

        public IList<DiseaseReportSamplePageSampleDetailViewModel> selectedSamples;

        protected bool showReason;
        protected RadzenDataGrid<DiseaseReportSamplePageSampleDetailViewModel> _grid;

        protected IEnumerable<BaseReferenceViewModel> getReasonForSampleNonCollection;

        private UserPermissions userPermissions;

        protected bool accessToHumanDiseaseReportData { get; set; }

        protected bool disableEditDelete { get; set; }

        protected bool LinkLocalSampleIDToReportSessionID = false;

        protected long constantNumber = -1;

        private struct HumaDiseaseReportPersistanceKeys
        {
            public const string HDRSample = "HDRSample";
        }

        protected override async Task OnInitializedAsync()
        {
            try
            {
                var systemPreferences = ConfigurationService.SystemPreferences;
                LinkLocalSampleIDToReportSessionID = systemPreferences.LinkLocalSampleIdToReportSessionId;

                await base.OnInitializedAsync();

                _logger = Logger;

                userPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);

                accessToHumanDiseaseReportData = userPermissions.Create;

                if (accessToHumanDiseaseReportData)
                    disableEditDelete = false;

                if (isReportClosed)
                    disableEditDelete = false;

                await JsRuntime.InvokeAsync<string>("SetSampleData", Model);
                StateContainer.SetHumanDiseaseReportSampleSessionStateViewModel(Model);

                //get the yes / no choices for radio buttons
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.YesNoValueList, HACodeList.HumanHACode);
                Model.YesNoChoices = list;

                //check the sample panel
                ToggleSamplePanel();
                ShowReason();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected void OnSamplesCollectedChange(long? value)
        {
            ToggleSamplePanel();
            ShowReason();
        }

        public async Task GetPageParams()
        {
            try
            {
                var elementId = "diseaseDD";
                var resultData = await JsRuntime.InvokeAsync<string>("getDomElementValue", elementId);
                if (!string.IsNullOrEmpty(resultData))
                {
                    Model.idfDisease = Convert.ToInt64(resultData);
                }
                elementId = "SymptomsSection_SymptomsOnsetDate";
                resultData = await JsRuntime.InvokeAsync<string>("getDomElementValue", elementId);
                if (!string.IsNullOrEmpty(resultData))
                {
                    Model.SymptomsOnsetDate = Convert.ToDateTime(resultData);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        private void ToggleSamplePanel()
        {
            if (Model.SamplesDetails is { Count: > 0 }) Model.SamplesCollectedYN = (long)YesNoUnknownEnum.Yes;

            try
            {
                if (Model.SamplesCollectedYN.GetValueOrDefault() != (long)YesNoUnknown.Yes)
                {
                    showSampleGrid = false;
                    enableAddButton = true;
                }
                else
                {
                    showSampleGrid = true;
                    enableAddButton = false;
                }

                if (isReportClosed)
                    enableAddButton = true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        private void ShowReason()
        {
            try
            {
                showReason = Model.SamplesCollectedYN.GetValueOrDefault() == (long)YesNoUnknown.No;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task OpenAddModal()
        {
            try
            {
                await GetPageParams();

                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("idfDisease", Model.idfDisease);
                dialogParams.Add("SymptomsOnsetDate", Model.AddSampleModel.SymptomsOnsetDate);
                if (Model.SamplesDetails != null)
                    dialogParams.Add("SampleDetailCount", Model.SamplesDetails.Count);
                else
                    dialogParams.Add("SampleDetailCount", 0);
                dialogParams.Add("idfHumanCase", Model.idfHumanCase);
                dialogParams.Add("strCaseId", Model.strCaseId);
                dialogParams.Add("sampleAdd", true);

                dynamic result = await DiagService.OpenAsync<DiseaseReportSampleAddModal>(Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportSamplesHeading),
                    dialogParams, new DialogOptions() { Width = "900px", Resizable = true, Draggable = false, Height = "auto" });

                if (result == null)
                    return;

                var test = result as EditContext;
                if (test != null && test.Validate())
                {
                    //var test = result as EditContext;
                    DiseaseReportSamplePageSampleDetailViewModel obj = (DiseaseReportSamplePageSampleDetailViewModel)result.Model;
                    DiseaseReportSamplePageSampleDetailViewModel item = new DiseaseReportSamplePageSampleDetailViewModel();
                    int count = 0;

                    if (Model.SamplesDetails != null)
                    {
                        count = Model.SamplesDetails.Count;
                    }

                    item.RowID = count + 1;
                    item.NewRecordId = item.RowID;
                    item.SampleTypeID = obj.SampleTypeID;
                    item.SampleType = obj.SampleType;

                    item.RowAction = (int)RowActionTypeEnum.Insert;

                    item.AccessionDate = obj.AccessionDate;
                    item.CollectionDate = obj.CollectionDate;
                    item.SentDate = obj.SentDate;

                    item.CollectedByOfficerID = obj.CollectedByOfficerID;

                    item.CollectedByOfficer = obj.CollectedByOfficer;
                    item.CollectedByOrganizationID = obj.CollectedByOrganizationID;
                    item.CollectedByOrganization = obj.CollectedByOrganization;
                    item.SentToOrganizationID = obj.SentToOrganizationID;
                    item.SentToOrganization = obj.SentToOrganization;

                    item.SampleConditionRecieved = obj.SampleConditionRecieved;
                    item.TempLocalSampleID = obj.TempLocalSampleID;
                    item.LocalSampleId = obj.LocalSampleId;
                    item.idfsSiteSentToOrg = obj.idfsSiteSentToOrg;

                    if (!LinkLocalSampleIDToReportSessionID && item.TempLocalSampleID == item.LocalSampleId)
                        item.blnNumberingSchema = 1;
                    else if (LinkLocalSampleIDToReportSessionID && item.TempLocalSampleID != item.LocalSampleId)
                    {
                        item.blnNumberingSchema = 1;
                    }
                    else if (LinkLocalSampleIDToReportSessionID && item.LocalSampleId == item.TempLocalSampleID && (Model.idfHumanCase == null || Model.idfHumanCase == 0))
                    {
                        item.blnNumberingSchema = 2;
                    }
                    if (Model.SamplesDetails == null)
                        Model.SamplesDetails = new List<DiseaseReportSamplePageSampleDetailViewModel>();
                    Model.SamplesCollectedYN = (long)YesNoUnknown.Yes;
                    Model.SamplesDetails.Add(item);
                    ToggleSamplePanel();
                    if (_grid != null)
                    {
                        await _grid.Reload();
                        await JsRuntime.InvokeAsync<string>("SetSampleData", Model);
                        StateContainer.SetHumanDiseaseReportSampleSessionStateViewModel(Model);
                    }
                }
                else
                {
                    //Logger.LogInformation("HandleSubmit called: Form is INVALID");
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task OpenEditModal(DiseaseReportSamplePageSampleDetailViewModel data)
        {
            try
            {
                var dialogParams = new Dictionary<string, object>();
                dialogParams.Add("Model", data);
                dialogParams.Add("idfDisease", Model.idfDisease);
                dialogParams.Add("SymptomsOnsetDate", Model.AddSampleModel.SymptomsOnsetDate);
                if (Model.SamplesDetails != null)
                    dialogParams.Add("SampleDetailCount", Model.SamplesDetails.Count);
                else
                    dialogParams.Add("SampleDetailCount", 0);
                dialogParams.Add("idfHumanCase", Model.idfHumanCase);
                dialogParams.Add("strCaseId", Model.strCaseId);
                dialogParams.Add("sampleAdd", false);
                dialogParams.Add("IsReportClosed", Model.IsReportClosed);

                dynamic result = await DiagService.OpenAsync<DiseaseReportSampleAddModal>(Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportSamplesHeading),
                    dialogParams, new DialogOptions() { Width = "700px", Resizable = true, Draggable = false });

                if (result == null)
                    return;

                if ((result as EditContext).Validate())
                {
                    var test = result as EditContext;
                    DiseaseReportSamplePageSampleDetailViewModel obj = (DiseaseReportSamplePageSampleDetailViewModel)result.Model;
                    DiseaseReportSamplePageSampleDetailViewModel item = new DiseaseReportSamplePageSampleDetailViewModel();
                    DiseaseReportSamplePageSampleDetailViewModel oldItem = new DiseaseReportSamplePageSampleDetailViewModel();
                    int count = 0;
                    if (Model.SamplesDetails != null)
                    {
                        count = Model.SamplesDetails.Count;
                        oldItem = Model.SamplesDetails.Find(x => x.RowID == obj.RowID);
                        if (oldItem != null)
                        {
                            //int count = Model.SamplesDetails.Count;
                            item.RowID = oldItem.RowID;
                            item.NewRecordId = item.RowID;
                            item.idfMaterial = obj.idfMaterial;
                            item.SampleTypeID = obj.SampleTypeID;
                            item.SampleType = obj.SampleType;
                            item.RowAction = (int)RowActionTypeEnum.Update;
                            item.AccessionDate = obj.AccessionDate;
                            item.CollectionDate = obj.CollectionDate;
                            item.SentDate = obj.SentDate;

                            item.CollectedByOfficerID = obj.CollectedByOfficerID;

                            item.CollectedByOfficer = obj.CollectedByOfficer;
                            item.CollectedByOrganizationID = obj.CollectedByOrganizationID;
                            item.CollectedByOrganization = obj.CollectedByOrganization;
                            item.SentToOrganizationID = obj.SentToOrganizationID;
                            item.SentToOrganization = obj.SentToOrganization;

                            item.SampleConditionRecieved = obj.SampleConditionRecieved;
                            item.TempLocalSampleID = obj.TempLocalSampleID;
                            item.LocalSampleId = obj.LocalSampleId;
                            item.idfsSiteSentToOrg = obj.idfsSiteSentToOrg;

                            if (!LinkLocalSampleIDToReportSessionID && item.TempLocalSampleID == item.LocalSampleId)
                                item.blnNumberingSchema = 1;
                            else if (LinkLocalSampleIDToReportSessionID && item.TempLocalSampleID != item.LocalSampleId)
                            {
                                item.blnNumberingSchema = 1;
                            }
                            else if (LinkLocalSampleIDToReportSessionID && item.LocalSampleId == item.TempLocalSampleID && (Model.idfHumanCase == null || Model.idfHumanCase == 0))
                            {
                                item.blnNumberingSchema = 2;
                            }

                            item.SampleType = obj.SampleType;
                            item.FunctionalAreaID = obj.FunctionalAreaID;
                            item.LabSampleID = obj.LabSampleID;
                            item.SampleStatus = obj.SampleStatus;
                            item.AdditionalTestNotes = obj.AdditionalTestNotes;

                            if (Model.SamplesDetails == null)
                                Model.SamplesDetails = new List<DiseaseReportSamplePageSampleDetailViewModel>();
                            Model.SamplesCollectedYN = (long)YesNoUnknown.Yes;

                            Model.SamplesDetails.Remove(oldItem);
                            Model.SamplesDetails.Add(item);
                            ToggleSamplePanel();
                            if (_grid != null)
                            {
                                await _grid.Reload();
                                await JsRuntime.InvokeAsync<string>("SetSampleData", Model);
                                StateContainer.SetHumanDiseaseReportSampleSessionStateViewModel(Model);
                            }
                        }
                    }
                }
                else
                {
                    //Logger.LogInformation("HandleSubmit called: Form is INVALID");
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task DeleteRow(DiseaseReportSamplePageSampleDetailViewModel item)
        {
            try
            {
                if (Model.SamplesDetails != null && Model.SamplesDetails.Contains(item))
                {
                    var list = StateContainer.TestModel.TestDetails;
                    var hasTest = list.Any(a => a.idfMaterial == item.idfMaterial && a.intRowStatus == 0);

                    var isDelete = false;
                    if (hasTest)
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
                                { nameof(EIDSSDialog.DialogButtons), buttons },
                                {
                                    nameof(EIDSSDialog.Message),
                                    Localizer.GetString(MessageResourceKeyConstants
                                        .UnableToDeleteBecauseOfChildRecordsMessage)
                                }
                            };
                        await DiagService.OpenAsync<EIDSSDialog>(Localizer.GetString(HeadingResourceKeyConstants.EIDSSModalHeading), dialogParams);
                    }
                    else if (item.blnAccessioned != null && item.blnAccessioned.Value)
                    {
                        var blnAccessionedResult =
                            await ShowWarningDialog(Localizer.GetString(MessageResourceKeyConstants.HumanDiseaseReportSamplesSampleIsAccessionedDoYouWantToDeleteTheSampleRecordMessage), null);

                        if ((blnAccessionedResult as DialogReturnResult)?.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            isDelete = true;
                        }
                    }
                    else
                    {
                        var result =
                            await ShowWarningDialog(Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage), null);

                        if ((result as DialogReturnResult)?.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                        {
                            isDelete = true;
                        }
                    }

                    if (isDelete)
                    {
                        item.intRowStatus = (int)RowStatusTypeEnum.Inactive;

                        await JsRuntime.InvokeAsync<string>("SetSampleData", Model);
                        StateContainer.SetHumanDiseaseReportSampleSessionStateViewModel(Model);

                        Model.SamplesDetails = Model.SamplesDetails.Where(d => d.intRowStatus == 0).ToList();
                    }

                    await _grid.Reload();
                }
                else
                {
                    _grid.CancelEditRow(item);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        protected async Task OpenAddReasonModal()
        {
            try
            {
                dynamic result = await DiagService.OpenAsync<DiseaseReportSampleReasonAddModal>(Localizer.GetString(HeadingResourceKeyConstants.BaseReferenceDetailsModalHeading),
                    null, new DialogOptions() { Width = "700px", Resizable = true, Draggable = false });

                if (result == null)
                    return;

                if ((result as EditContext).Validate())
                {
                    var test = result as EditContext;
                    BaseReferenceViewModel obj = (BaseReferenceViewModel)result.Model;
                    BaseReferenceSaveRequestModel baseReferenceSaveRequestModel = new BaseReferenceSaveRequestModel
                    {
                        intHACode = obj.IntHACode,
                        intOrder = obj.IntOrder,
                        LanguageId = GetCurrentLanguage(),
                        ReferenceTypeId = BaseReferenceTypeIds.ReasonForNotCollectingSample,
                        Default = obj.StrDefault,
                        Name = obj.Name,
                        EventTypeId = (long)SystemEventLogTypes.ReferenceTableChange,
                        AuditUserName = authenticatedUser.UserName,
                        LocationId = authenticatedUser.RayonId,
                        SiteId = Convert.ToInt64(authenticatedUser.SiteId),
                        UserId = Convert.ToInt64(authenticatedUser.EIDSSUserId)
                    };

                    var response = await AdminClient.SaveBaseReference(baseReferenceSaveRequestModel);
                    await GetReasonForSampleNonCollection(null);
                }
                else
                {
                    //Logger.LogInformation("HandleSubmit called: Form is INVALID");
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task GetReasonForSampleNonCollection(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.ReasonfornotCollectingSample, HACodeList.HumanHACode);
                getReasonForSampleNonCollection = list.AsODataEnumerable();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task UpdateNotes(Object Value, int Index)
        {
            try
            {
                if (Value != null)
                {
                    Model.SamplesDetails.Skip(Index).FirstOrDefault().strNote = Value.ToString();
                }
                await JsRuntime.InvokeAsync<string>("SetSampleData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }
    }
}