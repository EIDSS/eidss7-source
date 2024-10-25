using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Human;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using System.Threading;

using EIDSS.Domain.ResponseModels;
using System.IO;
using System.Net.Http.Headers;

namespace EIDSS.ClientLibrary.ApiClients.Human
{
    public partial interface IHumanActiveSurveillanceSessionClient
    {
        Task<List<ActiveSurveillanceSessionResponseModel>> GetActiveSurveillanceSessionListAsync(ActiveSurveillanceSessionRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceSessionSamplesResponseModel>> GetActiveSurveillanceSessionSamplesListAsync(ActiveSurveillanceSessionSamplesListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceSessionDetailResponseModel>> GetHumanActiveSurveillanceSessionDetailAsync(ActiveSurveillanceSessionDetailRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceSessionDetailedInformationResponseModel>> GetActiveSurveillanceSessionDetailedInformation(ActiveSurveillanceSessionDetailedInformationRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceSessionTestsResponseModel>> GetActiveSurveillanceSessionTests(ActiveSurveillanceSessionTestsRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceSessionActionsResponseModel>> GetHumanActiveSurveillanceSessionActionsListAsync(ActiveSurveillanceSessionActionsRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceSessionTestNamesResponseModel>> GetActiveSurveillanceSessionTestNames(ActiveSurveillanceSessionTestNameRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceSessionSaveResponseModel>> SetActiveSurveillanceSession(ActiveSurveillanceSessionSaveRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceSessionDiseaseSampleTypeResponseModel>> GetHumanActiveSurveillanceDiseaseSampleTypeListAsync(ActiveSurveillanceSessionDiseaseSampleTypeRequestModel request, CancellationToken cancellationToken = default);

        Task<APIPostResponseModel> DeleteHumanActiveSurveillanceSession(long MonitoringSessionID, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceSessionSamplesResponseModel>> GetActiveSurveillanceSessionToSampleList(ActiveSurveillanceSessionSamplesListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceSessionDiseaseReportsResponseModel>> GetActiveSurveillanceDiseaseReportsListAsync(ActiveSurveillanceSessionDiseaseReportsRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class HumanActiveSurveillanceSessionClient : BaseApiClient, IHumanActiveSurveillanceSessionClient
    {
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public HumanActiveSurveillanceSessionClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
              ILogger<HumanActiveSurveillanceSessionClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }

        public async Task<List<ActiveSurveillanceSessionResponseModel>> GetActiveSurveillanceSessionListAsync(ActiveSurveillanceSessionRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionResponseModel>>(contentStream,
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

        public async Task<List<ActiveSurveillanceSessionSamplesResponseModel>> GetActiveSurveillanceSessionSamplesListAsync(ActiveSurveillanceSessionSamplesListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionSamplesListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionSamplesResponseModel>>(contentStream,
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

        /// <summary>
        /// Retrieves the details of a Human Active Surveillance Session.
        /// </summary>
        /// <returns></returns>
        public async Task<List<ActiveSurveillanceSessionDetailResponseModel>> GetHumanActiveSurveillanceSessionDetailAsync(ActiveSurveillanceSessionDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionDetailAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionDetailResponseModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);

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
            //using (MemoryStream ms = new MemoryStream())
            //{
            //    var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionDetailAsyncPath, _eidssApiOptions.BaseUrl);
            //    var aj = new MediaTypeWithQualityHeaderValue("application/json");

            //    await JsonSerializer.SerializeAsync(ms, request);
            //    ms.Seek(0, SeekOrigin.Begin);

            //    var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
            //    requestmessage.Headers.Accept.Add(aj);

            //    using (var requestContent = new StreamContent(ms))
            //    {
            //        requestmessage.Content = requestContent;
            //        requestContent.Headers.ContentType = aj;
            //        using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
            //        {
            //            response.EnsureSuccessStatusCode();
            //            var content = await response.Content.ReadAsStreamAsync();
            //            return await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionDetailResponseModel>>(content, this.SerializationOptions);
            //        }
            //    }
            //}
        }

        /// <summary>
        /// Retrieves a list of Human Active Surveillance 'Detailed Information' for a Session.
        /// </summary>
        /// <returns></returns>
        public async Task<List<ActiveSurveillanceSessionDetailedInformationResponseModel>> GetActiveSurveillanceSessionDetailedInformation(ActiveSurveillanceSessionDetailedInformationRequestModel request, CancellationToken cancellationToken = default)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionDetailedInformationAsyncPath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionDetailedInformationResponseModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);

            return response;
            //using (MemoryStream ms = new MemoryStream())
            //{
            //    var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionDetailedInformationAsyncPath, _eidssApiOptions.BaseUrl);
            //    var aj = new MediaTypeWithQualityHeaderValue("application/json");

            //    await JsonSerializer.SerializeAsync(ms, request);
            //    ms.Seek(0, SeekOrigin.Begin);

            //    var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
            //    requestmessage.Headers.Accept.Add(aj);

            //    using (var requestContent = new StreamContent(ms))
            //    {
            //        requestmessage.Content = requestContent;
            //        requestContent.Headers.ContentType = aj;
            //        using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
            //        {
            //            response.EnsureSuccessStatusCode();
            //            var content = await response.Content.ReadAsStreamAsync();
            //            return await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionDetailedInformationResponseModel>>(content, this.SerializationOptions);
            //        }
            //    }
            //}
        }

        /// <summary>
        /// Retrieves a list of Human Active Surveillance 'Tests' for a Session.
        /// </summary>
        /// <returns></returns>
        public async Task<List<ActiveSurveillanceSessionTestsResponseModel>> GetActiveSurveillanceSessionTests(ActiveSurveillanceSessionTestsRequestModel request, CancellationToken cancellationToken = default)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionTestsAsyncPath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionTestsResponseModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);

            return response;
            //using (MemoryStream ms = new MemoryStream())
            //{
            //    var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionTestsAsyncPath, _eidssApiOptions.BaseUrl);
            //    var aj = new MediaTypeWithQualityHeaderValue("application/json");

            //    await JsonSerializer.SerializeAsync(ms, request);
            //    ms.Seek(0, SeekOrigin.Begin);

            //    var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
            //    requestmessage.Headers.Accept.Add(aj);

            //    using (var requestContent = new StreamContent(ms))
            //    {
            //        requestmessage.Content = requestContent;
            //        requestContent.Headers.ContentType = aj;
            //        using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
            //        {
            //            response.EnsureSuccessStatusCode();
            //            var content = await response.Content.ReadAsStreamAsync();
            //            return await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionTestsResponseModel>>(content, this.SerializationOptions);
            //        }
            //    }
            //}
        }

        /// <summary>
        /// Retrieves a list of Human Active Surveillance 'Actions' for a Session.
        /// </summary>
        /// <returns></returns>
        public async Task<List<ActiveSurveillanceSessionActionsResponseModel>> GetHumanActiveSurveillanceSessionActionsListAsync(ActiveSurveillanceSessionActionsRequestModel request, CancellationToken cancellationToken = default)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionActionsAsyncPath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionActionsResponseModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);

            return response;
            //using (MemoryStream ms = new MemoryStream())
            //{
            //    var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionActionsAsyncPath, _eidssApiOptions.BaseUrl);
            //    var aj = new MediaTypeWithQualityHeaderValue("application/json");

            //    await JsonSerializer.SerializeAsync(ms, request);
            //    ms.Seek(0, SeekOrigin.Begin);

            //    var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
            //    requestmessage.Headers.Accept.Add(aj);

            //    using (var requestContent = new StreamContent(ms))
            //    {
            //        requestmessage.Content = requestContent;
            //        requestContent.Headers.ContentType = aj;
            //        using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
            //        {
            //            response.EnsureSuccessStatusCode();
            //            var content = await response.Content.ReadAsStreamAsync();
            //            return await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionActionsResponseModel>>(content, this.SerializationOptions);
            //        }
            //    }
            //}
        }

        /// <summary>
        /// Retrieves a list of Human Active Surveillance 'Test Names' for a given disease.
        /// </summary>
        /// <returns></returns>
        public async Task<List<ActiveSurveillanceSessionTestNamesResponseModel>> GetActiveSurveillanceSessionTestNames(ActiveSurveillanceSessionTestNameRequestModel request, CancellationToken cancellationToken = default)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionTestNamesAsyncPath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionTestNamesResponseModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);

            return response;
            //using (MemoryStream ms = new MemoryStream())
            //{
            //    var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionTestNamesAsyncPath, _eidssApiOptions.BaseUrl);
            //    var aj = new MediaTypeWithQualityHeaderValue("application/json");

            //    await JsonSerializer.SerializeAsync(ms, request);
            //    ms.Seek(0, SeekOrigin.Begin);

            //    var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
            //    requestmessage.Headers.Accept.Add(aj);

            //    using (var requestContent = new StreamContent(ms))
            //    {
            //        requestmessage.Content = requestContent;
            //        requestContent.Headers.ContentType = aj;
            //        using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
            //        {
            //            response.EnsureSuccessStatusCode();
            //            var content = await response.Content.ReadAsStreamAsync();
            //            return await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionTestNamesResponseModel>>(content, this.SerializationOptions);
            //        }
            //    }
            //}
        }

        /// <summary>
        /// Saves / Edits a Human Active Surveillance record.
        /// </summary>
        /// <returns></returns>
        public async Task<List<ActiveSurveillanceSessionSaveResponseModel>> SetActiveSurveillanceSession(ActiveSurveillanceSessionSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionSetAsyncPath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionSaveResponseModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);

            return response;
            //using (MemoryStream ms = new MemoryStream())
            //{
            //    var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionSetAsyncPath, _eidssApiOptions.BaseUrl);
            //    var aj = new MediaTypeWithQualityHeaderValue("application/json");

            //    await JsonSerializer.SerializeAsync(ms, request);
            //    ms.Seek(0, SeekOrigin.Begin);

            //    var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
            //    requestmessage.Headers.Accept.Add(aj);

            //    using (var requestContent = new StreamContent(ms))
            //    {
            //        requestmessage.Content = requestContent;
            //        requestContent.Headers.ContentType = aj;
            //        using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
            //        {
            //            response.EnsureSuccessStatusCode();
            //            var content = await response.Content.ReadAsStreamAsync();
            //            return await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionSaveResponseModel>>(content, this.SerializationOptions);
            //        }
            //    }
            //}
        }

        /// <summary>
        /// Get a list of the Diseases/Sample Types combination for the Session Information section.
        /// </summary>
        /// <returns></returns>
        public async Task<List<ActiveSurveillanceSessionDiseaseSampleTypeResponseModel>> GetHumanActiveSurveillanceDiseaseSampleTypeListAsync(ActiveSurveillanceSessionDiseaseSampleTypeRequestModel request, CancellationToken cancellationToken = default)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceDiseaseSampleTypeListAsyncPath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionDiseaseSampleTypeResponseModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);

            return response;
            //using (MemoryStream ms = new MemoryStream())
            //{
            //    var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceDiseaseSampleTypeListAsyncPath, _eidssApiOptions.BaseUrl);
            //    var aj = new MediaTypeWithQualityHeaderValue("application/json");

            //    await JsonSerializer.SerializeAsync(ms, request);
            //    ms.Seek(0, SeekOrigin.Begin);

            //    var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
            //    requestmessage.Headers.Accept.Add(aj);

            //    using (var requestContent = new StreamContent(ms))
            //    {
            //        requestmessage.Content = requestContent;
            //        requestContent.Headers.ContentType = aj;
            //        using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
            //        {
            //            response.EnsureSuccessStatusCode();
            //            var content = await response.Content.ReadAsStreamAsync();
            //            return await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionDiseaseSampleTypeResponseModel>>(content, this.SerializationOptions);
            //        }
            //    }
            //}
        }

        /// <summary>
        /// Deletes an Active Surveillance Session for Human.
        /// </summary>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteHumanActiveSurveillanceSession(long MonitoringSessionID, CancellationToken cancellationToken = default)
        {
            var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceDeletePath, _eidssApiOptions.BaseUrl, MonitoringSessionID);
            var httpResponse = await _httpClient.DeleteAsync(new Uri(url), cancellationToken);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);

            return response;
        }

        /// <summary>
        /// Gets Session associated samples.
        /// </summary>
        /// <returns></returns>
        public async Task<List<ActiveSurveillanceSessionSamplesResponseModel>> GetActiveSurveillanceSessionToSampleList(ActiveSurveillanceSessionSamplesListRequestModel request, CancellationToken cancellationToken = default)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionSamplesListPath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionSamplesResponseModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);

