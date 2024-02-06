using EIDSS.ClientLibrary.ApiAbstracts;
using EIDSS.ClientLibrary.Configurations;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.FlexForm;
using EIDSS.Domain.ViewModels.FlexForm;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

using System.Threading;
using System.IO;
using System.Net.Http.Headers;


namespace EIDSS.ClientLibrary.ApiClients.FlexForm
{
    using static EIDSS.ClientLibrary.Enumerations.EIDSSConstants;

    public partial interface IFlexFormClient
    {
        Task<List<FlexFormFormTypesListViewModel>> GetFormTypesList(FlexFormFormTypesGetRequestModel request);
        Task<List<FlexFormParametersListViewModel>> GetParametersList(FlexFormParametersGetRequestModel request);
        Task<List<FlexFormSectionsListViewModel>> GetSectionsList(FlexFormSectionsGetRequestModel request);
        Task<List<FlexFormTemplateListViewModel>> GetTemplateList(FlexFormTemplateGetRequestModel request);
        Task<List<FlexFormSectionParameterListViewModel>> GetSectionParameterList(FlexFormSectionParameterGetRequestModel request);
        Task<List<FlexFormTemplateDeterminantValuesListViewModel>> GetTemplateDeterminantValues(FlexFormTemplateDeterminantValuesGetRequestModel request);
        Task<List<FlexFormTemplateDetailViewModel>> GetTemplateDetails(FlexFormTemplateDetailsGetRequestModel request);
        Task<List<FlexFormTemplateDesignListViewModel>> GetTemplateDesignList(FlexFormTemplateDesignGetRequestModel request);
        Task<FlexFormParametersSaveResponseModel> SetParameter(FlexFormParametersSaveRequestModel request);
        Task<APISaveResponseModel> SetSection(FlexFormSectionSaveRequestModel request);
        Task<FlexFormParameterTemplateSaveResponseModel> SetTemplate(FlexFormTemplateSaveRequestModel request);
        Task<APISaveResponseModel> SetTemplateParameter(FlexFormParameterTemplateSaveRequestModel request);
        Task<APIPostResponseModel> CopySection(FlexFormSectionCopyRequestModel request);
        Task<APIPostResponseModel> CopyParameter(FlexFormParameterCopyRequestModel request);
        Task<FlexFormDeleteTemplateParameterResponseModel> DeleteTemplateParameter(FlexFormParameterTemplateDeleteRequestModel request);
        Task<APIPostResponseModel> DeleteSection(FlexFormSectionDeleteRequestModel request);
        Task<List<FlexFormParameterDetailViewModel>> GetParameterDetails(FlexFormParameterDetailsGetRequestModel request);
        Task<List<FlexFormTemplateByParameterListModel>> GetTemplatesByParameterList(FlexFormTemplateByParameterGetRequestModel request);
        Task<List<FlexFormDeleteParameterResponseModel>> DeleteParameter(FlexFormParameterDeleteRequestModel request);
        Task<APIPostResponseModel> SetRequiredParameter(FlexFormRequiredParameterSaveRequestModel request);
        Task<APIPostResponseModel> SetTemplateParameterOrder(FlexFormTemplateParameterOrderRequestModel request);
        Task<APIPostResponseModel> SetTemplateSectionOrder(FlexFormTemplateSectionOrderRequestModel request);
        Task<List<FlexFormParameterInUseDetailViewModel>> IsParameterInUse(FlexFormParameterInUseRequestModel request);
        Task<APISaveResponseModel> SetDeterminant(FlexFormDeterminantSaveRequestModel request);
        Task<List<FlexFormRulesListViewModel>> GetRulesList(FlexFormRulesGetRequestModel request);
        Task<APISaveResponseModel> SetRule(FlexFormRuleSaveRequestModel request);
        Task<FlexFormCopyTemplateResponseModel> CopyTemplate(FlexFormCopyTemplateRequestModel request);
        Task<List<FlexFormRuleDetailsViewModel>> GetRuleDetails(FlexFormRuleDetailsGetRequestModel request);
        Task<List<FlexFormSectionParameterListViewModel>> GetSectionsParametersList(FlexFormSectionsParametersRequestModel request);
        Task<APIPostResponseModel> DeleteTemplate(FlexFormTemplateDeleteRequestModel request);
        Task<List<FlexFormDiagnosisReferenceListViewModel>> GetDiseaseList(FlexFormDiseaseGetListRequestModel request);
        Task<List<FlexFormQuestionnaireResponseModel>> GetQuestionnaire(FlexFormQuestionnaireGetRequestModel request);
        Task<List<FlexFormActivityParametersListResponseModel>> GetAnswers(FlexFormActivityParametersGetRequestModel request);
        Task<List<FlexFormParameterSelectListResponseModel>> GetDropDownOptionsList(FlexFormParameterSelectListGetRequestModel request);
        Task<FlexFormActivityParametersResponseModel> SaveAnswers(FlexFormActivityParametersSaveRequestModel request);
        Task<APIPostResponseModel> SetOutbreakFlexForm(FlexFormAddToOutbreakSaveRequestModel request);
        Task<List<FlexFormFormTemplateResponeModel>> GetFormTemplate(FlexFormFormTemplateRequestModel request);
        Task<List<FlexFormParameterTypeEditorMappingResponseModel>> GetParameterTypeEditorMapping(FlexFormParameterTypeEditorMappingRequestModel request);
        Task<List<FlexFormRuleListResponseModel>> GetFlexFormRuleList(FlexFormRuleListGetRequestModel request);
        Task<List<FlexFormRuleActionsResponseModel>> GetFlexFormRuleActionsList(FlexFormRuleActionsRequestModel request);
    }

