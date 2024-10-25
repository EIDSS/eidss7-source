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

namespace EIDSS.Web.Extensions;

public static class ServiceExtensions
{
    public static IServiceCollection ConfigureApiClientExtensions(this IServiceCollection services)
    {
        services.AddTransient<AuthenticationDelegatingHandler>();

        services.AddScoped<ICrossCuttingService, CrossCuttingService>();

        services.AddScoped<DialogService>();

        services.AddClient<IHumanActiveSurveillanceSessionClient, HumanActiveSurveillanceSessionClient>();
        services.AddClient<IAdminClient, AdminClient>();
        services.AddClient<IAggregateReportClient, AggregateReportClient>();
        services.AddClient<IPreferenceClient, PreferenceClient>();
        services.AddClient<IMenuClient, MenuClient>();
        services.AddClient<ICrossCuttingClient, CrossCuttingClient>();
        services.AddClient<ILocalizationClient, LocalizationClient>();
        services.AddClient<IBaseReferenceClient, BaseReferenceClient>();
        services.AddClient<ISpeciesTypeClient, SpeciesTypeClient>();
        services.AddClient<IVectorTypeClient, VectorTypeClient>();
        services.AddClient<IVectorClient, VectorClient>();
        services.AddClient<ISampleTypesClient, SampleTypesClient>();
        services.AddClient<IDiseaseClient, DiseaseClient>();
        services.AddClient<IReportDiseaseGroupClient, ReportDiseaseGroupClient>();
        services.AddClient<IMeasuresClient, MeasuresClient>();
        services.AddClient<IStatisticalTypeClient, StatisticalTypeClient>();
        services.AddClient<IStatisticalDataClient, StatisticalDataClient>();
        services.AddClient<IFlexFormClient, FlexFormClient>();
        services.AddClient<IConfigurableFiltrationClient, ConfigurableFiltrationClient>();
        services.AddClient<IVectorSpeciesTypeClient, VectorSpeciesTypeClient>();
        services.AddClient<ICaseClassificationClient, CaseClassificationClient>();
        services.AddClient<IOrganizationClient, OrganizationClient>();
        services.AddClient<IConfigurationClient, ConfigurationClient>();
        services.AddClient<IVeterinaryDiagnosticInvestigationMatrixClient, VeterinaryDiagnosticInvestigationMatrixClient>();
        services.AddClient<IVeterinaryAggregateDiseaseMatrixClient, VeterinaryAggregateDiseaseMatrixClient>();
        services.AddClient<IVeterinaryProphylacticMeasureMatrixClient, VeterinaryProphylacticMeasureMatrixClient>();
        services.AddClient<IVeterinarySanitaryActionMatrixClient, VeterinarySanitaryActionMatrixClient>();
        services.AddClient<IHumanAggregateDiseaseMatrixClient, HumanAggregateDiseaseMatrixClient>();
        services.AddClient<IHumanActiveSurveillanceCampaignClient, HumanActiveSurveillanceCampaignClient>();
        services.AddClient<IHumanDiseaseReportClient, HumanDiseaseReportClient>();
        services.AddClient<IUniqueNumberingSchemaClient, UniqueNumberingSchemaClient>();
        services.AddClient<IVectorTypeFieldTestMatrixClient, VectorTypeFieldTestMatrixClient>();
        services.AddClient<IVectorTypeCollectionMethodMatrixClient, VectorTypeCollectionMethodMatrixClient>();
        services.AddClient<IVectorTypeSampleTypeMatrixClient, VectorTypeSampleTypeMatrixClient>();
        services.AddClient<ISiteGroupClient, SiteGroupClient>();
        services.AddClient<ISiteClient, SiteClient>();
        services.AddClient<ISettlementClient, SettlementClient>();
        services.AddClient<IReportCrossCuttingClient, ReportCrossCuttingClient>();
        services.AddClient<ITestNameTestResultsMatrixClient, TestNameTestResultsMatrixClient>();
        services.AddClient<IAggregateSettingsClient, AggregateSettingsClient>();
        services.AddClient<IUserGroupClient, UserGroupClient>();
        services.AddClient<ISystemFunctionsClient, SystemFunctionsClient>();
        services.AddClient<IDiseaseAgeGroupMatrixClient, DiseaseAgeGroupMatrixClient>();
        services.AddClient<IPersonalIdentificationTypeMatrixClient, PersonalIdentificationTypeMatrixClient>();
        services.AddClient<IReportDiseaseGroupDiseaseMatrixClient, ReportDiseaseGroupDiseaseMatrixClient>();
        services.AddClient<IDiseaseHumanGenderMatrixClient, DiseaseHumanGenderMatrixClient>();
        services.AddClient<IInterfaceEditorClient, InterfaceEditorClient>();
        services.AddClient<IPersonClient, PersonClient>();
        services.AddClient<ISiteAlertsSubscriptionClient, SiteAlertsSubscriptionClient>();
        services.AddClient<ILaboratoryClient, LaboratoryClient>();
        services.AddClient<IEmployeeClient, EmployeeClient>();
        services.AddClient<ISecurityPolicyClient, SecurityPolicyClient>();
        services.AddClient<IWeeklyReportingFormClient, WeeklyReportingFormClient>();
        services.AddClient<IAggregateReportClient, AggregateReportClient>();
        services.AddClient<IILIAggregateFormClient, ILIAggregateFormClient>();
        services.AddClient<IOutbreakClient, OutbreakClient>();
        services.AddClient<IFreezerClient, FreezerClient>();
        services.AddClient<IDataArchivingClient, DataArchivingClient>();
        services.AddClient<IVeterinaryClient, VeterinaryClient>();
        services.AddClient<IDiseaseLabTestMatrixClient, DiseaseLabTestMatrixClient>();
        services.AddClient<IDiseasePensideTestMatrixClient, DiseasePensideTestMatrixClient>();
        services.AddClient<IAdministrativeUnitsClient, AdministrativeUnitsClient>();
        services.AddClient<INotificationClient, NotificationClient>();
        services.AddClient<IDashboardClient, DashboardClient>();
        services.AddClient<INotificationSiteAlertService, NotificationSiteAlertService>();
        services.AddClient<IPINClient, PINClient>();
        services.AddClient<IDataAuditClient, DataAuditClient>();
        services.AddClient<ISecurityEventClient, SecurityEventClient>();
        services.AddClient<ISystemEventClient, SystemEventClient>();
        services.AddClient<IWHOExportClient, WHOExportClient>();
        services.AddClient<IPersonalIDClient, PersonalIDClient>();
        services.AddClient<IAgeTypeClient, AgeTypeClient>();
        services.AddClient<IChangeDiagnosisHistoryClient, ChangeDiagnosisHistoryClient>();

        return services;
    }
    private static void AddClient<TClient, TImplementation>(this IServiceCollection services)
        where TClient : class
        where TImplementation : class, TClient
    {
        services.AddHttpClient<TClient, TImplementation>()
            .AddHttpMessageHandler<AuthenticationDelegatingHandler>()
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
}