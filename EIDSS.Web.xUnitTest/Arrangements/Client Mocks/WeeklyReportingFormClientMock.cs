using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.Domain.RequestModels.Human;
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
    public class WeeklyReportingFormClientMock : BaseClientMock<IWeeklyReportingFormClient>, IWeeklyReportingFormClient
    {
        public Task<List<ReportFormViewModel>> GetWeeklyReportingFormList(WeeklyReportingFormGetRequestModel request)
        {
            Client.Setup(p => p.GetWeeklyReportingFormList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ReportFormViewModel>().ToList());
            return Client.Object.GetWeeklyReportingFormList(request);

        }
    }
}
