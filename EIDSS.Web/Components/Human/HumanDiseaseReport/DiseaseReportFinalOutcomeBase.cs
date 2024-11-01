﻿using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.Services;
using EIDSS.Web.ViewModels.Administration;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.AspNetCore.Http;
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
using EIDSS.Domain.Interfaces;
using EIDSS.Web.Components.Shared.EmployerSearch;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class DiseaseReportFinalOutcomeBase : BaseComponent, IHdrContainerObserver
    {
        [Inject]
        protected IHdrStateContainer HdrStateContainer { get; set; }
        
        protected EmployerSearch EpidemiologistsSelect { get; set; }
        
        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IEmployeeClient EmployeeClient { get; set; }

        [Inject]
        private IPersonClient PersonClient { get; set; }

        [Inject]
        private IJSRuntime JsRuntime { get; set; }

        [Inject]
        private IHumanDiseaseReportClient humanDiseaseReportClient { get; set; }

        [Inject]
        private ILogger<DiseaseReportSampleAddModalBase> Logger { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ProtectedSessionStorage ProtectedSessionStore { get; set; }

        [Inject]
        private ProtectedLocalStorage ProtectedLocalStore { get; set; }

        [Inject]
        protected HumanDiseaseReportSessionStateContainer StateContainer { get; set; }

        [Inject]
        protected INotificationSiteAlertService _notificationService { get; set; }

        [Inject]
        protected IHttpContextAccessor _httpContextAccessor { get; set; }

        [Parameter]
        public DiseaseReportFinalOutcomeViewModel Model { get; set; }

        [Parameter]
        public long? idfDisease { get; set; }

        [Parameter]
        public DateTime? SymptomsOnsetDate { get; set; }

        [Parameter]
        public int SampleDetailCount { get; set; }

        public string? LocalSampleID { get; set; }

        [Parameter]
        public bool isReportClosed { get; set; }

        [Parameter]
        public long? idfHumanCase { get; set; }

        [Parameter]
        public string strCaseId { get; set; }

        protected IEnumerable<FiltersViewModel> finalCaseClassification;

        protected IEnumerable<FiltersViewModel> finalOutcome;

        protected RadzenTemplateForm<DiseaseReportFinalOutcomeViewModel> _form;

        protected int finalCaseClassificationCount { get; set; }

        protected int finalOutcomeCount { get; set; }

        protected int EpidemologistCount { get; set; }

        protected EditContext EditContext { get; set; }

        protected bool EnableCollectedByOfficer { get; set; } = true;

        private UserPermissions userPermissions;

        protected bool canAddEmployee { get; set; }

        protected bool canAddBaseReference { get; set; }

        [Parameter]
        public bool isEdit { get; set; }

        public bool showWarningForFinalCaseClassification { get; set; } = false;

        private CancellationTokenSource source;
        private CancellationToken token;
        private DotNetObjectReference<DiseaseReportFinalOutcomeBase> lDotNetReference;
        private IDisposable _unsubscribeHdrStateContainer;

        public bool showDateOfDeath { get; set; } = false;

        public bool EnableClinicalDiagnosis { get; set; } = true;

        public bool EnableEpiAndLabDiagnosis { get; set; } = true;

        public static DateTime? dateOfDiagnosis { get; set; } = null;

        protected override async Task OnInitializedAsync()
        {
            try
            {
                source = new();
                token = source.Token;
                DiagService.OnOpen += ModalOpen;
                DiagService.OnClose += ModalClose;

                userPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);

                canAddEmployee = userPermissions.Create;

                userPermissions = GetUserPermissions(PagePermission.CanManageReferenceDataTables);

                canAddBaseReference = userPermissions.Create;

                var systemPreferences = ConfigurationService.SystemPreferences;
                showWarningForFinalCaseClassification = systemPreferences.ShowWarningForFinalCaseClassification;
                Model.showWarningForFinalCaseClassification = systemPreferences.ShowWarningForFinalCaseClassification;
                _logger = Logger;

                if (Model.idfsOutCome == FinalOutcome.Died)
                {
                    showDateOfDeath = true;
                }
                else
                {
                    showDateOfDeath = false;
                }

                HdrStateContainer.DateOfFinalCaseClassification = Model.datFinalCaseClassificationDate;
                if (Model.datDateOfDeath != null)
                {
                    await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
                    {
                        x.DateOfDeath = Model.datDateOfDeath;
                    });
                }

                if (Model.datDateOfDischarge != null)
                {
                    await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
                    {
                        x.DateOfDischarge = Model.datDateOfDischarge;
                    });
                }

                await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        private void ModalOpen(string title, Type type, Dictionary<string, object> parameters, DialogOptions options)
        {
            //modal open event callback
        }

        private void ModalClose(dynamic result)
        {
            //modal close event callback
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            try
            {
                if (firstRender)
                {
                    if (HdrStateContainer.InvestigatedByOfficeId > 0)
                    {
                        await SetInvestigationOffice(HdrStateContainer.InvestigatedByOfficeId);
                    }
                    _unsubscribeHdrStateContainer = HdrStateContainer.Subscribe(this);
                    
                    lDotNetReference = DotNetObjectReference.Create(this);
                    await JsRuntime.InvokeVoidAsync("HumanDiseaseHelpers.setDotNetHelper", token, lDotNetReference);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        [JSInvokable("SetDiagnosisOrResultDate")]
        public async Task SetDiagnosisOrResultDate(string data)
        {
            try
            {
                if (!string.IsNullOrEmpty(data))
                    Model.dateOfDiagnosis = DateTime.Parse(data);
                var testDetails = StateContainer.TestModel.TestDetails;

                Model.datSampleStatusDate = testDetails.Max(a => a.datSampleStatusDate);

                if (Model.datSampleStatusDate == null && Model.dateOfDiagnosis != null)
                {
                    Model.datSampleStatusDate = Model.dateOfDiagnosis;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public void Dispose()
        {
            DiagService.OnOpen -= ModalOpen;
            DiagService.OnClose -= ModalClose;
            lDotNetReference?.Dispose();
            _unsubscribeHdrStateContainer.Dispose();
        }

        public async Task LoadFinalCaseClassification(LoadDataArgs args)
        {
            try
            {
                HumanDiseaseReportLkupCaseClassificationRequestModel request = new HumanDiseaseReportLkupCaseClassificationRequestModel();
                request.LangID = GetCurrentLanguage();
                var list = await humanDiseaseReportClient.GetHumanDiseaseReportLkupCaseClassificationAsync(request);
                var filterdlist = list.AsODataEnumerable();
                List<FiltersViewModel> tempData = new List<FiltersViewModel>();

                foreach (var item in filterdlist)
                {
                    if (item.blnFinalHumanCaseClassification && item.strHACode.Split(',').ToList().Contains(EIDSSConstants.HACodeList.HumanHACode.ToString()))
                    {
                        FiltersViewModel obj = new FiltersViewModel();
                        obj.idfsBaseReference = item.idfsCaseClassification;
                        obj.StrDefault = item.strName;
                        tempData.Add(obj);
                    }
                }
                finalCaseClassification = tempData.AsODataEnumerable();
                finalCaseClassificationCount = finalCaseClassification.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task LoadFinalOutcome(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.Outcome, HACodeList.HumanHACode);
                var filterdlist = list.AsODataEnumerable();
                List<FiltersViewModel> tempData = new List<FiltersViewModel>();
                foreach (var item in filterdlist)
                {
                    FiltersViewModel obj = new FiltersViewModel();
                    obj.idfsBaseReference = item.IdfsBaseReference;
                    obj.StrDefault = item.Name;
                    tempData.Add(obj);
                }
                finalOutcome = tempData.AsODataEnumerable();
                finalOutcomeCount = finalOutcome.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task SetInvestigationOffice(long? value)
        {
            try
            {
                Model.idfInvestigatedByOffice = value;
                await EpidemiologistsSelect.SetEmployeeOrganization(value);
                if (value == null)
                {
                    await UpdateEpidemologist(null);
                }
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task GetResultDate(DiseaseReportTestPageViewModel testPageModel)
        {
            try
            {
                var testDetails = testPageModel.TestDetails;
                if (Model == null)
                    Model = new DiseaseReportFinalOutcomeViewModel();
                Model.datSampleStatusDate = testDetails.Max(a => a.datSampleStatusDate);

                var diagnosisDate = await JsRuntime.InvokeAsync<string>("GetDateOfDiagnosis", Model);
                if (!string.IsNullOrEmpty(diagnosisDate))
                    Model.dateOfDiagnosis = DateTime.Parse(diagnosisDate);
                if (Model.datSampleStatusDate == null && Model.dateOfDiagnosis != null)
                {
                    Model.datSampleStatusDate = Model.dateOfDiagnosis;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateFinalCaseClassification(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    Model.idfsFinalCaseStatus = long.Parse(Value.ToString());

                    var h = finalCaseClassification.Where(x => x.idfsBaseReference == long.Parse(Value.ToString()));
                    if (h != null && h.Count() > 0)
                    {
                        Model.strFinalCaseStatus = h.FirstOrDefault().StrDefault;
                    }
                }
                if (Model.idfsFinalCaseStatus == OutbreakCaseClassification.Suspect)
                {
                    EnableClinicalDiagnosis = false;
                    EnableEpiAndLabDiagnosis = true;
                }
                else if (Model.idfsFinalCaseStatus == OutbreakCaseClassification.ProbableCase)
                {
                    EnableClinicalDiagnosis = false;
                    EnableEpiAndLabDiagnosis = false;
                }
                await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);

                if (Model.idfHumanCase != null)
                {
                    await GetSiteAlertForFinalCaseClassification();
                    await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task GetSiteAlertForFinalCaseClassification()
        {
            try
            {
                if (Model.idfHumanCase != null)
                {
                    var eventTypeId = Convert.ToInt64(authenticatedUser.SiteId) == Model.idfsSite
                        ? SystemEventLogTypes.HumanDiseaseReportClassificationWasChangedAtYourSite
                        : SystemEventLogTypes.HumanDiseaseReportClassificationWasChangedAtAnotherSite;
                    Events ??= new List<EventSaveRequestModel>();
                    Events.Add(await CreateEvent(Model.idfHumanCase.Value,
                        idfDisease, eventTypeId, Model.idfsSite, null));
                    Model.Events = (List<EventSaveRequestModel>)Events;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }

        public async Task UpdateFinalOutcome(object outcomeValue)
        {
            try
            {
                var isDead = false;

                if (outcomeValue != null && long.TryParse(outcomeValue.ToString(), out var outcomeId))
                {
                    Model.idfsOutCome = outcomeId;

                    var outcome = finalOutcome.FirstOrDefault(x => x.idfsBaseReference == outcomeId);
                    if (outcome != null)
                    {
                        Model.Outcome = outcome.StrDefault;
                    }

                    isDead = outcomeId == FinalOutcome.Died;
                }

                showDateOfDeath = isDead;
                await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
                {
                    x.DateOfDeath = Model.datDateOfDeath;
                });
                await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
                {
                    x.DateOfDischarge = Model.datDateOfDischarge;
                });

                await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateEpidemologist(PersonForOfficeViewModel? value)
        {
            try
            {
                if (value != null)
                {
                    Model.idfInvestigatedByPerson = value.idfPerson;
                    Model.strEpidemiologistsName = value.FullName;
                }
                else
                {
                    Model.idfInvestigatedByPerson = null;
                    Model.strEpidemiologistsName = null;
                }
                
                await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateFinalClassificationDate(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    Model.datFinalCaseClassificationDate = DateTime.Parse(Value.ToString());
                }

                await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateblnClinicalDiagBasis(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    Model.blnClinicalDiagBasis = Convert.ToBoolean(Value.ToString());
                }
                await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateblnEpiDiagBasis(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    Model.blnEpiDiagBasis = Convert.ToBoolean(Value.ToString());
                }
                await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateblnLabDiagBasis(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    Model.blnLabDiagBasis = Convert.ToBoolean(Value.ToString());
                }
                await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateDateOfDeath(Object newDate)
        {
            try
            {
                Model.datDateOfDeath = newDate != null ? DateTime.Parse(newDate.ToString()) : null;
                
                await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateComments(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    Model.Comments = Value.ToString();
                }
                await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task HandleValidFinalOutcomeSubmit(DiseaseReportFinalOutcomeViewModel model)
        {
            try
            {
                if (_form.IsValid)
                {
                    if (_form.EditContext.IsModified())
                    {
                        DiagService.Close(EditContext);
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task HandleInvalidFinalOutcomeSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
            }
            catch (Exception)
            {
                throw;
            }
        }

        protected async Task OpenEmployeeAddModal()
        {
            try
            {
                var dialogParams = new Dictionary<string, object>();

                dynamic result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
                    dialogParams, new DialogOptions() { Width = "700px", Resizable = true, Draggable = false });

                if (result == null)
                    return;

                (result as EditContext).Validate();

                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task OpenAddBaseReference()
        {
            try
            {
                Dictionary<string, object> dialogParams = new()
                {
                    {
                        nameof(AddBaseReferenceRecord.AccessoryCode)
                        ,(int) AccessoryCodes.HumanHACode
                    },
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeID),
                        (long)BaseReferenceTypeEnum.CaseOutcomes
                    },
                    {
                        nameof(AddBaseReferenceRecord.BaseReferenceTypeName),
                        FieldLabelResourceKeyConstants.HumanDiseaseReportFinalOutcomeOutcomeFieldLabel
                    },
                    { nameof(AddBaseReferenceRecord.Model), new BaseReferenceSaveRequestModel() }
                };
                var result = await DiagService.OpenAsync<AddBaseReferenceRecord>(
                    Localizer.GetString(HeadingResourceKeyConstants.BaseReferenceDetailsModalHeading),
                    dialogParams,
                    new DialogOptions
                    {
                        Width = CSSClassConstants.DefaultDialogWidth,
                        Resizable = true,
                        Draggable = false
                    }).ConfigureAwait(false);

                if (result is BaseReferenceSaveRequestResponseModel)
                {
                    await LoadFinalOutcome(new LoadDataArgs()).ConfigureAwait(false);
                    DiagService.Close(result);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task<EmployeeSaveRequestResponseModel> SaveNonUserEmployee(EditContext result)
        {
            var newEmployee = result as EditContext;
            EmployeeSaveRequestResponseModel response = new EmployeeSaveRequestResponseModel();
            EmployeeSaveRequestModel EmployeePersonalInfoSaveRequest = new EmployeeSaveRequestModel();
            EmployeePersonalInfoPageViewModel obj = (EmployeePersonalInfoPageViewModel)result.Model;
            EmployeePersonalInfoSaveRequest.strPersonalID = obj.PersonalID;
            EmployeePersonalInfoSaveRequest.idfPersonalIDType = obj.PersonalIDType.ToString();
            EmployeePersonalInfoSaveRequest.strFirstName = obj.FirstOrGivenName;
            EmployeePersonalInfoSaveRequest.strSecondName = obj.SecondName;
            EmployeePersonalInfoSaveRequest.strFamilyName = obj.LastOrSurName;
            EmployeePersonalInfoSaveRequest.strContactPhone = obj.ContactPhone;
            EmployeePersonalInfoSaveRequest.idfInstitution = obj.OrganizationID;
            EmployeePersonalInfoSaveRequest.idfsSite = obj.SiteID;
            EmployeePersonalInfoSaveRequest.idfsStaffPosition = obj.PositionTypeID;
            EmployeePersonalInfoSaveRequest.idfDepartment = obj.DepartmentID;

            EmployeePersonalInfoSaveRequest.idfsEmployeeCategory = (long)EmployeeCategory.NonUser;

            EmployeeGetListRequestModel DuplicateCheckRequest = new EmployeeGetListRequestModel();

            DuplicateCheckRequest.FirstOrGivenName = EmployeePersonalInfoSaveRequest.strFirstName;
            DuplicateCheckRequest.LanguageId = GetCurrentLanguage();
            DuplicateCheckRequest.LastOrSurName = EmployeePersonalInfoSaveRequest.strFamilyName;
            DuplicateCheckRequest.PersonalIdType = EmployeePersonalInfoSaveRequest.idfPersonalIDType != null && EmployeePersonalInfoSaveRequest.idfPersonalIDType.ToString() != string.Empty ? long.Parse(EmployeePersonalInfoSaveRequest.idfPersonalIDType.ToString()) : null;
            DuplicateCheckRequest.PersonalIDValue = EmployeePersonalInfoSaveRequest.strPersonalID;
            DuplicateCheckRequest.OrganizationID = EmployeePersonalInfoSaveRequest.idfInstitution;
            DuplicateCheckRequest.Page = 1;
            DuplicateCheckRequest.PageSize = 10;
            DuplicateCheckRequest.SortOrder = "ASC";
            DuplicateCheckRequest.SortColumn = "EmployeeID";

            response = await EmployeeClient.SaveEmployee(EmployeePersonalInfoSaveRequest);

            return response;
        }

        public async Task OnHdrStateContainerChange(IHdrStateContainer current, IHdrStateContainer previous)
        {
            if (current.InvestigatedByOfficeId != Model.idfInvestigatedByOffice)
            {
                await SetInvestigationOffice(current.InvestigatedByOfficeId);
            }
        }

        protected async Task OnDateofDischargeChanged(DateTime? value)
        {
            await HdrStateContainer.ChangeWithNotifyAboutStateChange(x =>
            {
                x.DateOfDischarge = value;
            });

            Model.datDateOfDischarge = value;

            await JsRuntime.InvokeAsync<string>("SetFinalOutcomeData", Model);
        }
    }
}