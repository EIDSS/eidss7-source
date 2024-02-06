using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Common;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using System.Linq;
using EIDSS.Domain.RequestModels.Administration.Security;

namespace EIDSS.ClientLibrary.ApiClients.CrossCutting
{
    public partial interface ICrossCuttingClient
    {
        Task<List<ActorGetListViewModel>> GetActorList(ActorGetRequestModel request);

        Task<List<ObjectAccessGetListViewModel>> GetObjectAccessList(ObjectAccessGetRequestModel request);

        Task<APIPostResponseModel> SaveObjectAccess(ObjectAccessSaveRequestModel request);

        Task<List<FilteredDiseaseGetListViewModel>> GetFilteredDiseaseList(FilteredDiseaseRequestModel request);

        Task<List<DepartmentGetListViewModel>> GetDepartmentList(DepartmentGetRequestModel request);

        Task<List<BaseReferenceTypeListViewModel>> GetReferenceTypes(string langId);

        Task<List<ReportLanguageModel>> GetReportLanguageList(string langId);

        Task<List<ReportYearModel>> GetReportYearList();

        Task<List<ReportMonthNameModel>> GetReportMonthNameList(string languageId);

        Task<List<GISLocationModel>> GetGisLocation(string languageId, int? level, string parentNode = null);

        Task<List<GisLocationChildLevelModel>> GetGisLocationChildLevel(string languageId, string parentIdfsReferenceId);

        Task<List<GisLocationCurrentLevelModel>> GetGisLocationCurrentLevel(string languageId, int level, bool allCountries);

        Task<List<GisLocationLevelModel>> GetGisLocationLevels(string languageId);

        Task<List<BaseReferenceViewModel>> GetBaseReferenceList(string langId, string referenceTypeName, long? intHACode);

        Task<List<BaseReferenceEditorsViewModel>> GetBaseReferenceList(BaseReferenceEditorGetRequestModel request);

        Task<List<BaseReferenceEditorsViewModel>> GetBaseReferenceLookupList(BaseReferenceEditorGetRequestModel request);

        Task<List<BaseReferenceTypeListViewModel>> GetReferenceTypesByName(ReferenceTypeRquestModel request);

        Task<List<BaseReferenceTypeListViewModel>> GetReferenceTypesByIdPaged(ReferenceTypeByIdRequestModel request);

        Task<List<CountryModel>> GetCountryList(string languageId);

        Task<List<StreetModel>> GetStreetList(long locationId);

        Task<List<PostalCodeViewModel>> GetPostalCodeList(long settlementId);

        Task<List<SettlementViewModel>> GetSettlementList(string languageId, long? parentAdminLevelId, long? id);

        Task<ReportAuditSaveResponseModel> SaveReportAudit(ReportAuditSaveRequestModel speciesTypeModel);

        Task<List<HACodeListViewModel>> GetHACodeList(string langId, int? intHACodeMask);

        Task<List<MatrixVersionViewModel>> GetMatrixVersionsByType(long matrixType);

        Task<List<SpeciesViewModel>> GetSpeciesListAsync(long idfsBaseReference, int intHACode, string languageId);

        Task<List<VeterinaryDiseaseMatrixListViewModel>> GetVeterinaryDiseaseMatrixListAsync(long idfsBaseReference, int intHACode, string languageId);

        Task<APISaveResponseModel> SaveMatrixVersion(HumanAggregateCaseMatrixRequestModel saveRequestModel);

        Task<List<UserGroupGetListViewModel>> GetUserGroupList(string languageId, long? idfsSite);

        Task<APIPostResponseModel> SaveDepartment(DepartmentSaveRequestModel request);

        Task<APIPostResponseModel> SaveStreet(StreetSaveRequestModel request);

        Task<APIPostResponseModel> SavePostalCode(PostalCodeSaveRequestModel request);

        Task<APIPostResponseModel> SaveSystemFunctions(SystemFunctionsSaveRequestModel request);

        Task<List<EmployeeLookupGetListViewModel>> GetEmployeeLookupList(EmployeeLookupGetRequestModel request);

        Task<List<SystemFunctionPermissionsViewModel>> GetUserGroupUserSystemFunctionPermissions(string userIds, string langId);

        Task<List<SystemFunctionsViewModel>> GetSystemFunctionPermissions(string langId, long? systemFunctionId);

        Task<List<BaseReferenceAdvancedListResponseModel>> GetBaseReferenceAdvanceList(BaseReferenceAdvancedListRequestModel request);

        Task<List<AccessRulesAndPermissions>> GetAccessRulesAndPermissions(long userId);

