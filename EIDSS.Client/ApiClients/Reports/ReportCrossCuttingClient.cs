using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ViewModels.Reports;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Reports;

namespace EIDSS.ClientLibrary.ApiClients.Reports
{
    public partial interface IReportCrossCuttingClient
    {
        Task<List<ReportingPeriodViewModel>> GetReportPeriod(string languageId, string year, string reportingPeriodType);

        Task<List<ReportingPeriodTypeViewModel>> GetReportPeriodType(string languageId);

        Task<List<VetNameOfInvestigationOrMeasureViewModel>> GetVetNameOfInvestigationOrMeasure(string languageId);

        Task<List<VetSummarySurveillanceTypeViewModel>> GetVetSummarySurveillanceType(string languageId);

        Task<List<SpeciesTypeViewModel>> GetSpeciesTypes(string languageId, long? idfsDiagnosis);

        Task<List<TuberculosisDiagnosisViewModel>> GetTuberculosisDiagnosisList(string languageId);

        Task<List<HumanComparitiveCounterViewModel>> GetHumanComparitiveCounter(string languageId);

        Task<List<WhoMeaslesRubellaDiagnosisViewModel>> GetHumanWhoMeaslesRubellaDiagnosis();

        Task<List<CurrentCountryViewModel>> GetCurrentCountryList(string languageId);

        Task<List<LABAssignmentDiagnosticAZSendToViewModel>> GetLABAssignmentDiagnosticAZSendToList(string languageId, string caseId);

        Task<List<LABTestingResultsDepartmentViewModel>> GetLABTestingResultsDepartmentList(string languageId, string sampleId);

        Task<List<ReportListViewModel>> GetReportList();

        Task<List<HumDateFieldSourceViewModel>> GetHumDateFieldSourceList(string languageId);

        Task<List<ReportOrganizationViewModel>> GetReportOrganizationList(string languageId);

        Task<List<VetDateFieldSourceViewModel>> GetVetDateFieldSourceList(string languageId);

        Task<List<HumanComparitiveCounterGGViewModel>> GetHumanComparitiveCounterGG(string languageId);

        Task<List<ReportQuarterModelGG>> GetReportQuarterGG(string languageId, int year);

        Task<List<AggregateSummaryViewModel>> GetVeterinaryAggregateReportDetail(AggregateSummaryRequestModel request, CancellationToken cancellationToken = default);

        Task<List<AggregateSummaryViewModel>> GetHumanAggregateReportDetail(AggregateSummaryRequestModel request, CancellationToken cancellationToken = default);

        Task<List<AggregateSummaryViewModel>> GetVeterinaryAggregateDiagnosticActionSummaryReportDetail(AggregateSummaryRequestModel request, CancellationToken cancellationToken = default);

        Task<List<AggregateSummaryViewModel>> GetVeterinaryAggregateProphylacticActionSummaryReportDetail(AggregateSummaryRequestModel request, CancellationToken cancellationToken = default);

