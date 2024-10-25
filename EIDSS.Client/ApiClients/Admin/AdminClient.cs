using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.ClientLibrary.Convertors;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using NewtonsoftJson = Newtonsoft.Json;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{

    public partial interface IAdminClient
    {
        Task<LoginResponseViewModel> LoginAsync(string username, string password);

        Task<ResponseViewModel> ValidatePassword(string username, string password);

        Task LogOutAsync(string userName);

        Task<BaseReferenceEditorsViewModel[]> GetBaseReferenceListAsync(string languageId, Nullable<long> idfsReferenceType, int page,
            int pageSize, string sortColumn, string sortOrder, string advancedSearch = null);

        Task<BaseReferenceSaveRequestResponseModel> SaveBaseReference(BaseReferenceSaveRequestModel request);

        Task<APIPostResponseModel> DeleteBaseReference(BaseReferenceSaveRequestModel request);

        Task<BaseReferenceEditorsViewModel[]> GetAgeGroupList(AgeGroupGetRequestModel request);

        Task<APIPostResponseModel> DeleteAgeGroup(AgeGroupSaveRequestModel request);

        Task<AgeGroupSaveRequestResponseModel> SaveAgeGroup(AgeGroupSaveRequestModel request);

        Task<bool> UserExists(string userName);

        Task<ResponseViewModel> AddEmployee(RegisterViewModel model);

        Task<AppUserViewModel> GetAppUser(string userName);

        Task<APIPostResponseModel> RemoveEmployee(string aspnetUserId);

        Task<ResponseViewModel> LockAccount(LockUserAccountParams lockUserAccountParams);

        Task<ResponseViewModel> UnLockAccount(UnLockUserAccountParams lockUserAccountParams);

        Task<ResponseViewModel> EnableUserAccount(EnableUserAccountParams enableUserAccountParams);

        Task<ResponseViewModel> DisableUserAccount(DisableUserAccountParams disableUserAccountParams);

        Task<ResponseViewModel> ResetPassword(ResetPasswordParams resetPasswordParams);

        Task<ResponseViewModel> UpdateUserName(UpdateUserNameParams updateUserNameParams);

        Task<ResponseViewModel> UpdatePasswordResetRequired(PasswordResetRequiredParams passwordResetRequiredParams);

        Task<ResponseViewModel> ResetPasswordByUser(ResetPasswordByUserParams resetPasswordByUserParams);

        Task<bool> UpdateIdentityOptions();

        Task<List<UserRolesAndPermissionsViewModel>> GetUserRolesAndPermissions(long? idfUserId, long? employeeId);

        Task<bool> ConnectToArchive(bool isConnectToArchive);

        Task<List<Claim>> GetUserClaims(string userName);

    }

    public partial class AdminClient : BaseApiClient, IAdminClient
    {

        public AdminClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<AdminClient> logger) : base(httpClient, eidssApiOptions, logger)
        {

        }

        public async Task<LoginResponseViewModel> LoginAsync(string username, string password)
        {
            LoginResponseViewModel errorResponse = null;
            try
            {
                var loginViewModel = new LoginViewModel
                {
                    Username = username,
                    Password = password
                };

                var loginViewModelJson = new StringContent(JsonSerializer.Serialize(loginViewModel), Encoding.UTF8, "application/json");
                var loginUrl = $"{_eidssApiOptions.BaseUrl}{_eidssApiOptions.LogInPath}";
                var httpResponse = await _httpClient.PostAsync(loginUrl, loginViewModelJson);


                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<LoginResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { username, password });
                throw;
            }
            finally
            {
            }

        }

        public async Task<ResponseViewModel> ValidatePassword(string username, string password)
        {
            try
            {
                var model = new RegisterViewModel
                {
                    Username = username,
                    Password = password
                };

                var loginViewModelJson = new StringContent(JsonSerializer.Serialize(model), Encoding.UTF8, "application/json");
                var loginUrl = $"{_eidssApiOptions.BaseUrl}{_eidssApiOptions.ValidatePasswordPath}";
                var httpResponse = await _httpClient.PostAsync(loginUrl, loginViewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { username, password });
                throw;
            }
            finally
            {
            }
        }

        public async Task<bool> UserExists(string userName)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.VerifyUserNamePath, _eidssApiOptions.BaseUrl, userName);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<bool>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { userName });
                throw;
            }
            finally
            {
            }
        }

        public async Task<AppUserViewModel> GetAppUser(string userName)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetAppUserPath, _eidssApiOptions.BaseUrl, userName);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<AppUserViewModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { userName });
                throw;
            }
            finally
            {
            }
        }

        public Task LogOutAsync(string userName)
        {
            throw new NotImplementedException();
        }

        public async Task<ResponseViewModel> AddEmployee(RegisterViewModel model)
        {
            try
            {                
                
                var requestModelJson = new StringContent(JsonSerializer.Serialize(model), Encoding.UTF8, "application/json");
                var saveASPNetUserIdentityPath = string.Format(_eidssApiOptions.SaveASPNetUserIdentityPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(saveASPNetUserIdentityPath, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { model });
                throw;
            }
        }

        public async Task<APIPostResponseModel> RemoveEmployee(string aspnetUserId)
        {
            var url = string.Format(_eidssApiOptions.RemoveEmployeePasswordPath, _eidssApiOptions.BaseUrl, aspnetUserId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

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

        public async Task<ResponseViewModel> UpdateUserName(UpdateUserNameParams updateUserNameParams)
        {
            try
            {

                var requestModelJson = new StringContent(JsonSerializer.Serialize(updateUserNameParams), Encoding.UTF8, "application/json");
                var updateUserNamePath = string.Format(_eidssApiOptions.UpdateUserNamePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(updateUserNamePath, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { updateUserNameParams });
                throw;
            }

        }


        public async Task<ResponseViewModel> UpdatePasswordResetRequired(PasswordResetRequiredParams passwordResetRequiredParams)
        {
            try
            {

                var requestModelJson = new StringContent(JsonSerializer.Serialize(passwordResetRequiredParams), Encoding.UTF8, "application/json");
                var updatePasswordResetRequiredPath = string.Format(_eidssApiOptions.UpdatePasswordResetRequiredPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(updatePasswordResetRequiredPath, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { passwordResetRequiredParams });
                throw;
            }

        }

        public async Task<ResponseViewModel> ResetPassword(ResetPasswordParams resetPasswordParams)
        {
            try
            {

                var requestModelJson = new StringContent(JsonSerializer.Serialize(resetPasswordParams), Encoding.UTF8, "application/json");
                var resetPasswordPath = string.Format(_eidssApiOptions.ResetPasswordPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(resetPasswordPath, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { resetPasswordParams });
                throw;
            }

        }

        #region Base Reference

        /// <summary>
        /// Gets a list of base reference types
        /// </summary>
        /// <param name="languageId"></param>
        /// <param name="idfsReferenceType"></param>
        /// <param name="page"></param>
        /// <param name="pageSize"></param>
        /// <param name="sortColumn"></param>
        /// <param name="sortOrder"></param>
        /// <param name="advancedSearch"></param>
        /// <returns></returns>
        public async Task<BaseReferenceEditorsViewModel[]> GetBaseReferenceListAsync(string languageId, Nullable<long> idfsReferenceType, int page,
            int pageSize, string sortColumn, string sortOrder, string advancedSearch = null)
        {
            BaseReferenceEditorGetRequestModel request = new()
            {
                LanguageId = languageId,
                IdfsReferenceType = idfsReferenceType,
                Page = page,
                PageSize = pageSize,
                SortColumn = sortColumn,
                SortOrder = sortOrder,
                AdvancedSearch = advancedSearch
            };

            //var request = "{'AdvancedSearch': null,'IdfsReferenceType': 19000110,'LanguageId':'en','Page': 0,'PageSize': 10,'SortColumn': 'IntOrder','SortOrder': 'desc'}";
            try
            {


                var sc = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");

                // new c# string concatenation...
                //var url = $"{_eidssApiOptions.BaseUrl}{_eidssApiOptions.GetBaseReferenceListPath}";
                var url = string.Format(_eidssApiOptions.GetBaseReferenceListPath, _eidssApiOptions.BaseUrl);
                // new using statement...
                var httpResponse = await _httpClient.PostAsync(url, sc);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();
                var responseStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<BaseReferenceEditorsViewModel[]>(responseStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] {languageId,idfsReferenceType,page,pageSize,sortColumn,sortOrder,advancedSearch}); 
                throw;
            }
        }

        public async Task<BaseReferenceSaveRequestResponseModel> SaveBaseReference(BaseReferenceSaveRequestModel request)
        {
            try
            {

                var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var saveBaseReferenceUrl = string.Format(_eidssApiOptions.SaveBaseReferencePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(saveBaseReferenceUrl, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<BaseReferenceSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] {request}); 
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteBaseReference(BaseReferenceSaveRequestModel request)
        {
            var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var saveBaseReferenceUrl = string.Format(_eidssApiOptions.DeleteBaseReferencePath, _eidssApiOptions.BaseUrl);

            var httpResponse = await _httpClient.PostAsync(saveBaseReferenceUrl, requestModelJson);

            // Throws an exception if the call to the service failed...
            httpResponse.EnsureSuccessStatusCode();

            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<BaseReferenceSaveRequestResponseModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });
        }

        #endregion

        #region AgeGroup

        public async Task<BaseReferenceEditorsViewModel[]> GetAgeGroupList(AgeGroupGetRequestModel request)
        {
            try
            {
                var sc = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                // new c# string concatenation...
                //var url = $"{_eidssApiOptions.BaseUrl}{_eidssApiOptions.GetBaseReferenceListPath}";
                var url = string.Format(_eidssApiOptions.GetAgeGroupListPath, _eidssApiOptions.BaseUrl);
                // new using statement...
                var httpResponse = await _httpClient.PostAsync(url, sc);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();
                var responseStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<BaseReferenceEditorsViewModel[]>(responseStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] {request}); 
                throw;
            }
        }

        public async Task<APIPostResponseModel> DeleteAgeGroup(AgeGroupSaveRequestModel request)
        {
            var requestModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var saveBaseReferenceUrl = string.Format(_eidssApiOptions.DeleteAgeGroupPath, _eidssApiOptions.BaseUrl);
            var httpResponse = await _httpClient.PostAsync(saveBaseReferenceUrl, requestModelJson);

            // Throws an exception if the call to the service failed...
            httpResponse.EnsureSuccessStatusCode();

            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });
        }

        public async Task<AgeGroupSaveRequestResponseModel> SaveAgeGroup(AgeGroupSaveRequestModel request)
        {
            try
            {
                var requestModelJson =
                    new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var saveBaseReferenceUrl = string.Format(_eidssApiOptions.SaveAgeGroupPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(saveBaseReferenceUrl, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<AgeGroupSaveRequestResponseModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] {request});
                throw;
            }
        }

        public async Task<ResponseViewModel> LockAccount(LockUserAccountParams lockUserAccountParams)
        {
            try
            {

                var requestModelJson = new StringContent(JsonSerializer.Serialize(lockUserAccountParams), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.LockAccountPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { lockUserAccountParams });
                throw;
            }
        }

        public async Task<ResponseViewModel> UnLockAccount(UnLockUserAccountParams unlockUserAccountParams)
        {
            try
            {

                var requestModelJson = new StringContent(JsonSerializer.Serialize(unlockUserAccountParams), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.UnLockAccountPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { unlockUserAccountParams });
                throw;
            }
        }

        public async Task<ResponseViewModel> EnableUserAccount(EnableUserAccountParams enableUserAccountParams)
        {
            try
            {

                var requestModelJson = new StringContent(JsonSerializer.Serialize(enableUserAccountParams), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.EnableUserAccountPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { enableUserAccountParams });
                throw;
            }
        }

        public async Task<ResponseViewModel> DisableUserAccount(DisableUserAccountParams disableUserAccountParams)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(disableUserAccountParams), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DisableUserAccountPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { disableUserAccountParams });
                throw;
            }
        }

        public async Task<ResponseViewModel> ResetPasswordByUser(ResetPasswordByUserParams resetPasswordByUserParams)
        {
            try
            {
                var requestModelJson = new StringContent(JsonSerializer.Serialize(resetPasswordByUserParams), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.ResetPasswordByUserPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestModelJson);

                // Throws an exception if the call to the service failed...
                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ResponseViewModel>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { resetPasswordByUserParams });
                throw;
            }
        }

        public async Task<bool> UpdateIdentityOptions()
        {
            try
            {
                var url = string.Format(_eidssApiOptions.UpdateIdentityOptions, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<bool>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] {  });
                throw;
            }
            finally
            {
            }
        }

        public async Task<bool> ConnectToArchive(bool isConnectToArchive)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.ConnectToArchive, _eidssApiOptions.BaseUrl, isConnectToArchive);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<bool>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { });
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<UserRolesAndPermissionsViewModel>> GetUserRolesAndPermissions(long? idfUserId, long? employeeId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetUserRolesAndPermissionsPath, _eidssApiOptions.BaseUrl,idfUserId,employeeId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<UserRolesAndPermissionsViewModel>>(contentStream,
                new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { });
                throw;
            }
            finally
            {
            }
        }

        public async Task<List<Claim>> GetUserClaims(string userName)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetUserClaimsPath, _eidssApiOptions.BaseUrl, userName);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                string responseBody = await httpResponse.Content.ReadAsStringAsync();

                var claims = NewtonsoftJson.JsonConvert.DeserializeObject<List<Claim>>(responseBody, new ClaimConverter());

                return claims;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { });
                throw;
            }
            finally
            {
            }
        }

        #endregion

    }
}
