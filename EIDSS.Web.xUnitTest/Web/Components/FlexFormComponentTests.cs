using AutoFixture;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.Components;
using EIDSS.Web.ViewModels.CrossCutting;
using EIDSS.Web.xUnitTest.Abstracts;
using EIDSS.Web.xUnitTest.Arrangements.Client_Mocks;
using Microsoft.AspNetCore.Mvc.ViewComponents;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace EIDSS.Web.xUnitTest.Web.Components
{
    public class FlexFormComponentTests
    {
        FlexFormViewComponent _fvc = null;
        public FlexFormComponentTests()
        {
            _fvc = new FlexFormViewComponent(new FlexFormClientMock());
        }

        [Fact]
        public async void JavaScript_Is_Formulated_Correctly()
        {
            ViewDataDictionary viewdata = null;
            FlexFormQuestionnaireViewModel model = null;

            // Arrange...
            var request = BaseArrangement.Fixture.Build<FlexFormQuestionnaireGetRequestModel>()
                .With(p => p.LangID, BaseArrangement.LanguageId)
                .With(p => p.idfsFormType, 10034011)
                .With(p => p.Title, "Testing")
                .Create();
            // sut...
            var result = await _fvc.InvokeAsync(request);

            try { viewdata = ((ViewViewComponentResult)result).ViewData; } catch { };
            try { model = (FlexFormQuestionnaireViewModel)viewdata.Model; } catch { };

            Assert.NotNull(viewdata);
            Assert.NotNull(model);
            Assert.Contains(request.SubmitButtonID, model.FlexFormScript);
            Assert.Contains($"getFlexFormAnswers{request.idfsFormType}", model.FlexFormScript);
            Assert.Contains($"#{request.idfsFormType} input[parameter]", model.FlexFormScript, StringComparison.OrdinalIgnoreCase);
            Assert.Contains($"#{request.idfsFormType} select[parameter]", model.FlexFormScript, StringComparison.OrdinalIgnoreCase);
            Assert.Contains($"[asp-for='{request.ObserationFieldID}']", model.FlexFormScript, StringComparison.OrdinalIgnoreCase);
        }
    }
}
