using EIDSS.ClientLibrary.Configurations;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiAbstracts;

public abstract class BaseApiClient
{
    protected static readonly JsonSerializerOptions SerializationOptions = new()
    {
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
        PropertyNameCaseInsensitive = true
    };

    protected readonly string _baseurl;
    protected readonly EidssApiOptions _eidssApiOptions;
    protected readonly ILogger _logger;
    protected readonly HttpClient _httpClient;
    protected readonly IUserConfigurationService _userConfigurationService;

    protected BaseApiClient(HttpClient httpClient, IOptions<EidssApiOptions> eidssApiOptions, ILogger logger,
        IUserConfigurationService userConfigService = null)
    {
        _eidssApiOptions = eidssApiOptions.Value;
        _baseurl = NormalizeBaseUrl(_eidssApiOptions.BaseUrl);
        httpClient.BaseAddress = new Uri(_eidssApiOptions.BaseUrl);
        httpClient.DefaultRequestHeaders.Add("Accept", "application/json");
        httpClient.DefaultRequestHeaders.Add("User-Agent", "EIDSS-Api-Client-v1");
        _logger = logger;
        _userConfigurationService = userConfigService;
        _httpClient = httpClient;
    }

    protected async Task<TResponse> PostAsync<TRequest, TResponse>(string uri, TRequest request)
    {
        try
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var httpResponse = await _httpClient.PostAsync(uri, requestJson);
            return await DeserializeValidHttpRequest<TResponse>(httpResponse);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex.Message, request);
            throw;
        }
    }

    protected async Task<TResponse> GetAsync<TResponse>(string url)
    {
        try
        {
            var httpResponse = await _httpClient.GetAsync(new Uri(url));
            return await DeserializeValidHttpRequest<TResponse>(httpResponse);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex.Message);
            throw;
        }
    }

    protected async Task<TResponse> DeleteAsync<TResponse>(string url)
    {
        try
        {
            var httpResponse = await _httpClient.SendAsync(new HttpRequestMessage(HttpMethod.Delete, new Uri(url)));
            return await DeserializeValidHttpRequest<TResponse>(httpResponse);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex.Message);
            throw;
        }
    }

    private static async Task<TResponse> DeserializeValidHttpRequest<TResponse>(HttpResponseMessage httpResponse)
    {
        httpResponse.EnsureSuccessStatusCode();
        var contentStream = await httpResponse.Content.ReadAsStreamAsync();
        return await JsonSerializer.DeserializeAsync<TResponse>(contentStream, SerializationOptions);
    }

    private static string NormalizeBaseUrl(string url)
    {
        return url.EndsWith("/") ? url : url + "/";
    }
}