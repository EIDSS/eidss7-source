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
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Human
{
    public partial interface IWeeklyReportingFormClient
    {
        Task<List<ReportFormViewModel>> GetWeeklyReportingFormList(WeeklyReportingFormGetRequestModel request);
        Task<List<ReportFormDetailViewModel>> GetWeeklyReportingFormDetail(WeeklyReportingFormGetDetailRequestModel request);
        Task<WeeklyReportSaveResponseModel> SaveWeeklyReportingForm(WeeklyReportSaveRequestModel request);
        Task<APIPostResponseModel> DeleteWeeklyReport(long? idfReportForm, string auditUpdateUser);
    }

    public partial class WeeklyReportingFormClient : BaseApiClient, IWeeklyReportingFormClient
    {
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public WeeklyReportingFormClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
            ILogger<WeeklyReportingFormClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }

        public async Task<List<ReportFormViewModel>> GetWeeklyReportingFormList(WeeklyReportingFormGetRequestModel request)
        {
            try
            {
                var requestContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetWeeklyReportingFormListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ReportFormViewModel>>(contentStream,
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

        public async Task<List<ReportFormDetailViewModel>> GetWeeklyReportingFormDetail(WeeklyReportingFormGetDetailRequestModel request)
        {
            try
            {
                var requestContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetWeeklyReportingFormDetailPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ReportFormDetailViewModel>>(contentStream,
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

        public async Task<WeeklyReportSaveResponseModel> SaveWeeklyReportingForm(WeeklyReportSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveWeeklyReportingFormPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<WeeklyReportSaveResponseModel>(contentStream,
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

        public async Task<APIPostResponseModel> DeleteWeeklyReport(long? idfReportForm, string auditUpdateUser)
        {
            var url = string.Format(_eidssApiOptions.DeleteWeeklyReportingFormPath, _eidssApiOptions.BaseUrl, idfReportForm, auditUpdateUser);            
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
