using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.Fakes;
using EIDSS.ClientLibrary.Services;
using EIDSS.ClientLibrary.Services.Fakes;
using EIDSS.Domain.RequestModels.DataTables;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.Controllers;
using EIDSS.Web.xUnitTest.Abstracts;
using EIDSS.Web.xUnitTest.Arrangements.Client_Mocks;
using EIDSS.Web.xUnitTest.Arrangements.Service_Mocks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.QualityTools.Testing.Fakes;
using RESTFulSense.Clients;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Xunit;

namespace EIDSS.Web.xUnitTest.Web.Controllers.Administration
{
    public class AdminControllerTests : BaseControllerTest
    {
        AdminController controller = null;
        public AdminControllerTests(WebApplicationFactory<TestStartup> factory) : base(factory)
        {
        }

        public class AdminTest : IClassFixture<WebApplicationFactory<Startup>>
        {
            //Create your properties
            public HttpClient httpClient;
            private readonly IRESTFulApiFactoryClient apiFactoryClient;

            //Create a constructor to initialize and use the clients
            public AdminTest()
            {
                var factory = new WebApplicationFactory<Startup>();
                httpClient = factory.CreateClient();
                //httpClient.BaseAddress = new Uri("http://localhost:53063/");
            }

            [Fact]
            public async Task Index_BaseReferenceEditor_CaseClassificationPageShouldRender()
            {
                try
                {
                    //Declare a response variable
                    var response = await httpClient.GetAsync("http://localhost:53063/Administration/CaseClassificationPage/Index");

                    //Check and see if the correct response code is returned
                    response.EnsureSuccessStatusCode();

                    //Declare variable to get response and read it into a string
                    var respString = await response.Content.ReadAsStringAsync();

                    //Assert page title is correct (i.e. Views/CaseClassificationPage/Index.cshtml)
                    Assert.Contains("Case Classification List", respString);
                }
                catch (Exception e)
                {

                }

            }

            [Fact]
            public async Task Index_BaseReferenceEditor_SampleTypePageShouldRender_TEsT()
            {
                //Create new object for a request
                JQueryDataTablesQueryObject dataTableQueryPostObj = new JQueryDataTablesQueryObject();
                dataTableQueryPostObj.draw = 1;
                dataTableQueryPostObj.length = 10;
                dataTableQueryPostObj.start = 0;

                //Call controller page
                var controllerRequest = new StringContent(JsonSerializer.Serialize(dataTableQueryPostObj), Encoding.UTF8, "application/json");

                //Declare a response variable
                var response = await httpClient.PostAsync("Administration/SampleType/GetList", controllerRequest);

                //Check and see if the correct response code is returned
                response.EnsureSuccessStatusCode();

                //Declare variable to get response and read it into a string
                var respString = await response.Content.ReadAsStringAsync();

                //Assert page title is correct (i.e. Views/SampleType/Index.cshtml)
                Assert.Contains("Sample Types List", respString);
            }

        }

        public class SampleTypeAdd
        {
            public String StrDefault { get; set; }
            public String StrName { get; set; }
            public String StrSampleCode { get; set; }
            public List<IntHACode> IntHACode { get; set; }
            public String intOrder { get; set; }


        }

        public class IntHACode
        {
            public String text { get; set; }
            public String id { get; set; }


        }

    }
}
