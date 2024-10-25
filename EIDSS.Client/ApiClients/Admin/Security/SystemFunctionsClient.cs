using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ResponseModels.Administration.Security;
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

namespace EIDSS.ClientLibrary.ApiClients.Admin.Security
{

    public partial interface ISystemFunctionsClient
    {
        Task<List<SystemFunctionViewModel>> GetSystemFunctionList(SystemFunctionsGetRequestModel request);
        Task<List<SystemFunctionUserGroupAndUserViewModel>> GetSystemFunctionActorList(SystemFunctionsActorsGetRequestModel request);
        Task<List<SystemFunctionUserPermissionViewModel>> GetSystemFunctionPermissionList(SystemFunctionPermissionGetRequestModel request);
        Task<SystemFunctionUserPermissionSaveResponseModel> SaveSystemFunctionUsePermission(SystemFunctionsUserPermissionsSetParams request);
        Task<List<SystemFunctionPersonANDEmployeeGroupViewModel>> GetPersonAndEmployeeGroupList(PersonAndEmployeeGroupGetRequestModel request);
        Task<SystemFunctionPersonANDEmployeeGroupDelResponseModel> DeleteSystemFunctionPersonAndEmployeeGroup(SystemFunctionsPersonAndEmpoyeeGroupDelRequestModel request);


    }

    public partial class SystemFunctionsClient : BaseApiClient, ISystemFunctionsClient
    {

        public SystemFunctionsClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<SystemFunctionsClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<List<SystemFunctionViewModel>> GetSystemFunctionList(SystemFunctionsGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetSystemFunctionListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(new Uri(url), viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                    var response = await JsonSerializer.DeserializeAsync<List<SystemFunctionViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, Array.Empty<object>());
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<SystemFunctionUserGroupAndUserViewModel>> GetSystemFunctionActorList(SystemFunctionsActorsGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetSystemFunctionActorsListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(new Uri(url), viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync< List<SystemFunctionUserGroupAndUserViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, Array.Empty<object>());
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<SystemFunctionUserPermissionViewModel>> GetSystemFunctionPermissionList(SystemFunctionPermissionGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetSystemFunctionPermissionListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(new Uri(url), viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<SystemFunctionUserPermissionViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, Array.Empty<object>());
                throw;
            }
            finally
            {
            }
        }

        public async Task<SystemFunctionUserPermissionSaveResponseModel> SaveSystemFunctionUsePermission(SystemFunctionsUserPermissionsSetParams request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveSystemFunctionUserPermissionPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(new Uri(url), viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<SystemFunctionUserPermissionSaveResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, Array.Empty<object>());
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<SystemFunctionPersonANDEmployeeGroupViewModel>> GetPersonAndEmployeeGroupList(PersonAndEmployeeGroupGetRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetPersonAndEmployeeGroupListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(new Uri(url), viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<SystemFunctionPersonANDEmployeeGroupViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, Array.Empty<object>());
                throw;
            }
            finally
            {
            }
        }

        public async Task<SystemFunctionPersonANDEmployeeGroupDelResponseModel> DeleteSystemFunctionPersonAndEmployeeGroup(SystemFunctionsPersonAndEmpoyeeGroupDelRequestModel request)
        {
            try
            {
                var viewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteSystemFunctionPersonAndEmployeeGroupPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(new Uri(url), viewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<SystemFunctionPersonANDEmployeeGroupDelResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, Array.Empty<object>());
                throw;
            }
            finally
            {
            }
        }
    }
}
