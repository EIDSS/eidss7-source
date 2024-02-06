#region Usings

using EIDSS.ClientLibrary.Configurations;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

#endregion

namespace EIDSS.Web.Controllers
{
    /// <summary>
    /// Used on Blazor components with the Radzen SSRS Report Viewer component.
    /// </summary>
    public partial class ReportController : Controller
    {
        #region Member Variables

        private readonly IConfiguration _configuration;
        private readonly ProtectedConfigurationSettings _protectedConfig;
        private HttpClient _httpClient;

        #endregion

        #region Properties

        public string Domain { get; set; }

        public string UserName { get; set; }

        public string Password { get; set; }

        #endregion

        #region Constructors

        /// <summary>
        /// 
        /// </summary>
        /// <param name="configuration"></param>
        public ReportController(IConfiguration configuration)
        {
            _configuration = configuration;

            var protectedConfigSection = configuration.GetSection("ProtectedConfiguration");
            _protectedConfig = protectedConfigSection.Get<ProtectedConfigurationSettings>();

            Domain = _protectedConfig.SSRS_Domain.Decrypt();
            UserName = _protectedConfig.SSRS_UserName.Decrypt();
            Password = _protectedConfig.SSRS_Password.Decrypt();
        }

        #endregion

        #region Methods

        /// <summary>
        /// 
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        [HttpGet("/__ssrsreport")]
        public async Task Get(string url)
        {
            if (!string.IsNullOrEmpty(url))
            {
                // Hide the parameters from the user.
                url += "&rc:Parameters=false";

                url = url.Replace("https", "http");

                CreateHttpClient();
                var responseMessage = await ForwardRequest(Request, url);

                CopyResponseHeaders(responseMessage, Response);

                await WriteResponse(Request, url, responseMessage, Response, true);
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [Route("/ssrsproxy/{*url}")]
        public async Task Proxy()
        {
            var urlToReplace = $"{Request.Scheme}://{Request.Host.Value}{Request.PathBase}/ssrsproxy/";
            var requestedUrl = Request.GetDisplayUrl().Replace(urlToReplace, "", StringComparison.InvariantCultureIgnoreCase);
            var reportServerIndex = requestedUrl.IndexOf("/ReportServer", StringComparison.InvariantCultureIgnoreCase);
            if (reportServerIndex == -1)
            {
                reportServerIndex = requestedUrl.IndexOf("/Reports", StringComparison.InvariantCultureIgnoreCase);
            }
            var reportUrlParts = requestedUrl[..reportServerIndex].Split('/');

            var url =
                $"{reportUrlParts[0]}://{reportUrlParts[1]}:{reportUrlParts[2]}{requestedUrl[reportServerIndex..]}";

            CreateHttpClient();
            var responseMessage = await ForwardRequest(Request, url);

            CopyResponseHeaders(responseMessage, Response);

            if (Request.Method == "POST")
            {
                await WriteResponse(Request, url, responseMessage, Response, true);
            }
            else
            {
                if (responseMessage.Content.Headers.ContentType is {MediaType: "text/html"})
                {
                    await WriteResponse(Request, url, responseMessage, Response, false);
                }
                else
                {
                    await using var responseStream = await responseMessage.Content.ReadAsStreamAsync();
                    await responseStream.CopyToAsync(Response.Body, 81920, HttpContext.RequestAborted);
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="handler"></param>
        partial void OnHttpClientHandlerCreate(ref HttpClientHandler handler);

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        private HttpClient CreateHttpClient()
        {
            var httpClientHandler = new HttpClientHandler
            {
                UseDefaultCredentials = false
            };

            if (httpClientHandler.SupportsAutomaticDecompression)
                httpClientHandler.AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate;

            Domain = _protectedConfig.SSRS_Domain.Decrypt();
            UserName = _protectedConfig.SSRS_UserName.Decrypt();
            Password = _protectedConfig.SSRS_Password.Decrypt();

            if (!string.IsNullOrEmpty(UserName))
                httpClientHandler.Credentials = new NetworkCredential(UserName, Password, Domain);

            _httpClient = new HttpClient(httpClientHandler);
            _httpClient.BaseAddress = new Uri(_configuration.GetValue<string>("ReportServer:Url") +
                                              _configuration.GetValue<string>("ReportServer:Path")
                                                  .Replace("/", string.Empty));
            _httpClient.DefaultRequestHeaders.ConnectionClose = false;
            
            OnHttpClientHandlerCreate(ref httpClientHandler);

            return _httpClient;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="requestMessage"></param>
        static partial void OnReportRequest(ref HttpRequestMessage requestMessage);

        private async Task<HttpResponseMessage> ForwardRequest(HttpRequest currentRequest, string url)
        {
            var proxyRequestMessage = new HttpRequestMessage(new HttpMethod(currentRequest.Method), url);

            foreach (var header in currentRequest.Headers)
            {
                if (header.Key != "Host")
                {
                    proxyRequestMessage.Headers.TryAddWithoutValidation(header.Key, new string[] {header.Value});
                }
            }

            proxyRequestMessage.Headers.Add("Connection", "keep-alive");

            OnReportRequest(ref proxyRequestMessage);

            if (currentRequest.Method != "POST") return await _httpClient.SendAsync(proxyRequestMessage);
            using var stream = new MemoryStream();
            await currentRequest.Body.CopyToAsync(stream);
            stream.Position = 0;

            var body = await new StreamReader(stream).ReadToEndAsync();
            proxyRequestMessage.Content = new StringContent(body);

            if (body.IndexOf("AjaxScriptManager", StringComparison.Ordinal) == -1)
                return await _httpClient.SendAsync(proxyRequestMessage);
            proxyRequestMessage.Content.Headers.Remove("Content-Type");
            proxyRequestMessage.Content.Headers.Add("Content-Type", new[] {currentRequest.ContentType});

            return await _httpClient.SendAsync(proxyRequestMessage);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="responseMessage"></param>
        /// <param name="response"></param>
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="currentRequest"></param>
        /// <param name="url"></param>
        /// <param name="responseMessage"></param>
        /// <param name="response"></param>
        /// <param name="isAjax"></param>
        /// <returns></returns>
        private static async Task WriteResponse(HttpRequest currentRequest, string url, HttpResponseMessage responseMessage, HttpResponse response, bool isAjax)
        {
            var result = await responseMessage.Content.ReadAsStringAsync();

            var reportServer = url.Contains("/ReportServer/", StringComparison.InvariantCultureIgnoreCase) ? "ReportServer" : "Reports";

            var reportUri = new Uri(url);
            var proxyUrl =
                $"{currentRequest.Scheme}://{currentRequest.Host.Value}{currentRequest.PathBase}/ssrsproxy/{reportUri.Scheme}/{reportUri.Host}/{reportUri.Port}";

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

        #endregion
    }
}