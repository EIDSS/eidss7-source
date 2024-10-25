using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.ApiClients.Administration.Security;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration.Security;
using EIDSS.Domain.ViewModels.Administration.Security;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EIDSS.ClientLibrary.ApiClients.Admin.Security
{

    public partial interface IDataAuditClient
    {
        Task<List<DataAuditTransactionLogGetListViewModel>> GetTransactionLog(DataAuditLogGetRequestModel request, CancellationToken cancellationToken = default);
        Task<List<DataAuditTransactionLogGetDetailViewModel>> GetTransactionDetailRecords(long dataAuditEventId, string languageId, CancellationToken cancellationToken = default);
        Task<DataAuditRestoreResponseModel> Restore(AuditRestoreRequestModel request);
    }

    public partial class DataAuditClient: BaseApiClient, IDataAuditClient
    {

        protected internal EidssApiConfigurationOptions eidssApiConfigurationOptions;

        public DataAuditClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<DataAuditClient> logger, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions) : 
            base(httpClient, eidssApiOptions, logger)
        {
            this.eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;

        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<DataAuditTransactionLogGetListViewModel>> GetTransactionLog(DataAuditLogGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetDataAuditTransLogPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<DataAuditTransactionLogGetListViewModel>>(contentStream,
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="dataAuditEventId"></param>
        /// <param name="languageId"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<DataAuditTransactionLogGetDetailViewModel>> GetTransactionDetailRecords(long dataAuditEventId, string languageId, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetDataAuditTransLogDetailPath, _eidssApiOptions.BaseUrl, languageId, dataAuditEventId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url), cancellationToken);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                var response = await JsonSerializer.DeserializeAsync<List<DataAuditTransactionLogGetDetailViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    }, cancellationToken);

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { dataAuditEventId, languageId });
                throw;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<DataAuditRestoreResponseModel> Restore(AuditRestoreRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DataAuditRestorePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<DataAuditRestoreResponseModel>(contentStream,
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

    }
}
