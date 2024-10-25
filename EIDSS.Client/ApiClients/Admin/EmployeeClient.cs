using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{

    public partial interface IEmployeeClient
    {
       
        Task<List<EmployeeListViewModel>> GetEmployeeList(EmployeeGetListRequestModel request);

        Task<List<EmployeeDetailRequestResponseModel>> GetEmployeeDetail(EmployeeDetailsGetRequestModel request);

        Task<List<AdminEmployeeSiteDetailsViewModel>>  GetEmployeeSiteDetails(EmployeesSiteDetailsGetRequestModel request);

        Task<List<EmployeeSiteFromOrgViewModel>> GetEmployeeSiteFromOrg(long? idfOffice);

        Task<List<EmployeeUserGroupsAndPermissionsViewModel>> GetEmployeeUserGroupAndPermissions(EmployeesUserGroupAndPermissionsGetRequestModel request);

        Task<List<AspNetUserDetailModel>> GetASPNetUser_GetDetails(string id);

        Task<List<EmployeeUserGroupOrgDetailsViewModel>> GetEmployeeUserGroupAndPermissionDetail(EmployeeUserGroupOrgDetailsGetRequestModel request);

        Task<EmployeeSaveRequestResponseModel> SaveEmployee(EmployeeSaveRequestModel request);

        Task<EmployeeLoginSaveRequestResponseModel> SaveUserLoginInfo(EmployeeLoginSaveRequestModel request);

        Task<EmployeeUserGroupMemberSaveRequestResponseModel> SaveUserGroupMemberInfo(EmployeeUserGroupMemberSaveRequestModel request);

        Task<EmployeeOrganizationSaveRequestResponseModel> SaveEmployeeOrganization(EmployeeOrganizationSaveRequestModel request);

        Task<EmployeeOrganizationSaveRequestResponseModel> SaveAdminNewDefaultEmployeeOrganization(EmployeeNewDefaultOrganizationSaveRequestModel request);

        Task<APIPostResponseModel> DeleteEmployeeOrganization(string aspNetUserId, long? idfUserId);

        Task<APIPostResponseModel> DeleteEmployee(long? idfPerson);

        Task<APIPostResponseModel> DeleteEmployeeLoginInfo(long? idfUserId);

        Task<APIPostResponseModel> DeleteEmployeeGroupMemberInfo(string idfEmployeeGroups, long? idfEmployee);

        Task<APIPostResponseModel> EmployeeOrganizationStatusSet(long? idfPerson, int? intRowStatus);

        Task<APIPostResponseModel> EmployeeOrganizationActivateDeactivateSet(long? idfPerson, bool? active);

        Task<List<EmployeeGroupsByUserViewModel>> GetEmployeeGroupsByUser(long? idfUserId);


    }

    public partial class EmployeeClient : BaseApiClient, IEmployeeClient
    {

        public EmployeeClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<EmployeeClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        /// <summary>
        /// Returns a list of Employees
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<EmployeeListViewModel>> GetEmployeeList(EmployeeGetListRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetEmployeeListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<EmployeeListViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<List<EmployeeDetailRequestResponseModel>> GetEmployeeDetail(EmployeeDetailsGetRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetEmployeeDetailsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<EmployeeDetailRequestResponseModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }
        public async Task<List<EmployeeSiteFromOrgViewModel>> GetEmployeeSiteFromOrg(long? idfOffice)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(idfOffice), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetEmployeeSiteFromOrgPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<EmployeeSiteFromOrgViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { idfOffice });
                throw;
            }
        }

        public async Task<List<EmployeeGroupsByUserViewModel>> GetEmployeeGroupsByUser(long? idfUserId)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(idfUserId), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetEmployeeGroupsByUserPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<EmployeeGroupsByUserViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { idfUserId });
                throw;
            }
        }
        public async Task<List<AdminEmployeeSiteDetailsViewModel>> GetEmployeeSiteDetails(EmployeesSiteDetailsGetRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetEmployeeSiteDetailsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<AdminEmployeeSiteDetailsViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }
        public async Task<List<EmployeeUserGroupsAndPermissionsViewModel>> GetEmployeeUserGroupAndPermissions(EmployeesUserGroupAndPermissionsGetRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetEmployeeUserGroupAndPermissionsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<EmployeeUserGroupsAndPermissionsViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<List<EmployeeUserGroupOrgDetailsViewModel>> GetEmployeeUserGroupAndPermissionDetail(EmployeeUserGroupOrgDetailsGetRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetEmployeeUserGroupAndPermissionDetailPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<EmployeeUserGroupOrgDetailsViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<List<AspNetUserDetailModel>> GetASPNetUser_GetDetails(string id)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(id), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetAspNetUserGetDetailsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<AspNetUserDetailModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { id });
                throw;
            }
        }
        public async Task<EmployeeSaveRequestResponseModel> SaveEmployee(EmployeeSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveEmployeePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<EmployeeSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<EmployeeLoginSaveRequestResponseModel> SaveUserLoginInfo(EmployeeLoginSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveUserLoginInfoPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<EmployeeLoginSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }
        public async Task<EmployeeUserGroupMemberSaveRequestResponseModel> SaveUserGroupMemberInfo(EmployeeUserGroupMemberSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveUserGroupMemberInfoPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<EmployeeUserGroupMemberSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }
        public async Task<EmployeeOrganizationSaveRequestResponseModel> SaveEmployeeOrganization(EmployeeOrganizationSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveEmployeeOrganizationPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<EmployeeOrganizationSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<EmployeeOrganizationSaveRequestResponseModel> SaveAdminNewDefaultEmployeeOrganization(EmployeeNewDefaultOrganizationSaveRequestModel request)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveEmployeeNewDefaultOrganizationPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<EmployeeOrganizationSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }
        
        public async Task<APIPostResponseModel> DeleteEmployeeOrganization(string aspNetUserId, long? idfUserId)
        {
            try
            {

                var url = string.Format(_eidssApiOptions.DeleteEmployeeOrganizationPath, _eidssApiOptions.BaseUrl, aspNetUserId, idfUserId);
                var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
                //var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                //var url = string.Format(_eidssApiOptions.DeleteEmployeeOrganizationPath, _eidssApiOptions.BaseUrl);

                //var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                //// Throws an exception if the call to the service failed...
                //httpResponse.EnsureSuccessStatusCode();

                //var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                //return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                //    new JsonSerializerOptions
                //    {
                //        IgnoreNullValues = true,
                //        PropertyNameCaseInsensitive = true
                //    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { aspNetUserId,idfUserId });
                throw;
            }
        }

        public async Task<APIPostResponseModel> EmployeeOrganizationStatusSet(long? idfPerson, int? intRowStatus)
        {
            var url = string.Format(_eidssApiOptions.EmployeeOrganizationStatusSetPath, _eidssApiOptions.BaseUrl, idfPerson, intRowStatus);
            var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            return response;
        }
        public async Task<APIPostResponseModel> EmployeeOrganizationActivateDeactivateSet(long? idfPerson, bool? active)
        {
            var url = string.Format(_eidssApiOptions.EmployeeOrganizationActivateDeactivateSetPath, _eidssApiOptions.BaseUrl, idfPerson, active);
            var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

            return response;
        }

        


        public async Task<APIPostResponseModel> DeleteEmployee(long? idfPerson)
        {
            try
            {
                //var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                //var url = string.Format(_eidssApiOptions.DeleteEmployeePath, _eidssApiOptions.BaseUrl);

                //var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                //// Throws an exception if the call to the service failed...
                //httpResponse.EnsureSuccessStatusCode();

                //var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                //return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                //    new JsonSerializerOptions
                //    {
                //        IgnoreNullValues = true,
                //        PropertyNameCaseInsensitive = true
                //    });

                var url = string.Format(_eidssApiOptions.DeleteEmployeePath, _eidssApiOptions.BaseUrl, idfPerson);
                var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { idfPerson });
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteEmployeeLoginInfo(long? idfUserId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteEmployeeLoginInfoPath, _eidssApiOptions.BaseUrl, idfUserId);
                var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
                //var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                //var url = string.Format(_eidssApiOptions.DeleteUserLoginInfoPath, _eidssApiOptions.BaseUrl);

                //var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                //// Throws an exception if the call to the service failed...
                //httpResponse.EnsureSuccessStatusCode();

                //var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                //return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                //    new JsonSerializerOptions
                //    {
                //        IgnoreNullValues = true,
                //        PropertyNameCaseInsensitive = true
                //    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { idfUserId });
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteEmployeeGroupMemberInfo(string idfEmployeeGroups, long? idfEmployee)
        {
            try
            {

                var url = string.Format(_eidssApiOptions.DeleteEmployeeGroupMemberInfoPath, _eidssApiOptions.BaseUrl, idfEmployeeGroups, idfEmployee);
                var httpResponse = await _httpClient.DeleteAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
                //var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                //var url = string.Format(_eidssApiOptions.DeleteUserGroupMemberInfoPath, _eidssApiOptions.BaseUrl);

                //var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                //// Throws an exception if the call to the service failed...
                //httpResponse.EnsureSuccessStatusCode();

                //var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                //return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                //    new JsonSerializerOptions
                //    {
                //        IgnoreNullValues = true,
                //        PropertyNameCaseInsensitive = true
                //    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { idfEmployeeGroups, idfEmployee });
                throw;
            }
        }
    }
        
}
