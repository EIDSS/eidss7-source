using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Configuration
{
    public partial interface IPersonalIdentificationTypeMatrixClient
    {
        Task<List<PersonalIdentificationTypeMatrixViewModel>> GetPersonalIdentificationTypeMatrixList(PersonalIdentificationTypeMatrixGetRequestModel request);
        Task<APIPostResponseModel> DeletePersonalIdentificationTypeMatrix(PersonalIdentificationTypeMatrixSaveRequestModel request);
        Task<APISaveResponseModel> SavePersonalIdentificationTypeMatrix(PersonalIdentificationTypeMatrixSaveRequestModel request);
    }

    public partial class PersonalIdentificationTypeMatrixClient : BaseApiClient, IPersonalIdentificationTypeMatrixClient
    {
        public PersonalIdentificationTypeMatrixClient(HttpClient httpClient,
            IOptionsSnapshot<EidssApiOptions> eidssApiOptions,
            ILogger<PersonalIdentificationTypeMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<APIPostResponseModel> DeletePersonalIdentificationTypeMatrix(PersonalIdentificationTypeMatrixSaveRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeletePersonalIdentificationTypeMatrixPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

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
            catch(Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<PersonalIdentificationTypeMatrixViewModel>> GetPersonalIdentificationTypeMatrixList(PersonalIdentificationTypeMatrixGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetPersonalIdentificationTypeMatrixListPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<PersonalIdentificationTypeMatrixViewModel>>(contentStream,
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

        public async Task<APISaveResponseModel> SavePersonalIdentificationTypeMatrix(PersonalIdentificationTypeMatrixSaveRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SavePersonalIdentificationTypeMatrixPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch(Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }
    }
}
