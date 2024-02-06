using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ResponseModels;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using System.IO;
using System.Net.Http.Headers;

namespace EIDSS.ClientLibrary.ApiClients.Admin
{
    public partial interface IInterfaceEditorClient
    {
        Task<List<InterfaceEditorModuleSectionViewModel>> GetInterfaceEditorModuleList(InterfaceEditorModuleGetRequestModel request);

        Task<List<InterfaceEditorModuleSectionViewModel>> GetInterfaceEditorSectionList(InterfaceEditorSectionGetRequestModel request);

        Task<List<InterfaceEditorResourceViewModel>> GetInterfaceEditorResourceList(InterfaceEditorResourceGetRequestModel request);

        Task<APIPostResponseModel> SaveInterfaceEditorResource(InterfaceEditorResourceSaveRequestModel request);

        Task<List<InterfaceEditorTemplateViewModel>> GetInterfaceEditorTemplateItems(string langId);

        Task<APIPostResponseModel> UploadLanguageTranslation(InterfaceEditorLangaugeFileSaveRequestModel request);
    }

    public partial class InterfaceEditorClient : BaseApiClient, IInterfaceEditorClient
    {
        public InterfaceEditorClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<InterfaceEditorClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        public async Task<List<InterfaceEditorModuleSectionViewModel>> GetInterfaceEditorModuleList(InterfaceEditorModuleGetRequestModel request)
        {
            try
            {
                var interfaceEditorModel = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetInterfaceEditorModuleListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, interfaceEditorModel);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<InterfaceEditorModuleSectionViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<List<InterfaceEditorResourceViewModel>> GetInterfaceEditorResourceList(InterfaceEditorResourceGetRequestModel request)
        {
            try
            {
                var interfaceEditorModel = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetInterfaceEditorResourceListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, interfaceEditorModel);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<InterfaceEditorResourceViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<List<InterfaceEditorModuleSectionViewModel>> GetInterfaceEditorSectionList(InterfaceEditorSectionGetRequestModel request)
        {
            try
            {
                var interfaceEditorModel = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetInterfaceEditorSectionListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, interfaceEditorModel);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<InterfaceEditorModuleSectionViewModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<APIPostResponseModel> SaveInterfaceEditorResource(InterfaceEditorResourceSaveRequestModel request)
        {
            APIPostResponseModel errorResponse = null;
            try
            {
                var interfaceEditorModel = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveInterfaceEditorResourcePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, interfaceEditorModel);

                if (!httpResponse.IsSuccessStatusCode)
                {
                    try
                    {
                        var errorStream = await httpResponse.Content.ReadAsStreamAsync();
                        errorResponse = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(errorStream);
                    }
                    catch
                    {
                    }
                }

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
                _logger.LogError(ex.Message, new object[] { errorResponse });
                throw;
            }
        }

        public async Task<List<InterfaceEditorTemplateViewModel>> GetInterfaceEditorTemplateItems(string langId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetInterfaceEditorTemplateItemsPath, _eidssApiOptions.BaseUrl, langId);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<InterfaceEditorTemplateViewModel>>(contentStream,
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
        }

        public async Task<APIPostResponseModel> UploadLanguageTranslation(InterfaceEditorLangaugeFileSaveRequestModel request)
        {
            APIPostResponseModel errorResponse = null;
            try
            {
                var multipartContent = new MultipartFormDataContent();

                //add other values to the multipart content
                var values = new[]
                {
                    new KeyValuePair<string, string>("LanguageName", request.LanguageName),
                    new KeyValuePair<string, string>("LanguageCode", request.LanguageCode),
                    new KeyValuePair<string, string>("FileName", request.FileName),
                    new KeyValuePair<string, string>("User", request.User),
                    new KeyValuePair<string, string>("CurrentLangId", request.CurrentLangId)
                };
                foreach (var val in values)
                {
                    multipartContent.Add(new StringContent(val.Value), val.Key);
                }

                //add file content to the multipart content
                byte[] bytes = new byte[request.LanguageFile.Length];
                using (var fileStream = request.LanguageFile.OpenReadStream())
                {
                    fileStream.Read(bytes, 0, (int)request.LanguageFile.Length);
                }
                var byteArrayContent = new ByteArrayContent(bytes);
                byteArrayContent.Headers.ContentType = new MediaTypeHeaderValue("application/vnd.ms-excel");
                byteArrayContent.Headers.ContentDisposition = new ContentDispositionHeaderValue("form-data")
                {
                    Name = "LanguageFile",
                    FileName = $"new_language-{request.LanguageName}.csv"
                };
                multipartContent.Add(byteArrayContent, "LanguageFile", request.FileName);

                var url = string.Format(_eidssApiOptions.UploadLanguageTranslationPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, multipartContent);

                if (!httpResponse.IsSuccessStatusCode)
                {
                    try
                    {
                        var errorStream = await httpResponse.Content.ReadAsStreamAsync();
                        errorResponse = await JsonSerializer.DeserializeAsync<APIPostResponseModel>(errorStream);
                    }
                    catch
                    {
                    }
                }

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
                _logger.LogError(ex.Message, new object[] { errorResponse });
                throw;
            }
        }
    }
}