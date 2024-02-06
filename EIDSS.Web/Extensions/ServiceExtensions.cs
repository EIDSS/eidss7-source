using EIDSS.ClientLibrary.ApiClients.Admin;
using EIDSS.ClientLibrary.ApiClients.Admin.Security;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.ClientLibrary.ApiClients.Dashboard;
using EIDSS.ClientLibrary.ApiClients.FlexForm;
using EIDSS.ClientLibrary.ApiClients.Human;
using EIDSS.ClientLibrary.ApiClients.Laboratory;
using EIDSS.ClientLibrary.ApiClients.Menu;
using EIDSS.ClientLibrary.ApiClients.Notification;
using EIDSS.ClientLibrary.ApiClients.Outbreak;
using EIDSS.ClientLibrary.ApiClients.PIN;
using EIDSS.ClientLibrary.ApiClients.Reports;
using EIDSS.ClientLibrary.ApiClients.Vector;
using EIDSS.ClientLibrary.ApiClients.Veterinary;
using EIDSS.ClientLibrary.Handlers;
using EIDSS.ClientLibrary.Services;
using Microsoft.Extensions.DependencyInjection;
using Polly;
using Polly.Extensions.Http;
using Radzen;
using System;
using System.Net.Http;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

namespace EIDSS.Web.Extensions
{
    public static class ServiceExtensions
    {
        //public static void ConfigureLoggingExtensions(this IServiceCollection services)
        //{
        //    services.AddSingleton<ILogger>(svc =>
        //   svc.GetRequiredService<ILogger<BaseReferenceTypes>>());
        //}

        public static void ConfigureApiClientExtensions(this IServiceCollection services)
        {
            services.AddTransient<AuthenticationDelegatingHandler>();

            services.AddScoped<ICrossCuttingService, CrossCuttingService>();

            //added for Radzen dialog
            services.AddScoped<DialogService>();

            //// Create Typed client
            services.AddHttpClient<IHumanActiveSurveillanceSessionClient, HumanActiveSurveillanceSessionClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IAdminClient, AdminClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IAggregateReportClient, AggregateReportClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IPreferenceClient, PreferenceClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IMenuClient, MenuClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ICrossCuttingClient, CrossCuttingClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ILocalizationClient, LocalizationClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IBaseReferenceClient, BaseReferenceClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ISpeciesTypeClient, SpeciesTypeClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVectorTypeClient, VectorTypeClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVectorClient, VectorClient>()
             .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
           //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
             .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
             .AddPolicyHandler(GetRetryPolicy())
             .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ISampleTypesClient, SampleTypesClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IDiseaseClient, DiseaseClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IReportDiseaseGroupClient, ReportDiseaseGroupClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IMeasuresClient, MeasuresClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IStatisticalTypeClient, StatisticalTypeClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IStatisticalDataClient, StatisticalDataClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IFlexFormClient, FlexFormClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IConfigurableFiltrationClient, ConfigurableFiltrationClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVectorSpeciesTypeClient, VectorSpeciesTypeClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ICaseClassificationClient, CaseClassificationClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IOrganizationClient, OrganizationClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IConfigurationClient, ConfigurationClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVeterinaryDiagnosticInvestigationMatrixClient, VeterinaryDiagnosticInvestigationMatrixClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVeterinaryAggregateDiseaseMatrixClient, VeterinaryAggregateDiseaseMatrixClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVeterinaryProphylacticMeasureMatrixClient, VeterinaryProphylacticMeasureMatrixClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVeterinarySanitaryActionMatrixClient, VeterinarySanitaryActionMatrixClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IHumanAggregateDiseaseMatrixClient, HumanAggregateDiseaseMatrixClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IHumanActiveSurveillanceCampaignClient, HumanActiveSurveillanceCampaignClient>()
              .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
            //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
              .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
              .AddPolicyHandler(GetRetryPolicy())
              .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IHumanDiseaseReportClient, HumanDiseaseReportClient>()
             .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
             .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
             .AddPolicyHandler(GetRetryPolicy())
             .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IUniqueNumberingSchemaClient, UniqueNumberingSchemaClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVectorTypeFieldTestMatrixClient, VectorTypeFieldTestMatrixClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVectorTypeCollectionMethodMatrixClient, VectorTypeCollectionMethodMatrixClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVectorTypeSampleTypeMatrixClient, VectorTypeSampleTypeMatrixClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ISiteGroupClient, SiteGroupClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ISiteClient, SiteClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ISettlementClient, SettlementClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IReportCrossCuttingClient, ReportCrossCuttingClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ITestNameTestResultsMatrixClient, TestNameTestResultsMatrixClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IAggregateSettingsClient, AggregateSettingsClient>()
             .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
           //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
             .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
             .AddPolicyHandler(GetRetryPolicy())
             .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IUserGroupClient, UserGroupClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ISystemFunctionsClient, SystemFunctionsClient>()
               .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
             //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
               .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
               .AddPolicyHandler(GetRetryPolicy())
               .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IDiseaseAgeGroupMatrixClient, DiseaseAgeGroupMatrixClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IPersonalIdentificationTypeMatrixClient, PersonalIdentificationTypeMatrixClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IReportDiseaseGroupDiseaseMatrixClient, ReportDiseaseGroupDiseaseMatrixClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IDiseaseHumanGenderMatrixClient, DiseaseHumanGenderMatrixClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IInterfaceEditorClient, InterfaceEditorClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IPersonClient, PersonClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ISiteAlertsSubscriptionClient, SiteAlertsSubscriptionClient>()
           .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
         //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
           .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
           .AddPolicyHandler(GetRetryPolicy())
           .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ILaboratoryClient, LaboratoryClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IEmployeeClient, EmployeeClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ISecurityPolicyClient, SecurityPolicyClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IWeeklyReportingFormClient, WeeklyReportingFormClient>()
         .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
       //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
         .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
         .AddPolicyHandler(GetRetryPolicy())
         .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IAggregateReportClient, AggregateReportClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IILIAggregateFormClient, ILIAggregateFormClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IOutbreakClient, OutbreakClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());


