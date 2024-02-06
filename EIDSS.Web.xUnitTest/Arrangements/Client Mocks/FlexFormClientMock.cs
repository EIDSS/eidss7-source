using AutoFixture;
using Moq;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.FlexForm;
using EIDSS.Domain.ViewModels.FlexForm;
using EIDSS.Web.xUnitTest.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class FlexFormClientMock : BaseClientMock<IFlexFormClient>, IFlexFormClient
    {
        public Task<APIPostResponseModel> CopyParameter(FlexFormParameterCopyRequestModel request)
        {
            Client.Setup(p => p.CopyParameter(request)).Returns(Task.FromResult(BaseArrangement.APIPostResponseMock_200));
            return Client.Object.CopyParameter(request);
        }

        public Task<APIPostResponseModel> CopySection(FlexFormSectionCopyRequestModel request)
        {
            Client.Setup(p => p.CopySection(request)).Returns(Task.FromResult(BaseArrangement.APIPostResponseMock_200));
            return Client.Object.CopySection(request);
        }

        public Task<FlexFormCopyTemplateResponseModel> CopyTemplate(FlexFormCopyTemplateRequestModel request)
        {
            Client.Setup(p => p.CopyTemplate(request)).Returns(Task.FromResult(BaseArrangement.Fixture.Create<FlexFormCopyTemplateResponseModel>()));
            return Client.Object.CopyTemplate(request);
        }

        public Task<APIPostResponseModel> DeleteParameter(FlexFormParameterDeleteRequestModel request)
        {
            Client.Setup(p => p.DeleteParameter(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteParameter(request);
        }

        public Task<APIPostResponseModel> DeleteSection(FlexFormSectionDeleteRequestModel request)
        {
            Client.Setup(p => p.DeleteSection(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteSection(request);
        }

        public Task<APIPostResponseModel> DeleteTemplate(FlexFormTemplateDeleteRequestModel request)
        {
            Client.Setup(p => p.DeleteTemplate(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteTemplate(request);
        }

        public Task<FlexFormDeleteTemplateParameterResponseModel> DeleteTemplateParameter(FlexFormParameterTemplateDeleteRequestModel request)
        {
            Client.Setup(p => p.DeleteTemplateParameter(request)).ReturnsAsync(BaseArrangement.Fixture.Create<FlexFormDeleteTemplateParameterResponseModel>());
            return Client.Object.DeleteTemplateParameter(request);
        }

        public Task<List<FlexFormActivityParametersListResponseModel>> GetAnswers(FlexFormActivityParametersGetRequestModel request)
        {
            Client.Setup(p => p.GetAnswers(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormActivityParametersListResponseModel>().ToList());
            return Client.Object.GetAnswers(request);
        }

        public Task<List<FlexFormDiagnosisReferenceListViewModel>> GetDiseaseList(FlexFormDiseaseGetListRequestModel request)
        {
            Client.Setup(p => p.GetDiseaseList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormDiagnosisReferenceListViewModel>().ToList());
            return Client.Object.GetDiseaseList(request);
        }

        public Task<List<FlexFormParameterSelectListResponseModel>> GetDropDownOptionsList(FlexFormParameterSelectListGetRequestModel request)
        {
            Client.Setup(p => p.GetDropDownOptionsList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormParameterSelectListResponseModel>().ToList());
            return Client.Object.GetDropDownOptionsList(request);
        }

        public Task<List<FlexFormFormTypesListViewModel>> GetFormTypesList(FlexFormFormTypesGetRequestModel request)
        {
            Client.Setup(p => p.GetFormTypesList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormFormTypesListViewModel>().ToList());
            return Client.Object.GetFormTypesList(request);
        }

        public Task<List<FlexFormParameterDetailViewModel>> GetParameterDetails(FlexFormParameterDetailsGetRequestModel request)
        {
            Client.Setup(p => p.GetParameterDetails(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormParameterDetailViewModel>().ToList());
            return Client.Object.GetParameterDetails(request);
        }

        public Task<List<FlexFormParametersListViewModel>> GetParametersList(FlexFormParametersGetRequestModel request)
        {
            Client.Setup(p => p.GetParametersList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormParametersListViewModel>().ToList());
            return Client.Object.GetParametersList(request);
        }

        public Task<List<FlexFormQuestionnaireResponseModel>> GetQuestionnaire(FlexFormQuestionnaireGetRequestModel request)
        {
            Client.Setup(p => p.GetQuestionnaire(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormQuestionnaireResponseModel>().ToList());
            return Client.Object.GetQuestionnaire(request);
        }

        public Task<FlexFormRuleDetailsViewModel> GetRuleDetails(FlexFormRuleDetailsGetRequestModel request)
        {
            Client.Setup(p => p.GetRuleDetails(request)).ReturnsAsync(BaseArrangement.Fixture.Create<FlexFormRuleDetailsViewModel>());
            return Client.Object.GetRuleDetails(request);
        }

        public Task<List<FlexFormRulesListViewModel>> GetRulesList(FlexFormRulesGetRequestModel request)
        {
            Client.Setup(p => p.GetRulesList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormRulesListViewModel>().ToList());
            return Client.Object.GetRulesList(request);
        }

        public Task<List<FlexFormSectionParameterListViewModel>> GetSectionParameterList(FlexFormSectionParameterGetRequestModel request)
        {
            Client.Setup(p => p.GetSectionParameterList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormSectionParameterListViewModel>().ToList());
            return Client.Object.GetSectionParameterList(request);
        }

        public Task<List<FlexFormSectionsListViewModel>> GetSectionsList(FlexFormSectionsGetRequestModel request)
        {
            Client.Setup(p => p.GetSectionsList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormSectionsListViewModel>().ToList());
            return Client.Object.GetSectionsList(request);
        }

        public Task<List<FlexFormSectionParameterListViewModel>> GetSectionsParametersList(FlexFormSectionsParametersRequestModel request)
        {
            Client.Setup(p => p.GetSectionsParametersList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormSectionParameterListViewModel>().ToList());
            return Client.Object.GetSectionsParametersList(request);
        }

        public Task<List<FlexFormTemplateDesignListViewModel>> GetTemplateDesignList(FlexFormTemplateDesignGetRequestModel request)
        {
            Client.Setup(p => p.GetTemplateDesignList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormTemplateDesignListViewModel>().ToList());
            return Client.Object.GetTemplateDesignList(request);
        }

        public Task<List<FlexFormTemplateDetailViewModel>> GetTemplateDetails(FlexFormTemplateDetailsGetRequestModel request)
        {
            Client.Setup(p => p.GetTemplateDetails(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormTemplateDetailViewModel>().ToList());
            return Client.Object.GetTemplateDetails(request);
        }

        public Task<List<FlexFormTemplateDeterminantValuesListViewModel>> GetTemplateDeterminantValues(FlexFormTemplateDeterminantValuesGetRequestModel request)
        {
            Client.Setup(p => p.GetTemplateDeterminantValues(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormTemplateDeterminantValuesListViewModel>().ToList());
            return Client.Object.GetTemplateDeterminantValues(request);
        }

        public Task<List<FlexFormTemplateListViewModel>> GetTemplateList(FlexFormTemplateGetRequestModel request)
        {
            Client.Setup(p => p.GetTemplateList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormTemplateListViewModel>().ToList());
            return Client.Object.GetTemplateList(request);
        }

        public Task<List<FlexFormTemplateByParameterListModel>> GetTemplatesByParameterList(FlexFormTemplateByParameterGetRequestModel request)
        {
            Client.Setup(p => p.GetTemplatesByParameterList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormTemplateByParameterListModel>().ToList());
            return Client.Object.GetTemplatesByParameterList(request);
        }

        public Task<List<FlexFormParameterInUseDetailViewModel>> IsParameterInUse(FlexFormParameterInUseRequestModel request)
        {
            Client.Setup(p => p.IsParameterInUse(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<FlexFormParameterInUseDetailViewModel>().ToList());
            return Client.Object.IsParameterInUse(request);
        }

        public Task<FlexFormActivityParametersResponseModel> SaveAnswers(FlexFormActivityParametersSaveRequestModel request)
        {
            Client.Setup(p => p.SaveAnswers(request)).ReturnsAsync(BaseArrangement.Fixture.Create<FlexFormActivityParametersResponseModel>());
            return Client.Object.SaveAnswers(request);
        }

        public Task<APISaveResponseModel> SetDeterminant(FlexFormDeterminantSaveRequestModel request)
        {
            Client.Setup(p => p.SetDeterminant(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SetDeterminant(request);
        }

        public Task<APIPostResponseModel> SetOutbreakFlexForm(FlexFormAddToOutbreakSaveRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<FlexFormParametersSaveResponseModel> SetParameter(FlexFormParametersSaveRequestModel request)
        {
            Client.Setup(p => p.SetParameter(request)).ReturnsAsync(BaseArrangement.Fixture.Create<FlexFormParametersSaveResponseModel>());
            return Client.Object.SetParameter(request);
        }

        public Task<APISaveResponseModel> SetRequiredParameter(FlexFormParameterRequiredRequestModel request)
        {
            Client.Setup(p => p.SetRequiredParameter(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SetRequiredParameter(request);
        }

        public Task<APISaveResponseModel> SetRule(FlexFormRuleSaveRequestModel request)
        {
            Client.Setup(p => p.SetRule(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SetRule(request);
        }

        public Task<APISaveResponseModel> SetSection(FlexFormSectionSaveRequestModel request)
        {
            Client.Setup(p => p.SetSection(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SetSection(request);
        }

        public Task<APISaveResponseModel> SetTemplate(FlexFormTemplateSaveRequestModel request)
        {
            Client.Setup(p => p.SetTemplate(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SetTemplate(request);
        }

        public Task<APISaveResponseModel> SetTemplateParameter(FlexFormParameterTemplateSaveRequestModel request)
        {
            Client.Setup(p => p.SetTemplateParameter(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SetTemplateParameter(request);
        }

        public Task<APIPostResponseModel> SetTemplateParameterOrder(FlexFormTemplateParamterOrderRequestModel request)
        {
            Client.Setup(p => p.SetTemplateParameterOrder(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SetTemplateParameterOrder(request);
        }
    }
}
