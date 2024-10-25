using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Services;
using EIDSS.Web.Abstracts;
using EIDSS.Web.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EIDSS.Web.Controllers
{
    public class ReportController(
        IConfiguration configuration,
        IReportServiceProxyHttpClient httpClient,
        ILogger<ReportController> logger,
        ITokenService tokenService)
        : BaseController(logger, tokenService)
    {
        private readonly string _reportServerUrl = configuration.GetValue<string>("ReportServer:Url");

        [HttpGet("/__ssrsreport")]
        public async Task Get([FromQuery] Dictionary<string, string> parameters)
        {
            parameters.TryGetValue("reportName", out var reportName);
            if (!string.IsNullOrEmpty(reportName))
            {
                var parametersUrl = string.Join("&", parameters.Keys
                    .Where(x => x != "reportName")
                    .Select(key => $"{key}={parameters[key]}"));
                    
                var url = $"{_reportServerUrl}/Pages/ReportViewer.aspx?/{reportName}&rs:Command=Render&rc:Parameters=false&rs:Embed=true&{parametersUrl}";

                var responseMessage = await ForwardRequest(Request, url);

                CopyResponseHeaders(responseMessage, Response);

                await WriteResponse(Request, url, responseMessage, Response, true);
            }
        }

        [Route("/ssrsproxy/{*rest}")]
        public async Task Proxy()
        {
            var urlToReplace = $"{Request.Scheme}://{Request.Host.Value}{Request.PathBase}/ssrsproxy";
            var requestedUrl = Request.GetDisplayUrl().Replace(urlToReplace, "", StringComparison.InvariantCultureIgnoreCase);

            var reportServerUrl = _reportServerUrl.Replace("/ReportServer", "");
            var url = $"{reportServerUrl}{requestedUrl}";

            var responseMessage = await ForwardRequest(Request, url);

            CopyResponseHeaders(responseMessage, Response);

            if (Request.Method == "POST")
            {
                await WriteResponse(Request, url, responseMessage, Response, true);
            }
            else if (responseMessage.Content.Headers.ContentType is { MediaType: "text/html" })
            {
                await WriteResponse(Request, url, responseMessage, Response, false);
            }
            else
            {
                await using var responseStream = await responseMessage.Content.ReadAsStreamAsync();
                await responseStream.CopyToAsync(Response.Body, 81920, HttpContext.RequestAborted);
            }
        }

        private async Task<HttpResponseMessage> ForwardRequest(HttpRequest currentRequest, string url)
        {
            var proxyRequestMessage = new HttpRequestMessage(new HttpMethod(currentRequest.Method), url);

            foreach (var header in currentRequest.Headers)
            {
                if (header.Key != "Host")
                {
                    proxyRequestMessage.Headers.TryAddWithoutValidation(header.Key, new string[] { header.Value });
                }
            }

            proxyRequestMessage.Headers.Add("Connection", "keep-alive");

            if (currentRequest.Method != "POST") return await httpClient.SendAsync(proxyRequestMessage);
            using var stream = new MemoryStream();
            await currentRequest.Body.CopyToAsync(stream);
            stream.Position = 0;

            var body = await new StreamReader(stream).ReadToEndAsync();
            proxyRequestMessage.Content = new StringContent(body);

            if (body.IndexOf("AjaxScriptManager", StringComparison.Ordinal) == -1)
                return await httpClient.SendAsync(proxyRequestMessage);
            proxyRequestMessage.Content.Headers.Remove("Content-Type");
            proxyRequestMessage.Content.Headers.Add("Content-Type", new[] { currentRequest.ContentType });

            return await httpClient.SendAsync(proxyRequestMessage);
        }

        private static void CopyResponseHeaders(HttpResponseMessage responseMessage, HttpResponse response)
        {
            response.StatusCode = (int)responseMessage.StatusCode;
            foreach (var header in responseMessage.Headers)
            {
                response.Headers[header.Key] = header.Value.ToArray();
            }

            foreach (var header in responseMessage.Content.Headers)
            {
                response.Headers[header.Key] = header.Value.ToArray();
            }

            response.Headers.Remove("transfer-encoding");
        }

        private static async Task WriteResponse(HttpRequest currentRequest, string url, HttpResponseMessage responseMessage, HttpResponse response, bool isAjax)
        {
            var result = await responseMessage.Content.ReadAsStringAsync();

            var reportServer = url.Contains("/ReportServer/", StringComparison.InvariantCultureIgnoreCase) ? "ReportServer" : "Reports";

            var proxyUrl = $"{currentRequest.Scheme}://{currentRequest.Host.Value}{currentRequest.PathBase}/ssrsproxy";

            if (isAjax && result.IndexOf("|", StringComparison.Ordinal) != -1 && !result.StartsWith("<!DOCTYPE html>", StringComparison.InvariantCultureIgnoreCase))
            {
                var builder = new StringBuilder();

                var index = 0;

                while (index < result.Length)
                {
                    var delimiterIndex = result.IndexOf("|", index, StringComparison.Ordinal);
                    if (delimiterIndex == -1)
                    {
                        break;
                    }

                    if (!int.TryParse(result.Substring(index, delimiterIndex - index), out var length))
                    {
                        break;
                    }

                    if ((length % 1) != 0)
                    {
                        break;
                    }
                    index = delimiterIndex + 1;
                    delimiterIndex = result.IndexOf("|", index, StringComparison.Ordinal);
                    if (delimiterIndex == -1)
                    {
                        break;
                    }
                    var type = result.Substring(index, delimiterIndex - index);
                    index = delimiterIndex + 1;
                    delimiterIndex = result.IndexOf("|", index, StringComparison.Ordinal);
                    if (delimiterIndex == -1)
                    {
                        break;
                    }
                    var id = result.Substring(index, delimiterIndex - index);
                    index = delimiterIndex + 1;
                    if ((index + length) >= result.Length)
                    {
                        break;
                    }
                    var content = result.Substring(index, length);
                    index += length;
                    if (result.Substring(index, 1) != "|")
                    {
                        break;
                    }
                    index++;

                    content = content.Replace($"/{reportServer}/", $"{proxyUrl}/{reportServer}/", StringComparison.InvariantCultureIgnoreCase);
                    content = content.Replace(content.Contains("./ReportViewer.aspx", StringComparison.InvariantCultureIgnoreCase) ? "./ReportViewer.aspx" : "ReportViewer.aspx", $"{proxyUrl}/{reportServer}/Pages/ReportViewer.aspx", StringComparison.InvariantCultureIgnoreCase);

                    builder.Append($"{content.Length}|{type}|{id}|{content}|");
                }

                result = builder.ToString();
            }
            else
            {
                result = result.Replace($"/{reportServer}/", $"{proxyUrl}/{reportServer}/", StringComparison.InvariantCultureIgnoreCase);

                result = result.Replace(result.Contains("./ReportViewer.aspx", StringComparison.InvariantCultureIgnoreCase) ? "./ReportViewer.aspx" : "ReportViewer.aspx", $"{proxyUrl}/{reportServer}/Pages/ReportViewer.aspx", StringComparison.InvariantCultureIgnoreCase);
            }

            response.Headers.Remove("Content-Length");
            response.Headers.Add("Content-Length", new[] { Encoding.UTF8.GetByteCount(result).ToString() });

            await response.WriteAsync(result);
        }

    }
}