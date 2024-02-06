using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit;
using Moq;
using EIDSS.Api.Providers;
using EIDSS.Repository.Interfaces;
using Microsoft.AspNetCore.Identity;

namespace EIDSS.Api.xUnitTest.Controllers_Tests
{
    public class AdminControllerUnitTests
    {
        [Fact]
        public void LoginUser_WithAnExistingUser_ReturnsFound()
        {
            var repositoryStub = new Mock<RoleManager<IdentityRole>>();
        }
    }
}
