using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Configuration
{
    public partial interface ITestNameTestResultsMatrixClient
    {
        public Task<List<TestNameTestResultsMatrixViewModel>> GetTestNameTestResultsMatrixList(TestNameTestResultsMatrixGetRequestModel request);
        public Task<TestNameTestResultsMatrixSaveRequestResponseModel> SaveTestNameTestResultsMatrix(TestNameTestResultsMatrixSaveRequestModel request);
        public Task<APIPostResponseModel> DeleteTestNameTestResultsMatrix(TestNameTestResultsMatrixSaveRequestModel request);
    }
    public partial class TestNameTestResultsMatrixClient : BaseApiClient , ITestNameTestResultsMatrixClient
    {
        ///api/Configuration/VectorTypeFieldTestMatrix/DeleteFieldTestMatrix
        ///#region Vector Type Field Test Matrix
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public TestNameTestResultsMatrixClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
        ILogger<TestNameTestResultsMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }
         
        public async Task<List<TestNameTestResultsMatrixViewModel>> GetTestNameTestResultsMatrixList(TestNameTestResultsMatrixGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetTestNameTestResultsMatrixListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<TestNameTestResultsMatrixViewModel>>(contentStream,
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
            finally
            {
            }
        }

        public async Task<TestNameTestResultsMatrixSaveRequestResponseModel> SaveTestNameTestResultsMatrix(TestNameTestResultsMatrixSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveTestNameTestResultsMatrixPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<TestNameTestResultsMatrixSaveRequestResponseModel>(contentStream,
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

        public async Task<APIPostResponseModel> DeleteTestNameTestResultsMatrix(TestNameTestResultsMatrixSaveRequestModel request)
        {
            var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.DeleteTestNameTestResultsMatrixPath, _eidssApiOptions.BaseUrl);

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
    }
}
