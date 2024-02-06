#region Usings

using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Laboratory;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Laboratory;
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

#endregion

namespace EIDSS.ClientLibrary.ApiClients.Laboratory
{
    public partial interface ILaboratoryClient
    {
        Task<List<TabCountsGetListViewModel>> GetTabCountsList(TabCountsGetRequestModel request, CancellationToken cancellationToken = default);
        Task<APISaveResponseModel> SaveLaboratory(LaboratorySaveRequestModel request, CancellationToken cancellationToken = default);
        Task<List<SamplesGetListViewModel>> GetSamplesAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<SamplesGetListViewModel>> GetSamplesList(SamplesGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<SamplesGetListViewModel>> GetSamplesSimpleSearchList(SamplesGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<SamplesGetListViewModel>> GetSamplesGroupAccessionInSearchList(GroupAccessionInSearchGetRequestModel request, CancellationToken cancellationToken = default);
        Task<SampleGetDetailViewModel> GetSampleDetail(string languageID, long sampleID, long userID, CancellationToken cancellationToken = default);
        Task<List<SampleIDsGetListViewModel>> GetSampleIDList(SampleIDsSaveRequestModel request, CancellationToken cancellationToken = default);
        Task<List<TestingGetListViewModel>> GetTestingAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<TestingGetListViewModel>> GetTestingList(TestingGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<TestingGetListViewModel>> GetTestingSimpleSearchList(TestingGetRequestModel request, CancellationToken cancellationToken = default);
        Task<TestGetDetailViewModel> GetTestDetail(string languageID, long testID, long userID, CancellationToken cancellationToken = default);
        Task<List<TestAmendmentsGetListViewModel>> GetTestAmendmentList(TestAmendmentGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<TransferredGetListViewModel>> GetTransferredAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<TransferredGetListViewModel>> GetTransferredList(TransferredGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<TransferredGetListViewModel>> GetTransferredSimpleSearchList(TransferredGetRequestModel request, CancellationToken cancellationToken = default);
        Task<TransferGetDetailViewModel> GetTransferDetail(string languageID, long transferID, long userID, CancellationToken cancellationToken = default);
        Task<List<MyFavoritesGetListViewModel>> GetMyFavoritesAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<MyFavoritesGetListViewModel>> GetMyFavoritesList(MyFavoritesGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<MyFavoritesGetListViewModel>> GetMyFavoritesSimpleSearchList(MyFavoritesGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<BatchesGetListViewModel>> GetBatchesAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<BatchesGetListViewModel>> GetBatchesList(BatchesGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<ApprovalsGetListViewModel>> GetApprovalsAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<ApprovalsGetListViewModel>> GetApprovalsList(ApprovalsGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<ApprovalsGetListViewModel>> GetApprovalsSimpleSearchList(ApprovalsGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<SamplesGetListViewModel>> GetSamplesByBarCodeList(SamplesGetRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class LaboratoryClient : BaseApiClient, ILaboratoryClient
    {
        protected internal EidssApiConfigurationOptions EidssApiConfigurationOptions;

        #region Constructors

        public LaboratoryClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptions<EidssApiConfigurationOptions> eidssApiConfigurationOptions, ILogger<LaboratoryClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            EidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
            _httpClient = httpClient;
        }

        #endregion

        #region Laboratory Common Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<TabCountsGetListViewModel>> GetTabCountsList(TabCountsGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                using var ms = new MemoryStream();
                var url = string.Format(_eidssApiOptions.GetLaboratoryTabCountsListPath, _eidssApiOptions.BaseUrl);
                var aj = new MediaTypeWithQualityHeaderValue("application/json");

                await JsonSerializer.SerializeAsync(ms, request, cancellationToken: cancellationToken);
                ms.Seek(0, SeekOrigin.Begin);

                var requestMessage = new HttpRequestMessage(HttpMethod.Post, url);
                requestMessage.Headers.Accept.Add(aj);

                using var requestContent = new StreamContent(ms);
                requestMessage.Content = requestContent;
                requestContent.Headers.ContentType = aj;
                using var response = await _httpClient.SendAsync(requestMessage, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
                response.EnsureSuccessStatusCode();
                var content = await response.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<TabCountsGetListViewModel>>(content, SerializationOptions, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<APISaveResponseModel> SaveLaboratory(LaboratorySaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveLaboratoryPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        #endregion

        #region Samples Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<SamplesGetListViewModel>> GetSamplesAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                using var ms = new MemoryStream();
                var url = string.Format(_eidssApiOptions.GetLaboratorySamplesAdvancedSearchListPath, _eidssApiOptions.BaseUrl);
                var aj = new MediaTypeWithQualityHeaderValue("application/json");

                await JsonSerializer.SerializeAsync(ms, request, cancellationToken: cancellationToken);
                ms.Seek(0, SeekOrigin.Begin);

                var requestMessage = new HttpRequestMessage(HttpMethod.Post, url);
                requestMessage.Headers.Accept.Add(aj);

                using var requestContent = new StreamContent(ms);
                requestMessage.Content = requestContent;
                requestContent.Headers.ContentType = aj;

                using var response = await _httpClient.SendAsync(requestMessage, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
                response.EnsureSuccessStatusCode();
                var content = await response.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<SamplesGetListViewModel>>(content, SerializationOptions, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<SamplesGetListViewModel>> GetSamplesList(SamplesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                using var ms = new MemoryStream();
                var url = string.Format(_eidssApiOptions.GetLaboratorySamplesListPath, _eidssApiOptions.BaseUrl);
                var aj = new MediaTypeWithQualityHeaderValue("application/json");

                await JsonSerializer.SerializeAsync(ms, request, cancellationToken: cancellationToken);
                ms.Seek(0, SeekOrigin.Begin);

                var requestMessage = new HttpRequestMessage(HttpMethod.Post, url);
                requestMessage.Headers.Accept.Add(aj);

                using var requestContent = new StreamContent(ms);
                requestMessage.Content = requestContent;
                requestContent.Headers.ContentType = aj;

                using var response = await _httpClient.SendAsync(requestMessage, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
                response.EnsureSuccessStatusCode();
                var content = await response.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<SamplesGetListViewModel>>(content, SerializationOptions, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<SamplesGetListViewModel>> GetSamplesSimpleSearchList(SamplesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratorySamplesSimpleSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<SamplesGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<SamplesGetListViewModel>> GetSamplesGroupAccessionInSearchList(GroupAccessionInSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratorySamplesGroupAccessionInSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<SamplesGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="languageID"></param>
        /// <param name="sampleID"></param>
        /// <param name="userID"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<SampleGetDetailViewModel> GetSampleDetail(string languageID, long sampleID, long userID, CancellationToken cancellationToken = default)
        {
            var url = string.Format(_eidssApiOptions.GetLaboratorySampleDetailPath, _eidssApiOptions.BaseUrl, languageID, sampleID, userID);
            var httpResponse = await _httpClient.GetAsync(new Uri(url), cancellationToken);

            httpResponse.EnsureSuccessStatusCode();

            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<SampleGetDetailViewModel>(contentStream, new JsonSerializerOptions
            {
                IgnoreNullValues = true,
                PropertyNameCaseInsensitive = true
            }, cancellationToken);

            return response;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<SampleIDsGetListViewModel>> GetSampleIDList(SampleIDsSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratorySampleIDListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<SampleIDsGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<SamplesGetListViewModel>> GetSamplesByBarCodeList(SamplesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratorySampleByBarCodePath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<SamplesGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        #endregion

        #region Testing Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<TestingGetListViewModel>> GetTestingAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryTestingAdvancedSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<TestingGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<TestingGetListViewModel>> GetTestingList(TestingGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryTestingListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<TestingGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<TestingGetListViewModel>> GetTestingSimpleSearchList(TestingGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryTestingSimpleSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<TestingGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="languageID"></param>
        /// <param name="testID"></param>
        /// <param name="userID"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<TestGetDetailViewModel> GetTestDetail(string languageID, long testID, long userID, CancellationToken cancellationToken = default)
        {
            var url = string.Format(_eidssApiOptions.GetLaboratoryTestDetailPath, _eidssApiOptions.BaseUrl, languageID, testID, userID);
            var httpResponse = await _httpClient.GetAsync(new Uri(url), cancellationToken);

            httpResponse.EnsureSuccessStatusCode();

            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<TestGetDetailViewModel>(contentStream, new JsonSerializerOptions
            {
                IgnoreNullValues = true,
                PropertyNameCaseInsensitive = true
            }, cancellationToken);

            return response;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<TestAmendmentsGetListViewModel>> GetTestAmendmentList(TestAmendmentGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryTestAmendmentListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<TestAmendmentsGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        #endregion

        #region Transferred Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<TransferredGetListViewModel>> GetTransferredAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryTransferredAdvancedSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<TransferredGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<TransferredGetListViewModel>> GetTransferredList(TransferredGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryTransferredListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<TransferredGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<TransferredGetListViewModel>> GetTransferredSimpleSearchList(TransferredGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryTransferredSimpleSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<TransferredGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="languageID"></param>
        /// <param name="transferID"></param>
        /// <param name="userID"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<TransferGetDetailViewModel> GetTransferDetail(string languageID, long transferID, long userID, CancellationToken cancellationToken = default)
        {
            var url = string.Format(_eidssApiOptions.GetLaboratoryTransferDetailPath, _eidssApiOptions.BaseUrl, languageID, transferID, userID);
            var httpResponse = await _httpClient.GetAsync(new Uri(url), cancellationToken);

            httpResponse.EnsureSuccessStatusCode();

            var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

            var response = await JsonSerializer.DeserializeAsync<TransferGetDetailViewModel>(contentStream, new JsonSerializerOptions
            {
                IgnoreNullValues = true,
                PropertyNameCaseInsensitive = true
            }, cancellationToken);

            return response;
        }

        #endregion

        #region My Favorites Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<MyFavoritesGetListViewModel>> GetMyFavoritesAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryMyFavoritesAdvancedSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<MyFavoritesGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<MyFavoritesGetListViewModel>> GetMyFavoritesList(MyFavoritesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryMyFavoritesListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<MyFavoritesGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<MyFavoritesGetListViewModel>> GetMyFavoritesSimpleSearchList(MyFavoritesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryMyFavoritesSimpleSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<MyFavoritesGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        #endregion

        #region Batches Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<BatchesGetListViewModel>> GetBatchesAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryBatchesAdvancedSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<BatchesGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<BatchesGetListViewModel>> GetBatchesList(BatchesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryBatchesListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<BatchesGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        #endregion

        #region Approvals Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<ApprovalsGetListViewModel>> GetApprovalsAdvancedSearchList(AdvancedSearchGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryApprovalsAdvancedSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<ApprovalsGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<ApprovalsGetListViewModel>> GetApprovalsList(ApprovalsGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryApprovalsListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<ApprovalsGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<ApprovalsGetListViewModel>> GetApprovalsSimpleSearchList(ApprovalsGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetLaboratoryApprovalsSimpleSearchListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<ApprovalsGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        #endregion
    }
}