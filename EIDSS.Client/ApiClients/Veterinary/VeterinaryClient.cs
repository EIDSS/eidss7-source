using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Veterinary;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Veterinary
{
    public partial interface IVeterinaryClient
    {
        Task<APIPostResponseModel> DeleteDiseaseReport(long diseaseReportID, bool deduplicationIndicator, long? dataAuditEventTypeID, string auditUserName);

        Task<APIPostResponseModel> DeleteFarmMaster(long farmMasterID, bool deduplicationIndicator, string auditUserName);

        Task<List<VeterinaryActiveSurveillanceSessionActionsViewModel>> GetActiveSurveillanceSessionActionsListAsync(VeterinaryActiveSurveillanceSessionActionsRequestModel request, CancellationToken cancellationToken = default);

        Task<List<VeterinaryActiveSurveillanceSessionAggregateViewModel>> GetActiveSurveillanceSessionAggregateInfoListAsync(VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel request, CancellationToken cancellationToken = default);

        Task<List<VeterinaryActiveSurveillanceSessionAggregateDiseaseViewModel>> GetActiveSurveillanceSessionAggregateDiseaseListAsync(VeterinaryActiveSurveillanceSessionAggregateNonPagedRequestModel request, CancellationToken cancellationToken = default);

        Task<List<VeterinaryActiveSurveillanceSessionDetailViewModel>> GetActiveSurveillanceSessionDetailAsync(VeterinaryActiveSurveillanceSessionDetailRequestModel request, CancellationToken cancellationToken = default);

        Task<List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel>> GetActiveSurveillanceSessionDiseaseSpeciesListAsync(VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel request, CancellationToken cancellationToken = default);

        Task<List<VeterinaryActiveSurveillanceSessionViewModel>> GetActiveSurveillanceSessionListAsync(VeterinaryActiveSurveillanceSessionSearchRequestModel request, CancellationToken cancellationToken = default);

        Task<List<SampleGetListViewModel>> GetActiveSurveillanceSessionSamplesListAsync(SampleGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<LaboratoryTestGetListViewModel>> GetActiveSurveillanceSessionTestsListAsync(LaboratoryTestGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<SampleToDiseaseGetListViewModel>> GetActiveSurveillanceSessionSampleDiseaseListAsync(VeterinaryActiveSurveillanceSessionSampleDiseaseRequestModel request, CancellationToken cancellationToken = default);

        Task<List<AnimalGetListViewModel>> GetAnimalList(AnimalGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<CaseLogGetListViewModel>> GetCaseLogList(CaseLogGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<DiseaseReportGetDetailViewModel>> GetDiseaseReportDetail(DiseaseReportGetDetailRequestModel request, CancellationToken cancellationToken = default);

        Task<List<FarmGetListDetailViewModel>> GetFarmDetail(FarmGetListDetailRequestModel request);

        Task<List<FarmInventoryGetListViewModel>> GetFarmInventoryList(FarmInventoryGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<FarmViewModel>> GetFarmListAsync(FarmSearchRequestModel request, CancellationToken cancellationToken = default);

        Task<List<FarmMasterGetDetailViewModel>> GetFarmMasterDetail(FarmMasterGetDetailRequestModel request);

        Task<List<FarmViewModel>> GetFarmMasterListAsync(FarmMasterSearchRequestModel request, CancellationToken cancellationToken = default);

        Task<List<SampleGetListViewModel>> GetImportSampleList(ImportSampleGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<LaboratoryTestInterpretationGetListViewModel>> GetLaboratoryTestInterpretationList(LaboratoryTestInterpretationGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<LaboratoryTestGetListViewModel>> GetLaboratoryTestList(LaboratoryTestGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<PensideTestGetListViewModel>> GetPensideTestList(PensideTestGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<SampleGetListViewModel>> GetSampleList(SampleGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<VaccinationGetListViewModel>> GetVaccinationList(VaccinationGetListRequestModel request, CancellationToken cancellationToken = default);

        Task<List<VeterinaryDiseaseReportViewModel>> GetVeterinaryDiseaseReportListAsync(VeterinaryDiseaseReportSearchRequestModel request, CancellationToken cancellationToken = default);

        Task<DiseaseReportSaveRequestResponseModel> SaveDiseaseReport(DiseaseReportSaveRequestModel request, CancellationToken cancellationToken = default);

        Task<FarmSaveRequestResponseModel> SaveFarm(FarmSaveRequestModel request);

        Task<VeterinaryActiveSurveillanceSessionSaveRequestResponseModel> SaveVeterinaryActiveSurveillanceSession(VeterinaryActiveSurveillanceSessionSaveRequestModel request, CancellationToken cancellationToken = default);

        Task<FarmDedupeResponseModel> DedupeFarmRecords(FarmDedupeRequestModel request, CancellationToken cancellationToken = default);

        Task<VeterinaryDiseaseReportDedupeResponseModel> DedupeVeterinaryDiseaseReportRecords(VeterinaryDiseaseReportDedupeRequestModel request, CancellationToken cancellationToken = default);

        Task<APIPostResponseModel> DeleteActiveSurveillanceSessionAsync(string LanguageID, long MonitoringSessionID, CancellationToken cancellationToken = default);
    }

    public partial class VeterinaryClient : BaseApiClient, IVeterinaryClient
    {
        public VeterinaryClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<VeterinaryClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="diseaseReportID"></param>
        /// <param name="deduplicationIndicator"></param>
        /// <param name="dataAuditEventTypeID"></param>
        /// <param name="auditUserName"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> DeleteDiseaseReport(long diseaseReportID, bool deduplicationIndicator, long? dataAuditEventTypeID, string auditUserName)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteVeterinaryDiseaseReportPath, _eidssApiOptions.BaseUrl, diseaseReportID, deduplicationIndicator, dataAuditEventTypeID, auditUserName);
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

        public async Task<APIPostResponseModel> DeleteFarmMaster(long farmMasterID, bool deduplicationIndicator, string auditUserName)
        {
            var url = string.Format(_eidssApiOptions.DeleteFarmPath, _eidssApiOptions.BaseUrl, farmMasterID, deduplicationIndicator, auditUserName);

            try
            {
                var request = new HttpRequestMessage(HttpMethod.Delete, url);
                request.Headers.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));
                var httpResponse = await _httpClient.SendAsync(request);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await System.Text.Json.JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<VeterinaryActiveSurveillanceSessionActionsViewModel>> GetActiveSurveillanceSessionActionsListAsync(VeterinaryActiveSurveillanceSessionActionsRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryActiveSurveillanceSessionActionsListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<VeterinaryActiveSurveillanceSessionActionsViewModel>>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<VeterinaryActiveSurveillanceSessionAggregateViewModel>> GetActiveSurveillanceSessionAggregateInfoListAsync(VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryActiveSurveillanceSessionAggregateInfoListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<VeterinaryActiveSurveillanceSessionAggregateViewModel>>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<VeterinaryActiveSurveillanceSessionAggregateDiseaseViewModel>> GetActiveSurveillanceSessionAggregateDiseaseListAsync(VeterinaryActiveSurveillanceSessionAggregateNonPagedRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryActiveSurveillanceSessionAggregateDiseaseListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<VeterinaryActiveSurveillanceSessionAggregateDiseaseViewModel>>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<VeterinaryActiveSurveillanceSessionDetailViewModel>> GetActiveSurveillanceSessionDetailAsync(VeterinaryActiveSurveillanceSessionDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryActiveSurveillanceSessionDetailAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<VeterinaryActiveSurveillanceSessionDetailViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel>> GetActiveSurveillanceSessionDiseaseSpeciesListAsync(VeterinaryActiveSurveillanceSessionNonPagedDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryActiveSurveillanceSessionDiseaseSpeciesListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel>>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<VeterinaryActiveSurveillanceSessionViewModel>> GetActiveSurveillanceSessionListAsync(VeterinaryActiveSurveillanceSessionSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryActiveSurveillanceSessionListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<VeterinaryActiveSurveillanceSessionViewModel>>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<SampleGetListViewModel>> GetActiveSurveillanceSessionSamplesListAsync(SampleGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryActiveSurveillanceSessionSamplesListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<SampleGetListViewModel>>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<LaboratoryTestGetListViewModel>> GetActiveSurveillanceSessionTestsListAsync(LaboratoryTestGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryActiveSurveillanceSessionTestsListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<LaboratoryTestGetListViewModel>>(contentStream,
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

        public async Task<List<SampleToDiseaseGetListViewModel>> GetActiveSurveillanceSessionSampleDiseaseListAsync(
                VeterinaryActiveSurveillanceSessionSampleDiseaseRequestModel request,
                CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetVeterinaryActiveSurveillanceSessionSampleDiseaseListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<SampleToDiseaseGetListViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
         
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<AnimalGetListViewModel>> GetAnimalList(AnimalGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportAnimalListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<AnimalGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<CaseLogGetListViewModel>> GetCaseLogList(CaseLogGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportCaseLogListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<CaseLogGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<DiseaseReportGetDetailViewModel>> GetDiseaseReportDetail(DiseaseReportGetDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportDetailPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<DiseaseReportGetDetailViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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

        public async Task<List<FarmGetListDetailViewModel>> GetFarmDetail(FarmGetListDetailRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFarmDetailPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await System.Text.Json.JsonSerializer.DeserializeAsync<List<FarmGetListDetailViewModel>>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<FarmInventoryGetListViewModel>> GetFarmInventoryList(FarmInventoryGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportFarmInventoryListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<FarmInventoryGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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

        public async Task<List<FarmViewModel>> GetFarmListAsync(FarmSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetFarmListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<FarmViewModel>>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<FarmMasterGetDetailViewModel>> GetFarmMasterDetail(FarmMasterGetDetailRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFarmMasterDetailPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<FarmMasterGetDetailViewModel>>(contentStream,
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

        public async Task<List<FarmViewModel>> GetFarmMasterListAsync(FarmMasterSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetFarmMasterListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<FarmViewModel>>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<SampleGetListViewModel>> GetImportSampleList(ImportSampleGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportImportSampleListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<SampleGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<LaboratoryTestInterpretationGetListViewModel>> GetLaboratoryTestInterpretationList(LaboratoryTestInterpretationGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportLaboratoryTestInterpretationListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<LaboratoryTestInterpretationGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<LaboratoryTestGetListViewModel>> GetLaboratoryTestList(LaboratoryTestGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportLaboratoryTestListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<LaboratoryTestGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<PensideTestGetListViewModel>> GetPensideTestList(PensideTestGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportPensideTestListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<PensideTestGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<SampleGetListViewModel>> GetSampleList(SampleGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportSampleListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<SampleGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<VaccinationGetListViewModel>> GetVaccinationList(VaccinationGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportVaccinationListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<VaccinationGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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

        public async Task<List<VeterinaryDiseaseReportViewModel>> GetVeterinaryDiseaseReportListAsync(VeterinaryDiseaseReportSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseReportListAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                return await JsonSerializer.DeserializeAsync<List<VeterinaryDiseaseReportViewModel>>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<DiseaseReportSaveRequestResponseModel> SaveDiseaseReport(DiseaseReportSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveVeterinaryDiseaseReportPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<DiseaseReportSaveRequestResponseModel>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<FarmSaveRequestResponseModel> SaveFarm(FarmSaveRequestModel SaveRequest)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveFarmPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(SaveRequest), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<FarmSaveRequestResponseModel>(contentStream,
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

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<VeterinaryActiveSurveillanceSessionSaveRequestResponseModel> SaveVeterinaryActiveSurveillanceSession(VeterinaryActiveSurveillanceSessionSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.SaveActiveSurveillanceSessionPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<VeterinaryActiveSurveillanceSessionSaveRequestResponseModel>(contentStream,
                   new JsonSerializerOptions
                   {
                       IgnoreNullValues = true,
                       PropertyNameCaseInsensitive = true
                   }, cancellationToken);
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

        public async Task<FarmDedupeResponseModel> DedupeFarmRecords(FarmDedupeRequestModel SaveRequest, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DedupeFarmPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(SaveRequest), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<FarmDedupeResponseModel>(contentStream,
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

        public async Task<VeterinaryDiseaseReportDedupeResponseModel> DedupeVeterinaryDiseaseReportRecords(VeterinaryDiseaseReportDedupeRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DedupeVeterinaryDiseaseReportPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<VeterinaryDiseaseReportDedupeResponseModel>(contentStream,
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
        }

        public async Task<APIPostResponseModel> DeleteActiveSurveillanceSessionAsync(string LanguageID, long MonitoringSessionID, CancellationToken cancellationToken = default)
        {
            var url = string.Format(_eidssApiOptions.VetActiveSurveillanceSessionDeletePath, _eidssApiOptions.BaseUrl, LanguageID, MonitoringSessionID);
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
    }
}