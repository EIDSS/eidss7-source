using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.xUnitTest.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class StatisticalTypeClientMock : BaseClientMock<IStatisticalTypeClient>, IStatisticalTypeClient
    {
        public Task<APIPostResponseModel> DeleteStatisticalType(long idfsStatisticDataType, bool? deleteAnyway)
        {
            Client.Setup(p => p.DeleteStatisticalType(idfsStatisticDataType, deleteAnyway)).Returns(Task.FromResult(BaseArrangement.APIPostResponseMock_200));
            return Client.Object.DeleteStatisticalType(idfsStatisticDataType, deleteAnyway);
        }

        public Task<List<BaseReferenceEditorsViewModel>> GetStatisticalTypeList(StatisticalTypeGetRequestModel request)
        {
            Client.Setup(p => p.GetStatisticalTypeList(request)).Returns(Task.FromResult(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList()));
            return Client.Object.GetStatisticalTypeList(request);
        }

        public Task<APIPostResponseModel> SaveStatisticalType(StatisticalTypeSaveRequestModel StatisticalTypeModel)
        {
            Client.Setup(p => p.SaveStatisticalType(StatisticalTypeModel)).Returns(Task.FromResult(BaseArrangement.APIPostResponseMock_200));
            return Client.Object.SaveStatisticalType(StatisticalTypeModel);
        }
    }
}
