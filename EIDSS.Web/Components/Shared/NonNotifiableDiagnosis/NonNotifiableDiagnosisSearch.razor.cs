using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.AspNetCore.Components;
using Microsoft.Extensions.Localization;
using Radzen;

namespace EIDSS.Web.Components.Shared.NonNotifiableDiagnosis;

public class NonNotifiableDiagnosisSearchBase : ComponentBase
{
    [Parameter] public long? SelectedDiagnosisId { get; set; }
    [Parameter] public string? SelectedDiagnosisText { get; set; }
    [Parameter] public EventCallback<long?> SelectedDiagnosisIdChanged { get; set; }
    [Parameter] public EventCallback<string?> SelectedDiagnosisTextChanged { get; set; }
    [Parameter] public string Name { get; set; } = string.Empty;
    [Parameter] public bool Disabled { get; set; }
    protected List<BaseReferenceEditorsViewModel> NonNotifiableDiagnosis { get; set; } = new();
    protected int PageSize { get; set; } = 10;
    [Inject] protected IStringLocalizer Localizer { get; set; }
    [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }
    private bool InitializedFirstDataSet { get; set; }
    protected int NonNotifiableDiagnosisCount => NonNotifiableDiagnosis.FirstOrDefault()?.TotalRowCount ?? 0;

    
    protected async Task OnNonNotifiableDiagnosisChange(object? selectedItem)
    {
        var item = (BaseReferenceEditorsViewModel?)selectedItem;
        await SelectedDiagnosisIdChanged.InvokeAsync(item?.KeyId); 
        await SelectedDiagnosisTextChanged.InvokeAsync(item?.StrName); 
    }
    
    protected async Task LoadNonNotifiableDiagnosisOnce(ElementReference arg)
    {
        if (!InitializedFirstDataSet)
        {
            InitializedFirstDataSet = true;
            await LoadData(new LoadDataArgs { Filter = "" });
        }
    }
        
    protected async Task LoadData(LoadDataArgs args)
    {
        var sortOrder = EIDSSConstants.SortConstants.Ascending;
        var pageNumber = ((args.Skip ?? 0) + PageSize) / PageSize;
        if (!string.IsNullOrWhiteSpace(args.OrderBy))
        {
            var orderByItems = args.OrderBy.Split(" ");
            sortOrder = orderByItems[1];
        }
        
        BaseReferenceEditorGetRequestModel request = new()
        {
            IdfsReferenceType = (long)ReferenceTypes.NonNotifiableDiagnosis,
            Page = pageNumber,
            PageSize = PageSize,
            LanguageId = Thread.CurrentThread.CurrentCulture.Name,
            SortColumn = nameof(BaseReferenceEditorsViewModel.StrName),
            SortOrder = sortOrder,
            AdvancedSearch = args.Filter
        };

        NonNotifiableDiagnosis = await CrossCuttingClient.GetBaseReferenceList(request);
    }
}

