using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Human;
using Flurl;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Human
{
    public class PersonClient : BaseApiClient, IPersonClient
    {
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public PersonClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
            ILogger<PersonClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }

        public async Task<List<PersonViewModel>> GetPersonList(HumanPersonSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            var url = string.Format(_eidssApiOptions.GetPersonListPath, _eidssApiOptions.BaseUrl);
            return await PostAsync<HumanPersonSearchRequestModel, List<PersonViewModel>>(url, request);
        }

        public async Task<List<PersonForOfficeViewModel>> GetPersonListForOffice(GetPersonForOfficeRequestModel request)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetPersonListForOfficePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<PersonForOfficeViewModel>>(contentStream,
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
        public async Task<List<DiseaseReportPersonalInformationViewModel>> GetHumanDiseaseReportPersonInfoAsync(HumanPersonDetailsRequestModel request)
        {
            var url = string.Format(_eidssApiOptions.HumanDiseaseReportPersonInfoPath, _eidssApiOptions.BaseUrl);
            var result = await PostAsync<HumanPersonDetailsRequestModel, List<DiseaseReportPersonalInformationViewModel>>(url, request);
            return result;
        }

        public async Task<PersonSaveResponseModel> SavePerson(PersonSaveRequestModel request)
        {
            var url = string.Format(_eidssApiOptions.SavePersonPath, _eidssApiOptions.BaseUrl);
            var response = await PostAsync<PersonSaveRequestModel, PersonSaveResponseModel>(url, request);
            return response;
        }

        public async Task<APIPostResponseModel> DeletePerson(long HumanMasterID, long? idfDataAuditEvent, string AuditUserName)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeletePersonPath, _eidssApiOptions.BaseUrl, HumanMasterID, idfDataAuditEvent, AuditUserName);
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
                _logger.LogError(ex.Message, new object[] { HumanMasterID });
                throw;
            }
        }

        public async Task<APIPostResponseModel> DedupePersonFarm(PersonDedupeRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DedupePersonFarmPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
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
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
            finally
            {
            }
        }

        public async Task<APIPostResponseModel> DedupePersonHumanDisease(PersonDedupeRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DedupePersonHumanDiseasePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
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
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
            finally
            {
            }
        }

        public async Task<PersonSaveResponseModel> DedupePersonRecords(PersonRecordsDedupeRequestModel SaveRequest, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DedupePersonRecordsPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(SaveRequest), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<PersonSaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { SaveRequest });
                throw;
            }
        }

        public async Task<int> UpdatePersonAsync(UpdateHumanActualRequestModel request)
        {
            var path = string.Format(_eidssApiOptions.UpdatePersonAsyncPath);
            var url = Url.Combine(_eidssApiOptions.BaseUrl, path);

            return await PostAsync<UpdateHumanActualRequestModel, int>(url, request);
        }
    }
}