    public partial class FlexFormClient : BaseApiClient, IFlexFormClient
    {
        protected internal EidssApiConfigurationOptions _eidssApiConfigurationOptions;

        public FlexFormClient(HttpClient httpClient, IOptionsSnapshot<EidssApiOptions> eidssApiOptions, IOptionsSnapshot<EidssApiConfigurationOptions> eidssApiConfigurationOptions,
            ILogger<FlexFormClient> logger): base(httpClient, eidssApiOptions, logger)
        {
            _eidssApiConfigurationOptions = eidssApiConfigurationOptions.Value;
        }

        public async Task<List<FlexFormFormTypesListViewModel>> GetFormTypesList(FlexFormFormTypesGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFlexFormTypesListPath, _eidssApiOptions.BaseUrl, request.LanguageId ?? CultureNames.enUS, request.idfsFormType);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormFormTypesListViewModel>>(contentStream,
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

        public async Task<List<FlexFormParametersListViewModel>> GetParametersList(FlexFormParametersGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFlexFormParametersListPath, _eidssApiOptions.BaseUrl, request.LanguageId ?? CultureNames.enUS, request.idfsSection, request.idfsFormType, request.SectionIDs);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormParametersListViewModel>>(contentStream,
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

        public async Task<List<FlexFormSectionsListViewModel>> GetSectionsList(FlexFormSectionsGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFlexFormSectionsListPath, _eidssApiOptions.BaseUrl, request.LanguageId, request.idfsFormType, request.idfsSection, request.idfsParentSection);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormSectionsListViewModel>>(contentStream,
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

        public async Task<List<FlexFormSectionParameterListViewModel>> GetSectionParameterList(FlexFormSectionParameterGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFlexFormSectionParameterListPath, _eidssApiOptions.BaseUrl, request.LanguageId, request.idfsSection, request.idfsFormType, request.parameterFilter, request.sectionFilter);
                
                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormSectionParameterListViewModel>>(contentStream,
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

        public async Task<List<FlexFormTemplateListViewModel>> GetTemplateList(FlexFormTemplateGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFlexFormTemplateListPath, _eidssApiOptions.BaseUrl, request.LanguageId, request.idfsFormTemplate, request.idfsFormType, request.idfOutbreak);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormTemplateListViewModel>>(contentStream,
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

        public async Task<List<FlexFormTemplateDeterminantValuesListViewModel>> GetTemplateDeterminantValues(FlexFormTemplateDeterminantValuesGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFlexFormTemplateDeterminantValuesListPath, _eidssApiOptions.BaseUrl, request.LanguageId ?? CultureNames.enUS, request.idfsFormTemplate);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormTemplateDeterminantValuesListViewModel>>(contentStream,
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

        public async Task<List<FlexFormTemplateDetailViewModel>> GetTemplateDetails(FlexFormTemplateDetailsGetRequestModel request)
        {
            try
            {
                var getParameterJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetFlexFormTemplateDetailPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getParameterJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormTemplateDetailViewModel>>(contentStream,
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

        public async Task<List<FlexFormTemplateDesignListViewModel>> GetTemplateDesignList(FlexFormTemplateDesignGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFlexFormTemplateDesignListPath, _eidssApiOptions.BaseUrl, request.LanguageId, request.idfsFormTemplate, request.User);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormTemplateDesignListViewModel>>(contentStream,
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

        public async Task<FlexFormParametersSaveResponseModel> SetParameter(FlexFormParametersSaveRequestModel request)
        {
            try
            {
                var setParameterJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormParameterPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setParameterJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<FlexFormParametersSaveResponseModel>(contentStream,
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

        public async Task<APISaveResponseModel> SetSection(FlexFormSectionSaveRequestModel request)
        {
            try
            {
                var setSectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormSectionPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setSectionJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
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
        public async Task<FlexFormParameterTemplateSaveResponseModel> SetTemplate(FlexFormTemplateSaveRequestModel request)
        {
            try
            {
                var setTemplateJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormTemplatePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setTemplateJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<FlexFormParameterTemplateSaveResponseModel>(contentStream,
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

        public async Task<APISaveResponseModel> SetTemplateParameter(FlexFormParameterTemplateSaveRequestModel request)
        {
            try
            {
                var setTemplateParameterJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormTemplateParameterPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setTemplateParameterJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
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

        public async Task<APIPostResponseModel> CopySection(FlexFormSectionCopyRequestModel request)
        {
            try
            {
                var copySectionJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.CopyFlexFormSectionPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, copySectionJson);

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

        public async Task<APIPostResponseModel> CopyParameter(FlexFormParameterCopyRequestModel request)
        {
            try
            {
                var copyParameterJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.CopyFlexFormParameterPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, copyParameterJson);

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

        public async Task<FlexFormDeleteTemplateParameterResponseModel> DeleteTemplateParameter(FlexFormParameterTemplateDeleteRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteFlexFormTemplateParameterPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<FlexFormDeleteTemplateParameterResponseModel>(contentStream,
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

        public async Task<APIPostResponseModel> DeleteSection(FlexFormSectionDeleteRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteFlexFormSectionPath, _eidssApiOptions.BaseUrl, request.idfsSection);
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
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, new object[] { request });
                throw new NotImplementedException();
            }
            finally
            {

            }
        }

        public async Task<List<FlexFormParameterDetailViewModel>> GetParameterDetails(FlexFormParameterDetailsGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFlexFormParameterDetailPath, _eidssApiOptions.BaseUrl, request.LanguageId ?? CultureNames.enUS, request.idfsParameter);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormParameterDetailViewModel>>(contentStream,
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

        public async Task<List<FlexFormTemplateByParameterListModel>> GetTemplatesByParameterList(FlexFormTemplateByParameterGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFlexFormTemplatesByParameterListPath, _eidssApiOptions.BaseUrl, request.LanguageId ?? CultureNames.enUS, request.idfsParameter);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormTemplateByParameterListModel>>(contentStream,
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

        public async Task<List<FlexFormDeleteParameterResponseModel>> DeleteParameter(FlexFormParameterDeleteRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.DeleteFlexFormParameterPath, _eidssApiOptions.BaseUrl, request.LangId, request.idfsParameter, request.User);
                var httpResponse = await _httpClient.GetAsync(new Uri(url));

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormDeleteParameterResponseModel>>(contentStream,
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

        public async Task<APIPostResponseModel> SetRequiredParameter(FlexFormRequiredParameterSaveRequestModel request)
        {
            try
            {
                var setParameterJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormRequiredParameterPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setParameterJson);

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

        public async Task<APIPostResponseModel> SetTemplateParameterOrder(FlexFormTemplateParameterOrderRequestModel request)
        {
            try
            {
                var setParameterJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormTemplateParameterOrderPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setParameterJson);

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

        public async Task<APIPostResponseModel> SetTemplateSectionOrder(FlexFormTemplateSectionOrderRequestModel request)
        {
            try
            {
                var setParameterJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormTemplateSectionOrderPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setParameterJson);

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

        public async Task<List<FlexFormParameterInUseDetailViewModel>> IsParameterInUse(FlexFormParameterInUseRequestModel request)
        {
            try
            {
                var setParameterJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormTemplateParameterOrderPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setParameterJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormParameterInUseDetailViewModel>>(contentStream,
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

        public async Task<APISaveResponseModel> SetDeterminant(FlexFormDeterminantSaveRequestModel request)
        {
            try
            {
                var setDeterminantJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormDeterminantPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setDeterminantJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
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

        public async Task<List<FlexFormRulesListViewModel>> GetRulesList(FlexFormRulesGetRequestModel request)
        {
            try
            {
                var url = string.Format(_eidssApiOptions.GetFlexFormRulesListPath, _eidssApiOptions.BaseUrl, request.LangID, request.idfsFunctionParameter);

                var httpResponse = await _httpClient.GetAsync(url);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormRulesListViewModel>>(contentStream,
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

        public async Task<APISaveResponseModel> SetRule(FlexFormRuleSaveRequestModel request)
        {
            try
            {
                var setDeterminantJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormRulePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setDeterminantJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<APISaveResponseModel>(contentStream,
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

        public async Task<List<FlexFormRuleDetailsViewModel>> GetRuleDetails(FlexFormRuleDetailsGetRequestModel request)
        {
            try
            {
                var setDeterminantJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetFlexFormRuleDetailPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setDeterminantJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormRuleDetailsViewModel>>(contentStream,
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

        public async Task<List<FlexFormSectionParameterListViewModel>> GetSectionsParametersList(FlexFormSectionsParametersRequestModel request)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetFlexFormSectionsParametersListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormSectionParameterListViewModel>>(contentStream,
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

        public async Task<APIPostResponseModel> DeleteTemplate(FlexFormTemplateDeleteRequestModel request)
        {
            try
            {
                var requestJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.DeleteFlexFormTemplatePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, requestJson);


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

        public async Task<FlexFormCopyTemplateResponseModel> CopyTemplate(FlexFormCopyTemplateRequestModel request)
        {
            try
            {
                var setDeterminantJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.CopyFlexFormTemplate, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setDeterminantJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<FlexFormCopyTemplateResponseModel>(contentStream,
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

        public async Task<List<FlexFormDiagnosisReferenceListViewModel>> GetDiseaseList(FlexFormDiseaseGetListRequestModel request)
        {
            try
            {
                var diseaseViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetFlexFormDeterminantDiseaseList, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, diseaseViewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormDiagnosisReferenceListViewModel>>(contentStream,
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

        public async Task<List<FlexFormQuestionnaireResponseModel>> GetQuestionnaire(FlexFormQuestionnaireGetRequestModel request)
        {
            try
            {
                var getSectionsParameters = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetFlexFormQuestionnairePath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, getSectionsParameters);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormQuestionnaireResponseModel>>(contentStream,
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

        public async Task<List<FlexFormActivityParametersListResponseModel>> GetAnswers(FlexFormActivityParametersGetRequestModel request)
        {
            try
            {
                var diseaseViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetFlexFormAnswersPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, diseaseViewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormActivityParametersListResponseModel>>(contentStream,
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

        public async Task<List<FlexFormParameterSelectListResponseModel>> GetDropDownOptionsList(FlexFormParameterSelectListGetRequestModel request)
        {
            try
            {
                var diseaseViewModelJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetFlexFormParameterSelectListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, diseaseViewModelJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormParameterSelectListResponseModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
            finally
            {
            }
        }

        public async Task<FlexFormActivityParametersResponseModel> SaveAnswers(FlexFormActivityParametersSaveRequestModel request)
        {
            try
            {
                var setDeterminantJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetFlexFormActivityParametersPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setDeterminantJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<FlexFormActivityParametersResponseModel>(contentStream,
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

        public async Task<APIPostResponseModel> SetOutbreakFlexForm(FlexFormAddToOutbreakSaveRequestModel request)
        {
            try
            {
                var setParameterJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.SetOutbreakFlexFormPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setParameterJson);

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

        public async Task<List<FlexFormFormTemplateResponeModel>> GetFormTemplate(FlexFormFormTemplateRequestModel request)
        {
            try
            {
                var setDeterminantJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetFlexFormFormTemplateDetailAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setDeterminantJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormFormTemplateResponeModel>>(contentStream,
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

        public async Task<List<FlexFormParameterTypeEditorMappingResponseModel>> GetParameterTypeEditorMapping(FlexFormParameterTypeEditorMappingRequestModel request)
        {
            try
            {
                var mappingJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetParameterTypeEditorMappingAsyncPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, mappingJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormParameterTypeEditorMappingResponseModel>>(contentStream,
                    new JsonSerializerOptions
                    {
                        IgnoreNullValues = true,
                        PropertyNameCaseInsensitive = true
                    });

                return response;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message, request);
                throw;
            }
            finally
            {
            }
        }
        
        public async Task<List<FlexFormRuleListResponseModel>> GetFlexFormRuleList(FlexFormRuleListGetRequestModel request)
        {
            try
            {
                var setDeterminantJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetFlexFormRuleListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setDeterminantJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormRuleListResponseModel>>(contentStream,
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

        public async Task<List<FlexFormRuleActionsResponseModel>> GetFlexFormRuleActionsList(FlexFormRuleActionsRequestModel request)
        {
            try
            {
                var setDeterminantJson = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");
                var url = string.Format(_eidssApiOptions.GetFlexFormRuleActionsListPath, _eidssApiOptions.BaseUrl);

                var httpResponse = await _httpClient.PostAsync(url, setDeterminantJson);

                httpResponse.EnsureSuccessStatusCode();
                var contentStream = await httpResponse.Content.ReadAsStreamAsync();

                var response = await JsonSerializer.DeserializeAsync<List<FlexFormRuleActionsResponseModel>>(contentStream,
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
    }
}
