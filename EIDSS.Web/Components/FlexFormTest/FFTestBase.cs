using System;
using EIDSS.Domain.RequestModels.FlexForm;
using System.Threading.Tasks;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Components;
using EIDSS.Web.Components.FlexForm;

namespace EIDSS.Web.Components.FlexFormTest
{
    public class FFTestBase : BaseComponent, IDisposable
    {
        public EIDSS.Web.Components.FlexForm.FlexForm ff { get; set; }
        
        protected FlexFormQuestionnaireGetRequestModel flexFormRequest { get; set; }
        protected override async Task OnInitializedAsync()
        {

            //flexFormRequest = new FlexFormQuestionnaireGetRequestModel();

            //flexFormRequest.Title = "Test Flex Form";
            //flexFormRequest.LangID = "en-us";
            //flexFormRequest.idfsDiagnosis = 9843770000000;
            //flexFormRequest.idfsFormType = 10034018;


            flexFormRequest = new FlexFormQuestionnaireGetRequestModel();

            flexFormRequest.LangID = "en-us";
            flexFormRequest.idfsDiagnosis = 9843770000000;
            flexFormRequest.idfsFormType = 10034015;
            flexFormRequest.idfObservation = 155575710005824;
            flexFormRequest.Title = "Test Flex Form";

            await base.OnInitializedAsync();

            //ff = new FlexForm.FlexForm();
            //ff.Render(flexFormRequest);
        }

        protected override async Task OnAfterRenderAsync(bool firstRender)
        {
            //string test = string.Empty;
            //await ff.Render();
        }

        protected async Task Save()
        {
            await InvokeAsync(() =>
            {
                _ = ff.SaveFlexForm();
                StateHasChanged();
            });
            
        }

        public void Dispose()
        {
            
        }
    }
}
