using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Controllers;
using EIDSS.Web.xUnitTest.Abstracts;
using EIDSS.Web.xUnitTest.Arrangements;
using EIDSS.Web.xUnitTest.Arrangements.Client_Mocks;
using EIDSS.Web.xUnitTest.Arrangements.Service_Mocks;
using Microsoft.AspNetCore.Mvc.Testing;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace EIDSS.Web.xUnitTest.Clients
{
    public class AdminClientUnitTests : IClassFixture<WebApplicationFactory<EIDSS.Web.Startup>>
    {
        [Fact]
        public async void Password_Is_Valid()
        {

        }
    }
}
