using EIDSS.ClientLibrary;
using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.ApiClients.Laboratory;
using EIDSS.ClientLibrary.ApiClients.Menu;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.ClientLibrary.Handlers;
using EIDSS.ClientLibrary.Services;
using EIDSS.Domain.Attributes;
using EIDSS.Localization.Extensions;
using EIDSS.Web.ActionFilters;
using EIDSS.Web.Helpers;
using EIDSS.Web.Services;
using EIDSS.Web.xUnitTest.Abstracts;
using EIDSS.Web.xUnitTest.Arrangements.Client_Mocks;
using EIDSS.Web.xUnitTest.Arrangements.Service_Mocks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Razor;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest
{
    public class TestStartup //: Startup
    {
        public IConfiguration Configuration { get; }
        public TestStartup(IConfiguration configuration) //: base(configuration)
        {
            Configuration = configuration;
        }
        public void ConfigureServices(IServiceCollection services)
        {
            services.TryAddSingleton<IHttpContextAccessor, HttpContextAccessor>();
            services.AddHttpContextAccessor();


            // Instead of configuring real HTTP Clients, we'll use our mocks...
            // HttpClient overrides...
            services.ConfigureClientHTTPMocks();

            services.AddScoped<ITokenService, TokenServiceMock>();

            services.AddSingleton<IConfiguration>(Configuration);

            services.AddSingleton<IValidationAttributeAdapterProvider, CustomValidationAttributeAdapterProvider>();

            services.AddScoped<LoginRedirectionAttribute>();

            services.ConfigureApplicationCookie(options =>
            {
                // Cookie settings
                options.Cookie.HttpOnly = true;
                options.ExpireTimeSpan = TimeSpan.FromMinutes(5);

                options.LoginPath = "/Identity/Account/Login";
                options.AccessDeniedPath = "/Identity/Account/AccessDenied";
                options.SlidingExpiration = true;
            });

            services.AddSession(options => {
                options.IdleTimeout = TimeSpan.FromMinutes(60);
            });

            services.Configure<RazorViewEngineOptions>(o =>
            {
                o.ViewLocationExpanders.Add(new SubAreaViewLocationExpander());
            });

            services.AddControllersWithViews();

            //Configuration
            services.Configure<EidssApiOptions>(Configuration.GetSection(EidssApiOptions.EidssApi));
            services.Configure<EidssApiConfigurationOptions>(Configuration.GetSection(EidssApiConfigurationOptions.EidssApiConfiguration));

            services.AddMemoryCache();

            services.AddMvc(option => option.EnableEndpointRouting = false).AddViewLocalization();
            services.AddTransient<IAppVersionService, AppVersionService>();

            // Configuration service.  This service replaces the ConfigFactory.
            services.AddSingleton<IUserConfigurationService, UserConfigurationServiceMock>();

        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, ILoggerFactory loggerFactory)
        {
            app.UseDeveloperExceptionPage();


            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthentication();
            app.UseAuthorization();

            app.UseSession();

            ApplicationContext.Configure(app.ApplicationServices.GetRequiredService<IHttpContextAccessor>());

            app.UseMvc(routes => {

                routes.MapRoute(
                 name: "subarearoute",
                 template: "{area:exists}/{subarea:exists}/{controller=Home}/{action=Index}/{id?}");
                routes.MapRoute(
                  name: "areaRoute",
                  template: "{area:exists}/{controller=Home}/{action=Index}/{id?}");

                routes.MapRoute(
                   name: "default",
                   template: "{controller=Home}/{action=Index}/{id?}");
            });

        }
    }

    public static class ServiceExtensions
    {
        /// <summary>
        /// HTTP Client Mocks
        /// </summary>
        /// <param name="services"></param>
        public static void ConfigureClientHTTPMocks(this IServiceCollection services)
        {
            services.AddTransient<AuthenticationDelegatingHandler>();
            services.AddScoped<ICrossCuttingService, CrossCuttingServiceMock>();
            services.AddHttpClient<IAdminClient, AdminClientMock>();
            services.AddHttpClient<IPreferenceClient, PreferenceClientMock>();
            services.AddHttpClient<IMenuClient, MenuClientMock>();
            services.AddHttpClient<ICrossCuttingClient, CrossCuttingClientMock>();
            services.AddHttpClient<ILocalizationClient, LocalizationClientMock>();
            services.AddHttpClient<IBaseReferenceClient, BaseClientMock>();
            services.AddHttpClient<ISpeciesTypeClient, SpeciesTypeClientMock>();
            services.AddHttpClient<IVectorTypeClient, VectorTypeClientMock>();
            services.AddHttpClient<ISampleTypesClient, SampleTypesClientMock>();
            services.AddHttpClient<IDiseaseClient, DiseaseClientMock>();
            services.AddHttpClient<IReportDiseaseGroupClient, ReportDiseaseGroupClientMock>();
            services.AddHttpClient<IMeasuresClient, MeasuresClientMock>();
            services.AddHttpClient<IStatisticalTypeClient, StatisticalTypeClientMock>();
            services.AddHttpClient<IFlexFormClient, FlexFormClientMock>();
            services.AddHttpClient<IConfigurableFiltrationClient, ConfigurableFiltrationClientMock>();
            services.AddHttpClient<IVectorSpeciesTypeClient, VectorSpeciesTypeClientMock>();
            services.AddHttpClient<ICaseClassificationClient, CaseClassificationClientMock>();
            services.AddHttpClient<IOrganizationClient, OrganizationClientMock>();
            services.AddHttpClient<IConfigurationClient, ConfigurationClientMock>();
            services.AddHttpClient<IVeterinaryDiagnosticInvestigationMatrixClient, VeterinaryDiagnosticInvestigationMatrixClientMock>();
            services.AddHttpClient<IVeterinaryAggregateDiseaseMatrixClient, VeterinaryAggregateDiseaseMatrixClientMock>();
            services.AddHttpClient<IVeterinaryProphylacticMeasureMatrixClient, VeterinaryProphylacticMeasureMatrixClientMock>();
            services.AddHttpClient<IVeterinarySanitaryActionMatrixClient, VeterinarySanitaryActionMatrixClientMock>();
            services.AddHttpClient<IHumanAggregateDiseaseMatrixClient, HumanAggregateDiseaseMatrixClientMock>();
            services.AddHttpClient<IHumanActiveSurveillanceCampaignClient, HumanActiveSurveillanceCampaignClientMock>();
            services.AddHttpClient<IUniqueNumberingSchemaClient, UniqueNumberingSchemaClientMock>();
            services.AddHttpClient<IVectorTypeFieldTestMatrixClient, VectorTypeFieldTestMatrixClientMock>();
            services.AddHttpClient<IVectorTypeCollectionMethodMatrixClient, VectorTypeCollectionMethodMatrixClientMock>();
            services.AddHttpClient<IVectorTypeSampleTypeMatrixClient, VectorTypeSampleTypeMatrixClientMock>();
            services.AddHttpClient<ISiteGroupClient, SiteGroupClientMock>();
            services.AddHttpClient<ISiteClient, SiteClientMock>();
            services.AddHttpClient<ISettlementClient, SettlementClientMock>();
            services.AddHttpClient<IReportCrossCuttingClient, ReportCrossCuttingClientMock>();
            services.AddHttpClient<ITestNameTestResultsMatrixClient, TestNameTestResultsMatrixClientMock>();
            services.AddHttpClient<IAggregateSettingsClient, AggregateSettingsClientMock>();
            services.AddHttpClient<IUserGroupClient, UserGroupClientMock>();
            services.AddHttpClient<ISystemFunctionsClient, SystemFunctionsClientMock>();
            services.AddHttpClient<IDiseaseAgeGroupMatrixClient, DiseaseAgeGroupMatrixClientMock>();
            services.AddHttpClient<IPersonalIdentificationTypeMatrixClient, PersonalIdentificationTypeMatrixClientMock>();
            services.AddHttpClient<IReportDiseaseGroupDiseaseMatrixClient, ReportDiseaseGroupDiseaseMatrixClientMock>();
            services.AddHttpClient<IDiseaseHumanGenderMatrixClient, DiseaseHumanGenderMatrixClientMock>();
            services.AddHttpClient<IInterfaceEditorClient, InterfaceEditorClientMock>();
            services.AddHttpClient<IPersonClient, PersonClientMock>();
            services.AddHttpClient<ISiteAlertsSubscriptionClient, SiteAlertsSubscriptionClientMock>();
            services.AddHttpClient<ILaboratoryClient, LaboratoryClientMock>();
            services.AddHttpClient<IEmployeeClient, EmployeeClientMock>();
            services.AddHttpClient<ISecurityPolicyClient, SecurityPolicyClientMock>();
            services.AddHttpClient<IWeeklyReportingFormClient, WeeklyReportingFormClientMock>();
            services.AddHttpClient<IAggregateDiseaseReportClient, AggregateDiseaseReportClientMock>();
            services.AddHttpClient<IILIAggregateFormClient, ILIAggregateFormClientMock>();
            services.AddHttpClient<IOutbreakClient, OutbreakClientMock>();
        }

    }

}
