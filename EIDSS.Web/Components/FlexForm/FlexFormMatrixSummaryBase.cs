using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using Microsoft.AspNetCore.Components;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EIDSS.Web.Components.FlexForm;

public class FlexFormMatrixSummaryBase : ComponentBase
{
    [Inject]
    public IFlexFormClient _flexFormClient { get; set; }

    [Parameter]
    public FlexFormQuestionnaireGetRequestModel Request { get; set; }

    protected List<FlexFormQuestionnaireResponseModel> flexForm;
    protected string title;
    protected List<Section> sections;
    protected List<FlexFormActivityParametersListResponseModel> answers;

    private string observationList = string.Empty;

    protected override async Task OnInitializedAsync()
    {
        await LoadQuestionnaire();

        await base.OnInitializedAsync();
    }

    protected override async Task OnParametersSetAsync()
    {
        if (observationList != Request.observationList)
        {
            observationList = Request.observationList;

            await LoadQuestionnaire();

            await base.OnParametersSetAsync();
        }
    }

    private async Task LoadQuestionnaire()
    {
        title = Request.Title;
        sections = [];

        flexForm = await _flexFormClient.GetQuestionnaire(Request);

        if (!string.IsNullOrEmpty(Request.observationList))
        {
            var answersRequest = new FlexFormActivityParametersGetRequestModel
            {
                observationList = Request.observationList,
                LangID = Request.LangID
            };

            answers = await _flexFormClient.GetAnswers(answersRequest);
        }

        //Iterate through to create section containers
        long? idfsSection = null;
        foreach (var item in flexForm)
        {
            //TODO: skip sections and labels until proper implementation
            if (item.idfsSection == item.idfsParameter || item.idfsEditor is null)
                continue;

            if (item.idfsSection != null && item.idfsSection != idfsSection)
            {
                var section = new Section
                {
                    blnGrid = (bool)(item.blnGrid ?? false),
                    idfsSection = (long)item.idfsSection
                };

                idfsSection = (long)item.idfsSection;
                sections.Add(section);
            }
        }
    }
}
