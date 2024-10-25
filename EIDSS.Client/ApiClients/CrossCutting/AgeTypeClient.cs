using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.CrossCutting;
using Flurl;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.CrossCutting
{
    public class AgeTypeClient : BaseApiClient, IAgeTypeClient
    {
        public AgeTypeClient(
            HttpClient httpClient,
            IOptions<EidssApiOptions> eidssApiOptions,
            ILogger<AgeTypeClient> logger,
            IUserConfigurationService userConfigService = null)
            : base(httpClient, eidssApiOptions, logger, userConfigService)
        {
        }

        public async Task<IEnumerable<AgeTypeResponseModel>> GetAgeTypesAsync(GetAgeTypesRequestModel request)
        {
            var path = string.Format(_eidssApiOptions.GetAgeTypesAsyncPath);
            var url = Url.Combine(_eidssApiOptions.BaseUrl, path);

            return await PostAsync<GetAgeTypesRequestModel, IEnumerable<AgeTypeResponseModel>>(url, request);
        }
    }
}
