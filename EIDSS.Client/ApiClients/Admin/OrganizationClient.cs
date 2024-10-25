using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Collections.Generic;
using System.Net.Http;
using System.Threading.Tasks;
using EIDSS.ClientLibrary.Extensions;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{
    public interface IOrganizationClient
    {
        Task<List<OrganizationGetListViewModel>> GetOrganizationList(OrganizationGetRequestModel request);
        Task<List<OrganizationGetSearchModelResult>> Search(OrganizationGetSearchModel request);
        Task<List<OrganizationAdvancedGetListViewModel>> GetOrganizationAdvancedList(OrganizationAdvancedGetRequestModel request);
        Task<OrganizationGetDetailViewModel> GetOrganizationDetail(string languageID, long organizationID);
        Task<APISaveResponseModel> SaveOrganization(OrganizationSaveRequestModel request);
        Task<APIPostResponseModel> DeleteOrganization(long organizationID, string auditUserName, bool? deleteAnyway);
    }

    public class OrganizationClient : BaseApiClient, IOrganizationClient
    {
        public OrganizationClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<OrganizationClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        public async Task<List<OrganizationGetListViewModel>> GetOrganizationList(OrganizationGetRequestModel request)
        {
            var url = string.Format(_eidssApiOptions.GetOrganizationListPath, _eidssApiOptions.BaseUrl);
            return await PostAsync<OrganizationGetRequestModel, List<OrganizationGetListViewModel>>(url, request);
        }
        
        public async Task<List<OrganizationGetSearchModelResult>> Search(OrganizationGetSearchModel request)
        {
            var url = $"{string.Format(_eidssApiOptions.OrganizationSearch, _eidssApiOptions.BaseUrl)}{request.ToQueryString()}";
            return await GetAsync<List<OrganizationGetSearchModelResult>>(url);
        }

        public async Task<List<OrganizationAdvancedGetListViewModel>> GetOrganizationAdvancedList(OrganizationAdvancedGetRequestModel request)
        {
            string url = string.Format(_eidssApiOptions.GetAdvancedOrganizationListPath, _eidssApiOptions.BaseUrl);
            return await PostAsync<OrganizationAdvancedGetRequestModel, List<OrganizationAdvancedGetListViewModel>>(url, request);
        }

        public Task<OrganizationGetDetailViewModel> GetOrganizationDetail(string languageID, long organizationID)
        {
            var url = string.Format(_eidssApiOptions.GetOrganizationDetailPath, _eidssApiOptions.BaseUrl, languageID, organizationID);
            return GetAsync<OrganizationGetDetailViewModel>(url);
        }

        public Task<APISaveResponseModel> SaveOrganization(OrganizationSaveRequestModel request)
        {
            var url = string.Format(_eidssApiOptions.SaveOrganizationPath, _eidssApiOptions.BaseUrl);
            return PostAsync<OrganizationSaveRequestModel, APISaveResponseModel>(url, request);
        }

        public Task<APIPostResponseModel> DeleteOrganization(long organizationID, string auditUserName, bool? deleteAnyway)
        {
            var url = string.Format(_eidssApiOptions.DeleteOrganizationPath, _eidssApiOptions.BaseUrl, organizationID, auditUserName, deleteAnyway);
            return DeleteAsync<APIPostResponseModel>(url);
        }
    }
}
