using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Menu;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class MenuClientMock : BaseClientMock<IMenuClient>, IMenuClient
    {
        public Task<List<MenuByUserViewModel>> GetMenuByUserListAsync(long userID, string languageID)
        {
            throw new NotImplementedException();
        }

        public Task<List<MenuViewModel>> GetMenuListAsync(long userID, string lanuageID)
        {
            Client.Setup(p => p.GetMenuListAsync(userID, lanuageID)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<MenuViewModel>().ToList());
            return Client.Object.GetMenuListAsync(userID, lanuageID);
        }
    }
}
