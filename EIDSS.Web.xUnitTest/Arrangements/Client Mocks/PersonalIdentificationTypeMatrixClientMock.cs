using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class PersonalIdentificationTypeMatrixClientMock : BaseClientMock<IPersonalIdentificationTypeMatrixClient>, IPersonalIdentificationTypeMatrixClient
    {
        public Task<APIPostResponseModel> DeletePersonalIdentificationTypeMatrix(long idfBaseReferenceAttribute)
        {
            Client.Setup(p=> p.DeletePersonalIdentificationTypeMatrix(idfBaseReferenceAttribute)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeletePersonalIdentificationTypeMatrix(idfBaseReferenceAttribute);
        }

        public Task<List<PersonalIdentificationTypeMatrixViewModel>> GetPersonalIdentificationTypeMatrixList(PersonalIdentificationTypeMatrixGetRequestModel request)
        {
            Client.Setup(p=> p.GetPersonalIdentificationTypeMatrixList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<PersonalIdentificationTypeMatrixViewModel>().ToList());
            return Client.Object.GetPersonalIdentificationTypeMatrixList(request);
        }

        public Task<APISaveResponseModel> SavePersonalIdentificationTypeMatrix(PersonalIdentificationTypeMatrixSaveRequestModel saveRequestModel)
        {
            Client.Setup(p=> p.SavePersonalIdentificationTypeMatrix(saveRequestModel)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SavePersonalIdentificationTypeMatrix(saveRequestModel);
        }
    }
}
