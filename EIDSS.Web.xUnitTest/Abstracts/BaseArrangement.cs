using AutoFixture;
using AutoFixture.AutoMoq;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.xUnitTest.Arrangements.Service_Mocks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Moq;
using Moq.Protected;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Runtime.Serialization;
using System.ServiceModel.Channels;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Abstracts
{
    /// <summary>
    /// Static testing arrangements
    /// </summary>
    public static class BaseArrangement
    {
        #region Fields

        private static IConfiguration _configuration;
        private static SystemPreferences _systemPrefs;
        private static string _token;
        private static AuthenticatedUser _user;
        private static LocationViewModel _userLocation;

        /// <summary>
        /// AutoFixture fixture
        /// </summary>
        public static IFixture Fixture
        {
            get => new Fixture().Customize(new AutoMoqCustomization());
        }

        #endregion Fields

        #region Properties

        /// <summary>
        /// An instance of <see cref="APIPostResponseModel"/> that returns "success"
        /// </summary>
        public static APIPostResponseModel APIPostResponseMock_200
        {
            get => new APIPostResponseModel
            {
                ReturnCode = 202,
                ReturnMessage = "SUCCESS"
            };
        }

        /// <summary>
        /// An instance of <see cref="APIPostResponseModel"/> that returns "not found"
        /// </summary>
        public static APIPostResponseModel APIPostResponseMock_404
        {
            get => new APIPostResponseModel
            {
                ReturnCode = 404,
                ReturnMessage = "Not Found"
            };
        }

        /// <summary>
        /// An instance of <see cref="APIPostResponseModel"/> that returns "internal server error"
        /// </summary>
        public static APIPostResponseModel APIPostResponseMock_500
        {
            get => new APIPostResponseModel
            {
                ReturnCode = 500,
                ReturnMessage = "Internal server error"
            };
        }

        /// <summary>
        /// APISaveResponse mock
        /// </summary>
        public static APISaveResponseModel APISaveResponseMock
        {
            get => new APISaveResponseModel
            {
                ReturnCode = 200,
                ReturnMessage = "SUCESS",
                AdditionalKeyId = Fixture.Create<long>(),
                AdditionalKeyName = Fixture.Create<string>(),
                KeyId = 100000,
                KeyIdName = Fixture.Create<string>(),
                PageAction = 0,
                strClientPageMessage = Fixture.Create<string>()
            };
        }

        /// <summary>
        /// Mocked AuthenticatedUserLocation instance
        /// </summary>
        public static LocationViewModel AuthenticatedUserLocation
        {
            get => _userLocation;
        }

        /// <summary>
        /// Mocked AuthenticatedUser instance
        /// </summary>
        public static AuthenticatedUser AuthenticatedUserMock
        {
            get => _user;
        }

        /// <summary>
        /// Mocked IConfiguration instance
        /// </summary>
        public static IConfiguration Configuration
        {
            get => _configuration;
        }

        /// <summary>
        /// IdfsReferenceTypes
        /// </summary>
        public static Dictionary<string, long> IdfsReferenceTypes { get; } = new Dictionary<string, long>()
        {
            { "Aberration Analysis Method", 19000165},
            { "Access Permission", 19000515},
            { "Accession Condition", 19000110},
            { "Accessory List", 19000040},
            { "Account State", 19000527},
            { "Administrative Level", 19000003},
            { "Age Groups", 19000146},
            { "Aggregate Case Type", 19000102},
            { "Animal Age", 19000005},
            { "Animal Sex", 19000007},
            { "Animal/Bird Status", 19000006},
            { "AS Campaign Status", 19000115},
            { "AS Campaign Type", 19000116},
            { "AS Session Action Status", 19000128},
            { "AS Session Action Type", 19000127},
            { "AS Session Status", 19000117},
            { "Avian Farm Type", 19000008},
            { "AVR Aggregate Function", 19000004},
            { "AVR Chart Name", 19000125},
            { "AVR Chart Type", 19000013},
            { "AVR Folder Name", 19000123},
            { "AVR Group Date", 19000039},
            { "AVR Layout Description", 19000122},
            { "AVR Layout Field Name", 19000143},
            { "AVR Layout Name", 19000050},
            { "AVR Map Name", 19000126},
            { "AVR Query Description", 19000121},
            { "AVR Query Name", 19000075},
            { "AVR Report Name", 19000124},
            { "AVR Search Field", 19000080},
            { "AVR Search Field Type", 19000081},
            { "AVR Search Object", 19000082},
            { "Basic Syndromic Surveillance - Aggregate Columns For AVR", 19000163},
            { "Basic Syndromic Surveillance - Method of Measurement", 19000160},
            { "Basic Syndromic Surveillance - Outcome", 19000161},
            { "Basic Syndromic Surveillance - Test Result", 19000162},
            { "Basic Syndromic Surveillance - Type", 19000159},
            { "Basis of record", 19000137},
            { "Case Classification", 19000011},
            { "Case Outcome List", 19000064},
            { "Case Report Type", 19000144},
            { "Case Status", 19000111},
            { "Case/Session Type", 19000012},
            { "Collection method", 19000135},
            { "Collection time period", 19000136},
            { "Contact Phone Type", 19000500},
            { "Custom Report Type", 19000129},
            { "Data Audit Event Type", 19000016},
            { "Data Audit Object Type", 19000017},
            { "Data Export Detail Status", 19000018},
            { "Department Name", 19000164},
            { "Destruction Method", 19000157},
            { "Diagnoses Groups", 19000156},
            { "Diagnosis", 19000019},
            { "Diagnosis Using Type", 19000020},
            { "Diagnostic Investigation List", 19000021},
            { "Disease Report Relationship", 19000503},
            { "Document Type", 19000530},
            { "EIDSSAppModuleGroup", 19000510},
            { "EIDSSAppObjectList", 19000506},
            { "EIDSSAppObjectType", 19000505},
            { "EIDSSAppPreference", 19000509},
            { "EIDSSAuditParameters", 19000511},
            { "EIDSSModuleConstant", 19000508},
            { "EIDSSPageTitle", 19000507},
            { "Employee Category", 19000526},
            { "Employee Group Name", 19000022},
            { "Employee Position", 19000073},
            { "Employee Type", 19000023},
            { "Event Subscriptions", 19000155},
            { "Event Type", 19000025},
            { "Farm Ownership Type", 19000065},
            { "Flexible Form Check Point", 19000028},
            { "Flexible Form Decorate Element Type", 19000108},
            { "Flexible Form Label Text", 19000131},
            { "Flexible Form Parameter Caption", 19000070},
            { "Flexible Form Parameter Editor", 19000067},
            { "Flexible Form Parameter Mode", 19000068},
            { "Flexible Form Parameter Tooltip", 19000066},
            { "Flexible Form Parameter Type", 19000071},
            { "Flexible Form Parameter Value", 19000069},
            { "Flexible Form Rule", 19000029},
            { "Flexible Form Rule Action", 19000030},
            { "Flexible Form Rule Function", 19000031},
            { "Flexible Form Rule Message", 19000032},
            { "Flexible Form Section", 19000101},
            { "Flexible Form Section Type", 19000525},
            { "Flexible Form Template", 19000033},
            { "Flexible Form Type", 19000034},
            { "Freezer Box Size", 19000512},
            { "Freezer Subdivision Type", 19000093},
            { "Geo Location Type", 19000036},
            { "Ground Type", 19000038},
            { "Human Age Type", 19000042},
            { "Human Gender", 19000043},
            { "Identification method", 19000138},
            { "Language", 19000049},
            { "Legal Form", 19000522},
            { "Main Form of Activity", 19000523},
            { "Matrix Column", 19000152},
            { "Matrix Type", 19000151},
            { "Nationality List", 19000054},
            { "Non-Notifiable Diagnosis", 19000149},
            { "Notification Type", 19000056},
            { "Numbering Schema Document Type", 19000057},
            { "Object Type", 19000060},
            { "Object Type Relation", 19000109},
            { "Occupation Type", 19000061},
            { "Office Type", 19000062},
            { "Organization Abbreviation", 19000045},
            { "Organization Name", 19000046},
            { "OrganizationType", 19000504},
            { "Outbreak Case Status", 19000520},
            { "Outbreak Contact Status", 19000517},
            { "Outbreak Contact Type", 19000516},
            { "Outbreak Species Group", 19000514},
            { "Outbreak Status", 19000063},
            { "Outbreak Type", 19000513},
            { "Outbreak Update Priority", 19000518},
            { "Ownership Form", 19000521},
            { "Patient Contact Type", 19000014},
            { "Patient Location Type", 19000041},
            { "Patient State", 19000035},
            { "Penside Test Category", 19000134},
            { "Penside Test Name", 19000104},
            { "Penside Test Result", 19000105},
            { "Person ID Type", 19000148},
            { "Prophylactic Measure List", 19000074},
            { "Reason for Changed Diagnosis", 19000147},
            { "Reason for not Collecting Sample", 19000150},
            { "Reference Type Name", 19000076},
            { "Report Additional Text", 19000132},
            { "Report Diagnosis Group", 19000130},
            { "Resource Flag", 19000535},
            { "Resource Type", 19000531},
            { "Rule In Value for Test Validation", 19000106},
            { "Sample Kind", 19000158},
            { "Sample Status", 19000015},
            { "Sample Type", 19000087},
            { "Sanitary Measure List", 19000079},
            { "Search Method", 19000529},
            { "Security Audit Action", 19000112},
            { "Security Audit Process Type", 19000114},
            { "Security Audit Result", 19000113},
            { "Security Level", 19000119},
            { "Site Group Type", 19000524},
            { "Site Relation Type", 19000084},
            { "Site Type", 19000085},
            { "Source System Name", 19000519},
            { "Species Groups", 19000166},
            { "Species List", 19000086},
            { "Statistical Age Groups", 19000145},
            { "Statistical Area Type", 19000089},
            { "Statistical Data Type", 19000090},
            { "Statistical Period Type", 19000091},
            { "Storage Type", 19000092},
            { "Surrounding", 19000139},
            { "System Function", 19000094},
            { "System Function Operation", 19000059},
            { "Test Category", 19000095},
            { "Test Name", 19000097},
            { "Test Result", 19000096},
            { "Test Status", 19000001},
            { "Vaccination Route List", 19000098},
            { "Vaccination Type", 19000099},
            { "Vector sub type", 19000141},
            { "Vector Surveillance Session Status", 19000133},
            { "Vector type", 19000140},
            { "Vet Case Log Status", 19000103},
            { "Yes/No Value List", 19000100}
        };

        /// <summary>
        /// LanguagedId.  Defaults to "en-US" culture
        /// </summary>
        public static string LanguageId { get; set; } = "en-US";

        /// <summary>
        /// Long integer sequence generator that begins at 100,000,000
        /// </summary>
        public static Generator<long> LongSequenceGenerator { get; } = Fixture.Create<Generator<long>>();

        /// <summary>
        /// An instance of <see cref="ResponseViewModel"/> that returns failure
        /// </summary>
        public static ResponseViewModel PostResponseMock_Failure
        {
            get => new ResponseViewModel
            {
                Message = "Error",
                Status = "Error",
                Errors = Fixture.CreateMany<string>()
            };
        }

        /// <summary>
        /// An instance of <see cref="ResponseViewModel"/> that returns success
        /// </summary>
        public static ResponseViewModel PostResponseMock_Success
        {
            get => new ResponseViewModel
            {
                Status = "Success",
                Message = "Operation completed successfully"
            };
        }

        /// <summary>
        /// Returns a mocked instance of SystemPreferences
        /// </summary>
        public static SystemPreferences SystemPreferences
        {
            get => GetSystemPreferences();
        }

        /// <summary>
        /// The expiration for dummy user's token
        /// </summary>
        public static DateTime TokenExpiration
        {
            get => new DateTime(2021, 12, 31, 0, 0, 0);
        }

        public static UserPreferences UserPreferences
        {
            get => GetUserPreferencesMock();
        }

        /// <summary>
        /// The login token for "dummyuser"
        /// </summary>
        public static string UserToken
        {
            get => _token;
        }

        /// <summary>
        /// Gets a mocked HttpClient
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public static HttpClient GetHttpClientMoq(object model)
        {
            var factory = new Mock<IHttpClientFactory>();
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
            var fixture = new Fixture();

            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    StatusCode = HttpStatusCode.OK,
                    Content = new StringContent(JsonSerializer.Serialize(model), Encoding.UTF8, "application/json")
                });
            var client = new HttpClient(mockHttpMessageHandler.Object);
            client.BaseAddress = fixture.Create<Uri>();

            return client;
        }

        /// <summary>
        /// Returns a mocked instance of <see cref="IOptionsSnapshot{TOptions}"/>
        /// </summary>
        /// <returns></returns>
        public static IOptionsSnapshot<EidssApiOptions> GetIOptions()
        {
            var moc = new Mock<IOptionsSnapshot<EidssApiOptions>>();

            var fixture = new Fixture();
            var options = fixture.Create<EidssApiOptions>();

            options.BaseUrl = fixture.Create<Uri>().ToString();

            moc.Setup(s => s.Value).Returns(options);

            return moc.Object;
        }

        /// <summary>
        /// Returns an instance of IHttpClientFactory mocked.
        /// </summary>
        /// <returns></returns>
        public static IHttpClientFactory HttpClientMock()
        {
            var httpClientFactory = new Mock<IHttpClientFactory>();
            var mockHttpMessageHandler = new Mock<HttpMessageHandler>();

            mockHttpMessageHandler.Protected()
                .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
                .ReturnsAsync(new HttpResponseMessage
                {
                    Content = new StringContent(It.IsAny<string>()),
                    StatusCode = HttpStatusCode.OK,
                });

            var client = new HttpClient(mockHttpMessageHandler.Object);
            client.BaseAddress = Fixture.Create<Uri>();

            httpClientFactory.Setup(_ => _.CreateClient(It.IsAny<string>())).Returns(client);

            return httpClientFactory.Object;
        }

        #endregion Properties

        #region Service Mocks

        private static IHttpContextAccessor _httpContextAccessor;

        public static IHttpContextAccessor HttpContextAccessor
        {
            get => _httpContextAccessor;
        }

        #endregion Service Mocks

        #region Constructors

        /// <summary>
        /// Instantiates a new instance of the class and sets the default languge to en-US
        /// </summary>
        static BaseArrangement()
        {
            _httpContextAccessor = SetHttpContextAccessor();

            // Creates a maximum of 5 items per list...
            Fixture.RepeatCount = 5;

            _configuration = GetConfiguration();


            _user = GetAuthenticatedUserMock();

            _token = Fixture.Create<string>();

            _userLocation = GetUserLocationInfo();

        }

        #endregion Constructors

        #region Property Setters


        private static AuthenticatedUser GetAuthenticatedUserMock()
        {
            var u = new Mock<AuthenticatedUser>(new UserConfigurationServiceMock()); // this.UserConfigurationService);
            u.Setup(p => p.AccessRulePermissions).Returns(Fixture.CreateMany<AccessRulePermission>().ToList());
            u.Setup(p => p.AccessToken).Returns(UserToken);
            u.Setup(p => p.Adminlevel0).Returns(19000001);
            u.Setup(p => p.Adminlevel1).Returns(19000003);
            u.Setup(p => p.Adminlevel2).Returns(19000002);
            u.Setup(p => p.Adminlevel3).Returns(19000004);
            u.Setup(p => p.AdminLevels).Returns(3);
            u.Setup(p => p.BottomAdminLevel).Returns(19000004);
            u.Setup(p => p.Settlement).Returns(19000004);
            u.Setup(p => p.ASPNetId).Returns(Fixture.Create<string>());
            u.Setup(p => p.Claims).Returns(Fixture.CreateMany<Permission>().ToList());
            u.Setup(p => p.DefaultCountry).Returns("Wakanda");
            u.Setup(p => p.EIDSSUserId).Returns(Fixture.Create<string>());
            u.Setup(p => p.Email).Returns("dummy@dummycorp.com");
            u.Setup(p => p.ExpireDate).Returns(TokenExpiration);
            u.Setup(p => p.FirstName).Returns("Dummy");
            u.Setup(p => p.GetPermissions()).Returns(Fixture.CreateMany<Permission>().ToList());
            u.Setup(p => p.Institution).Returns("Acme");
            u.Setup(p => p.IsInAnyRole(It.IsAny<List<RoleEnum>>())).Returns(true);
            u.Setup(p => p.IsInRole(It.IsAny<List<RoleEnum>>())).Returns(true);
            u.Setup(p => p.IsInRole(It.IsAny<RoleEnum>())).Returns(true);
            u.Setup(p => p.IssueDate).Returns(DateTime.Now);
            u.Setup(p => p.LastName).Returns("User");
            u.Setup(p => p.OfficeId).Returns(Fixture.Create<long>());
            u.Setup(p => p.Organization).Returns("Acme");
            u.Setup(p => p.OrganizationFullName).Returns("Acme Corp, LLC");
            u.Setup(p => p.PasswordResetRequired).Returns(false);
            u.Setup(p => p.Permission(It.IsAny<PagePermission>())).Returns(Fixture.Create<Permission>());
            u.Setup(p => p.PersonId).Returns(Fixture.Create<string>());
            u.Setup(p => p.Preferences).Returns(UserPreferences);

            u.Setup(p => p.RayonId).Returns(1344330000000); // This is a valid region idfsReference from wakanda hierarchy...
            u.Setup(p => p.RegionId).Returns(1344420000000); // Again, from wakanda hierarchy...

            u.Setup(p => p.RoleMembership).Returns(Fixture.CreateMany<string>().ToList());
            u.Setup(p => p.Settlement).Returns(1345280000000); // Binagadi settlement from Wakanda hi...
            u.Setup(p => p.SiteGroupID).Returns(Fixture.Create<string>());
            u.Setup(p => p.SiteId).Returns(Fixture.Create<string>());
            u.Setup(p => p.SiteTypeId).Returns(LongSequenceGenerator.Where(x => x != 0).Take(1).First());
            u.Setup(p => p.TokenType).Returns("bearer");
            u.Setup(p => p.UserHasPermission(It.IsAny<PagePermission>(), It.IsAny<PermissionLevelEnum>())).Returns(true);
            u.Setup(p => p.UserName).Returns("DummyUser");
            u.Setup(p => p.UserOrganizations).Returns(Fixture.CreateMany<UserOrganization>().ToList());
            return u.Object;
        }

        /// <summary>
        /// Gets an IConfiguration instance
        /// </summary>
        /// <returns></returns>
        private static IConfiguration GetConfiguration()
        {
            var config = new Dictionary<string, string>
            {
                {"EIDSSGlobalSettings:CountryID", "170000000" },
                {"EIDSSGlobalSettings:DefaultCountry", "Wakanda" },
                {"EIDSSGlobalSettings:LeafletAPIUrl", "https://photon.komoot.io/" }
            };

            return new ConfigurationBuilder()
                .AddInMemoryCollection(config)
                .Build();
        }

        //private static FlexFormQuestionnaireGetRequestModel GetFlexForm

        private static SystemPreferences GetSystemPreferences()
        {
            var s = new Mock<SystemPreferences>();
            s.Setup(p => p.StartupLanguage).Returns(BaseArrangement.LanguageId);
            s.Setup(p => p.PageHeading).Returns("TestHeading");

            // CALL LOCATIONARRANGEMENTS
            s.Setup(p => p.CountryList).Returns(LocationArrangements.CountryList);
            return s.Object;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private static LocationViewModel GetUserLocationInfo()
        {
            return Fixture.Build<LocationViewModel>()
                .With(p => p.CallingObjectID, "Testing Framework")
                .Without(p => p.AdminLevel0List)
                .Without(p => p.AdminLevel0Text)
                .With(p => p.AdminLevel0Value, 170000000)
                .With(p => p.AdminLevel1Value, 1344330000000)
                .With(p => p.AdminLevel2Value, 1344420000000)
                .With(p => p.AdminLevel3Value, 1345280000000)
                .With(p => p.EnableAdminLevel0, true)
                .With(p => p.EnableAdminLevel1, true)
                .With(p => p.EnableAdminLevel2, true)
                .With(p => p.EnableAdminLevel3, true)
                .With(p=> p.ShowAdminLevel0, false)
                .With(p=> p.ShowAdminLevel1,true)
                .With(p => p.ShowAdminLevel2, true)
                .With(p => p.ShowAdminLevel3, true)
                .With(p => p.ShowAdminLevel4, false)
                .With(p => p.ShowAdminLevel5, false)
                .With(p => p.ShowAdminLevel6, false)
              .Create();
        }

        /// <summary>
        /// Returns a UserPreferences mock
        /// </summary>
        /// <returns></returns>
        private static UserPreferences GetUserPreferencesMock()
        {
            var p = new Mock<UserPreferences>(new UserConfigurationServiceMock());
            p.Setup(p => p.ActiveLanguage).Returns(LanguageId);
            p.Setup(p => p.AuditUserName).Returns("dummyuser");
            p.Setup(p => p.UserId).Returns(LongSequenceGenerator.Where(x => x != 0).Take(1).First());

            p.Setup(p => p.MapProjects).Returns(Fixture.CreateMany<MapProject>().ToList());
            p.Setup(p => p.PageHeading).Returns(Fixture.Create<string>());
            // CALL LOCATIONARRANGEMENTS
            p.Setup(p => p.CountryList).Returns(LocationArrangements.CountryList);
            return p.Object;
        }

        private static IHttpContextAccessor SetHttpContextAccessor()
        {
            var RoutingRequestContext = new Mock<RequestContext>(MockBehavior.Loose);
            var ActionExecuting = new Mock<ActionExecutingContext>(MockBehavior.Loose);
            var Http = new Mock<HttpContext>(MockBehavior.Loose);
            var Response = new Mock<HttpResponse>(MockBehavior.Loose);
            var Request = new Mock<HttpRequest>(MockBehavior.Loose);
            var Session = new Mock<Microsoft.AspNetCore.Http.ISession>(MockBehavior.Loose);

            Http.SetupGet(c => c.Request).Returns(Request.Object);
            Http.SetupGet(c => c.Response).Returns(Response.Object);
            Http.SetupGet(c => c.Session).Returns(Session.Object);

            var c = new Mock<IHttpContextAccessor>();
            c.Setup(p => p.HttpContext).Returns(Http.Object);
            return c.Object;
        }

        #endregion Property Setters

        /// <summary>
        /// Gets supported languages
        /// </summary>
        /// <param name="CultureID"></param>
        /// <returns></returns>
        public static string GetDBLangID(string CultureID)
        {
            string strLangID = string.Empty;
            switch (CultureID)
            {
                case "az-Latn-AZ":
                    {
                        strLangID = "az-L";
                        break;
                    }

                case "ru-RU":
                    {
                        strLangID = "ru";
                        break;
                    }

                case "en-US":
                    {
                        strLangID = "en";
                        break;
                    }

                case "ka-GE":
                    {
                        strLangID = "ka";
                        break;
                    }

                case "kk-KZ":
                    {
                        strLangID = "kk";
                        break;
                    }

                case "uz-Cyrl-UZ":
                    {
                        strLangID = "uz-C";
                        break;
                    }

                case "uz-Latn-UZ":
                    {
                        strLangID = "uz-L";
                        break;
                    }

                case "uk-UA":
                    {
                        strLangID = "uk";
                        break;
                    }

                case "hy-AM":
                    {
                        strLangID = "hy";
                        break;
                    }

                case "ar-IQ":
                    {
                        strLangID = "ar";
                        break;
                    }

                case "vi-VN":
                    {
                        strLangID = "vi";
                        break;
                    }

                case "lo-LA":
                    {
                        strLangID = "lo";
                        break;
                    }

                case "th-TH":
                    {
                        strLangID = "th";
                        break;
                    }

                default:
                    {
                        strLangID = "en";
                        break;
                    }
            }

            return strLangID;
        }

        /// <summary>
        /// Get an instance of ILogger<typeparamref name="T"/>
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        public static ILogger<T> GetLogger<T>()
        {
            var logger = new Mock<ILogger<T>>();
            logger.Setup(x => x.Log(
            It.IsAny<LogLevel>(),
            It.IsAny<EventId>(),
            It.IsAny<It.IsAnyType>(),
            It.IsAny<Exception>(),
            (Func<It.IsAnyType, Exception, string>)It.IsAny<object>()));

            return logger.Object;
        }
    }

    /// <summary>
    /// Fictional location container
    /// </summary>
    public static class LocationArrangements
    {
        public static FictionalHierarchy _fictionalHierarchy = new FictionalHierarchy();

        static LocationArrangements()
        {
            string filename = "Wakanda Location Hierarchy.json";
            string jstring = string.Empty;
            try
            {
                //load up Wakanda Hierarchy...
                jstring = File.ReadAllText(filename);

                _fictionalHierarchy =
                    JsonSerializer.Deserialize<FictionalHierarchy>(jstring);

                // Load up country list...
                filename = "CountryList.json";
                jstring = File.ReadAllText(filename);
                CountryList = JsonSerializer.Deserialize<List<CountryModel>>(jstring);
            }
            catch (Exception ex)
            { }
        }

        public static GISLocationModel Country { get => GetWakanda(); }
        public static List<CountryModel> CountryList { get; set; }
        public static List<GisLocationCurrentLevelModel> GetGISCurrentLevel(string languageId, int level)
        {
            GisLocationChildLevelModel[] levelChildren = null;
            List<GisLocationCurrentLevelModel> currentLevel = new List<GisLocationCurrentLevelModel>();

            if (level == 1)
            {
                var cn = Country;
                currentLevel.Add(new GisLocationCurrentLevelModel
                {
                    idfsReference = cn.idfsLocation,
                    Name = cn.LevelName,
                    strCode = cn.strCode,
                    strGISReferenceTypeName = cn.strGISReferenceTypeName,
                    strHASC = cn.strHASC,
                    strNode = cn.Node
                });
            }
            else if (level == 2) levelChildren = _fictionalHierarchy.Regions.ToArray();
            else if (level == 3) levelChildren = _fictionalHierarchy.Regions.Select(s => s.Rayons).Cast<GisLocationChildLevelModel>().ToArray();
            else if (level == 4) levelChildren = _fictionalHierarchy.Regions.Select(s => s.Rayons.Select(s => s.Settlements)).Cast<GisLocationChildLevelModel>().ToArray();
            else return null;

            if (levelChildren != null)
                foreach (var c in levelChildren)
                {
                    var cl = new GisLocationCurrentLevelModel();
                    cl.idfsReference = (long)c.idfsReference;
                    cl.strGISReferenceTypeName = c.strGISReferenceTypeName;
                    cl.strHASC = c.strHASC;
                    cl.Name = c.Name;
                    cl.strNode = c.strNode;
                    cl.strCode = c.strCode;
                    currentLevel.Add(cl);
                }
            return currentLevel;
        }

        public static List<GisLocationChildLevelModel> GetGisLocationChildLevel(string languageid, string parentIdfsReferenceId)
        {
            GisLocationChildLevelModel[] ret = null;

            if (Convert.ToString(Country.idfsLocation) == parentIdfsReferenceId)
            {
                ret = _fictionalHierarchy.Regions.ToArray();
            }
            else
            {
                var rays =
                    from reg in _fictionalHierarchy.Regions
                    where Convert.ToString(reg.idfsReference) == parentIdfsReferenceId
                    from ray in reg.Rayons
                    select ray;

                if (rays != null && rays.Count() > 0)
                    ret = rays.ToArray();
                else
                {
                    var sets =
                        from reg in _fictionalHierarchy.Regions
                        from ray in reg.Rayons
                        where Convert.ToString(ray.idfsReference) == parentIdfsReferenceId
                        from s in ray.Settlements
                        select s;

                    ret = sets.ToArray();
                }
            }
            return ret.ToList();
        }

        public static List<GisLocationLevelModel> GetWakandaLocationHierarchy(string languageId)
        {
            return new List<GisLocationLevelModel>()
                {
                new GisLocationLevelModel
                {
                    Level = 1,
                    idfsGISReferenceType = 19000001,
                    strDefault = "Country",
                    Name = "Country"
                },
                new GisLocationLevelModel
                {
                    Level = 2,
                    idfsGISReferenceType = 19000003,
                    strDefault = "Region",
                    Name = "Region"
                },
                new GisLocationLevelModel
                {
                    Level = 3,
                    idfsGISReferenceType = 19000002,
                    strDefault = "Rayon",
                    Name = "Rayon"
                },
              new GisLocationLevelModel
                {
                    Level = 4,
                    idfsGISReferenceType = 19000004,
                    strDefault = "Settlement",
                    Name = "Settlement"
                }
            };
        }
        private static GISLocationModel GetWakanda()
        {
            GISLocationModel ret = null;

            var c = CountryList.Where(w => w.strCountryName.ToLower() == "wakanda").FirstOrDefault();
            if (c != null)
                ret = new GISLocationModel
                {
                    idfsLocation = c.idfsCountry,
                    LevelName = "Country",
                    strCode = c.strCountryCode,
                    strGISReferenceTypeName = "Country"
                };
            return ret;
        }
    }

    public class FictionalHierarchy
    {
        public List<RegionContainer> Regions { get; set; }
    }

    public class RayonContainer : GisLocationChildLevelModel
    {
        [DataMember(Name = "settlements")]
        public List<GisLocationChildLevelModel> Settlements { get; set; } = new List<GisLocationChildLevelModel>();
    }

    public class RegionContainer : GisLocationChildLevelModel
    {
        [DataMember(Name = "rayons")]
        public List<RayonContainer> Rayons { get; set; } = new List<RayonContainer>();
    }
}