            return response;
            //using (MemoryStream ms = new MemoryStream())
            //{
            //    var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceSessionSamplesListPath, _eidssApiOptions.BaseUrl);
            //    var aj = new MediaTypeWithQualityHeaderValue("application/json");

            //    await JsonSerializer.SerializeAsync(ms, request);
            //    ms.Seek(0, SeekOrigin.Begin);

            //    var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
            //    requestmessage.Headers.Accept.Add(aj);

            //    using (var requestContent = new StreamContent(ms))
            //    {
            //        requestmessage.Content = requestContent;
            //        requestContent.Headers.ContentType = aj;
            //        using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
            //        {
            //            response.EnsureSuccessStatusCode();
            //            var content = await response.Content.ReadAsStreamAsync();
            //            return await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionSamplesResponseModel>>(content, this.SerializationOptions);
            //        }
            //    }
            //}
        }

        /// <summary>
        /// Gets Session associated Disease Reports.
        /// </summary>
        /// <returns></returns>
        public async Task<List<ActiveSurveillanceSessionDiseaseReportsResponseModel>> GetActiveSurveillanceDiseaseReportsListAsync(ActiveSurveillanceSessionDiseaseReportsRequestModel request, CancellationToken cancellationToken = default)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.GetHumanActiveSurveillanceDiseaseReportsListAsyncPath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionDiseaseReportsResponseModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);

            return response;
            //using (MemoryStream ms = new MemoryStream())
            //{
            //    var url = string.Format(_eidssApiOptions.GetHumanActiveSurveillanceDiseaseReportsListAsyncPath, _eidssApiOptions.BaseUrl);
            //    var aj = new MediaTypeWithQualityHeaderValue("application/json");

            //    await JsonSerializer.SerializeAsync(ms, request);
            //    ms.Seek(0, SeekOrigin.Begin);

            //    var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
            //    requestmessage.Headers.Accept.Add(aj);

            //    using (var requestContent = new StreamContent(ms))
            //    {
            //        requestmessage.Content = requestContent;
            //        requestContent.Headers.ContentType = aj;
            //        using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
            //        {
            //            response.EnsureSuccessStatusCode();
            //            var content = await response.Content.ReadAsStreamAsync();
            //            return await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceSessionDiseaseReportsResponseModel>>(content, this.SerializationOptions);
            //        }
            //    }
            //}
        }
    }
}