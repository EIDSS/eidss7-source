using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.Abstracts;
using EIDSS.Web.ViewModels.Human;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.Extensions.Logging;
using Radzen;
using Radzen.Blazor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Components.Shared.EmployerSearch;
using EIDSS.Web.Services;

namespace EIDSS.Web.Components.Human.HumanDiseaseReport;

public class DiseaseReportSampleAddModalBase : BaseComponent
{
    [Inject]
    private IOrganizationClient OrganizationClient { get; set; }
    
    [Inject]
    protected IHdrStateContainer HdrStateContainer { get; set; }

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

    protected List<OrganizationAdvancedGetListViewModel> sentToInstitutions;
    protected IEnumerable<FiltersViewModel> sampleTypes;

    protected RadzenTemplateForm<DiseaseReportSamplePageSampleDetailViewModel> _form;

    protected int SampleCount { get; set; }


    protected EditContext EditContext { get; set; }

    protected bool EnableCollectedByOfficer { get; set; } = true;

    private UserPermissions userPermissions;

    protected bool canAddEmployee { get; set; }
    
    protected EmployerSearchBase CollectedByOfficerComponent { get; set; }

    protected override async Task OnInitializedAsync()
    {
        try
        {
            userPermissions = GetUserPermissions(PagePermission.CanAccessEmployeesList_WithoutManagingAccessRights);

            canAddEmployee = userPermissions.Create;
            var systemPreferences = ConfigurationService.SystemPreferences;
            _logger = Logger;
            if (Model == null)
                Model = new DiseaseReportSamplePageSampleDetailViewModel();

            sampleDetailModel = Model;
            HdrStateContainer.DateOfCurrentSampleSent = sampleDetailModel.SentDate;
            HdrStateContainer.DateOfCurrentSampleCollection = sampleDetailModel.CollectionDate;

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

            await LoadSampleTypes(sampleDetailModel.FilterSampleByDisease);

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

    public async Task UpdateCollectedByOrganizationName(long? organizationId)
    {
        sampleDetailModel.CollectedByOrganizationID = organizationId;
        await CollectedByOfficerComponent.SetEmployeeOrganization(organizationId);
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

    protected async Task HandleValidSamplesSubmit(DiseaseReportSamplePageSampleDetailViewModel model)
    {
        try
        {
            if (_form.IsValid)
            {
                DiagService.Close(EditContext);
            }
        }
        catch (Exception ex)
        {
            Logger.LogError(ex.Message, ex);
            throw;
        }
    }
}
