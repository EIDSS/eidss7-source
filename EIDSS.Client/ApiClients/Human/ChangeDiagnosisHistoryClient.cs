using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ResponseModels.Human;
using Flurl;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Human;

public class ChangeDiagnosisHistoryClient(
    HttpClient httpClient,
    IOptions<EidssApiOptions> eidssApiOptions,
    ILogger<ChangeDiagnosisHistoryClient> logger,
    IUserConfigurationService userConfigService = null)
    : BaseApiClient(httpClient, eidssApiOptions, logger, userConfigService), IChangeDiagnosisHistoryClient
{
    public async Task<IEnumerable<ChangeDiagnosisHistoryResponseModel>> GetChangeDiagnosisHistoryAsync(long humanCaseId, string languageIsoCode)
    {
        var path = string.Format(_eidssApiOptions.GetChangeDiagnosisHistoryAsyncPath, humanCaseId, languageIsoCode);
        var url = Url.Combine(_eidssApiOptions.BaseUrl, path);

        return await GetAsync<IEnumerable<ChangeDiagnosisHistoryResponseModel>>(url);
    }
}
