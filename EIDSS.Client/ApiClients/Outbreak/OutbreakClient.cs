using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ResponseModels.Outbreak;
using System.Net.Http;
using System.Text.Json;
using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Logging;
using EIDSS.Domain.ResponseModels;
using System.Net.Http.Headers;
using System.Threading;

using System.IO;
using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ViewModels.Vector;

namespace EIDSS.ClientLibrary.ApiClients.Outbreak
{
    public partial interface IOutbreakClient
    {
        public Task<List<OutbreakSessionListViewModel>> GetSessionList(OutbreakSessionListRequestModel request);
        public Task<List<OutbreakSessionDetailsResponseModel>> GetSessionDetail(OutbreakSessionDetailRequestModel request);
        public Task<List<OutbreakSessionParametersListModel>> GetSessionParametersList(OutbreakSessionDetailRequestModel request);
        public Task<OutbreakSessionDetailsSaveResponseModel> SetSession(OutbreakSessionCreateRequestModel request);
        public Task<List<CaseGetListViewModel>> GetCasesList(OutbreakCaseListRequestModel request);
        public Task<List<VeterinaryCaseGetListViewModel>> GetVeterinaryCaseList(VeterinaryCaseSearchRequestModel request, CancellationToken cancellationToken = default);
        public Task<List<CaseGetDetailViewModel>> GetCaseDetail(string languageId, long caseId, CancellationToken cancellationToken = default);
        public Task<OutbreakCaseSaveResponseModel> SetCase(OutbreakCaseCreateRequestModel request);
        public Task<CaseQuickSaveResponseModel> QuickSaveCase(CaseQuickSaveRequestModel request);
        public Task<List<OutbreakSessionNoteListViewModel>> GetSessionNoteList(OutbreakSessionNoteListRequestModel request);
        public Task<OutbreakSessionNoteSaveResponseModel> SetSessionNote(OutbreakSessionNoteCreateRequestModel request);
        public Task<List<OutbreakSessionNoteDetailsViewModel>> GetSessionNoteDetails(OutbreakSessionNoteDetailsRequestModel request);
        public Task<APIPostResponseModel> DeleteSessionNote(OutbreakSessionNoteDeleteRequestModel request);
        public Task<List<OutbreakNoteFileResponseModel>> GetNoteFile(OutbreakNoteRequestModel request);
        public Task<List<OutbreakHeatMapResponseModel>> GetHeatMapData(OutbreakHeatMapRequestModel request);
        public Task<List<CaseMonitoringGetListViewModel>> GetCaseMonitoringList(CaseMonitoringGetListRequestModel request, CancellationToken cancellationToken = default);
        public Task<List<ContactGetListViewModel>> GetContactList(ContactGetListRequestModel request, CancellationToken cancellationToken = default);
        public Task<List<VectorGetListViewModel>> GetVectorList(VectorGetListRequestModel request, CancellationToken cancellationToken = default);
        public Task<ContactSaveResponseModel> SaveContact(ContactSaveRequestModel request);
        Task<List<OutbreakHumanCaseDetailResponseModel>> GetHumanCaseDetailAsync(OutbreakHumanCaseDetailRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class OutbreakClient : BaseApiClient, IOutbreakClient
    {
        public OutbreakClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<OutbreakClient> logger) : base(httpClient, eidssApiOptions, logger)
        {
        }

        public async Task<List<CaseGetListViewModel>> GetCasesList(OutbreakCaseListRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetOutbreakCaseListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<CaseGetListViewModel>>(contentStream,
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

        public async Task<List<VeterinaryCaseGetListViewModel>> GetVeterinaryCaseList(VeterinaryCaseSearchRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetOutbreakVeterinaryCaseListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<VeterinaryCaseGetListViewModel>>(contentStream,
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="languageId"></param>
        /// <param name="caseId"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<CaseGetDetailViewModel>> GetCaseDetail(string languageId, long caseId, CancellationToken cancellationToken = default)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetOutbreakCaseDetailPath, _eidssApiOptions.BaseUrl, languageId, caseId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url), cancellationToken);

                httpResponse.EnsureSuccessStatusCode();

                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<CaseGetDetailViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { caseId });
                throw;
            }
        }

        public async Task<List<OutbreakSessionListViewModel>> GetSessionList(OutbreakSessionListRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetOutbreakSessionListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<OutbreakSessionListViewModel>>(contentStream,
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

        public async Task<List<OutbreakSessionDetailsResponseModel>> GetSessionDetail(OutbreakSessionDetailRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetOutbreakSessionDetailsPath, _eidssApiOptions.BaseUrl, request.LanguageID, request.idfsOutbreak);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<OutbreakSessionDetailsResponseModel>>(contentStream,
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
            finally
            {
            }
        }

        public async Task<List<OutbreakSessionParametersListModel>> GetSessionParametersList(OutbreakSessionDetailRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetOutbreakSessionParametersListPath, _eidssApiOptions.BaseUrl, request.LanguageID, request.idfsOutbreak);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<OutbreakSessionParametersListModel>>(contentStream,
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
            finally
            {
            }
        }

        public async Task<OutbreakSessionDetailsSaveResponseModel> SetSession(OutbreakSessionCreateRequestModel request)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetOutbreakSessionPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<OutbreakSessionDetailsSaveResponseModel>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<OutbreakCaseSaveResponseModel> SetCase(OutbreakCaseCreateRequestModel request)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetOutbreakCasePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<OutbreakCaseSaveResponseModel>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<CaseQuickSaveResponseModel> QuickSaveCase(CaseQuickSaveRequestModel request)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.QuickSaveCasePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<CaseQuickSaveResponseModel>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<OutbreakSessionNoteListViewModel>> GetSessionNoteList(OutbreakSessionNoteListRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetOutbreakSessionNoteListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<OutbreakSessionNoteListViewModel>>(contentStream,
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

        public async Task<OutbreakSessionNoteSaveResponseModel> SetSessionNote(OutbreakSessionNoteCreateRequestModel request)
        {
            APIPostResponseModel errorResponse = null;
            try
            {
                var multipartContent = new MultipartFormDataContent();

                //add other values to the multipart content

                string strFilename = string.Empty;

                if (request.FileUpload != null)
                {
                    strFilename = request.FileUpload.FileName;
                }

                var values = new[] {
                    new KeyValuePair<string,string>("LangID",request.LangID),
                    new KeyValuePair<string,string>("idfOutbreakNote",request.idfOutbreakNote.ToString()),
                    new KeyValuePair<string,string>("idfOutbreak",request.idfOutbreak.ToString()),
                    new KeyValuePair<string,string>("strNote",request.strNote),
                    new KeyValuePair<string,string>("idfPerson",request.idfPerson.ToString()),
                    new KeyValuePair<string,string>("intRowStatus",request.intRowStatus.ToString()),
                    new KeyValuePair<string,string>("strMaintenanceFlag",request.strMaintenanceFlag),
                    new KeyValuePair<string,string>("strReservedAttribute",request.strReservedAttribute),
                    new KeyValuePair<string,string>("UpdatePriorityID",request.UpdatePriorityID.ToString()),
                    new KeyValuePair<string,string>("UpdateRecordTitle",request.UpdateRecordTitle),
                    new KeyValuePair<string,string>("UploadFileName",strFilename),
                    new KeyValuePair<string,string>("UploadFileDescription",request.UploadFileDescription),
                    new KeyValuePair<string,string>("DeleteAttachment",request.DeleteAttachment),
                    new KeyValuePair<string,string>("User",request.User)
                };

                foreach (var val in values)
                {
                    if (val.Value != null)
                    {
                        multipartContent.Add(new StringContent(val.Value), val.Key);
                    }
                }

                //add file content to the multipart content
                if (request.FileUpload != null)
                {
                    byte[] bytes = new byte[request.FileUpload.Length];
                    using (var fileStream = request.FileUpload.OpenReadStream())
                    {
                        fileStream.Read(bytes, 0, (int)request.FileUpload.Length);
                    }
                    var byteArrayContent = new ByteArrayContent(bytes);

                    byteArrayContent.Headers.ContentType = new MediaTypeHeaderValue(request.FileUpload.ContentType);
                    byteArrayContent.Headers.ContentDisposition = new ContentDispositionHeaderValue("form-data")
                    {
                        Name = "FileUpload",
                        FileName = request.FileUpload.FileName
                    };

                    multipartContent.Add(byteArrayContent, "FileUpload", request.FileUpload.FileName);
                }

                var url = string.Format(_eidssApiOptions.SetOutbreakSessionNotePath, _eidssApiOptions.BaseUrl);

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

                return await JsonSerializer.DeserializeAsync<OutbreakSessionNoteSaveResponseModel>(contentStream,
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

        public async Task<List<OutbreakSessionNoteDetailsViewModel>> GetSessionNoteDetails(OutbreakSessionNoteDetailsRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetOutbreakSessionNoteDetailsPath, _eidssApiOptions.BaseUrl, request.LangID, request.idfOutbreakNote);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<OutbreakSessionNoteDetailsViewModel>>(contentStream,
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
            finally
            {
            }
        }

        public async Task<APIPostResponseModel> DeleteSessionNote(OutbreakSessionNoteDeleteRequestModel request)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteOutbreakSessionNoteDeletePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

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
                _logger.LogError(ex.Message, new object[] { request });
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        public async Task<List<OutbreakNoteFileResponseModel>> GetNoteFile(OutbreakNoteRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetOutbreakNoteFilePath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<OutbreakNoteFileResponseModel>>(contentStream,
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

            throw new NotImplementedException();

        }

        public async Task<List<OutbreakHeatMapResponseModel>> GetHeatMapData(OutbreakHeatMapRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetOutbreakHeatMapDataPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<OutbreakHeatMapResponseModel>>(contentStream,
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

        /// <summary>
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<CaseMonitoringGetListViewModel>> GetCaseMonitoringList(CaseMonitoringGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetOutbreakCaseMonitoringListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<CaseMonitoringGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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

        /// <summary>
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<ContactGetListViewModel>> GetContactList(ContactGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetOutbreakContactListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<ContactGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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

        public async Task<ContactSaveResponseModel> SaveContact(ContactSaveRequestModel request)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveOutbreakContactPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<ContactSaveResponseModel>(contentStream,
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
                throw new NotImplementedException();
            }
            finally
            {
            }
        }

        /// <summary>
        /// </summary>
        /// <param name="request"></param>
        /// <param name="cancellationToken"></param>
        /// <returns></returns>
        public async Task<List<VectorGetListViewModel>> GetVectorList(VectorGetListRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetOutbreakVectorListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);
                return await JsonSerializer.DeserializeAsync<List<VectorGetListViewModel>>(contentStream, new JsonSerializerOptions
                {
                    IgnoreNullValues = true,
                    PropertyNameCaseInsensitive = true
                }, cancellationToken);
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
        
        public async Task<List<OutbreakHumanCaseDetailResponseModel>> GetHumanCaseDetailAsync(OutbreakHumanCaseDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            using (MemoryStream ms = new MemoryStream())
            {
                var url = string.Format(_eidssApiOptions.OutbreakHumanCaseDetailAsyncPath, _eidssApiOptions.BaseUrl);
                var aj = new MediaTypeWithQualityHeaderValue("application/json");

                await JsonSerializer.SerializeAsync(ms, request);
                ms.Seek(0, SeekOrigin.Begin);

                var requestmessage = new HttpRequestMessage(HttpMethod.Post, url);
                requestmessage.Headers.Accept.Add(aj);

                using (var requestContent = new StreamContent(ms))
                {
                    requestmessage.Content = requestContent;
                    requestContent.Headers.ContentType = aj;
                    using (var response = await _httpClient.SendAsync(requestmessage, HttpCompletionOption.ResponseHeadersRead))
                    {
                        response.EnsureSuccessStatusCode();
                        var content = await response.Content.ReadAsStreamAsync();
                        return await JsonSerializer.DeserializeAsync<List<OutbreakHumanCaseDetailResponseModel>>(content, SerializationOptions);
                    }
                }
            }
        }
    }
}
