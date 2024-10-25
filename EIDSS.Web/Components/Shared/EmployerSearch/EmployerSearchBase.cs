using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Localization.Constants;
using EIDSS.Web.Components.Administration;
using EIDSS.Web.ViewModels.Administration;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Radzen;
using Radzen.Blazor;

namespace EIDSS.Web.Components.Shared.EmployerSearch;

public class EmployerSearchBase : ComponentBase
{
    [Parameter] public long? OrganizationId { get; set; }
    [Parameter] public bool ShowAddButton { get; set; } = true;
    [Parameter] public long? SelectedEmployerId { get; set; }
    [Parameter] public string? SelectedEmployerText { get; set; }
    [Parameter] public EventCallback<long?> SelectedEmployerIdChanged { get; set; }
    [Parameter] public EventCallback<string?> SelectedEmployerTextChanged { get; set; }
    [Parameter] public string Name { get; set; } = string.Empty;
    [Parameter] public bool Disabled { get; set; }
    [Parameter] public EventCallback<PersonForOfficeViewModel?> Change { get; set; }
    protected RadzenDropDownDataGrid<PersonForOfficeViewModel> EmployeeDropDownDataGrid { get; set; }
    protected List<PersonForOfficeViewModel> Employees { get; set; } = new();
    protected int PageSize { get; set; } = 10;
    [Inject] protected IStringLocalizer Localizer { get; set; }
    [Inject] private IPersonClient PersonClient { get; set; }
    [Inject] private DialogService DiagService { get; set; }
    private bool InitializedFirstDataSet { get; set; }
    protected int EmployeesCount => Employees.Count;

    protected async Task OnEmployeeChange(object? selectedItem)
    {
        var item = (PersonForOfficeViewModel?)selectedItem;
        await SelectedEmployerIdChanged.InvokeAsync(item?.idfPerson); 
        await SelectedEmployerTextChanged.InvokeAsync(item?.FullName);
        await Change.InvokeAsync(item);
    }
    
    protected async Task LoadOnce(ElementReference arg)
    {
        if (!InitializedFirstDataSet)
        {
            InitializedFirstDataSet = true;
            await LoadData();
        }
    }

    public async Task SetEmployeeOrganization(long? employeeOrganizationId)
    {
        if (employeeOrganizationId == OrganizationId)
        {
            return;
        }
        
        OrganizationId = employeeOrganizationId;
        await LoadData();
        if (Employees.Count == 0 || Employees.All(x => x.idfPerson != SelectedEmployerId))
        {
            await EmployeeDropDownDataGrid.SelectItem(null);
            await SelectedEmployerIdChanged.InvokeAsync(null); 
            await SelectedEmployerTextChanged.InvokeAsync(null);
            await Change.InvokeAsync(null);
            StateHasChanged();
        }
    }
        
    private async Task LoadData()
    {
        Employees.Clear();
        if (OrganizationId > 0)
        {
            var request = new GetPersonForOfficeRequestModel
            {
                intHACode = EIDSSConstants.HACodeList.HumanHACode,
                LangID = Thread.CurrentThread.CurrentCulture.Name,
                OfficeID = OrganizationId,
            };

            Employees = await PersonClient.GetPersonListForOffice(request);
        }
    }
    
    protected async Task OpenAddEmployeePopup()
    {
        var dialogParams = new Dictionary<string, object>
        {
            { nameof(NonUserEmployeeAddModal.OrganizationID), OrganizationId },
            { nameof(NonUserEmployeeAddModal.DisableOrganizationField), true }
        };

        var result = await DiagService.OpenAsync<NonUserEmployeeAddModal>(
            Localizer.GetString(HeadingResourceKeyConstants.EmployeeDetailsModalHeading),
            dialogParams,
            new DialogOptions
            {
                Width = EIDSSConstants.CSSClassConstants.DefaultDialogWidth,
                Resizable = true,
                Draggable = false
            });

        if (result is EmployeePersonalInfoPageViewModel)
        {
            var newPerson = new PersonForOfficeViewModel
            {
                FullName = $"{result.FirstOrGivenName} {result.LastOrSurName}",
                idfPerson = result.EmployeeID,
            };
            Employees = Employees.Concat(new List<PersonForOfficeViewModel> {newPerson}).ToList();
            await EmployeeDropDownDataGrid.SelectItem(newPerson);
        }
    }
}

