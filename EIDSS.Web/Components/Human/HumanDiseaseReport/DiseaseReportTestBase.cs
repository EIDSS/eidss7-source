using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.CrossCutting;
using EIDSS.Web.Enumerations;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels.Human;
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
using System.Linq.Dynamic.Core;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class DiseaseReportTestBase : BaseComponent
    {
        [Inject]
        private IConfigurationClient ConfigurationClient { get; set; }

        [Inject]
        protected GridContainerServices GridContainerServices { get; set; }

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

        [Parameter]
        public DiseaseReportTestPageViewModel Model { get; set; }

        [Parameter]
        public bool isReportClosed { get; set; }

        [Parameter]
        public bool CanAddTests { get; set; }

        protected IList<DiseaseReportTestDetailForDiseasesViewModel> SelectedTests;

        protected RadzenDataGrid<DiseaseReportTestDetailForDiseasesViewModel> Grid;

        protected bool ShowTestGrid;

        protected bool EnableAddButton;

        protected bool DisableEditDelete;

        private UserPermissions _userPermissions;

        private UserPermissions _canAddTestResultsForHumanCaseSession;

        private bool _accessToHumanDiseaseReportData;

        private GridExtensionBase _gridExtension;

        protected override void OnInitialized()
        {
            _gridExtension = new GridExtensionBase();
            GridColumnLoad("HumanDiseaseReportTest");

            base.OnInitialized();
        }

        protected override async Task OnInitializedAsync()
        {
            try
            {
                await base.OnInitializedAsync();

                _logger = Logger;

                _userPermissions = GetUserPermissions(PagePermission.AccessToHumanDiseaseReportData);

                _accessToHumanDiseaseReportData = _userPermissions.Create;

                _canAddTestResultsForHumanCaseSession = GetUserPermissions(PagePermission.CanAddTestResultsForHumanCase_Session);

                if (_accessToHumanDiseaseReportData)
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

                if (StateContainer.SampleModel?.SamplesDetails != null)
                {
                    Model.SamplesDetails = StateContainer.SampleModel.SamplesDetails;
                }

                await JsRuntime.InvokeAsync<string>("SetTestData", Model);

                // get the yes / no choices for radio buttons
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), EIDSSConstants.BaseReferenceConstants.YesNoValueList, EIDSSConstants.HACodeList.HumanHACode);
                Model.YesNoChoices = list;

                ToggleTestPanel();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }
        protected async Task OnTestsCollectedChange(long? value)
        {
            Model.TestsConducted = value;
            ToggleTestPanel();
            await JsRuntime.InvokeAsync<string>("SetTestData", Model);
        }

        private async Task GetPageParams()
        {
            try
            {
                const string elementId = "diseaseDD";
                var resultData = await JsRuntime.InvokeAsync<string>("getDomElementValue", elementId);
                if (!string.IsNullOrEmpty(resultData))
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
                var hasActiveSamples = HasActiveSamples();
                if (_accessToHumanDiseaseReportData &&
                    _canAddTestResultsForHumanCaseSession.Execute &&
                    hasActiveSamples)
                {
                    if (Model.TestsConducted.GetValueOrDefault() != (long)YesNoUnknown.Yes)
                    {
                        ShowTestGrid = Model.TestDetailsForGrid.Count > 0;
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

        protected bool HasActiveSamples()
        {
            return StateContainer.SampleModel?.SamplesDetails?.Count(d => d.intRowStatus == (int)RowStatusTypeEnum.Active) > 0;
        }

        protected async Task OpenAddModal()
        {
            try
            {
                await GetPageParams();

                Model.SamplesDetails = StateContainer.SampleModel.SamplesDetails;
                var diseaseId = GetDiseaseId();

                var dialogParams = new Dictionary<string, object>
                {
                    {"idfDisease", diseaseId},
                    {"idfHumanCase", Model.idfHumanCase},
                    {"strCaseId", Model.strCaseId},
                    {"LocalSampleID", Model.LocalSampleID},
                    {"SamplesDetails", Model.SamplesDetails}
                };

                var result = await DiagService.OpenAsync<DiseaseReportTestAddModal>(Localizer.GetString(HeadingResourceKeyConstants.HumanDiseaseReportTestsDetailHeading),
                    dialogParams, new DialogOptions { Width = "900px", Resizable = true, Draggable = false });

                if (result == null)
                    return;

                if (((EditContext)result).Validate())
                {
                    var obj = (DiseaseReportTestDetailForDiseasesViewModel)result.Model;
                    var item = new DiseaseReportTestDetailForDiseasesViewModel();

                    switch (Model.SamplesDetails)
                    {
                        case { Count: > 0 } when Model.idfHumanCase is null or 0:
                            item.NewRecordId = Model.SamplesDetails.Find(a => a.LocalSampleId == obj.strFieldBarcode).NewRecordId;
                            item.idfMaterial = obj.idfMaterial == 0 ? Model.SamplesDetails.Find(a => a.LocalSampleId == obj.strFieldBarcode).NewRecordId : obj.idfMaterial;
                            break;
                        case { Count: > 0 } when Model.idfHumanCase != null && Model.idfHumanCase != 0:
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

                var diseaseId = GetDiseaseId();
                var dialogParams = new Dictionary<string, object>
                {
                    {"Model", data},
                    {"idfDisease", diseaseId},
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

                if (((EditContext)result).Validate())
                {
                    var obj = (DiseaseReportTestDetailForDiseasesViewModel)result.Model;
                    var item = new DiseaseReportTestDetailForDiseasesViewModel();

                    if (Model.TestDetails != null)
                    {
                        var count = Model.TestDetails.Count;
                        var oldItem = Model.TestDetails.Find(x => x.RowID == obj.RowID);

                        item.RowID = obj.RowID;
                        item.idfMaterial = obj.idfMaterial;
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
                            item.idfTestValidation = item.RowID * -1;
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

        private long? GetDiseaseId()
        {
            return StateContainer.NotificationModel.ChangedDiseaseId ?? Model.idfDisease;
        }

        private async Task GetSiteAlertForTestResultCreation()
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

        private async Task GetSiteAlertForLabTestResultAmendment()
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

        private async Task GetSiteAlertForTestInterpretation()
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

        private void GridColumnLoad(string columnNameId)
        {
            try
            {
                GridContainerServices.GridColumnConfig = _gridExtension.GridColumnLoad(columnNameId, _tokenService, ConfigurationClient);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        protected void GridColumnSave(string columnNameId)
        {
            try
            {
                _gridExtension.GridColumnSave(columnNameId, _tokenService, ConfigurationClient, Grid.ColumnsCollection.ToDynamicList(), GridContainerServices);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        protected int FindColumnOrder(string columnName)
        {
            var index = 0;
            try
            {
                index = _gridExtension.FindColumnOrder(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return index;
        }

        protected bool GetColumnVisibility(string columnName)
        {
            var visible = true;
            try
            {
                visible = _gridExtension.GetColumnVisibility(columnName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
            return visible;
        }

        protected void HeaderCellRender(string propertyName)
        {
            try
            {
                GridContainerServices.VisibleColumnList = _gridExtension.HandleVisibilityList(GridContainerServices, propertyName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        protected void GridHumanDiseaseReportTestClickHandler()
        {
            GridColumnSave("HumanDiseaseReportTest");
        }
    }
}