            services.AddHttpClient<IFreezerClient, FreezerClient>()
                 .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
               //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                 .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                 .AddPolicyHandler(GetRetryPolicy())
                 .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IDataArchivingClient, DataArchivingClient>()
               .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
             //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
               .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
               .AddPolicyHandler(GetRetryPolicy())
               .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IVeterinaryClient, VeterinaryClient>()
              .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
            //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
              .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
              .AddPolicyHandler(GetRetryPolicy())
              .AddPolicyHandler(GetCircuitBreakerPolicy()); ;

            services.AddHttpClient<IDiseaseLabTestMatrixClient, DiseaseLabTestMatrixClient>()
              .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
            //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
              .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
              .AddPolicyHandler(GetRetryPolicy())
              .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IDiseasePensideTestMatrixClient, DiseasePensideTestMatrixClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IAdministrativeUnitsClient, AdministrativeUnitsClient>()
          .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
        //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
          .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
          .AddPolicyHandler(GetRetryPolicy())
          .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<INotificationClient, NotificationClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IDashboardClient, DashboardClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<INotificationSiteAlertService, NotificationSiteAlertService>()
          .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
          .AddPolicyHandler(GetRetryPolicy())
          .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IPINClient, PINClient>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
          //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
            .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
            .AddPolicyHandler(GetRetryPolicy())
            .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IDataAuditClient, DataAuditClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ISecurityEventClient, SecurityEventClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<ISystemEventClient, SystemEventClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());

            services.AddHttpClient<IWHOExportClient, WHOExportClient>()
                .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
              //.SetHandlerLifetime(TimeSpan.FromMinutes(5))
                .ConfigurePrimaryHttpMessageHandler(x => new DefaultHttpClientHandler())
                .AddPolicyHandler(GetRetryPolicy())
                .AddPolicyHandler(GetCircuitBreakerPolicy());
        }

        private static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
        {
            return HttpPolicyExtensions
                .HandleTransientHttpError()
                .CircuitBreakerAsync(2, TimeSpan.FromSeconds(3));
        }

        private static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy()
        {
            return HttpPolicyExtensions
                .HandleTransientHttpError()
                .WaitAndRetryAsync(2, retryAttempt => TimeSpan.FromSeconds(3));
        }

        public class DefaultHttpClientHandler : HttpClientHandler
        {
            public DefaultHttpClientHandler() =>
                this.ServerCertificateCustomValidationCallback = ServerCertificateCustomValidation;
        }

        /// <summary>
        /// Auto accepts server certificate.
        /// WE'LL NEED TO CHANGE THIS FOR PRODUCTION!!!!
        /// </summary>
        /// <param name="requestMessage"></param>
        /// <param name="certificate"></param>
        /// <param name="chain"></param>
        /// <param name="sslErrors"></param>
        /// <returns></returns>
        public static bool ServerCertificateCustomValidation(HttpRequestMessage requestMessage, X509Certificate2 certificate, X509Chain chain, SslPolicyErrors sslErrors)
        {
            return true;
        }
    }
}