using EIDSS.ClientLibrary.Configurations;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiAbstracts
{


    public interface IBaseApiClient
    {
        
    }
    public abstract class BaseApiClient :IBaseApiClient
    {
        private const string ClientUserAgent = "EIDSS-Api-Client-v1";

        protected internal string _baseurl;
        public HttpClient _httpClient;
        private IConfiguration _configuration;
        private TimeSpan _timeout;
        protected internal EidssApiOptions _eidssApiOptions;
        protected internal ILogger _logger;

        /// <summary>
        /// Default JSON serialization options.  Property names are case sensitive and null values are ignored.
        /// </summary>
        protected JsonSerializerOptions SerializationOptions;
        
        /// <summary>
        /// An instance of <see cref="IUserConfigurationService"/> which can be optionally set during construction if user security information is required.
        /// </summary>
        protected internal IUserConfigurationService _userConfigurationService { get; set; }

        public System.Net.Http.Headers.HttpRequestHeaders CustomHeaders { get; set; }

        public IConfiguration Configuration { get { return _configuration; } }


        protected BaseApiClient( HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger logger, IUserConfigurationService userConfigService = null )
        {
            _eidssApiOptions = eidssApiOptions.Value;
           
            this._baseurl = NormalizeBaseUrl(_eidssApiOptions.BaseUrl);

            httpClient.BaseAddress = new Uri(_eidssApiOptions.BaseUrl);
            //json
            httpClient.DefaultRequestHeaders.Add("Accept", "application/json");
            // user-agent
            httpClient.DefaultRequestHeaders.Add("User-Agent", "EIDSS-Api-Client-v1");

            _logger = logger;

            _logger.LogInformation("API Called");

            // Optional parameter ...
            _userConfigurationService = userConfigService;

            // Default Json serialization options.
            SerializationOptions = new JsonSerializerOptions
            {
                IgnoreNullValues = true,
                PropertyNameCaseInsensitive = true
            };
            _httpClient = httpClient;
        }

        protected internal static string NormalizeBaseUrl(string url)
        {
            return url.EndsWith("/") ? url : url + "/";
        }
    }
}
