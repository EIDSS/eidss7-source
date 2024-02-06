using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Components.Laboratory;
using EIDSS.Web.Enumerations;
using EIDSS.Web.ViewModels.CrossCutting;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Web.Components.CrossCutting;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Web.ViewModels.Administration;
using EIDSS.Web.Components.Administration;
using EIDSS.Domain.ViewModels;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport
{
    public class DiseaseReportSampleAddModalBase : BaseComponent
    {
        [Inject]
        private IOrganizationClient OrganizationClient { get; set; }

        [Inject]
        private ICrossCuttingClient CrossCuttingClient { get; set; }

        [Inject]
        private IEmployeeClient EmployeeClient { get; set; }

        [Inject]
        private IPersonClient PersonClient { get; set; }

        [Inject]
        private IHumanDiseaseReportClient humanDiseaseReportClient { get; set; }

        [Inject]
        private ILogger<DiseaseReportSampleAddModalBase> Logger { get; set; }

        [Inject]
        private IUserConfigurationService ConfigurationService { get; set; }

        [Inject]
        private ISampleTypesClient _sampleTypesClient { get; set; }

        [Inject]
        private ProtectedSessionStorage ProtectedSessionStore { get; set; }

        [Parameter]
        public DiseaseReportSamplePageSampleDetailViewModel Model { get; set; }

        [Parameter]
        public long? idfDisease { get; set; }

        [Parameter]
        public DateTime? SymptomsOnsetDate { get; set; }

        [Parameter]
        public int SampleDetailCount { get; set; }

        public string? LocalSampleID { get; set; }

        [Parameter]
        public long? idfHumanCase { get; set; }

        [Parameter]
        public string strCaseId { get; set; }

        [Parameter]
        public bool sampleAdd { get; set; }

        [Parameter]
        public bool IsReportClosed { get; set; } = false;

        public long? idfsSite { get; set; }

        public DiseaseReportSamplePageSampleDetailViewModel sampleDetailModel { get; set; }

        protected IEnumerable<OrganizationAdvancedGetListViewModel> collectedByInstitution;
        protected IEnumerable<PersonForOfficeViewModel> collectedByEmployees;
        protected List<OrganizationAdvancedGetListViewModel> sentToInstitutions;
        protected IEnumerable<FiltersViewModel> sampleTypes;

        protected RadzenTemplateForm<DiseaseReportSamplePageSampleDetailViewModel> _form;

        protected int SampleCount { get; set; }

        protected int CollectedByInstitutionCount { get; set; }

        protected int CollectedByEmployeeCount { get; set; }

        protected int SentToInstitutionCount { get; set; }

        protected EditContext EditContext { get; set; }

        protected bool EnableCollectedByOfficer { get; set; } = true;

        private UserPermissions userPermissions;

        protected bool canAddEmployee { get; set; }

        protected override async Task OnInitializedAsync()
        {
            try
            {
                DiagService.OnOpen += ModalOpen;
                DiagService.OnClose += ModalClose;

                userPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);

                canAddEmployee = userPermissions.Create;
                var systemPreferences = ConfigurationService.SystemPreferences;
                _logger = Logger;
                if (Model == null)
                    Model = new DiseaseReportSamplePageSampleDetailViewModel();

                sampleDetailModel = Model;

                if (sampleAdd)
                    sampleDetailModel.FilterSampleByDisease = systemPreferences.FilterSamplesByDisease;
                else
                    sampleDetailModel.FilterSampleByDisease = false;
                if (string.IsNullOrEmpty(sampleDetailModel.LocalSampleId))
                    sampleDetailModel.LocalSampleId = GenerateLocalSampleId();

                sampleDetailModel.TempLocalSampleID = sampleDetailModel.LocalSampleId;

                sampleDetailModel.SymptomsOnsetDate = SymptomsOnsetDate;
                sampleDetailModel.idfDisease = idfDisease;

                EditContext = new(sampleDetailModel);

                var tsk = LoadSampleTypes(sampleDetailModel.FilterSampleByDisease);
                await LoadCollectedByInstitution(null);

                if (sampleDetailModel.CollectedByOrganizationID != 0 && sampleDetailModel.CollectedByOrganizationID != null)
                {
                    EnableCollectedByOfficer = false;
                }
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

        protected string GenerateLocalSampleId()
        {
            try
            {
                var systemPreferences = ConfigurationService.SystemPreferences;
                bool LinkLocalSampleIDToReportSessionID = systemPreferences.LinkLocalSampleIdToReportSessionId;
                string TempLocalSampleID;
                int sampleCount = 0;
                string strSampleCount = "";
                if (LinkLocalSampleIDToReportSessionID && !string.IsNullOrEmpty(strCaseId))
                {
                    if (SampleDetailCount != 0)
                    {
                        sampleCount = SampleDetailCount + 1;

                        if (sampleCount < 10)
                        {
                            strSampleCount = "0" + sampleCount;
                        }

                        TempLocalSampleID = strCaseId + "-" + strSampleCount;
                    }
                    else
                    {
                        strSampleCount = "0" + 1;
                        TempLocalSampleID = strCaseId + "-" + strSampleCount;
                    }
                    LocalSampleID = TempLocalSampleID;
                }
                else
                {
                    if (SampleDetailCount != 0)
                    {
                        sampleCount = SampleDetailCount + 1;

                        if (sampleCount < 10)
                        {
                            strSampleCount = "0" + sampleCount;
                        }

                        TempLocalSampleID = "New-" + strSampleCount;
                    }
                    else
                    {
                        strSampleCount = "0" + 1;
                        TempLocalSampleID = "New-" + strSampleCount;
                    }
                    LocalSampleID = TempLocalSampleID;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
            return LocalSampleID;
        }

        public void Dispose()
        {
            DiagService.OnOpen -= ModalOpen;
            DiagService.OnClose -= ModalClose;
        }

        public async Task GetSampleTypes(LoadDataArgs args)
        {
            try
            {
                var list = await CrossCuttingClient.GetBaseReferenceList(GetCurrentLanguage(), BaseReferenceConstants.SampleType, HACodeList.HumanHACode);
                var filterdlist = list.AsODataEnumerable();
                foreach (var item in filterdlist)
                {
                    FiltersViewModel obj = new FiltersViewModel();
                    obj.idfsBaseReference = item.IdfsBaseReference;
                    obj.StrDefault = item.StrDefault;
                    sampleTypes.Append(obj);
                }
                SampleCount = sampleTypes.Count();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, null);
                throw;
            }
        }

        public async Task LoadSampleTypes(bool? args)
        {
            try
            {
                if (args == true && idfDisease != null && idfDisease != 0)
                {
                    var request = new HumanSampleForDiseasesRequestModel
                    {
                        LangId = GetCurrentLanguage(),
                        AccessoryCode = HACodeList.HumanHACode,
                        idfsDiagnosis = idfDisease
                    };
                    var list = await humanDiseaseReportClient.GetHumanDiseaseSampleForDiseasesListAsync(request);
                    var filterdlist = list.AsODataEnumerable();
                    List<FiltersViewModel> tempData = new List<FiltersViewModel>();

                    foreach (var item in filterdlist)
                    {
                        FiltersViewModel obj = new FiltersViewModel();
                        obj.idfsBaseReference = item.idfsSampleType;
                        obj.StrDefault = item.strSampleType;
                        tempData.Add(obj);
                    }
                    sampleTypes = tempData.AsODataEnumerable();
                    SampleCount = sampleTypes.Count();
                    await InvokeAsync(StateHasChanged);
                }
                else
                {
                    var request = new SampleTypesEditorGetRequestModel
                    {
                        LanguageId = GetCurrentLanguage(),
                        SampleTypeSearch = null,
                        AdvancedSearch = null,
                        Page = 1,
                        PageSize = 1000,
                        SortColumn = "intOrder",
                        SortOrder = "asc",
                        intHACode = HACodeList.HumanHACode
                    };

                    var list = await _sampleTypesClient.GetSampleTypesReferenceList(request);
                    var filterdlist = list.AsODataEnumerable();
                    List<FiltersViewModel> tempData = new List<FiltersViewModel>();
                    foreach (var item in filterdlist)
                    {
                        FiltersViewModel obj = new FiltersViewModel();
                        obj.idfsBaseReference = item.KeyId;
                        obj.StrDefault = item.StrName;
                        tempData.Add(obj);
                    }
                    sampleTypes = tempData.AsODataEnumerable();
                    SampleCount = sampleTypes.Count();
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task LoadCollectedByInstitution(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = HACodeList.HumanHACode,
                    AdvancedSearch = null,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = null,
                };
                //if (args != null && args.Filter != null)
                //{
                //    request.AdvancedSearch = args.Filter;
                //}
                var list = await OrganizationClient.GetOrganizationAdvancedList(request);
                if (args != null && args.Filter != null)
                {
                    List<OrganizationAdvancedGetListViewModel> toList = list.Where(c => c.name != null && c.name.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                    list = toList;
                }
                collectedByInstitution = list.AsODataEnumerable();
                CollectedByInstitutionCount = collectedByInstitution.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateCollectedByOrganizationName(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    var h = collectedByInstitution.Where(x => x.idfOffice == long.Parse(Value.ToString()));
                    if (h != null)
                    {
                        sampleDetailModel.CollectedByOrganization = h.FirstOrDefault().name;
                        EnableCollectedByOfficer = false;
                        GetCollectedByOfficer(h.FirstOrDefault().idfOffice);
                        sampleDetailModel.CollectedByOfficerID = 0;
                        sampleDetailModel.CollectedByOfficer = null;
                        await InvokeAsync(StateHasChanged);
                    }
                }
                else
                {
                    sampleDetailModel.CollectedByOfficerID = 0;
                    sampleDetailModel.CollectedByOfficer = null;
                    EnableCollectedByOfficer = true;
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateCollectedByOfficeName(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    var h = collectedByEmployees.Where(x => x.idfPerson == long.Parse(Value.ToString()));
                    if (h != null)
                    {
                        sampleDetailModel.CollectedByOfficer = h.FirstOrDefault().FullName;
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task UpdateSentByName(Object Value)
        {
            try
            {
                if (Value != null)
                {
                    var h = sentToInstitutions.Where(x => x.idfOffice == long.Parse(Value.ToString()));
                    if (h != null)
                    {
                        sampleDetailModel.SentToOrganization = h.FirstOrDefault().name;
                        sampleDetailModel.idfsSiteSentToOrg = h.FirstOrDefault().idfsSite;
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected void UpdateSampleTypeName(object value)
        {
            try
            {
                if (value != null)
                {
                    var h = sampleTypes.Where(x => x.idfsBaseReference == long.Parse(value.ToString() ?? string.Empty));
                    sampleDetailModel.SampleType = h.FirstOrDefault()?.StrDefault;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task LoadSentToInstitution(LoadDataArgs args)
        {
            try
            {
                OrganizationAdvancedGetRequestModel request = new()
                {
                    LangID = GetCurrentLanguage(),
                    AccessoryCode = HACodeList.HumanHACode,
                    AdvancedSearch = args.Filter,
                    SiteFlag = (int)OrganizationSiteAssociations.OrganizationsWithOrWithoutSite,
                    OrganizationTypeID = (long)OrganizationTypes.Laboratory,
                };
                if (args != null)
                {
                    request.AdvancedSearch = args.Filter;
                }

                sentToInstitutions = await OrganizationClient.GetOrganizationAdvancedList(request);
                SentToInstitutionCount = sentToInstitutions.Count();
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task LoadCollectedByOfficer(LoadDataArgs args)
        {
            try
            {
                if (Model.CollectedByOrganizationID != null && Model.CollectedByOrganizationID != 0)
                {
                    //if (args != null && !string.IsNullOrEmpty(args.Filter))
                    //{
                        GetPersonForOfficeRequestModel request = new GetPersonForOfficeRequestModel();
                        request.intHACode = EIDSSConstants.HACodeList.HumanHACode;
                        request.LangID = GetCurrentLanguage();
                        request.OfficeID = Model.CollectedByOrganizationID;
                        //if (args != null && string.IsNullOrEmpty(args.Filter))
                        //    request.AdvancedSearch = args.Filter;
                        var list = await PersonClient.GetPersonListForOffice(request);
                        if (!string.IsNullOrEmpty(args.Filter))
                        {
                            List<PersonForOfficeViewModel> toList = list.Where(c => c.FullName != null && c.FullName.Contains(args.Filter, StringComparison.CurrentCultureIgnoreCase)).ToList();
                            list = toList;
                        }
                        collectedByEmployees = list.AsODataEnumerable();
                        CollectedByEmployeeCount = collectedByEmployees.Count();
                    //}
                    //else
                    //{
                    //    collectedByEmployees = new List<PersonForOfficeViewModel>();
                    //}
                    await InvokeAsync(StateHasChanged);
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        public async Task GetCollectedByOfficer(long? value)
        {
            try
            {
                if (value != null && value != 0)
                {
                    GetPersonForOfficeRequestModel request = new GetPersonForOfficeRequestModel();
                    request.intHACode = EIDSSConstants.HACodeList.HumanHACode;
                    request.LangID = GetCurrentLanguage();
                    request.OfficeID = value;
                    request.AdvancedSearch = null;

                    var list = await PersonClient.GetPersonListForOffice(request);
                    collectedByEmployees = list.AsODataEnumerable();
                    CollectedByEmployeeCount = collectedByEmployees.Count();
                }
                else
                {
                    collectedByEmployees = new List<PersonForOfficeViewModel>();
                }
                await InvokeAsync(StateHasChanged);
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task HandleValidSamplesSubmit(DiseaseReportSamplePageSampleDetailViewModel model)
        {
            try
            {
                if (_form.IsValid)
                {
                    if (_form.EditContext.IsModified())
                    {
                        DiagService.Close(EditContext);
                    }
                    else
                    {
                        //no search criteria entered - display the EIDSS dialog component
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
                throw;
            }
        }

        protected async Task HandleInvalidSamplesSubmit(FormInvalidSubmitEventArgs args)
        {
            try
            {
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, ex);
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
                {
                    await LoadCollectedByOfficer(new LoadDataArgs());
                    return;
                }

                if ((result as EditContext).Validate())
                {
                }
                else
                {
                    //Logger.LogInformation("HandleSubmit called: Form is INVALID");
                }

                await InvokeAsync(StateHasChanged);
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
    }
}