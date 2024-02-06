using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
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
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.Services;
using System.Linq;
using EIDSS.Domain.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using System.Linq.Dynamic.Core;
using static System.String;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class DiseaseReportTestBase : BaseComponent
    {
        #region Grid Column Reorder Picker

        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }

        public GridExtensionBase GridExtension { get; set; }

        protected override void OnInitialized()
        {
            GridExtension = new GridExtensionBase();
            GridColumnLoad("HumanDiseaseReportTest");

            base.OnInitialized();
        }

        public void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig = GridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
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
                GridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, Grid.ColumnsCollection.ToDynamicList(), GridContainerServices);
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
                index = GridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return index;
        }

        public bool GetColumnVisibility(string columnName)
        {
            var visible = true;
            try
            {
                visible = GridExtension.GetColumnVisibility(columnName);
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
                GridContainerServices.VisibleColumnList = GridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        #endregion Grid Column Reorder Picker

        [Parameter]
        public DiseaseReportTestPageViewModel Model { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private ILogger<DiseaseReportSampleBase> Logger { get; set; }

        [Inject]
        protected HumanDiseaseReportSessionStateContainer StateContainer { get; set; }

        [Inject]
        protected INotificationSiteAlertService NotificationService { get; set; }

        protected bool ShowTestGrid;

        protected bool EnableAddButton;

        [Parameter]
        public bool isReportClosed { get; set; }

        [Parameter]
        public bool CanAddTests { get; set; }

        public IList<DiseaseReportTestDetailForDiseasesViewModel> SelectedTests;

        protected RadzenDataGrid<DiseaseReportTestDetailForDiseasesViewModel> Grid;

        private UserPermissions _userPermissions;

        private UserPermissions _canAddTestResultsForHumanCaseSession;

        protected bool AccessToHumanDiseaseReportData { get; set; }

        protected bool DisableEditDelete { get; set; }

        protected override async Task OnInitializedAsync()
        {
            try
            {
                await base.OnInitializedAsync();

                _logger = Logger;

                _userPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);

                AccessToHumanDiseaseReportData = _userPermissions.Create;

                _canAddTestResultsForHumanCaseSession = GetUserPermissions(PagePermission.CanAddTestResultsForHumanCase_Session);

                if (AccessToHumanDiseaseReportData)
                    DisableEditDelete = false;

                if (isReportClosed)
                    DisableEditDelete = true;

                StateContainer.SetHumanDiseaseReportTestSessionStateViewModel(Model);

                var count = 1;
                foreach (var t in Model.TestDetails)
                {
                    t.RowID = count;
                    count++;
                }

                Model.TestDetailsForGrid = Model.TestDetails;

                if (StateContainer.Model?.SamplesDetails != null)
                {
                    Model.SamplesDetails = StateContainer.Model.SamplesDetails;
                }

                await JsRuntime.InvokeAsync<string>("SetTestData", Model);
                //subscribe to the modal dialog events
                // DiagService.OnOpen += ModalOpen;
                // DiagService.OnClose += ModalClose;

                //get the yes / no choices for radio buttons
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.YesNoValueList, HACodeList.HumanHACode);
                Model.YesNoChoices = list;

                //check the sample panel
                ToggleTestPanel();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        protected void OnTestsCollectedChange(long? value)
        {
            ToggleTestPanel();
        }

        public async Task GetPageParams()
        {
            try
            {
                const string elementId = "diseaseDD";
                var resultData = await JsRuntime.InvokeAsync<string>("getDomElementValue", elementId);
                if (!IsNullOrEmpty(resultData))
                {
                    Model.idfDisease = Convert.ToInt64(resultData);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        private void ToggleTestPanel()
        {
            try
            {
                if (AccessToHumanDiseaseReportData && _canAddTestResultsForHumanCaseSession.Execute && Model.SamplesDetails is
                    {
                        Count: > 0
                    })
                {
                    if (Model.TestsConducted.GetValueOrDefault() != (long)YesNoUnknown.Yes)
                    {
                        ShowTestGrid = Model.SamplesDetails is {Count: > 0};
                        EnableAddButton = true;
                    }
                    else
                    {
                        ShowTestGrid = true;
                        EnableAddButton = false;
                    }
                }
                else
                {
                    ShowTestGrid = false;
                    EnableAddButton = true;
                }
                if (isReportClosed)
                    EnableAddButton = true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public void Dispose()
        {
            StateContainer.OnChange -= StateHasChanged;
        }

        protected async Task OpenAddModal()
        {
            try
            {
                await GetPageParams();

                var dialogParams = new Dictionary<string, object>
                {
                    {"idfDisease", Model.idfDisease},
                    {"idfHumanCase", Model.idfHumanCase},
                    {"strCaseId", Model.strCaseId},
                    {"LocalSampleID", Model.LocalSampleID},
                    {"SamplesDetails", Model.SamplesDetails}
                };

                var result = await DiagService.OpenAsync<DiseaseReportTestAddModal>(Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportTestsDetailHeading),
                    dialogParams, new DialogOptions { Width = "900px", Resizable = true, Draggable = false });

                if (result == null)
                    return;

                if (((EditContext) result).Validate())
                {
                    var obj = (DiseaseReportTestDetailForDiseasesViewModel)result.Model;
                    var item = new DiseaseReportTestDetailForDiseasesViewModel();
                    if (Model.TestDetails != null)
                    {
                    }
                    switch (Model.SamplesDetails)
                    {
                        case {Count: > 0} when Model.idfHumanCase is null or 0:
                            item.NewRecordId = Model.SamplesDetails.Find(a => a.LocalSampleId == obj.strFieldBarcode).NewRecordId;
                            item.idfMaterial = obj.idfMaterial == 0 ? Model.SamplesDetails.Find(a => a.LocalSampleId == obj.strFieldBarcode).NewRecordId : obj.idfMaterial;
                            break;
                        case {Count: > 0} when Model.idfHumanCase != null && Model.idfHumanCase != 0:
                        {
                            item.idfMaterial = obj.idfMaterial == 0 ? Model.SamplesDetails.Find(a => a.LocalSampleId == obj.strFieldBarcode).SampleKey : obj.idfMaterial;

                            if (item.idfMaterial == 0)
                            {
                                item.NewRecordId = Model.SamplesDetails.Find(a => a.LocalSampleId == obj.strFieldBarcode).NewRecordId;
                                item.idfMaterial = obj.idfMaterial == 0 ? Model.SamplesDetails.Find(a => a.LocalSampleId == obj.strFieldBarcode).NewRecordId : obj.idfMaterial;
                            }

                            break;
                        }
                    }

                    item.intRowStatus = (int)RowStatusTypeEnum.Active;
                    item.idfHumanCase = obj.idfHumanCase;
                    item.idfFieldCollectedByOffice = obj.idfFieldCollectedByOffice;
                    item.RowAction = (int)RowActionTypeEnum.Insert;
                    item.blnNonLaboratoryTest = true;
                    item.blnValidateStatus = obj.blnValidateStatus;

                    item.idfsYNTestsConducted = (long)YesNoUnknown.Yes;
                    item.datConcludedDate = obj.datConcludedDate;
                    item.datFieldCollectionDate = obj.datFieldCollectionDate;
                    item.datFieldSentDate = obj.datFieldSentDate;
                    item.datInterpretedDate = obj.datInterpretedDate;
                    item.datReceivedDate = obj.datReceivedDate;
                    item.datSampleStatusDate = obj.datSampleStatusDate;
                    item.datValidationDate = obj.datValidationDate;

                    item.filterTestByDisease = obj.filterTestByDisease;
                    item.idfFieldCollectedByOffice = obj.idfFieldCollectedByOffice;

                    item.idfFieldCollectedByPerson = obj.idfFieldCollectedByPerson;
                    item.idfHumanCase = obj.idfHumanCase;
                    item.idfInterpretedByPerson = obj.idfInterpretedByPerson;

                    item.idfsDiagnosis = obj.idfsDiagnosis;
                    item.idfSendToOffice = obj.idfSendToOffice;

                    item.idfsInterpretedStatus = obj.idfsInterpretedStatus;
                    item.idfsSampleStatus = obj.idfsSampleStatus;
                    item.idfsSampleType = obj.idfsSampleType;
                    item.idfsTestCategory = obj.idfsTestCategory;
                    item.idfsTestName = obj.idfsTestName;
                    item.idfsTestResult = obj.idfsTestResult;
                    item.idfsTestStatus = obj.idfsTestStatus;
                    item.idfTestedByOffice = obj.idfTestedByOffice;
                    item.idfTestedByPerson = obj.idfTestedByPerson;
                    item.idfTesting = obj.idfTesting;
                    item.idfValidatedByPerson = obj.idfValidatedByPerson;
                    item.name = obj.name;
                    item.sampleGuid = obj.sampleGuid;
                    item.SampleStatusTypeName = obj.SampleStatusTypeName;
                    item.strBarcode = obj.strBarcode;
                    item.strDiagnosis = obj.strDiagnosis;
                    item.strFieldBarcode = obj.strFieldBarcode;
                    item.strInterpretedBy = obj.strInterpretedBy;
                    item.strInterpretedComment = obj.strInterpretedComment;
                    item.strInterpretedStatus = obj.strInterpretedStatus;
                    item.strSampleTypeName = obj.strSampleTypeName;
                    item.strTestCategory = obj.strTestCategory;
                    item.strTestedByOffice = obj.strTestedByOffice;
                    item.strTestedByPerson = obj.strTestedByPerson;
                    item.strTestResult = obj.strTestResult;
                    item.strTestStatus = obj.strTestStatus;
                    item.strValidateComment = obj.strValidateComment;
                    item.strValidatedBy = obj.strValidatedBy;
                    item.testGuid = obj.testGuid;
                    item.blnNonLaboratoryTest = true;

                    Model.TestDetails ??= new List<DiseaseReportTestDetailForDiseasesViewModel>();
                    Model.TestDetails.Add(item);

                    await GetSiteAlertForTestResultCreation();

                    StateContainer.SetHumanDiseaseReportTestSessionStateViewModel(Model);
                    await JsRuntime.InvokeAsync<string>("SetTestData", Model);
                    if (Grid != null)
                        await Grid.Reload();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        protected async Task OpenEditModal(DiseaseReportTestDetailForDiseasesViewModel data)
        {
            try
            {
                await GetPageParams();
                var dialogParams = new Dictionary<string, object>
                {
                    {"Model", data},
                    {"idfDisease", Model.idfDisease},
                    {"idfHumanCase", Model.idfHumanCase},
                    {"strCaseId", Model.strCaseId},
                    {"LocalSampleID", Model.LocalSampleID},
                    {"SamplesDetails", Model.SamplesDetails},
                    {"IsReportClosed", isReportClosed}
                };

                var result = await DiagService.OpenAsync<DiseaseReportTestAddModal>(Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportTestsDetailHeading),
                    dialogParams, new DialogOptions() { Width = "700px", Resizable = true, Draggable = false });

                if (result == null)
                    return;

                if (((EditContext) result).Validate())
                {
                    var obj = (DiseaseReportTestDetailForDiseasesViewModel)result.Model;
                    var item = new DiseaseReportTestDetailForDiseasesViewModel();

                    if (Model.TestDetails != null)
                    {
                        var count = Model.TestDetails.Count;
                        var oldItem = Model.TestDetails.Find(x => x.RowID == obj.RowID);

                        //int count = Model.SamplesDetails.Count;
                        item.RowID = obj.RowID;
                        item.idfMaterial = obj.idfMaterial;
                        //item.new = obj.ID;
                        item.idfHumanCase = obj.idfHumanCase;
                        item.idfFieldCollectedByOffice = obj.idfFieldCollectedByOffice;
                        item.RowAction = (int)RowActionTypeEnum.Update;
                        item.idfsYNTestsConducted = (long)YesNoUnknown.Yes;

                        item.blnNonLaboratoryTest = obj.blnNonLaboratoryTest;
                        item.blnValidateStatus = obj.blnValidateStatus;

                        item.datConcludedDate = obj.datConcludedDate;
                        item.datFieldCollectionDate = obj.datFieldCollectionDate;
                        item.datFieldSentDate = obj.datFieldSentDate;
                        item.datInterpretedDate = obj.datInterpretedDate;
                        item.datReceivedDate = obj.datReceivedDate;
                        item.datSampleStatusDate = obj.datSampleStatusDate;
                        item.datValidationDate = obj.datValidationDate;

                        item.filterTestByDisease = obj.filterTestByDisease;
                        item.idfFieldCollectedByOffice = obj.idfFieldCollectedByOffice;

                        if (obj.idfTestValidation is null or <= 0)
                            item.idfTestValidation = item.RowID *-1;
                        else
                            item.idfTestValidation = obj.idfTestValidation;

                        item.idfFieldCollectedByPerson = obj.idfFieldCollectedByPerson;
                        item.idfHumanCase = obj.idfHumanCase;
                        item.idfInterpretedByPerson = obj.idfInterpretedByPerson;

                        item.idfsDiagnosis = obj.idfsDiagnosis;
                        item.idfSendToOffice = obj.idfSendToOffice;

                        item.idfsInterpretedStatus = obj.idfsInterpretedStatus;
                        item.idfsSampleStatus = obj.idfsSampleStatus;
                        item.idfsSampleType = obj.idfsSampleType;
                        item.idfsTestCategory = obj.idfsTestCategory;
                        item.idfsTestName = obj.idfsTestName;
                        item.idfsTestResult = obj.idfsTestResult;
                        item.idfsTestStatus = obj.idfsTestStatus;
                        item.idfTestedByOffice = obj.idfTestedByOffice;
                        item.idfTestedByPerson = obj.idfTestedByPerson;
                        item.idfTesting = obj.idfTesting;
                        item.idfValidatedByPerson = obj.idfValidatedByPerson;
                        item.name = obj.name;
                        item.sampleGuid = obj.sampleGuid;
                        item.SampleStatusTypeName = obj.SampleStatusTypeName;
                        item.strBarcode = obj.strBarcode;
                        item.strDiagnosis = obj.strDiagnosis;
                        item.strFieldBarcode = obj.strFieldBarcode;
                        item.strInterpretedBy = obj.strInterpretedBy;
                        item.strInterpretedComment = obj.strInterpretedComment;
                        item.strInterpretedStatus = obj.strInterpretedStatus;
                        item.strSampleTypeName = obj.strSampleTypeName;
                        item.strTestCategory = obj.strTestCategory;
                        item.strTestedByOffice = obj.strTestedByOffice;
                        item.strTestedByPerson = obj.strTestedByPerson;
                        item.strTestResult = obj.strTestResult;
                        item.strTestStatus = obj.strTestStatus;
                        item.strValidateComment = obj.strValidateComment;
                        item.strValidatedBy = obj.strValidatedBy;
                        item.testGuid = obj.testGuid;
                        item.intRowStatus = obj.intRowStatus;
                        item.blnNonLaboratoryTest = obj.blnNonLaboratoryTest;

                        Model.TestDetails ??= new List<DiseaseReportTestDetailForDiseasesViewModel>();
                        Model.TestDetails.Remove(oldItem);
                        Model.TestDetails.Add(item);
                        if (obj.OriginalTestResultTypeId != obj.idfsTestResult && obj.idfTesting is not null)
                        {
                            await GetSiteAlertForLabTestResultAmendment();
                        }

                        if (obj.idfsInterpretedStatus is not null && obj.idfTestValidation is null)
                        {
                            await GetSiteAlertForTestInterpretation();
                        }

                        StateContainer.SetHumanDiseaseReportTestSessionStateViewModel(Model);
                        await JsRuntime.InvokeAsync<string>("SetTestData", Model);
                        if (Grid != null)
                            await Grid.Reload();
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

        protected async Task DeleteRow(DiseaseReportTestDetailForDiseasesViewModel item)
        {
            try
            {
                var result =
                    await ShowWarningDialog(Localizer.GetString(MessageResourceKeyConstants.DoYouWantToDeleteThisRecordMessage), null);

                if ((result as DialogReturnResult)?.ButtonResultText == Localizer.GetString(ButtonResourceKeyConstants.YesButton))
                {
                    DiagService.Close(result);
                    if (Model.TestDetails != null && Model.TestDetails.Contains(item))
                    {
                        item.intRowStatus = (int)RowStatusTypeEnum.Inactive;
                        StateContainer.SetHumanDiseaseReportTestSessionStateViewModel(Model);
                        await JsRuntime.InvokeAsync<string>("SetTestData", Model);
                        Model.TestDetailsForGrid = Model.TestDetails.Where(d => d.intRowStatus == 0).ToList();

                        await Grid.Reload();
                    }
                }
                else
                {
                    DiagService.Close();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task GetSiteAlertForTestResultCreation()
        {
            try
            {
                var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Model.idfsSite
                    ? SystemEventLogTypes.NewLaboratoryTestResultForHumanDiseaseReportWasRegisteredAtYourSite
                    : SystemEventLogTypes.NewLaboratoryTestResultForHumanDiseaseReportWasRegisteredAtAnotherSite;
                Events ??= new List<EventSaveRequestModel>();
                if (Model.idfHumanCase != null)
                    Events.Add(await CreateEvent(Model.idfHumanCase.Value,
                        Model.idfDisease, eventTypeId, Model.idfsSite, null));
                Model.Events = (List<EventSaveRequestModel>)Events;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public async Task GetSiteAlertForLabTestResultAmendment()
        {
            try
            {
                var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Model.idfsSite
                    ? SystemEventLogTypes.LaboratoryTestResultForHumanDiseaseReportWasAmendedAtYourSite
                    : SystemEventLogTypes.LaboratoryTestResultForHumanDiseaseReportWasAmendedAtAnotherSite;
                Events ??= new List<EventSaveRequestModel>();
                if (Model.idfHumanCase != null)
                    Events.Add(await CreateEvent(Model.idfHumanCase.Value,
                        Model.idfDisease, eventTypeId, Model.idfsSite, null));
                Model.Events = (List<EventSaveRequestModel>)Events;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public async Task GetSiteAlertForTestInterpretation()
        {
            try
            {
                var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Model.idfsSite
                    ? SystemEventLogTypes.LaboratoryTestResultForHumanDiseaseReportWasInterpretedAtYourSite
                    : SystemEventLogTypes.LaboratoryTestResultForHumanDiseaseReportWasInterpretedAtAnotherSite;
                Events ??= new List<EventSaveRequestModel>();
                if (Model.idfHumanCase != null)
                    Events.Add(await CreateEvent(Model.idfHumanCase.Value,
                        Model.idfDisease, eventTypeId, Model.idfsSite, null));
                Model.Events = (List<EventSaveRequestModel>)Events;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }
    }
}