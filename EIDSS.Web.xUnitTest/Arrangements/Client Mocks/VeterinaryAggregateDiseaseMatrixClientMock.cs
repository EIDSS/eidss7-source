using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Configuration;
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
    public class VeterinaryAggregateDiseaseMatrixClientMock : BaseClientMock<IVeterinaryAggregateDiseaseMatrixClient>, IVeterinaryAggregateDiseaseMatrixClient
    {
        public Task<APIPostResponseModel> DeleteVeterinaryAggregateDiseaseMatrixRecord(long idfAggrVetCaseMTX)
        {
            Client.Setup(p=> p.DeleteVeterinaryAggregateDiseaseMatrixRecord(idfAggrVetCaseMTX)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteVeterinaryAggregateDiseaseMatrixRecord(idfAggrVetCaseMTX);
        }

        public Task<List<VeterinaryAggregateDiseaseMatrixViewModel>> GetVeterinaryAggregateDiseaseMatrixListAsync(string versionList, string LangID)
        {
            Client.Setup(p=> p.GetVeterinaryAggregateDiseaseMatrixListAsync(versionList, LangID)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< VeterinaryAggregateDiseaseMatrixViewModel>().ToList());
            return Client.Object.GetVeterinaryAggregateDiseaseMatrixListAsync(versionList, LangID);
        }

        public Task<APIPostResponseModel> SaveVeterinaryAggregateDiseaseMatrix(MatrixViewModel saveRequestModel)
        {
            Client.Setup(p=> p.SaveVeterinaryAggregateDiseaseMatrix(saveRequestModel)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveVeterinaryAggregateDiseaseMatrix(saveRequestModel);
        }
    }
}
