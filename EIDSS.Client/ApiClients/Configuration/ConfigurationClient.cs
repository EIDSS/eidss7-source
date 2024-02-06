using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
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
    public partial interface IConfigurationClient
    {
        Task<List<AggregateSettingsModel>> GetAggregateSettings(AggregateSettingsGetRequestModel request);
        Task<List<ConfigurationMatrixViewModel>> GetSpeciesAnimalAgeList(SpeciesAnimalAgeGetRequestModel request);
        Task<APISaveResponseModel> SaveSpeciesAnimalAge(SpeciesAnimalAgeSaveRequestModel request);
        Task<APIPostResponseModel> DeleteSpeciesAnimalAge(SpeciesAnimalAgeSaveRequestModel request);
        Task<List<ConfigurationMatrixViewModel>> GetSampleTypeDerivativeMatrixList(SampleTypeDerivativeMatrixGetRequestModel request);
        Task<APISaveResponseModel> SaveSampleTypeDerivativeMatrix(SampleTypeDerivativeMatrixSaveRequestModel request);        
        Task<APIPostResponseModel> DeleteSampleTypeDerivativeMatrix(SampleTypeDerivativeMatrixSaveRequestModel request);

        Task<List<ConfigurationMatrixViewModel>> GetCustomReportRowsMatrixList(CustomReportRowsMatrixGetRequestModel request);
        Task<APISaveResponseModel> SaveCustomReportRowsMatrix(CustomReportRowsMatrixSaveRequestModel request);
        Task<APISaveResponseModel> SaveCustomReportRowsOrder(CustomReportRowsRowOrderSaveRequestModel request);
        Task<APIPostResponseModel> DeleteCustomReportRowsMatrix(CustomReportRowsMatrixSaveRequestModel request);

        Task<List<ConfigurationMatrixViewModel>> GetDiseaseGroupDiseaseMatrixList(DiseaseGroupDiseaseMatrixGetRequestModel request);
        Task<APISaveResponseModel> SaveDiseaseGroupDiseaseMatrix(DiseaseGroupDiseaseMatrixSaveRequestModel request);
        Task<APIPostResponseModel> DeleteDiseaseGroupDiseaseMatrix(DiseaseGroupDiseaseMatrixSaveRequestModel request);

        //statistical age group interface
        public Task<List<StatisticalAgeGroupMatrixViewModel>> GetStatisticalAgeGroupMatrixList(StatisticalAgeGroupMatrixGetRequestModel request);
        public Task<StatisticalAgeGroupMatrixSaveRequestResponseModel> SaveStatisticalAgeGroupMatrix(StatisticalAgeGroupMatrixSaveRequestModel request);
        public Task<APIPostResponseModel> DeleteStatisticalAgeGroupMatrix(StatisticalAgeGroupMatrixSaveRequestModel request);

        //parameter type editor interface
        public Task<List<ParameterTypeViewModel>> GetParameterTypeList(ParameterTypeGetRequestModel request);
        public Task<ParameterTypeSaveRequestResponseModel> SaveParameterType(ParameterTypeSaveRequestModel request);
        public Task<APIPostResponseModel> DeleteParameterType(long? idfsParameterType, string user, bool? deleteAnyway, string langId);
        public Task<List<ParameterFixedPresetValueViewModel>> GetParameterFixedPresetValueList(ParameterFixedPresetValueGetRequestModel request);
        public Task<List<ParameterReferenceValueViewModel>> GetParameterReferenceValueList(ParameterReferenceValueGetRequestModel request);
        public Task<List<ParameterReferenceViewModel>> GetParameterReferenceList(ParameterReferenceGetRequestModel request);
        public Task<APIPostResponseModel> DeleteParameterFixedPresetValue(long idfsParameterFixedPresetValue, bool? deleteAnyway);
        public Task<ParameterFixedPresetValueSaveRequestResponseModel> SaveParameterFixedPresetValue(ParameterFixedPresetValueSaveRequestModel request);

        //SampleType Disease

        public Task<List<DiseaseSampleTypeByDiseaseResponseModel>> GetDiseaseSampleTypeByDiseasePaged(DiseaseSampleTypeByDiseaseRequestModel request);

        //GRID Configuration
        Task<List<USP_CONF_USER_GRIDS_SETResponseModel>> SetUserGridConfiguration(USP_CONF_USER_GRIDS_SETRequestModel request);
        List<USP_CONF_USER_GRIDS_GETDETAILResponseModel> GetUserGridConfiguration(USP_CONF_USER_GRIDS_GETDETAILRequestModel request);
    }

    public partial class ConfigurationClient : BaseApiClient, IConfigurationClient
    {
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public ConfigurationClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
            ILogger<ConfigurationClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }

        public async Task<List<AggregateSettingsModel>> GetAggregateSettings(AggregateSettingsGetRequestModel request)
        {
            var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiConfigurationOptions.GetAggregateSettingsPath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(url, viewModelJson);


            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<List<AggregateSettingsModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            return response;
        }

        public async Task<List<ConfigurationMatrixViewModel>> GetSpeciesAnimalAgeList(SpeciesAnimalAgeGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetSpeciesAnimalAgeListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ConfigurationMatrixViewModel>>(contentStream,
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

        public async Task<APISaveResponseModel> SaveSpeciesAnimalAge(SpeciesAnimalAgeSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var saveSampleTypeUrl = string.Format(_eidssApiOptions.SaveSpeciesAnimalAgePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(saveSampleTypeUrl, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteSpeciesAnimalAge(SpeciesAnimalAgeSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteSpeciesAnimalAgePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

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
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<List<ConfigurationMatrixViewModel>> GetSampleTypeDerivativeMatrixList(SampleTypeDerivativeMatrixGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetSampleTypeDerivativeMatrixListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ConfigurationMatrixViewModel>>(contentStream,
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

        public async Task<APISaveResponseModel> SaveSampleTypeDerivativeMatrix(SampleTypeDerivativeMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveSampleTypeDerivativeMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteSampleTypeDerivativeMatrix(SampleTypeDerivativeMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteSampleTypeDerivativeMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

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
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<List<ConfigurationMatrixViewModel>> GetCustomReportRowsMatrixList(CustomReportRowsMatrixGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetCustomReportRowsMatrixListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ConfigurationMatrixViewModel>>(contentStream,
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

        public async Task<APISaveResponseModel> SaveCustomReportRowsMatrix(CustomReportRowsMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveCustomReportRowsMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<APISaveResponseModel> SaveCustomReportRowsOrder(CustomReportRowsRowOrderSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveCustomReportRowsOrderPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteCustomReportRowsMatrix(CustomReportRowsMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteCustomReportRowsMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
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
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<ConfigurationMatrixViewModel>> GetDiseaseGroupDiseaseMatrixList(DiseaseGroupDiseaseMatrixGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDiseaseGroupDiseaseMatrixListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ConfigurationMatrixViewModel>>(contentStream,
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

        public async Task<APISaveResponseModel> SaveDiseaseGroupDiseaseMatrix(DiseaseGroupDiseaseMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveDiseaseGroupDiseaseMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteDiseaseGroupDiseaseMatrix(DiseaseGroupDiseaseMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteDiseaseGroupDiseaseMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

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
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<List<StatisticalAgeGroupMatrixViewModel>> GetStatisticalAgeGroupMatrixList(StatisticalAgeGroupMatrixGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetStatisticalAgeGroupMatrixListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<StatisticalAgeGroupMatrixViewModel>>(contentStream,
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

        public async Task<StatisticalAgeGroupMatrixSaveRequestResponseModel> SaveStatisticalAgeGroupMatrix(
            StatisticalAgeGroupMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson =
                    new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveStatisticalAgeGroupMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<StatisticalAgeGroupMatrixSaveRequestResponseModel>(
                    contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteStatisticalAgeGroupMatrix(StatisticalAgeGroupMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteStatisticalAgeGroupMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<StatisticalAgeGroupMatrixSaveRequestResponseModel>(contentStream,
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

        public async Task<List<ParameterTypeViewModel>> GetParameterTypeList(ParameterTypeGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetParameterTypeEditorListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ParameterTypeViewModel>>(contentStream,
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
        public async Task<ParameterTypeSaveRequestResponseModel> SaveParameterType(ParameterTypeSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveParameterTypeEditorPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ParameterTypeSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }


        }

        public async Task<APIPostResponseModel> DeleteParameterType(long? idfsParameterType, string user, bool? deleteAnyway, string langId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteParameterTypeEditorPath, _eidssApiOptions.BaseUrl, idfsParameterType, user, deleteAnyway, langId);
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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;

            }
        }

        public async Task<List<ParameterFixedPresetValueViewModel>> GetParameterFixedPresetValueList(ParameterFixedPresetValueGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetParameterFixedPresetValueListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ParameterFixedPresetValueViewModel>>(contentStream,
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

        public async Task<List<ParameterReferenceValueViewModel>> GetParameterReferenceValueList(ParameterReferenceValueGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetParameterReferenceValueListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ParameterReferenceValueViewModel>>(contentStream,
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

        public async Task<List<ParameterReferenceViewModel>> GetParameterReferenceList(ParameterReferenceGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetParameterReferenceListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ParameterReferenceViewModel>>(contentStream,
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

        public async Task<APIPostResponseModel> DeleteParameterFixedPresetValue(long idfsParameterFixedPresetValue, bool? deleteAnyway)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteParameterFixedPresetValuePath, _eidssApiOptions.BaseUrl, idfsParameterFixedPresetValue, deleteAnyway);
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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }


        }

        public async Task<ParameterFixedPresetValueSaveRequestResponseModel> SaveParameterFixedPresetValue(ParameterFixedPresetValueSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveParameterFixedPresetValuePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ParameterFixedPresetValueSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
        }

        public async Task<List<DiseaseSampleTypeByDiseaseResponseModel>> GetDiseaseSampleTypeByDiseasePaged(DiseaseSampleTypeByDiseaseRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDiseaseSampleTypeByDiseasePagedPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<DiseaseSampleTypeByDiseaseResponseModel>>(contentStream,
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

        public List<USP_CONF_USER_GRIDS_GETDETAILResponseModel> GetUserGridConfiguration(USP_CONF_USER_GRIDS_GETDETAILRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetUserGridConfigurationPath, _eidssApiOptions.BaseUrl);

                var httpResponse =  _httpClient.PostAsync(url, viewModelJson).Result;

                httpResponse.EnsureSuccessStatusCode();
                var contentByteArray =  httpResponse.Content.ReadAsByteArrayAsync().Result;

                var response =  JsonSerializer.Deserialize<List<USP_CONF_USER_GRIDS_GETDETAILResponseModel>>(contentByteArray,
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
        public async Task<List<USP_CONF_USER_GRIDS_SETResponseModel>> SetUserGridConfiguration(USP_CONF_USER_GRIDS_SETRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetUserGridConfigurationPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<USP_CONF_USER_GRIDS_SETResponseModel>>(contentStream,
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