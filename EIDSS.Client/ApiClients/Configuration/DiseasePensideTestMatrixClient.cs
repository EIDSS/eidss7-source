using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Configuration
{

    public partial interface IDiseasePensideTestMatrixClient
    {
        Task<List<DiseasePensideTestMatrixGetRequestResponseModel>> GetDiseasePensideTestMatrix(DiseasePensideTestMatrixGetRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class DiseasePensideTestMatrixClient : BaseApiClient, IDiseasePensideTestMatrixClient
    {
        public DiseasePensideTestMatrixClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<DiseasePensideTestMatrixClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<DiseasePensideTestMatrixGetRequestResponseModel>> GetDiseasePensideTestMatrix(DiseasePensideTestMatrixGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var _ = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetDiseasePensideTestMatrixPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, _, cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<DiseasePensideTestMatrixGetRequestResponseModel>>(contentStream, new JsonSerializerOptions
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
