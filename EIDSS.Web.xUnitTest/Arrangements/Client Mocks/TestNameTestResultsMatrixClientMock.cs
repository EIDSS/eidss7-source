using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
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
    public class TestNameTestResultsMatrixClientMock : BaseClientMock<ITestNameTestResultsMatrixClient>, ITestNameTestResultsMatrixClient
    {
        public Task<APIPostResponseModel> DeleteTestNameTestResultsMatrix(long idfsTestResultRelation, long idfsTestName, long idfsTestResult, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteTestNameTestResultsMatrix(idfsTestResultRelation, idfsTestName, idfsTestResult, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteTestNameTestResultsMatrix(idfsTestResultRelation, idfsTestName, idfsTestResult, deleteAnyway);
        }

        public Task<List<TestNameTestResultsMatrixViewModel>> GetTestNameTestResultsMatrixList(TestNameTestResultsMatrixGetRequestModel request)
        {
            Client.Setup(p=> p.GetTestNameTestResultsMatrixList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany< TestNameTestResultsMatrixViewModel>().ToList());
            return Client.Object.GetTestNameTestResultsMatrixList(request);
        }

        public Task<TestNameTestResultsMatrixSaveRequestResponseModel> SaveTestNameTestResultsMatrix(TestNameTestResultsMatrixSaveRequestModel request)
        {
            Client.Setup(p=> p.SaveTestNameTestResultsMatrix(request)).ReturnsAsync(BaseArrangement.Fixture.Create< TestNameTestResultsMatrixSaveRequestResponseModel>());
            return Client.Object.SaveTestNameTestResultsMatrix(request);
        }
    }
}