        Task<List<AggregateSummaryViewModel>> GetVeterinaryAggregateSanitaryActionSummaryReportDetail(AggregateSummaryRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class ReportCrossCuttingClient : BaseApiClient, IReportCrossCuttingClient
    {
        public ReportCrossCuttingClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<ReportCrossCuttingClient> logger)
           : base(httpClient, eidssApiOptions, logger)
        {
        }

        /// <summary>
        /// GetReportPeriod
        /// </summary>
        /// <param name="languageId"></param>
        /// <param name="year"></param>
        /// <param name="reportingPeriodType"></param>
        /// <returns>ReportingPeriodViewModel</returns>
        public async Task<List<ReportingPeriodViewModel>> GetReportPeriod(string languageId, string year, string reportingPeriodType)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetReportPeriodPath, _eidssApiOptions.BaseUrl, languageId, year, reportingPeriodType);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ReportingPeriodViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetReportPeriodType
        /// </summary>
        /// <param name="languageId"></param>
        /// <returns>ReportingPeriodTypeViewModel</returns>
        public async Task<List<ReportingPeriodTypeViewModel>> GetReportPeriodType(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetReportPeriodTypePath, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                if (httpResponse.StatusCode == HttpStatusCode.NoContent)
                    return new List<ReportingPeriodTypeViewModel>();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ReportingPeriodTypeViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetVetNameOfInvestigationOrMeasure
        /// </summary>
        /// <param name="languageId"></param>
        /// <returns>VetNameOfInvestigationOrMeasureViewModel</returns>
        public async Task<List<VetNameOfInvestigationOrMeasureViewModel>> GetVetNameOfInvestigationOrMeasure(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetVetNameOfInvestigationOrMeasurePath, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VetNameOfInvestigationOrMeasureViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetVetSummarySurveillanceType
        /// </summary>
        /// <param name="languageId"></param>
        /// <returns>VetSummarySurveillanceTypeViewModel</returns>
        public async Task<List<VetSummarySurveillanceTypeViewModel>> GetVetSummarySurveillanceType(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetVetSummarySurveillanceType, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VetSummarySurveillanceTypeViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetHumanWhoMeaslesRubellaDiagnosis
        /// </summary>
        /// <returns>WhoMeaslesRubellaDiagnosisViewModel</returns>
        public async Task<List<WhoMeaslesRubellaDiagnosisViewModel>> GetHumanWhoMeaslesRubellaDiagnosis()
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetHumanWhoMeaslesRubellaDiagnosisPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<WhoMeaslesRubellaDiagnosisViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetHumanComparitiveCounter
        /// </summary>
        /// <returns>HumanComparitiveCounterViewModel</returns>
        public async Task<List<HumanComparitiveCounterViewModel>> GetHumanComparitiveCounter(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetHumanComparitiveCounterPath, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<HumanComparitiveCounterViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetHumanComparitiveCounterGG
        /// </summary>
        /// <returns>HumanComparitiveCounterViewModel</returns>
        public async Task<List<HumanComparitiveCounterGGViewModel>> GetHumanComparitiveCounterGG(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetHumanComparitiveCounterGGPath, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<HumanComparitiveCounterGGViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetTuberculosisDiagnosisList
        /// </summary>
        /// <param name="languageId"></param>
        /// <returns>TuberculosisDiagnosisViewModel</returns>
        public async Task<List<TuberculosisDiagnosisViewModel>> GetTuberculosisDiagnosisList(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetTuberculosisDiagnosisListPath, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<TuberculosisDiagnosisViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetSpeciesTypes
        /// </summary>
        /// <param name="languageId"></param>
        /// <param name="idfsDiagnosis"></param>
        /// <returns>SpeciesTypeViewModel</returns>
        public async Task<List<SpeciesTypeViewModel>> GetSpeciesTypes(string languageId, long? idfsDiagnosis)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetSpeciesTypesPath, _eidssApiOptions.BaseUrl, languageId, idfsDiagnosis);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<SpeciesTypeViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetCurrentCountryList
        /// </summary>
        /// <param name="languageId"></param>
        /// <returns>CurrentCountryViewModel</returns>
        public async Task<List<CurrentCountryViewModel>> GetCurrentCountryList(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetCurrentCountryListPath, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<CurrentCountryViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetLABAssignmentDiagnosticAZSendToList
        /// </summary>
        /// <param name="languageId"></param>
        /// <param name="caseId"></param>
        /// <returns>LABAssignmentDiagnosticAZSendToViewModel</returns>
        public async Task<List<LABAssignmentDiagnosticAZSendToViewModel>> GetLABAssignmentDiagnosticAZSendToList(string languageId, string caseId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetLABAssignmentDiagnosticAZSendToListPath, _eidssApiOptions.BaseUrl, languageId, caseId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<LABAssignmentDiagnosticAZSendToViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// GetLABTestingResultsDepartmentList
        /// </summary>
        /// <param name="languageId"></param>
        /// <param name="sampleId"></param>
        /// <returns>LABTestingResultsDepartmentViewModel</returns>
        public async Task<List<LABTestingResultsDepartmentViewModel>> GetLABTestingResultsDepartmentList(string languageId, string sampleId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetLABAssignmentDiagnosticAZSendToListPath, _eidssApiOptions.BaseUrl, languageId, sampleId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<LABTestingResultsDepartmentViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<ReportListViewModel>> GetReportList()
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetReportListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ReportListViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<HumDateFieldSourceViewModel>> GetHumDateFieldSourceList(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetHumDateFieldSourceListPath, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<HumDateFieldSourceViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<ReportOrganizationViewModel>> GetReportOrganizationList(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetReportOrganizationListPath, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ReportOrganizationViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<VetDateFieldSourceViewModel>> GetVetDateFieldSourceList(string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetVetDateFieldSourceListPath, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VetDateFieldSourceViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<ReportQuarterModelGG>> GetReportQuarterGG(string languageId, int year)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetReportQuarterGGPath, _eidssApiOptions.BaseUrl, languageId, year);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ReportQuarterModelGG>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<AggregateSummaryViewModel>> GetVeterinaryAggregateReportDetail(AggregateSummaryRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVeterinaryAggregateReportDetailPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                var response = await JsonSerializer.DeserializeAsync<List<AggregateSummaryViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<AggregateSummaryViewModel>> GetHumanAggregateReportDetail(AggregateSummaryRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetHumanAggregateReportDetailPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                var response = await JsonSerializer.DeserializeAsync<List<AggregateSummaryViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<AggregateSummaryViewModel>> GetVeterinaryAggregateDiagnosticActionSummaryReportDetail(AggregateSummaryRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVeterinaryAggregateDiagnosticActionSummaryReportDetailPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                var response = await JsonSerializer.DeserializeAsync<List<AggregateSummaryViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<AggregateSummaryViewModel>> GetVeterinaryAggregateProphylacticActionSummaryReportDetail(AggregateSummaryRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVeterinaryAggregateProphylacticActionSummaryReportDetailPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                var response = await JsonSerializer.DeserializeAsync<List<AggregateSummaryViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<AggregateSummaryViewModel>> GetVeterinaryAggregateSanitaryActionSummaryReportDetail(AggregateSummaryRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVeterinaryAggregateSanitaryActionSummaryReportDetailPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                var response = await JsonSerializer.DeserializeAsync<List<AggregateSummaryViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }
    }
}