using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
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

namespace EIDSS.ClientLibrary.ApiClients.Human
{
    public partial interface IHumanActiveSurveillanceCampaignClient
    {
        Task<List<HumanActiveSurveillanceCampaignViewModel>> GetHumanActiveSurveillanceCampaignListAsync(HumanActiveSurveillanceCampaignRequestModel request);

        Task<List<SetHumanActiveSurveillanceCampaignResponseModel>> SetHumanActiveServiellanceCampaign(SetHumanActiveSurveillanceCampaignRequestModel request);

        Task<List<GetHumanActiveSurveillanceCampaignDetailsResponseModel>> GetHumanActiveServiellanceDetailsCampaign(HumanActiveSurveillanceCampaignDetailsRequestModel request);

        Task<List<GetHumanActiveCampaignSampleToSampleTypeResponseModel>> GetHumanActiveCampaignSampleToSampleType(GetHumanActiveCampaignSampleToSampleTypeRequestModel request);

        Task<List<DeleteHumanActiveSurveillanceCampaignDetailsResponseModel>> DeleteActiveSurveillanceCampaignAsync(DeleteHumanActiveSurveillanceCampaignRequestModel request);
    }

    public partial class HumanActiveSurveillanceCampaignClient : BaseApiClient, IHumanActiveSurveillanceCampaignClient
    {
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;
      
        public HumanActiveSurveillanceCampaignClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
          ILogger<HumanActiveSurveillanceCampaignClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }


        public async Task<List<HumanActiveSurveillanceCampaignViewModel>> GetHumanActiveSurveillanceCampaignListAsync(HumanActiveSurveillanceCampaignRequestModel request)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.HumanActiveSurveillanceCampaignPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<HumanActiveSurveillanceCampaignViewModel>>(contentStream,
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
        /// Set Human Active Serveillance Campaign
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<SetHumanActiveSurveillanceCampaignResponseModel>> SetHumanActiveServiellanceCampaign(SetHumanActiveSurveillanceCampaignRequestModel request)
        {
            try
            {
                var sc = JsonSerializer.Serialize(request);
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url =  string.Format(_eidssApiOptions.SetHumanActiveSurveillanceCampaignPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<SetHumanActiveSurveillanceCampaignResponseModel>>(contentStream,
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
        /// Get Details of Human Active Serveillance Campaign Details By ID
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<GetHumanActiveSurveillanceCampaignDetailsResponseModel>> GetHumanActiveServiellanceDetailsCampaign(HumanActiveSurveillanceCampaignDetailsRequestModel request)
        {
            try
            {
                var sc = JsonSerializer.Serialize(request);
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url =  string.Format(_eidssApiOptions.GetHumanActiveSurveillanceCampaignDetailsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<GetHumanActiveSurveillanceCampaignDetailsResponseModel>>(contentStream,
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
        /// Deletes Human Active Surveillance Campaign
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<DeleteHumanActiveSurveillanceCampaignDetailsResponseModel>> DeleteActiveSurveillanceCampaignAsync(DeleteHumanActiveSurveillanceCampaignRequestModel request)
        {
            try
            {
                var sc = JsonSerializer.Serialize(request);
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteHumanActiveSurveillanceCampaignDetailsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<DeleteHumanActiveSurveillanceCampaignDetailsResponseModel>>(contentStream,
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

        public async Task<List<GetHumanActiveCampaignSampleToSampleTypeResponseModel>> GetHumanActiveCampaignSampleToSampleType(GetHumanActiveCampaignSampleToSampleTypeRequestModel request)
        {
            try
            {
                var sc = JsonSerializer.Serialize(request);
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetHumanActiveCampaignSampleToSampleTypePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<GetHumanActiveCampaignSampleToSampleTypeResponseModel>>(contentStream,
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
    }
}
