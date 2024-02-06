using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{

    public partial interface IDataArchivingClient
    {
        Task<List<DataArchivingViewModel>> GetDataArchivingSettingAsync();
    }
    public partial class DataArchivingClient : BaseApiClient, IDataArchivingClient
    {

        public DataArchivingClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<DataArchivingClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<DataArchivingViewModel>> GetDataArchivingSettingAsync()
        {
            try
            {
              
                var url = string.Format(_eidssApiOptions.GetDataArchivingListPath, _eidssApiOptions.BaseUrl);
                var DataArchivingViewModel = new List<DataArchivingViewModel>();
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(DataArchivingViewModel), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.GetAsync(url);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                var response = await System.Text.Json.JsonSerializer.DeserializeAsync<List<DataArchivingViewModel>>(contentStream,
                   new JsonSerializerOptions
                   {
                       IgnoreNullValues = true,
                       PropertyNameCaseInsensitive = true
                   });
                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
            finally
            {
            }
        }
    }
}
