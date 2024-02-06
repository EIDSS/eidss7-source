using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class InterfaceEditorClientMock : BaseClientMock<IInterfaceEditorClient>, IInterfaceEditorClient
    {
        public Task<List<InterfaceEditorModuleSectionViewModel>> GetInterfaceEditorModuleList(InterfaceEditorModuleGetRequestModel request)
        {
            Client.Setup(p=> p.GetInterfaceEditorModuleList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<InterfaceEditorModuleSectionViewModel>().ToList());
            return Client.Object.GetInterfaceEditorModuleList(request);
        }

        public Task<List<InterfaceEditorResourceViewModel>> GetInterfaceEditorResourceList(InterfaceEditorResourceGetRequestModel request)
        {
            Client.Setup(p=> p.GetInterfaceEditorResourceList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<InterfaceEditorResourceViewModel>().ToList());
            return Client.Object.GetInterfaceEditorResourceList(request);
        }

        public Task<List<InterfaceEditorModuleSectionViewModel>> GetInterfaceEditorSectionList(InterfaceEditorSectionGetRequestModel request)
        {
            Client.Setup(p=> p.GetInterfaceEditorSectionList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<InterfaceEditorModuleSectionViewModel>().ToList());
            return Client.Object.GetInterfaceEditorSectionList(request);
        }

        public Task<List<InterfaceEditorTemplateViewModel>> GetInterfaceEditorTemplateItems(string langId)
        {
            Client.Setup(p=> p.GetInterfaceEditorTemplateItems(langId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<InterfaceEditorTemplateViewModel>().ToList());
            return Client.Object.GetInterfaceEditorTemplateItems(langId);
        }

        public Task<APIPostResponseModel> SaveInterfaceEditorResource(InterfaceEditorResourceSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveInterfaceEditorResource(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveInterfaceEditorResource(request);
        }

        public Task<APIPostResponseModel> UploadLanguageTranslation(InterfaceEditorLangaugeFileSaveRequestModel request)
        {
            Client.Setup(p=> p.UploadLanguageTranslation(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.UploadLanguageTranslation(request);
        }
    }
}
