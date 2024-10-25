using System.Net.Http;
using System.Threading.Tasks;

namespace EIDSS.Web.Services;

public interface IReportServiceProxyHttpClient
{
    Task<HttpResponseMessage> SendAsync(HttpRequestMessage proxyRequestMessage);
}