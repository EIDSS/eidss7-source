using EIDSS.Domain.ViewModels;
using Microsoft.AspNetCore.Mvc.Testing;
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
    public abstract class BaseTest : IClassFixture<WebApplicationFactory<TestStartup>>
    {
        protected readonly WebApplicationFactory<TestStartup> _factory;

        public BaseTest(WebApplicationFactory<TestStartup> factory)
        {
            _factory = factory;
        }

    }
}
