using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using Flurl;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Net.Http;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Human
{
    public class PersonalIDClient : BaseApiClient, IPersonalIDClient
    {
        public PersonalIDClient(
            HttpClient httpClient,
            IOptions<EidssApiOptions> eidssApiOptions,
            ILogger<PersonalIDClient> logger,
            IUserConfigurationService userConfigService = null)
            : base(httpClient, eidssApiOptions, logger, userConfigService)
        {
        }

        public async Task<bool> IsPersonalIDExistsAsync(string personalID, long? humanActualId)
        {
            if (string.IsNullOrEmpty(personalID))
            {
                return false;
            }

            var path = string.Format(_eidssApiOptions.IsPersonalIDExistsAsyncPath, personalID, humanActualId);
            var url = Url.Combine(_eidssApiOptions.BaseUrl, path);

            return await GetAsync<bool>(url);
        }
    }
}
