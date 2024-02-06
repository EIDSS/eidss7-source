using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
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
    public partial interface IBaseReferenceClient
    {
        Task<List<BaseReferenceListViewModel>> GetBaseReferenceList(long idfsreferenceType, string langId);
      

    }


    public partial class BaseReferenceClient : BaseApiClient, IBaseReferenceClient
    {

        public BaseReferenceClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<BaseReferenceClient> logger) 
            : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<BaseReferenceListViewModel>> GetBaseReferenceList(long idfsreferenceType, string langId)
        {
            List<BaseReferenceListViewModel> response = new List<BaseReferenceListViewModel>();
            try
            {
                var url = string.Format(_eidssApiOptions.GetBaseReferenceListPath, _eidssApiOptions.BaseUrl, idfsreferenceType, langId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();
                response = await JsonSerializer.DeserializeAsync<List<BaseReferenceListViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {

                _logger.LogError(ex.Message);
            }
          
            return response;

        }



    }
}

