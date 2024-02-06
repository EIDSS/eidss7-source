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
    public partial interface ISpeciesTypeClient
    {
        Task<List<BaseReferenceEditorsViewModel>> GetSpeciesTypeList(SpeciesTypeGetRequestModel request);
        Task<SpeciesTypeSaveRequestResponseModel> SaveSpeciesType(SpeciesTypeSaveRequestModel speciesTypeModel);
        Task<APIPostResponseModel> DeleteSpeciesType(SpeciesTypeSaveRequestModel request, CancellationToken cancellationToken = default);
        Task<List<HACodeListViewModel>> GetHACodeList(string langId, int? intHACodeMask);
    }

    public partial class SpeciesTypeClient : BaseApiClient, ISpeciesTypeClient
    {
        public SpeciesTypeClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<SpeciesTypeClient> logger)
    : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<BaseReferenceEditorsViewModel>> GetSpeciesTypeList(SpeciesTypeGetRequestModel request)
        {
            try
            {
                
                var sampleTypesViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetSpeciesTypeListPath, _eidssApiOptions.BaseUrl);

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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<SpeciesTypeSaveRequestResponseModel> SaveSpeciesType(SpeciesTypeSaveRequestModel speciesTypeModel)
        {
            SpeciesTypeSaveRequestResponseModel errorResponse = null;
            try
            {
                var speciesTypeViewModelJson = new StringContent(JsonSerializer.Serialize(speciesTypeModel), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveSpeciesTypePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, speciesTypeViewModelJson);

                if (!httpResponse.IsSuccessStatusCode)
                {
                    try
                    {
                        var errorStream = await httpResponse.Content.ReadAsStreamAsync();
                        errorResponse = await JsonSerializer.DeserializeAsync<SpeciesTypeSaveRequestResponseModel>(errorStream);
                    }
                    catch
                    {
                    }
                }

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<SpeciesTypeSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, speciesTypeModel);
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteSpeciesType(SpeciesTypeSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteSpeciesTypePath, _eidssApiOptions.BaseUrl);
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

        public async Task<List<HACodeListViewModel>> GetHACodeList(string langId, int? intHACodeMask)
        {
            var url = string.Format(_eidssApiOptions.GetHACodeListPath, _eidssApiOptions.BaseUrl, langId, intHACodeMask);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<List<HACodeListViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            return response;
        }
    }
}
