using AutoFixture;
using Castle.Core.Configuration;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.xUnitTest.Abstracts;
using Microsoft.AspNetCore.Http;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Service_Mocks
{
    public class TokenServiceMock : BaseServiceMock<ITokenService>, ITokenService
    {
        public TokenServiceMock()
        {
            SetTokenServiceMock();
        }

        public AuthenticatedUser CreateAuthenticatedUser(string token, DateTime tokenExpireDatetime)
        {
            return BaseArrangement.AuthenticatedUserMock;
        }

        public UserPermissions GerUserPermissions(PagePermission permission)
        {
            return Service.Object.GerUserPermissions(permission);
        }

        public AuthenticatedUser GetAuthenticatedUser()
        {
            return Service.Object.GetAuthenticatedUser();
        }


        private void SetTokenServiceMock()
        {
            var ctx = new Mock<IHttpContextAccessor>();
            var conf = new Mock<IConfiguration>();

            var c = new Mock<ITokenService>();
            Service = new Mock<ITokenService>();
            Service.Setup(p => p.CreateAuthenticatedUser(BaseArrangement.UserToken, BaseArrangement.TokenExpiration)).Returns(BaseArrangement.AuthenticatedUserMock);
            Service.Setup(p => p.GetAuthenticatedUser()).Returns(BaseArrangement.AuthenticatedUserMock);
            Service.Setup(p => p.GerUserPermissions(It.IsAny<PagePermission>())).Returns(BaseArrangement.Fixture.Create<UserPermissions>());

        }

    }
}
