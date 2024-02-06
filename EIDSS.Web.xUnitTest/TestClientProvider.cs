using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.TestHost;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest
{
    public class TestClientProvider : IDisposable
    {
        private TestServer server;

        public HttpClient Client { get; private set; }

        public TestClientProvider()
        {
            server = new TestServer(new WebHostBuilder().UseStartup<TestStartup>());
            Client = server.CreateClient();
        }
        public void Dispose()
        {
            server?.Dispose();
            Client?.Dispose();
        }
    }
}
