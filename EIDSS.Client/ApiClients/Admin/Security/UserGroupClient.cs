using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Administration.Security
{
    public partial interface IUserGroupClient
    {
        Task<List<UserGroupDashboardViewModel>> GetUserGroupDashboardList(UserGroupDashboardGetRequestModel request);
        Task<APIPostResponseModel> SaveUserGroupDashboard(UserGroupDashboardSaveRequestModel request);
        Task<APIPostResponseModel> DeleteUserGroup(long? roleID, long? roleName, long? idfsSite, string user);
        Task<List<UserGroupDetailViewModel>> GetUserGroupDetail(long? idfEmployeeGroup, string langId, string user);
        Task<List<UserGroupViewModel>> GetUserGroupList(UserGroupGetRequestModel request);
        Task<UserGroupSaveResponseModel> SaveUserGroup(UserGroupSaveRequestModel request);
        Task<APIPostResponseModel> SaveUserGroupSystemFunctions(UserGroupSystemFunctionsSaveRequestModel request);
        Task<APIPostResponseModel> DeleteEmployeesFromUserGroup(long? idfEmployeeGroup, string idfEmployeeList, string AuditUser);
        Task<List<EmployeesForUserGroupViewModel>> GetEmployeesForUserGroupList(EmployeesForUserGroupGetRequestModel request);
        Task<List<UsergroupSystemfunctionPermissionViewModel>> GetUsergroupSystemfunctionPermissionList(string langId,long? systemFunctionId);
        Task<APIPostResponseModel> SaveEmployeesToUserGroup(EmployeesToUserGroupSaveRequestModel request);
        Task<List<UserPermissionByRoleViewModel>> GetPermissionsbyRole(PermissionsbyRoleGetRequestModel request);
    }

    public partial class UserGroupClient : BaseApiClient, IUserGroupClient
    {
        public UserGroupClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<UserGroupClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        public async Task<List<UserGroupDashboardViewModel>> GetUserGroupDashboardList(UserGroupDashboardGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetUserGroupDashboardListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<UserGroupDashboardViewModel>>(contentStream,
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
            finally
            {
            }
        }

        public async Task<APIPostResponseModel> SaveUserGroupDashboard(UserGroupDashboardSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveUserGroupDashboardPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
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
            finally
            {
            }
        }

        public async Task<APIPostResponseModel> DeleteUserGroup(long? roleID, long? roleName, long? idfsSite, string user)
        {
            var url = string.Format(_eidssApiOptions.DeleteUserGroupPath, _eidssApiOptions.BaseUrl, roleID, roleName, idfsSite, user);
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

        public async Task<List<UserGroupDetailViewModel>> GetUserGroupDetail(long? idfEmployeeGroup, string langId, string user)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetUserGroupDetailPath, _eidssApiOptions.BaseUrl, idfEmployeeGroup, langId, user);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync< List<UserGroupDetailViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { idfEmployeeGroup });
                throw;
            }
            finally
            {
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<UserGroupViewModel>> GetUserGroupList(UserGroupGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetUserGroupListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<UserGroupViewModel>>(contentStream,
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
            finally
            {
            }
        }

        public async Task<UserGroupSaveResponseModel> SaveUserGroup(UserGroupSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveUserGroupPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<UserGroupSaveResponseModel>(contentStream,
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
            finally
            {
            }
        }

        public async Task<APIPostResponseModel> SaveUserGroupSystemFunctions(UserGroupSystemFunctionsSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveUserGroupSystemFunctionsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
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
            finally
            {
            }
        }

        public async Task<APIPostResponseModel> DeleteEmployeesFromUserGroup(long? idfEmployeeGroup, string idfEmployeeList, string AuditUser)
        {
            var url = string.Format(_eidssApiOptions.DeleteEmployeesFromUserGroupPath, _eidssApiOptions.BaseUrl, idfEmployeeGroup, idfEmployeeList, AuditUser);
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

        public async Task<List<EmployeesForUserGroupViewModel>> GetEmployeesForUserGroupList(EmployeesForUserGroupGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetEmployeesForUserGroupListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<EmployeesForUserGroupViewModel>>(contentStream,
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
            finally
            {
            }
        }

        public async Task<List<UsergroupSystemfunctionPermissionViewModel>> GetUsergroupSystemfunctionPermissionList(string langId,long? systemFunctionId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetUsergroupSystemfunctionPermissionListPath, _eidssApiOptions.BaseUrl, langId,systemFunctionId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<UsergroupSystemfunctionPermissionViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { langId });
                throw;
            }
            finally
            {
            }
        }

        public async Task<APIPostResponseModel> SaveEmployeesToUserGroup(EmployeesToUserGroupSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveEmployeesToUserGroupPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
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
            finally
            {
            }
        }

        public async Task<List<UserPermissionByRoleViewModel>> GetPermissionsbyRole(PermissionsbyRoleGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetPermissionsbyRolePath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<UserPermissionByRoleViewModel>>(contentStream,
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
            finally
            {
            }
        }
    }
}