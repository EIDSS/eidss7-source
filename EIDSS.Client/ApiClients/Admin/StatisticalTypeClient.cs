using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ResponseModels;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using System.Threading;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{
    public partial interface IStatisticalTypeClient
    {
        Task<List<BaseReferenceEditorsViewModel>> GetStatisticalTypeList(StatisticalTypeGetRequestModel request);
        Task<APIPostResponseModel> SaveStatisticalType(StatisticalTypeSaveRequestModel statisticalTypeModel);
        Task<APIPostResponseModel> DeleteStatisticalType(StatisticalTypeSaveRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class StatisticalTypeClient : BaseApiClient, IStatisticalTypeClient
    {
        public StatisticalTypeClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<StatisticalTypeClient> logger)
    : base(httpClient, eidssApiOptions, logger)
        {
            
        }

        public async Task<List<BaseReferenceEditorsViewModel>> GetStatisticalTypeList(StatisticalTypeGetRequestModel request)
        {
            try
            {

                var sampleTypesViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetStatisticalTypeListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, sampleTypesViewModelJson);

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
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<APIPostResponseModel> SaveStatisticalType(StatisticalTypeSaveRequestModel statisticalTypeModel)
        {
            StatisticalTypeSaveRequestResponseModel errorResponse = null;
            try
            {
                var statisticalTypeViewModelJson = new StringContent(JsonSerializer.Serialize(statisticalTypeModel), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveStatisticalTypePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, statisticalTypeViewModelJson);

                if (!httpResponse.IsSuccessStatusCode)
                {
                    try
                    {
                        var errorStream = await httpResponse.Content.ReadAsStreamAsync();
                        errorResponse = await JsonSerializer.DeserializeAsync<StatisticalTypeSaveRequestResponseModel>(errorStream);
                    }
                    catch
                    {
                    }
                }

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
                _logger.LogError(ex.Message, statisticalTypeModel);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteStatisticalType(StatisticalTypeSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteStatisticalTypePath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestModelJson, cancellationToken);

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
    }
}
