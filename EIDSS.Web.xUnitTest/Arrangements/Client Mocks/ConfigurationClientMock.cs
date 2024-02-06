using AutoFixture;
using Moq;
using EIDSS.ClientLibrary.ApiClients.Configuration;
using EIDSS.Domain.RequestModels.Configuration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Web.xUnitTest.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class ConfigurationClientMock : BaseClientMock<IConfigurationClient>, IConfigurationClient
    {
        public Task<APIPostResponseModel> DeleteCustomReportRowsMatrix(long idfReportRows, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteCustomReportRowsMatrix(idfReportRows, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteCustomReportRowsMatrix(idfReportRows, deleteAnyway);
        }

        public Task<APIPostResponseModel> DeleteDiseaseGroupDiseaseMatrix(long idfDiagnosisToDiagnosisGroup, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteDiseaseGroupDiseaseMatrix(idfDiagnosisToDiagnosisGroup, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteDiseaseGroupDiseaseMatrix(idfDiagnosisToDiagnosisGroup, deleteAnyway);
        }

        public Task<APIPostResponseModel> DeleteParameterFixedPresetValue(long idfsParameterFixedPresetValue, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteParameterFixedPresetValue(idfsParameterFixedPresetValue, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteParameterFixedPresetValue(idfsParameterFixedPresetValue, deleteAnyway);
        }

        public Task<APIPostResponseModel> DeleteParameterType(long? idfsParameterType, string user, bool? deleteAnyway, string langId)
        {
            Client.Setup(p=> p.DeleteParameterType(idfsParameterType, user, deleteAnyway, langId)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteParameterType(idfsParameterType,user,deleteAnyway,langId);
        }

        public Task<APIPostResponseModel> DeleteSampleTypeDerivativeMatrix(long idfDerivativeForSampleType, bool? deleteAnyway)
        {
            Client.Setup(p=> p.DeleteSampleTypeDerivativeMatrix(idfDerivativeForSampleType,deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteSampleTypeDerivativeMatrix(idfDerivativeForSampleType, deleteAnyway);
        }

        public Task<APIPostResponseModel> DeleteSpeciesAnimalAge(long idfSpeciesTypeToAnimalAge, bool? deleteAnyway)
        {
            Client.Setup(prop=> prop.DeleteSpeciesAnimalAge(idfSpeciesTypeToAnimalAge,deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteSpeciesAnimalAge(idfSpeciesTypeToAnimalAge, deleteAnyway);
        }

        public Task<APIPostResponseModel> DeleteStatisticalAgeGroupMatrix(long idfsDiagnosisAgeGroupToStatisticalAgeGroup, bool? deleteAnyway)
        {
            Client.Setup(prop=> prop.DeleteStatisticalAgeGroupMatrix(idfsDiagnosisAgeGroupToStatisticalAgeGroup, deleteAnyway)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteStatisticalAgeGroupMatrix(idfsDiagnosisAgeGroupToStatisticalAgeGroup, deleteAnyway);
        }

        public Task<List<AggregateSettingsModel>> GetAggregateSettings(AggregateSettingsGetRequestModel request)
        {
            Client.Setup(p=> p.GetAggregateSettings(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<AggregateSettingsModel>().ToList());
            return Client.Object.GetAggregateSettings(request);
        }

        public Task<List<ConfigurationMatrixViewModel>> GetCustomReportRowsMatrixList(CustomReportRowsMatrixGetRequestModel request)
        {
            Client.Setup(p=> p.GetCustomReportRowsMatrixList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ConfigurationMatrixViewModel>().ToList());
            return Client.Object.GetCustomReportRowsMatrixList(request);
        }

        public Task<List<ConfigurationMatrixViewModel>> GetDiseaseGroupDiseaseMatrixList(DiseaseGroupDiseaseMatrixGetRequestModel request)
        {
            Client.Setup(prop => prop.GetDiseaseGroupDiseaseMatrixList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ConfigurationMatrixViewModel>().ToList());
            return Client.Object.GetDiseaseGroupDiseaseMatrixList(request);
        }

        public Task<List<ParameterFixedPresetValueViewModel>> GetParameterFixedPresetValueList(ParameterFixedPresetValueGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetParameterFixedPresetValueList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ParameterFixedPresetValueViewModel>().ToList());
            return Client.Object.GetParameterFixedPresetValueList(request);
        }

        public Task<List<ParameterReferenceViewModel>> GetParameterReferenceList(ParameterReferenceGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetParameterReferenceList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ParameterReferenceViewModel>().ToList());
            return Client.Object.GetParameterReferenceList(request);
        }

        public Task<List<ParameterReferenceValueViewModel>> GetParameterReferenceValueList(ParameterReferenceValueGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetParameterReferenceValueList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ParameterReferenceValueViewModel>().ToList());
            return Client.Object.GetParameterReferenceValueList(request);
        }

        public Task<List<ParameterTypeViewModel>> GetParameterTypeList(ParameterTypeGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetParameterTypeList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ParameterTypeViewModel>().ToList());
            return Client.Object.GetParameterTypeList(request);
        }

        public Task<List<ConfigurationMatrixViewModel>> GetSampleTypeDerivativeMatrixList(SampleTypeDerivativeMatrixGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetSampleTypeDerivativeMatrixList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ConfigurationMatrixViewModel>().ToList());
            return Client.Object.GetSampleTypeDerivativeMatrixList(request);
        }

        public Task<List<ConfigurationMatrixViewModel>> GetSpeciesAnimalAgeList(SpeciesAnimalAgeGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetSpeciesAnimalAgeList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ConfigurationMatrixViewModel>().ToList());
            return Client.Object.GetSpeciesAnimalAgeList(request);
        }

        public Task<List<StatisticalAgeGroupMatrixViewModel>> GetStatisticalAgeGroupMatrixList(StatisticalAgeGroupMatrixGetRequestModel request)
        {
            Client.Setup(prop=> prop.GetStatisticalAgeGroupMatrixList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<StatisticalAgeGroupMatrixViewModel>().ToList());
            return Client.Object.GetStatisticalAgeGroupMatrixList(request);
        }

        public Task<APISaveResponseModel> SaveCustomReportRowsMatrix(CustomReportRowsMatrixSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveCustomReportRowsMatrix(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveCustomReportRowsMatrix(request);
        }

        public Task<APISaveResponseModel> SaveCustomReportRowsOrder(CustomReportRowsRowOrderSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveCustomReportRowsOrder(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveCustomReportRowsOrder(request);
        }

        public Task<APISaveResponseModel> SaveDiseaseGroupDiseaseMatrix(DiseaseGroupDiseaseMatrixSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveDiseaseGroupDiseaseMatrix(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveDiseaseGroupDiseaseMatrix(request);
        }

        public Task<ParameterFixedPresetValueSaveRequestResponseModel> SaveParameterFixedPresetValue(ParameterFixedPresetValueSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveParameterFixedPresetValue(request)).ReturnsAsync(BaseArrangement.Fixture.Create<ParameterFixedPresetValueSaveRequestResponseModel>());
            return Client.Object.SaveParameterFixedPresetValue(request);
        }

        public Task<ParameterTypeSaveRequestResponseModel> SaveParameterType(ParameterTypeSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveParameterType(request)).ReturnsAsync(BaseArrangement.Fixture.Create<ParameterTypeSaveRequestResponseModel>());
            return Client.Object.SaveParameterType(request);
        }

        public Task<APISaveResponseModel> SaveSampleTypeDerivativeMatrix(SampleTypeDerivativeMatrixSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveSampleTypeDerivativeMatrix(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveSampleTypeDerivativeMatrix(request);
        }

        public Task<APISaveResponseModel> SaveSpeciesAnimalAge(SpeciesAnimalAgeSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveSpeciesAnimalAge(request)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveSpeciesAnimalAge(request);
        }

        public Task<StatisticalAgeGroupMatrixSaveRequestResponseModel> SaveStatisticalAgeGroupMatrix(StatisticalAgeGroupMatrixSaveRequestModel request)
        {
            Client.Setup(prop=> prop.SaveStatisticalAgeGroupMatrix(request)).ReturnsAsync(BaseArrangement.Fixture.Create<StatisticalAgeGroupMatrixSaveRequestResponseModel>());
            return Client.Object.SaveStatisticalAgeGroupMatrix(request);
        }
    }
}
