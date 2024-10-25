using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{
    public partial interface IMeasuresClient
    {
        Task<List<BaseReferenceEditorsViewModel>> GetMeasuresList(MeasuresGetRequestModel measuresGetRequestModel);
        Task<List<BaseReferenceEditorsViewModel>> GetMeasuresDropDownList(string langId);
        Task<MeasuresSaveRequestResponseModel> SaveMeasure(MeasuresSaveRequestModel saveRequestModel);
        Task<APIPostResponseModel> DeleteMeasure(MeasuresSaveRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class MeasuresClient : BaseApiClient, IMeasuresClient
    {
        public MeasuresClient
            (HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<MeasuresClient> logger)
            : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<APIPostResponseModel> DeleteMeasure(MeasuresSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var saveBaseReferenceUrl = string.Format(_eidssApiOptions.DeleteMeasuresPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(saveBaseReferenceUrl, requestModelJson, cancellationToken);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                    new JsonSerializerOptions
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

        public async Task<List<BaseReferenceEditorsViewModel>> GetMeasuresDropDownList(string langId)
        {            
            try
            {
                var url = string.Format(_eidssApiOptions.GetMeasuresDropDownListPath, _eidssApiOptions.BaseUrl, langId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<BaseReferenceEditorsViewModel>>(contentStream,
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

        public async Task<List<BaseReferenceEditorsViewModel>> GetMeasuresList(MeasuresGetRequestModel measuresGetRequestModel)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetMeasuresListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(measuresGetRequestModel), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<BaseReferenceEditorsViewModel>>(contentStream,
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

        public async Task<MeasuresSaveRequestResponseModel> SaveMeasure(MeasuresSaveRequestModel saveRequestModel)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveMeasuresPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(saveRequestModel), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<MeasuresSaveRequestResponseModel>(contentStream,
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

            //return returnResult;     
        }
    }
}
