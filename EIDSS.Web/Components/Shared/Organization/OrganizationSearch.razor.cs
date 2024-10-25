using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Radzen;
using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants.SortConstants;

namespace EIDSS.Web.Components.Shared.Organization;

public class OrganizationSearchBase : ComponentBase
{
    [Parameter] public string? SelectedOrganizationText { get; set; }
    [Parameter] public long? SelectedOrganizationId { get; set; }
    [Parameter] public EventCallback<long?> SelectedOrganizationIdChanged { get; set; }
    [Parameter] public EventCallback<string?> SelectedOrganizationTextChanged { get; set; }
    [Parameter] public bool Disabled { get; set; }
    [Parameter] public string Name { get; set; }
    [Inject] protected IStringLocalizer Localizer { get; set; }
    [Inject] private IOrganizationClient OrganizationClient { get; set; }
    protected string ComponentId { get; } = $"organization-search-{Guid.NewGuid()}";
    protected List<OrganizationGetSearchModelResult> Organizations { get; set; } = new ();
    protected int OrganizationCount => Organizations.FirstOrDefault()?.TotalRowCount ?? 0;
    protected int PageSize => 10;
    private bool InitializedFirstDataSet { get; set; }
    
    protected async Task OnOrganizationChanged(object organization)
    {
        var item = (OrganizationGetSearchModelResult?)organization;
        await SelectedOrganizationTextChanged.InvokeAsync(item?.AbbreviatedName); 
        await SelectedOrganizationIdChanged.InvokeAsync(item?.OrganizationId); 
    }
    
    protected async Task LoadFirstDataPageOnce(ElementReference arg)
    {
        if (!InitializedFirstDataSet)
        {
            InitializedFirstDataSet = true;
            await LoadData(new LoadDataArgs { Filter = "" });
        }
    }

    protected async Task LoadData(LoadDataArgs args)
    {
        var sortProperty = nameof(OrganizationGetListViewModel.AbbreviatedName);
        var sortOrder = Ascending;
        var pageNumber = ((args.Skip ?? 0) + PageSize) / PageSize;
        
        if (!string.IsNullOrWhiteSpace(args.OrderBy))
        {
            var orderByItems = args.OrderBy.Split(" ");
            sortProperty = orderByItems[0];
            sortOrder = orderByItems[1];
        }
        
        var request = new OrganizationGetSearchModel
        {
            LanguageId = Thread.CurrentThread.CurrentCulture.Name,
            PageNumber = pageNumber,
            PageSize = PageSize,
            SortColumn = sortProperty,
            SortOrder = sortOrder,
            FilterValue = args.Filter,
            AccessoryCode = (int) AccessoryCodes.HumanHACode
        };
        
        Organizations = await OrganizationClient.Search(request);
    }
}

