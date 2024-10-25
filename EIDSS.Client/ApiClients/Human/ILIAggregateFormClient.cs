using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Human;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Human
{
    public partial interface IILIAggregateFormClient
    {
        Task<List<ILIAggregateViewModel>> GetILIAggregateList(ILIAggregateFormSearchRequestModel request);
        Task<List<ILIAggregateDetailViewModel>> GetILIAggregateDetailList(ILIAggregateFormDetailRequestModel request);
        Task<ILIAggregateSaveRequestModel> SaveILIAggregate(ILIAggregateSaveRequestModel request);
        Task<APIPostResponseModel> DeleteILIAggregateHeader(long idfAggregateHeader, string auditUserName);
        Task<APIPostResponseModel> DeleteILIAggregateDetail(string userId, long idfAggregateDetail);
    }

    public partial class ILIAggregateFormClient : BaseApiClient, IILIAggregateFormClient
    {
        public ILIAggregateFormClient(HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<ILIAggregateFormClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<ILIAggregateViewModel>> GetILIAggregateList(ILIAggregateFormSearchRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetILIAggregateListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<ILIAggregateViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<ILIAggregateDetailViewModel>> GetILIAggregateDetailList(ILIAggregateFormDetailRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetILIAggregateDetailListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<ILIAggregateDetailViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<ILIAggregateSaveRequestModel> SaveILIAggregate(ILIAggregateSaveRequestModel saveRequestModel)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveILIAggregatePath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(saveRequestModel), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ILIAggregateSaveRequestModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            } 
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, saveRequestModel);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteILIAggregateHeader(long idfAggregateHeader, string auditUserName)
        {                        
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteILIAggregateHeaderPath, _eidssApiOptions.BaseUrl, idfAggregateHeader, auditUserName);                
                var request = new HttpRequestMessage(HttpMethod.Delete, url);
                request.Headers.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
                var httpResponse = await _httpClient.SendAsync(request);

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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteILIAggregateDetail(string userId, long idfAggregateDetail)
        {            
            var url = string.Format(_eidssApiOptions.DeleteILIAggregateDetailPath, _eidssApiOptions.BaseUrl, userId, idfAggregateDetail);

            try
            {
                // New....
                var request = new HttpRequestMessage(HttpMethod.Delete, url);
                request.Headers.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
                var httpResponse = await _httpClient.SendAsync(request);

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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }
    }
}