using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.CrossCutting;
using Microsoft.AspNetCore.Components;

namespace EIDSS.Web.Components.Shared.Organization;

public class YesNoUnknownBase : ComponentBase
{
    [Parameter] public long? SelectedAnswerId { get; set; }
    [Parameter] public string Name { get; set; }
    [Parameter] public EventCallback<long?> SelectedAnswerIdChanged { get; set; }
    [Parameter] public bool Disabled { get; set; }
    protected List<BaseReferenceViewModel> YesNoChoices { get; set; } = new();
    [Inject] private ICrossCuttingClient CrossCuttingClient { get; set; }
    private long? LastSelectedAnswerId { get; set; }
    
    protected override async Task OnInitializedAsync()
    {
        await base.OnInitializedAsync();
        YesNoChoices = await CrossCuttingClient.GetBaseReferenceList(Thread.CurrentThread.CurrentCulture.Name, EIDSSConstants.BaseReferenceConstants.YesNoValueList, EIDSSConstants.HACodeList.HumanHACode);
    }

    protected override void OnParametersSet()
    {
        base.OnParametersSet();
        LastSelectedAnswerId = SelectedAnswerId;
    }

    protected async Task OnSelectedAnswerIdChanged(long? answerId)
    { 
        if (answerId == LastSelectedAnswerId)
        {
            SelectedAnswerId = null;
            await SelectedAnswerIdChanged.InvokeAsync(null);
        }
        else
        {
            await SelectedAnswerIdChanged.InvokeAsync(answerId); 
        }

        LastSelectedAnswerId = SelectedAnswerId;
    }
}

