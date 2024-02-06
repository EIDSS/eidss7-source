using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class PersonClientMock : BaseClientMock<IPersonClient>, IPersonClient
    {
        public Task<List<DiseaseReportPersonalInformationViewModel>> GetHumanDiseaseReportPersonInfoAsync(HumanPersonDetailsRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<PersonViewModel>> GetPersonList(HumanPersonSearchRequestModel request)
        {
            Client.Setup(p=> p.GetPersonList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<PersonViewModel>().ToList());
            return Client.Object.GetPersonList(request);
        }

        public Task<List<PersonForOfficeViewModel>> GetPersonListForOffice(GetPersonForOfficeRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<PersonSaveResponseModel> SavePerson(PersonSaveRequestModel request)
        {
            throw new NotImplementedException();
        }
    }
}
