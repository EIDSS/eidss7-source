using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.ApiClients.Laboratory;
using EIDSS.ClientLibrary.ApiClients.Menu;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.ViewModels;
using Microsoft.AspNetCore.Mvc.Testing;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Xunit;

namespace EIDSS.Web.xUnitTest.Abstracts
{
    public abstract class BaseControllerTest : IClassFixture<WebApplicationFactory<TestStartup>>
    {
        protected readonly WebApplicationFactory<TestStartup> _factory;

        public BaseControllerTest(WebApplicationFactory<TestStartup> factory) 
        {
            _factory = factory;
        }
    }
}
