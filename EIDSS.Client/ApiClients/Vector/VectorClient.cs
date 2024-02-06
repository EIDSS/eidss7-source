using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Domain.ViewModels.Vector;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Domain.ResponseModels;

namespace EIDSS.ClientLibrary.ApiClients.Vector
{
    public partial interface IVectorClient
    {
        public Task<List<APIPostResponseModel>> CopyDetailedCollectionAsync(USP_VCTS_DetailedCollections_CopyRequestModel request, CancellationToken cancellationToken = default);

        public Task<APIPostResponseModel> DeleteAggregateCollection(long idfsVSSessionSummary, CancellationToken cancellationToken = default);

        public Task<APIPostResponseModel> DeleteDetailedCollection(long idfVector, CancellationToken cancellationToken = default);

        public Task<APIPostResponseModel> DeleteVectorSurveillanceSessionAsync(long idfVectorSurveillanceSession, CancellationToken cancellationToken = default);

        public Task<List<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel>> GetSessionDiagnosis(USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailRequestModel request, CancellationToken cancellationToken = default);

        public Task<List<VectorSessionDetailResponseModel>> GetVectorAggregateCollectionList(USP_VCTS_VecSessionSummary_GETListRequestModel request, CancellationToken cancellationToken = default);

        public Task<List<USP_VCTS_VECT_GetDetailResponseModel>> GetVectorDetails(USP_VCTS_VECT_GetDetailRequestModel request, CancellationToken cancellationToken = default);

        public Task<List<USP_VCTS_VECTCollection_GetDetailResponseModel>> GetVectorDetailsCollection(USP_VCTS_VECTCollection_GetDetailRequestModel request, CancellationToken cancellationToken = default);

        public Task<List<USP_VCTS_LABTEST_GetListResponseModel>> GetVectorLabTestsAsync(USP_VCTS_LABTEST_GetListRequestModel request, CancellationToken cancellationToken = default);

        public Task<List<VectorSampleGetListViewModel>> GetVectorSamplesAsync(USP_VCTS_SAMPLE_GetListRequestModels request, CancellationToken cancellationToken = default);

        public Task<List<VectorSessionDetailResponseModel>> GetVectorSessionAggregateCollectionDetail(VectorSessionDetailRequestModel request, CancellationToken cancellationToken = default);

        public Task<List<FieldTestGetListViewModel>> GetVectorSessionFieldTestsAsync(USP_VCTS_FIELDTEST_GetListRequestModel request, CancellationToken cancellationToken = default);

        public Task<List<VectorSurveillanceSessionViewModel>> GetVectorSurveillanceSessionListAsync(VectorSurveillanceSessionSearchRequestModel request, CancellationToken cancellationToken = default);

        public Task<List<USP_VCTS_VSSESSION_New_GetDetailResponseModel>> GetVectorSurveillanceSessionMasterAsync(USP_VCTS_VSSESSION_NEW_GetDetailRequestModel request, CancellationToken cancellationToken = default);

        public Task<List<VectorSessionResponseModel>> SaveVectorSurveillanceSessionAsync(VectorSessionSetRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class VectorClient : BaseApiClient, IVectorClient
    {
        public VectorClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<VectorClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        public async Task<List<APIPostResponseModel>> CopyDetailedCollectionAsync(USP_VCTS_DetailedCollections_CopyRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.CopyVectorDetailedCollectionPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                var response = await JsonSerializer.DeserializeAsync<List<APIPostResponseModel>>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<APIPostResponseModel> DeleteAggregateCollection(long idfsVSSessionSummary, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteAggregateCollectionPath, _eidssApiOptions.BaseUrl, idfsVSSessionSummary);
                var request = new HttpRequestMessage(HttpMethod.Delete, url);
                request.Headers.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
                var httpResponse = await _httpClient.SendAsync(request, cancellationToken);

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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { });
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<APIPostResponseModel> DeleteDetailedCollection(long idfVector, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteDetailedCollectionPath, _eidssApiOptions.BaseUrl, idfVector);
                var request = new HttpRequestMessage(HttpMethod.Delete, url);
                request.Headers.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
                var httpResponse = await _httpClient.SendAsync(request, cancellationToken);

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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { });
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="idfVectorSurveillanceSession"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteVectorSurveillanceSessionAsync(long idfVectorSurveillanceSession, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteVectorSurveillanceSessionPath, _eidssApiOptions.BaseUrl, idfVectorSurveillanceSession);
                var request = new HttpRequestMessage(HttpMethod.Delete, url);
                request.Headers.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
                var httpResponse = await _httpClient.SendAsync(request, cancellationToken);

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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel>> GetSessionDiagnosis(USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetSessionDiagnosisPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel>>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<VectorSessionDetailResponseModel>> GetVectorAggregateCollectionList(USP_VCTS_VecSessionSummary_GETListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVectorSessionSummaryPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VectorSessionDetailResponseModel>>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<USP_VCTS_VECT_GetDetailResponseModel>> GetVectorDetails(USP_VCTS_VECT_GetDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVectorDetailsListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<USP_VCTS_VECT_GetDetailResponseModel>>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<USP_VCTS_VECTCollection_GetDetailResponseModel>> GetVectorDetailsCollection(USP_VCTS_VECTCollection_GetDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVectorDetailsCollectionPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<USP_VCTS_VECTCollection_GetDetailResponseModel>>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        /// <summary>
        /// Return vector detailed collection lab tests
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<USP_VCTS_LABTEST_GetListResponseModel>> GetVectorLabTestsAsync(USP_VCTS_LABTEST_GetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVectorSurveillanceLabTestPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<USP_VCTS_LABTEST_GetListResponseModel>>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        /// <summary>
        /// Return Vector Sample Records
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<VectorSampleGetListViewModel>> GetVectorSamplesAsync(USP_VCTS_SAMPLE_GetListRequestModels request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVectorSurveillanceSamplesPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VectorSampleGetListViewModel>>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<VectorSessionDetailResponseModel>> GetVectorSessionAggregateCollectionDetail(VectorSessionDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVectorSessionAggregateCollectionDetailAsyncPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<VectorSessionDetailResponseModel>>(contentStream,
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

        public async Task<List<FieldTestGetListViewModel>> GetVectorSessionFieldTestsAsync(USP_VCTS_FIELDTEST_GetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVectorFieldTestPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FieldTestGetListViewModel>>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<VectorSurveillanceSessionViewModel>> GetVectorSurveillanceSessionListAsync(VectorSurveillanceSessionSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVectorSurveillanceSessionListAsyncPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<VectorSurveillanceSessionViewModel>>(contentStream,
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

        public async Task<List<USP_VCTS_VSSESSION_New_GetDetailResponseModel>> GetVectorSurveillanceSessionMasterAsync(USP_VCTS_VSSESSION_NEW_GetDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVectorSurveillanceSessionMasterPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<USP_VCTS_VSSESSION_New_GetDetailResponseModel>>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<VectorSessionResponseModel>> SaveVectorSurveillanceSessionAsync(VectorSessionSetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveVectorSurveillanceSessionAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<VectorSessionResponseModel>>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }
    }
}