        Task<List<DiseaseGetListPagedResponseModel>> GetDiseasesByIdsPaged(DiseaseGetListPagedRequestModel request);

        Task<List<DiseaseTestGetListViewModel>> GetDiseaseTestList(DiseaseTestGetRequestModel request);

        Task<List<XSiteDocumentListViewModel>> GetPageDocuments(long eidssMenuId, string languageId);

        Task<List<ActiveSurveillanceCampaignListViewModel>> GetActiveSurveillanceCampaignListAsync(ActiveSurveillanceCampaignRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceCampaignDetailViewModel>> GetActiveSurveillanceCampaignGetDetailAsync(ActiveSurveillanceCampaignDetailRequestModel request, CancellationToken cancellationToken = default);

        Task<List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel>> GetActiveSurveillanceCampaignDiseaseSpeciesSamplesListAsync(ActiveSurveillanceCampaignDiseaseSpeciesSamplesGetRequestModel request, CancellationToken cancellationToken = default);

        Task<ActiveSurveillanceCampaignSaveResponseModel> SaveActiveSurveillanceCampaignAsync(ActiveSurveillanceCampaignSaveRequestModel request, CancellationToken cancellationToken = default);

        Task<APIPostResponseModel> DeleteActiveSurveillanceCampaign(string LanguageID, long CampaignID, string userName, CancellationToken cancellationToken = default);

        Task<APIPostResponseModel> DisassociateSessionFromCampaignAsync(DisassociateSessionFromCampaignSaveRequestModel request, CancellationToken cancellationToken = default);

        Task<List<BaseReferenceTranslationResponseModel>> GetBaseReferenceTranslation(BaseReferenceTranslationRequestModel request, CancellationToken cancellationToken = default);

        Task<List<SiteModel>> GetGblSiteList(SiteGblGetRequestModel request, CancellationToken cancellationToken = default);

        Task<List<UserModel>> GetGblUserList(UserGetRequestModel request, CancellationToken cancellationToken = default);
    }

