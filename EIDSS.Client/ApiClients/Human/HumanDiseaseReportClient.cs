using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Human
{
    public partial interface IHumanDiseaseReportClient
    {
        Task<List<HumanDiseaseReportViewModel>> GetHumanDiseaseReports(HumanDiseaseReportSearchRequestModel request, CancellationToken cancellationToken = default);
        Task<List<HumanDiseaseReportDetailViewModel>> GetHumanDiseaseDetail(HumanDiseaseReportDetailRequestModel request);
        Task<List<DiseaseReportPersonalInformationViewModel>> GetHumanDiseaseReportPersonInfoAsync(HumanPersonDetailsRequestModel request);
        Task<List<DiseaseReportPersonalInformationViewModel>> GetHumanDiseaseReportFromHumanIDAsync(HumanPersonDetailsFromHumanIDRequestModel request);
        Task<List<DiseaseReportAntiviralTherapiesViewModel>> GetAntiviralTherapisListAsync(HumanAntiviralTherapiesAndVaccinationRequestModel request);
        Task<List<DiseaseReportVaccinationViewModel>> GetVaccinationListAsync(HumanAntiviralTherapiesAndVaccinationRequestModel request);
        Task<List<HumanDiseaseReportSamplesViewModel>> GetHumanDiseaseReportSamplesListAsync(HumanDiseaseReportSamplesRequestModel request);
        Task<List<DiseaseReportSampleForDiseasesViewModel>> GetHumanDiseaseSampleForDiseasesListAsync(HumanSampleForDiseasesRequestModel request);
        Task<List<DiseaseReportTestDetailForDiseasesViewModel>> GetHumanDiseaseReportTestListAsync(HumanTestListRequestModel request);
        Task<List<DiseaseReportTestNameForDiseasesViewModel>> GetHumanDiseaseReportTestNameForDiseasesAsync(HumanTestNameForDiseasesRequestModel request);
        Task<List<SetHumanDiseaseReportResponseModel>> SaveHumanDiseaseReport(HumanSetDiseaseReportRequestModel request);
        Task<List<DiseaseReportContactDetailsViewModel>> GetHumanDiseaseContactListAsync(HumanDiseaseContactListRequestModel request);
        Task<APIPostResponseModel> DeleteHumanDiseaseReport(long? idfHumanCase, long? idfUserID, long? idfSiteId, bool? DeduplicationIndicator);
        Task<APIPostResponseModel> UpdateHumanDiseaseInvestigatedByAsync(HumanSetDiseaseReportRequestModel request, CancellationToken cancellationToken = default);
        Task<List<HumanDiseaseReportLkupCaseClassificationResponseModel>> GetHumanDiseaseReportLkupCaseClassificationAsync(HumanDiseaseReportLkupCaseClassificationRequestModel request);
        Task<HumanDiseaseReportDedupeResponseModel> DedupeHumanDiseaseReportRecords(HumanDiseaseReportDedupeRequestModel request, CancellationToken cancellationToken = default);
        Task<List<RecordPermissionsViewModel>> GetHumanDiseaseDetailPermissions(RecordPermissionsGetRequestModel request);
    }

    public partial class HumanDiseaseReportClient : BaseApiClient, IHumanDiseaseReportClient
    {
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public HumanDiseaseReportClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
          ILogger<HumanDiseaseReportClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }


        public async Task<List<HumanDiseaseReportViewModel>> GetHumanDiseaseReports(HumanDiseaseReportSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseReportListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                var response = await JsonSerializer.DeserializeAsync<List<HumanDiseaseReportViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }

        }

        public async Task<List<HumanDiseaseReportDetailViewModel>> GetHumanDiseaseDetail(HumanDiseaseReportDetailRequestModel request)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseReportDetailAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<HumanDiseaseReportDetailViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }

        }

        public async Task<List<DiseaseReportPersonalInformationViewModel>> GetHumanDiseaseReportPersonInfoAsync(HumanPersonDetailsRequestModel request)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseReportPersonInfoPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<DiseaseReportPersonalInformationViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
            finally
            {
            }
        }
        public async Task<List<DiseaseReportPersonalInformationViewModel>> GetHumanDiseaseReportFromHumanIDAsync(HumanPersonDetailsFromHumanIDRequestModel request)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseReportFromHumanIDPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<DiseaseReportPersonalInformationViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
            finally
            {
            }
        }
        public async Task<List<DiseaseReportAntiviralTherapiesViewModel>> GetAntiviralTherapisListAsync(HumanAntiviralTherapiesAndVaccinationRequestModel request)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseAntviralTherapiesAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<DiseaseReportAntiviralTherapiesViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }

        }
        public async Task<List<DiseaseReportVaccinationViewModel>> GetVaccinationListAsync(HumanAntiviralTherapiesAndVaccinationRequestModel request)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseVaccinationListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<DiseaseReportVaccinationViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }

        }

        public async Task<List<HumanDiseaseReportSamplesViewModel>> GetHumanDiseaseReportSamplesListAsync(HumanDiseaseReportSamplesRequestModel request)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseSamplesListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<HumanDiseaseReportSamplesViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }

        }

        public async Task<List<DiseaseReportSampleForDiseasesViewModel>> GetHumanDiseaseSampleForDiseasesListAsync(HumanSampleForDiseasesRequestModel request)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseSamplesForDiseaseListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<DiseaseReportSampleForDiseasesViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }

        }
        public async Task<List<DiseaseReportTestDetailForDiseasesViewModel>> GetHumanDiseaseReportTestListAsync(HumanTestListRequestModel request)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseTestListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<DiseaseReportTestDetailForDiseasesViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }

        }
        public async Task<List<DiseaseReportTestNameForDiseasesViewModel>> GetHumanDiseaseReportTestNameForDiseasesAsync(HumanTestNameForDiseasesRequestModel request)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseTestNameForDiseasesAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<DiseaseReportTestNameForDiseasesViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }

        }
        public async Task<List<SetHumanDiseaseReportResponseModel>> SaveHumanDiseaseReport(HumanSetDiseaseReportRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveHumanDiseaseReportPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<SetHumanDiseaseReportResponseModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
            finally
            {
            }
        }
        public async Task<List<DiseaseReportContactDetailsViewModel>> GetHumanDiseaseContactListAsync(HumanDiseaseContactListRequestModel request)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseContactListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<DiseaseReportContactDetailsViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }

        }
        public async Task<APIPostResponseModel> DeleteHumanDiseaseReport(long? idfHumanCase, long? idfUserID, long? idfSiteId, bool? DeduplicationIndicator)
        {
            var url = string.Format(_eidssApiOptions.DeleteHumanDiseaseReportPath, _eidssApiOptions.BaseUrl, idfHumanCase, idfUserID, idfSiteId,DeduplicationIndicator);
            var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            return response;
        }

       
        public async Task<APIPostResponseModel> UpdateHumanDiseaseInvestigatedByAsync(HumanSetDiseaseReportRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.UpdateHumanDiseaseInvestigatedByPath, _eidssApiOptions.BaseUrl);                

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<List<HumanDiseaseReportLkupCaseClassificationResponseModel>> GetHumanDiseaseReportLkupCaseClassificationAsync(HumanDiseaseReportLkupCaseClassificationRequestModel request)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseReportLkupCaseClassificationAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<HumanDiseaseReportLkupCaseClassificationResponseModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }

        }

        public async Task<HumanDiseaseReportDedupeResponseModel> DedupeHumanDiseaseReportRecords(HumanDiseaseReportDedupeRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DedupeHumanDiseaseReportPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<HumanDiseaseReportDedupeResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<List<RecordPermissionsViewModel>> GetHumanDiseaseDetailPermissions(RecordPermissionsGetRequestModel request)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanDiseaseReportDetailPermissionsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, _);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<RecordPermissionsViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }

        }
    }
}

