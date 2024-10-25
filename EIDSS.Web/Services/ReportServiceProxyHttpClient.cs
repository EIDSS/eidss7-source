using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Security.Encryption;
using Microsoft.Extensions.Configuration;

namespace EIDSS.Web.Services;

public class ReportServiceProxyHttpClient : IReportServiceProxyHttpClient
{
    private readonly HttpClient _httpClient;

    public ReportServiceProxyHttpClient(IConfiguration configuration)
    {
        var protectedConfigSection = configuration.GetSection("ProtectedConfiguration");
        var protectedConfig = protectedConfigSection.Get<ProtectedConfigurationSettings>();

        _httpClient = CreateHttpClient(protectedConfig);
    }
        
    public Task<HttpResponseMessage> SendAsync(HttpRequestMessage proxyRequestMessage)
    {
        return _httpClient.SendAsync(proxyRequestMessage);
    }

    private HttpClient CreateHttpClient(ProtectedConfigurationSettings protectedConfig)
    {
        var httpClientHandler = new HttpClientHandler
        {
            UseDefaultCredentials = false
        };

        if (httpClientHandler.SupportsAutomaticDecompression)
        {
            httpClientHandler.AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate;
        }

        var userName = protectedConfig.SSRS_UserName.Decrypt();
        if (!string.IsNullOrEmpty(userName))
        {
            var domain = protectedConfig.SSRS_Domain.Decrypt();
            var password = protectedConfig.SSRS_Password.Decrypt();
            httpClientHandler.Credentials = new NetworkCredential(userName, password, domain);
        }

        var httpClient = new HttpClient(httpClientHandler);
        httpClient.DefaultRequestHeaders.ConnectionClose = false;
        return httpClient;
    }
}