    public partial class CrossCuttingClient : BaseApiClient, ICrossCuttingClient
    {
        public CrossCuttingClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, ILogger<CrossCuttingClient> logger)
            :
            base(httpClient, eidssApiOptions, logger)
        {
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<ActorGetListViewModel>> GetActorList(ActorGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetActorListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<ActorGetListViewModel>>(contentStream, SerializationOptions);
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
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<ObjectAccessGetListViewModel>> GetObjectAccessList(ObjectAccessGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetObjectAccessListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<ObjectAccessGetListViewModel>>(contentStream, SerializationOptions);
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
        /// Saves access permissions for disease records.
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<APIPostResponseModel> SaveObjectAccess(ObjectAccessSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveObjectAccessPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream, SerializationOptions);
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
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<FilteredDiseaseGetListViewModel>> GetFilteredDiseaseList(FilteredDiseaseRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetFilteredDiseaseListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<FilteredDiseaseGetListViewModel>>(contentStream, SerializationOptions);
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
        /// Returns Filetered and Paged List of Diseases
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<DiseaseGetListPagedResponseModel>> GetDiseasesByIdsPaged(DiseaseGetListPagedRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.DiseaseGetListPagedRequestModelPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<DiseaseGetListPagedResponseModel>>(contentStream, SerializationOptions);
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
        /// Returns filtered list of tests by disease
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<DiseaseTestGetListViewModel>> GetDiseaseTestList(DiseaseTestGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                string url = string.Format(_eidssApiOptions.GetDiseaseTestListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<DiseaseTestGetListViewModel>>(contentStream, SerializationOptions);
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

        public async Task<List<DepartmentGetListViewModel>> GetDepartmentList(DepartmentGetRequestModel request)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            string url = string.Format(_eidssApiOptions.GetDepartmentListPath, _eidssApiOptions.BaseUrl);
            var httpResponse = await _httpClient.PostAsync(url, requestJson);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<DepartmentGetListViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<APIPostResponseModel> SaveDepartment(DepartmentSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveDepartmentPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
                SerializationOptions);
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

        public async Task<APIPostResponseModel> SaveSystemFunctions(SystemFunctionsSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveSystemFunctionsPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream, SerializationOptions);
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

        public async Task<List<UserGroupGetListViewModel>> GetUserGroupList(string langId, long? idfsSite)
        {
            var url = string.Format(_eidssApiOptions.GetUserGroupGetListPath, _eidssApiOptions.BaseUrl, langId, idfsSite);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<UserGroupGetListViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<BaseReferenceTypeListViewModel>> GetReferenceTypes(string langId)
        {
            var url = string.Format(_eidssApiOptions.GetBaseReferenceTypeListPath, _eidssApiOptions.BaseUrl, langId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<BaseReferenceTypeListViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<BaseReferenceTypeListViewModel>> GetReferenceTypesByName(ReferenceTypeRquestModel request)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.GetBaseReferenceTypesByNamePath, _eidssApiOptions.BaseUrl);
            var httpResponse = await _httpClient.PostAsync(new Uri(url), requestJson).ConfigureAwait(false);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<BaseReferenceTypeListViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<BaseReferenceTypeListViewModel>> GetReferenceTypesByIdPaged(ReferenceTypeByIdRequestModel request)
        {
            var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var url = string.Format(_eidssApiOptions.GetBaseReferenceTypesByIdPagedPath, _eidssApiOptions.BaseUrl);
            var httpResponse = await _httpClient.PostAsync(new Uri(url), requestJson).ConfigureAwait(false);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<BaseReferenceTypeListViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<ReportLanguageModel>> GetReportLanguageList(string languageId)
        {
            var url = string.Format(_eidssApiOptions.GetReportLanuageListPath, _eidssApiOptions.BaseUrl, languageId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<ReportLanguageModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<ReportYearModel>> GetReportYearList()
        {
            var url = string.Format(_eidssApiOptions.GetReportYearListPath, _eidssApiOptions.BaseUrl);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<ReportYearModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<ReportMonthNameModel>> GetReportMonthNameList(string languageId)
        {
            var url = string.Format(_eidssApiOptions.GetReportMonthNameListPath, _eidssApiOptions.BaseUrl, languageId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<ReportMonthNameModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<GISLocationModel>> GetGisLocation(string languageId, int? level, string parentNode = null)
        {
            var url = string.Format(_eidssApiOptions.GetGisLocationPath, _eidssApiOptions.BaseUrl, languageId, level, parentNode);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<GISLocationModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<BaseReferenceViewModel>> GetBaseReferenceList(string langId, string referenceTypeName, long? intHACode)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetBaseReferenceListCrossCuttingPath, _eidssApiOptions.BaseUrl, langId, referenceTypeName, intHACode);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<BaseReferenceViewModel>>(contentStream, SerializationOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { referenceTypeName, intHACode });
                throw;
            }
        }

        public async Task<List<BaseReferenceEditorsViewModel>> GetBaseReferenceList(BaseReferenceEditorGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetBaseReferenceListByIDCrossCuttingPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(new Uri(url), requestJson).ConfigureAwait(false);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<BaseReferenceEditorsViewModel>>(contentStream, SerializationOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<List<BaseReferenceEditorsViewModel>> GetBaseReferenceLookupList(BaseReferenceEditorGetRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetBaseReferenceLookupListPath, _eidssApiOptions.BaseUrl);
                var httpResponse = await _httpClient.PostAsync(new Uri(url), requestJson).ConfigureAwait(false);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<BaseReferenceEditorsViewModel>>(contentStream, SerializationOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw;
            }
        }

        public async Task<List<GisLocationCurrentLevelModel>> GetGisLocationCurrentLevel(string languageId, int level, bool allCountries = false)
        {
            var url = string.Format(_eidssApiOptions.GetGisLocationCurrentPath, _eidssApiOptions.BaseUrl, languageId, level, allCountries);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<GisLocationCurrentLevelModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<GisLocationChildLevelModel>> GetGisLocationChildLevel(string languageId, string parentIdfsRefereneId)
        {
            var url = string.Format(_eidssApiOptions.GetGisLocationChildPath, _eidssApiOptions.BaseUrl, languageId, parentIdfsRefereneId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<GisLocationChildLevelModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<CountryModel>> GetCountryList(string languageId)
        {
            var url = string.Format(_eidssApiOptions.GetCountryListPath, _eidssApiOptions.BaseUrl, languageId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<CountryModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<GisLocationLevelModel>> GetGisLocationLevels(string languageId)
        {
            var url = string.Format(_eidssApiOptions.GetGisLocationLevelsPath, _eidssApiOptions.BaseUrl, languageId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<GisLocationLevelModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<StreetModel>> GetStreetList(long locationId)
        {
            var url = string.Format(_eidssApiOptions.GetStreetListPath, _eidssApiOptions.BaseUrl, locationId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<StreetModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<PostalCodeViewModel>> GetPostalCodeList(long settlementId)
        {
            var url = string.Format(_eidssApiOptions.GetPostalCodeListPath, _eidssApiOptions.BaseUrl, settlementId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<PostalCodeViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<SettlementViewModel>> GetSettlementList(string languageId, long? parentAdminLevelId, long? id)
        {
            var url = string.Format(_eidssApiOptions.GetSettlementListPath, _eidssApiOptions.BaseUrl, languageId, parentAdminLevelId, id);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<SettlementViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<HACodeListViewModel>> GetHACodeList(string langId, int? intHACodeMask)
        {
            var url = string.Format(_eidssApiOptions.GetHACodeListPath, _eidssApiOptions.BaseUrl, langId, intHACodeMask);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<HACodeListViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<ReportAuditSaveResponseModel> SaveReportAudit(ReportAuditSaveRequestModel reportAuditSaveRequestViewModel)
        {
            ReportAuditSaveResponseModel errorResponse;

            try
            {
                var reportAuditSaveJson = new StringContent(JsonSerializer.Serialize(reportAuditSaveRequestViewModel), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveReportAuditPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, reportAuditSaveJson).ConfigureAwait(false);

                if (!httpResponse.IsSuccessStatusCode)
                {
                    try
                    {
                        var errorStream = await httpResponse.Content.ReadAsStreamAsync();
                        errorResponse = await JsonSerializer.DeserializeAsync<ReportAuditSaveResponseModel>(errorStream);
                    }
                    catch
                    {
                    }
                }

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ReportAuditSaveResponseModel>(contentStream, SerializationOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { reportAuditSaveRequestViewModel });
                throw;
            }
        }

        public async Task<List<MatrixVersionViewModel>> GetMatrixVersionsByType(long matrixType)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetMatrixVersionsByTypePath, _eidssApiOptions.BaseUrl, matrixType);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<List<MatrixVersionViewModel>>(contentStream, SerializationOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { matrixType });
                throw;
            }
        }

        public async Task<List<SpeciesViewModel>> GetSpeciesListAsync(long idfsBaseReference, int intHACode, string languageId)
        {
            var url = string.Format(_eidssApiOptions.GetSpeciesListAsyncPath, _eidssApiOptions.BaseUrl, idfsBaseReference, intHACode, languageId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await System.Text.Json.JsonSerializer.DeserializeAsync<List<SpeciesViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<VeterinaryDiseaseMatrixListViewModel>> GetVeterinaryDiseaseMatrixListAsync(long idfsBaseReference, int intHACode, string languageId)
        {
            var url = string.Format(_eidssApiOptions.GetVeterinaryDiseaseMatrixListAsyncPath, _eidssApiOptions.BaseUrl, idfsBaseReference, intHACode, languageId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await System.Text.Json.JsonSerializer.DeserializeAsync<List<VeterinaryDiseaseMatrixListViewModel>>(contentStream,
            SerializationOptions);
        }

        public async Task<APISaveResponseModel> SaveMatrixVersion(HumanAggregateCaseMatrixRequestModel saveRequestModel)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.SaveMatrixVersionPath, _eidssApiOptions.BaseUrl);
                var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(saveRequestModel), Encoding.UTF8, "application/json");
                var httpResponse = await _httpClient.PostAsync(url, stringContent);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await System.Text.Json.JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream, SerializationOptions);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { saveRequestModel });
                throw;
            }
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<List<EmployeeLookupGetListViewModel>> GetEmployeeLookupList(EmployeeLookupGetRequestModel request)
        {
            var url = string.Format(_eidssApiOptions.GetEmployeeLookupListPath, _eidssApiOptions.BaseUrl);
            var stringContent = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var httpResponse = await _httpClient.PostAsync(url, stringContent);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<EmployeeLookupGetListViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<SystemFunctionPermissionsViewModel>> GetUserGroupUserSystemFunctionPermissions(string userIds, string langId)
        {
            var url = string.Format(_eidssApiOptions.GetEmployeeAndEmployeeGroupSystemFunctionsPermissionsListPath, _eidssApiOptions.BaseUrl, userIds, langId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<SystemFunctionPermissionsViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<SystemFunctionsViewModel>> GetSystemFunctionPermissions(string langId, long? systemFunctiId)
        {
            var url = string.Format(_eidssApiOptions.GetSystemFunctionsPermissionsListPath, _eidssApiOptions.BaseUrl, langId, systemFunctiId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<SystemFunctionsViewModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<BaseReferenceAdvancedListResponseModel>> GetBaseReferenceAdvanceList(BaseReferenceAdvancedListRequestModel request)
        {
            var url = string.Format(_eidssApiOptions.BaseReferenceAdvancedListPath, _eidssApiOptions.BaseUrl);
            var stringContent = new StringContent(System.Text.Json.JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
            var httpResponse = await _httpClient.PostAsync(url, stringContent);

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await JsonSerializer.DeserializeAsync<List<BaseReferenceAdvancedListResponseModel>>(contentStream, SerializationOptions);
        }

        public async Task<List<AccessRulesAndPermissions>> GetAccessRulesAndPermissions(long userId)
        {
            var url = string.Format(_eidssApiOptions.GetAccessRulesAndPermissionsPath, _eidssApiOptions.BaseUrl, userId);
            var httpResponse = await _httpClient.GetAsync(new Uri(url));

            httpResponse.EnsureSuccessStatusCode();
            var contentStream = await httpResponse.Content.ReadAsStreamAsync();

            return await System.Text.Json.JsonSerializer.DeserializeAsync<List<AccessRulesAndPermissions>>(contentStream, SerializationOptions);
        }

        public async Task<APIPostResponseModel> SaveStreet(StreetSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SaveStreetPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
                SerializationOptions);
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

        public async Task<APIPostResponseModel> SavePostalCode(PostalCodeSaveRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SavePostalCodePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
                SerializationOptions);
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

        public async Task<List<ActiveSurveillanceCampaignListViewModel>> GetActiveSurveillanceCampaignListAsync(ActiveSurveillanceCampaignRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.ActiveSurveillanceCampaignPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceCampaignListViewModel>>(contentStream,
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

        public async Task<List<ActiveSurveillanceCampaignDetailViewModel>> GetActiveSurveillanceCampaignGetDetailAsync(ActiveSurveillanceCampaignDetailRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.ActiveSurveillanceCampaignDetailPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceCampaignDetailViewModel>>(contentStream,
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

        public async Task<List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel>> GetActiveSurveillanceCampaignDiseaseSpeciesSamplesListAsync(ActiveSurveillanceCampaignDiseaseSpeciesSamplesGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.ActiveSurveillanceCampaignDiseaseSpeciesSamplesListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<ActiveSurveillanceCampaignDiseaseSpeciesSamplesViewModel>>(contentStream,
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

        public async Task<ActiveSurveillanceCampaignSaveResponseModel> SaveActiveSurveillanceCampaignAsync(ActiveSurveillanceCampaignSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.ActiveSurveillanceCampaignSavePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<ActiveSurveillanceCampaignSaveResponseModel>(contentStream,
                SerializationOptions);
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

        public async Task<APIPostResponseModel> DeleteActiveSurveillanceCampaign(string LanguageID, long CampaignID, string userName, CancellationToken cancellationToken = default)
        {
            var url = string.Format(_eidssApiOptions.ActiveSurveillanceCampaignDeletePath, _eidssApiOptions.BaseUrl, LanguageID, CampaignID,userName);
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

        public async Task<APIPostResponseModel> DisassociateSessionFromCampaignAsync(DisassociateSessionFromCampaignSaveRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DisassociateSessionFromCampaignPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<APIPostResponseModel>(contentStream,
                SerializationOptions);
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
        /// Retrieves a list of help documents given the menu identifier.
        /// </summary>
        /// <returns></returns>
        public async Task<List<XSiteDocumentListViewModel>> GetPageDocuments(long eidssMenuId, string languageId)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetXSiteDocumentList, _eidssApiOptions.BaseUrl, languageId);
                var httpResponse = await _httpClient.GetAsync(new Uri(url), HttpCompletionOption.ResponseHeadersRead);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var docList = await JsonSerializer.DeserializeAsync<List<XSiteDocumentListViewModel>>(contentStream, SerializationOptions);

                // only return the documents for this MenuId
                var result = docList.Where(w => w.EIDSSMenuID == eidssMenuId).ToList();

                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
                throw;
            }
        }

        public async Task<List<BaseReferenceTranslationResponseModel>> GetBaseReferenceTranslation(BaseReferenceTranslationRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.BaseReferenceTranslationPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                return await JsonSerializer.DeserializeAsync<List<BaseReferenceTranslationResponseModel>>(contentStream,
                SerializationOptions);
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

        public async Task<List<SiteModel>> GetGblSiteList(SiteGblGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetGblSiteListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<SiteModel>>(contentStream,
                    SerializationOptions, cancellationToken);
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

        public async Task<List<UserModel>> GetGblUserList(UserGetRequestModel request, CancellationToken cancellationToken = default)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetGblUserListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson, cancellationToken);
                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync(cancellationToken);

                return await JsonSerializer.DeserializeAsync<List<UserModel>>(contentStream,
                    SerializationOptions, cancellationToken);
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