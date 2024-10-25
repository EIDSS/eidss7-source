using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ViewModels;
using System.Net.Http;
using System.Text.Json;
using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Configuration;

namespace EIDSS.ClientLibrary.GeoLocationClients
{
    public interface IPhotonClient
    {
        Task<bool> IsLocationCoordinateValid(string locationName, double latPlusOrMinusRange, double lonPlusOrMinusRange);
    }
    /// <summary>
    /// PhotonClient
    /// </summary>
    public class PhotonClient : IPhotonClient
    {
        protected internal HttpClient HttpClient;
        private TimeSpan _timeout;
        protected internal EidssGlobalSettingsOptions EidssGlobalSettingsOptions;
        protected internal ILogger Logger;

        public PhotonClient(HttpClient httpClient, IOptionsSnapshot<EidssGlobalSettingsOptions> eidssGlobalSettingsOptions, ILogger logger, TimeSpan timeout)
        {
            Logger = logger;
            _timeout = timeout;
            EidssGlobalSettingsOptions = eidssGlobalSettingsOptions.Value;
        }

        public async Task<bool> IsLocationCoordinateValid(string locationName, double latPlusOrMinusRange,double lonPlusOrMinusRange)
        {
            var returnValue = false;
            try
            {
                var url = $"{EidssGlobalSettingsOptions.LeafletApiUrl}api/?q={locationName}";
                var httpResponse = await HttpClient.GetAsync(new Uri(url));
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<LanguageModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return false;
            }
            catch (Exception ex)
            {
                Logger.LogError(ex.Message, Array.Empty<object>());
                throw;
            }
            finally
            {
            }


        }

       
    }
}
