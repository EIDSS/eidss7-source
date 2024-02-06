using AutoFixture;
using EIDSS.ClientLibrary.ApiClients.CrossCutting;
using EIDSS.Domain.RequestModels;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.xUnitTest.Abstracts;
using Moq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Web.xUnitTest.Arrangements.Client_Mocks
{
    public class CrossCuttingClientMock : BaseClientMock<ICrossCuttingClient>, ICrossCuttingClient
    {
        public Task<APIPostResponseModel> DeleteMatrixVersion(long idfVersion)
        {
            Client.Setup(p => p.DeleteMatrixVersion(idfVersion)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.DeleteMatrixVersion(idfVersion);
        }

        public Task<List<AccessRulesAndPermissions>> GetAccessRulesAndPermissions(long userId)
        {
            throw new NotImplementedException();
        }

        public Task<List<ActorGetListViewModel>> GetActorList(ActorGetRequestModel request)
        {
            Client.Setup(p => p.GetActorList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ActorGetListViewModel>().ToList());
            return Client.Object.GetActorList(request);
        }

        public Task<List<BaseReferenceAdvancedListResponseModel>> GetBaseReferenceAdvanceList(BaseReferenceAdvancedListRequestModel request)
        {
            Client.Setup(p => p.GetBaseReferenceAdvanceList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<BaseReferenceAdvancedListResponseModel>().ToList());
            return Client.Object.GetBaseReferenceAdvanceList(request);
        }

        public Task<List<BaseReferenceViewModel>> GetBaseReferenceList(string langId, string referenceTypeName, long? intHACode)
        {
            Client.Setup(p => p.GetBaseReferenceList(langId, referenceTypeName, intHACode)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<BaseReferenceViewModel>().ToList());
            return Client.Object.GetBaseReferenceList(langId, referenceTypeName, intHACode);
        }

        public Task<List<BaseReferenceEditorsViewModel>> GetBaseReferenceList(BaseReferenceEditorGetRequestModel request)
        {
            Client.Setup(p => p.GetBaseReferenceList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<BaseReferenceEditorsViewModel>().ToList());
            return Client.Object.GetBaseReferenceList(request);
        }

        public Task<List<CountryModel>> GetCountryList(string languageId)
        {
            Client.Setup(p => p.GetCountryList(languageId)).ReturnsAsync( LocationArrangements.CountryList);
            return Client.Object.GetCountryList(languageId);
        }

        public Task<List<DepartmentGetListViewModel>> GetDepartmentList(DepartmentGetRequestModel request)
        {
            Client.Setup(p => p.GetDepartmentList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<DepartmentGetListViewModel>().ToList());
            return Client.Object.GetDepartmentList(request);
        }

        public Task<List<DiseaseGetListPagedResponseModel>> GetDiseasesByIdsPaged(DiseaseGetListPagedRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<FilteredDiseaseGetListViewModel>> GetFilteredDiseaseList(FilteredDiseaseRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<List<GISLocationModel>> GetGisLocation(string languageId, int? level, string parentNode = null)
        {
            Client.Setup(p => p.GetGisLocation(languageId, level, parentNode)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<GISLocationModel>().ToList());
            return Client.Object.GetGisLocation(languageId, level, parentNode);
        }

        public Task<List<GisLocationChildLevelModel>> GetGisLocationChildLevel(string languageId, string parentIdfsReferenceId)
        {
            Client.Setup(p => p.GetGisLocationChildLevel(languageId, parentIdfsReferenceId))
                .ReturnsAsync(LocationArrangements.GetGisLocationChildLevel(languageId, parentIdfsReferenceId));
            return Client.Object.GetGisLocationChildLevel(languageId, parentIdfsReferenceId);
        }

        public Task<List<GisLocationCurrentLevelModel>> GetGisLocationCurrentLevel(string languageId, int level)
        {
            Client.Setup(p => p.GetGisLocationCurrentLevel(languageId, level))
                .ReturnsAsync(LocationArrangements.GetGISCurrentLevel(languageId, level));
            return Client.Object.GetGisLocationCurrentLevel(languageId, level);
        }

        public Task<List<GisLocationLevelModel>> GetGisLocationLevels(string languageId)
        {
            Client.Setup(p => p.GetGisLocationLevels(languageId))
                .ReturnsAsync(LocationArrangements.GetWakandaLocationHierarchy(languageId));
            return Client.Object.GetGisLocationLevels(languageId);
        }

        public Task<List<HACodeListViewModel>> GetHACodeList(string langId, int? intHACodeMask)
        {
            Client.Setup(p => p.GetHACodeList(langId, intHACodeMask)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<HACodeListViewModel>().ToList());
            return Client.Object.GetHACodeList(langId, intHACodeMask);
        }

        public Task<List<MatrixVersionViewModel>> GetMatrixVersionsByType(long matrixType)
        {
            Client.Setup(p => p.GetMatrixVersionsByType(matrixType)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<MatrixVersionViewModel>().ToList());
            return Client.Object.GetMatrixVersionsByType(matrixType);
        }

        public Task<List<ObjectAccessGetListViewModel>> GetObjectAccessList(ObjectAccessGetRequestModel request)
        {
            Client.Setup(p => p.GetObjectAccessList(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ObjectAccessGetListViewModel>().ToList());
            return Client.Object.GetObjectAccessList(request);
        }

        public Task<List<XSiteDocumentListViewModel>> GetPageDocuments(long eidssMenuId, string languageId)
        {
            throw new NotImplementedException();
        }

        public Task<List<PostalCodeViewModel>> GetPostalCodeList(long settlementId)
        {
            Client.Setup(p => p.GetPostalCodeList(settlementId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<PostalCodeViewModel>().ToList());
            return Client.Object.GetPostalCodeList(settlementId);
        }

        public Task<List<BaseReferenceTypeListViewModel>> GetReferenceTypes(string langId)
        {
            Client.Setup(p => p.GetReferenceTypes(langId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<BaseReferenceTypeListViewModel>().ToList());
            return Client.Object.GetReferenceTypes(langId);
        }

        public Task<List<BaseReferenceTypeListViewModel>> GetReferenceTypesByIdPaged(ReferenceTypeByIdRequestModel request)
        {
            Client.Setup(p => p.GetReferenceTypesByIdPaged(request)).Returns(Task.FromResult(BaseArrangement.Fixture.CreateMany<BaseReferenceTypeListViewModel>().ToList()));
            return Client.Object.GetReferenceTypesByIdPaged(request);
        }

        public Task<List<BaseReferenceTypeListViewModel>> GetReferenceTypesByName(ReferenceTypeRquestModel request)
        {
            Client.Setup(p => p.GetReferenceTypesByName(request)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<BaseReferenceTypeListViewModel>().ToList());
            return Client.Object.GetReferenceTypesByName(request);
        }

        public Task<List<ReportLanguageModel>> GetReportLanguageList(string langId)
        {
            Client.Setup(p => p.GetReportLanguageList(langId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ReportLanguageModel>().ToList());
            return Client.Object.GetReportLanguageList(langId);

        }

        public Task<List<ReportMonthNameModel>> GetReportMonthNameList(string languageId)
        {
            Client.Setup(p => p.GetReportMonthNameList(languageId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ReportMonthNameModel>().ToList());
            return Client.Object.GetReportMonthNameList(languageId);

        }

        public Task<List<ReportYearModel>> GetReportYearList()
        {
            Client.Setup(p => p.GetReportYearList()).ReturnsAsync(BaseArrangement.Fixture.CreateMany<ReportYearModel>().ToList());
            return Client.Object.GetReportYearList();
        }

        public Task<List<SettlementViewModel>> GetSettlementList(string languageId, long? parentAdminLevelId, long? id)
        {
            Client.Setup(p => p.GetSettlementList(languageId, parentAdminLevelId, id)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SettlementViewModel>().ToList());
            return Client.Object.GetSettlementList(languageId, parentAdminLevelId, id);

        }

        public Task<List<SpeciesViewModel>> GetSpeciesListAsync(long idfsBaseReference, int intHACode, string languageId)
        {
            Client.Setup(p => p.GetSpeciesListAsync(idfsBaseReference, intHACode, languageId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SpeciesViewModel>().ToList());
            return Client.Object.GetSpeciesListAsync(idfsBaseReference, intHACode, languageId);

        }

        public Task<List<StreetModel>> GetStreetList(long locationId)
        {
            Client.Setup(p => p.GetStreetList(locationId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<StreetModel>().ToList());
            return Client.Object.GetStreetList(locationId);
        }

        public Task<List<SystemFunctionsViewModel>> GetSystemFunctionPermissions(string langId, long? systemFunctionId)
        {
            Client.Setup(p => p.GetSystemFunctionPermissions(langId, systemFunctionId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SystemFunctionsViewModel>().ToList());
            return Client.Object.GetSystemFunctionPermissions(langId, systemFunctionId);
        }

        public Task<List<UserGroupGetListViewModel>> GetUserGroupList(string languageId)
        {
            Client.Setup(p => p.GetUserGroupList(languageId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<UserGroupGetListViewModel>().ToList());
            return Client.Object.GetUserGroupList(languageId);
        }

        public Task<List<UserGroupGetListViewModel>> GetUserGroupList(string languageId, long? idfsSite)
        {
            throw new NotImplementedException();
        }

        public Task<List<SystemFunctionPermissionsViewModel>> GetUserGroupUserSystemFunctionPermissions(string userIds, string langId)
        {
            Client.Setup(p => p.GetUserGroupUserSystemFunctionPermissions(userIds, langId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<SystemFunctionPermissionsViewModel>().ToList());
            return Client.Object.GetUserGroupUserSystemFunctionPermissions(userIds, langId);
        }

        public Task<List<VeterinaryDiseaseMatrixListViewModel>> GetVeterinaryDiseaseMatrixListAsync(long idfsBaseReference, int intHACode, string languageId)
        {
            Client.Setup(p => p.GetVeterinaryDiseaseMatrixListAsync(idfsBaseReference, intHACode, languageId)).ReturnsAsync(BaseArrangement.Fixture.CreateMany<VeterinaryDiseaseMatrixListViewModel>().ToList());
            return Client.Object.GetVeterinaryDiseaseMatrixListAsync(idfsBaseReference, intHACode, languageId);
        }

        public Task<APIPostResponseModel> SaveDepartment(DepartmentSaveRequestModel request)
        {
            Client.Setup(p => p.SaveDepartment(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveDepartment(request);
        }

        public Task<APISaveResponseModel> SaveMatrixVersion(HumanAggregateCaseMatrixRequestModel saveRequestModel)
        {
            Client.Setup(p => p.SaveMatrixVersion(saveRequestModel)).ReturnsAsync(BaseArrangement.APISaveResponseMock);
            return Client.Object.SaveMatrixVersion(saveRequestModel);
        }

        public Task<APIPostResponseModel> SaveObjectAccess(ObjectAccessSaveRequestModel request)
        {
            Client.Setup(p => p.SaveObjectAccess(request)).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveObjectAccess(request);
        }

        public Task<APIPostResponseModel> SavePostalCode(PostalCodeSaveRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<ReportAuditSaveResponseModel> SaveReportAudit(ReportAuditSaveRequestModel speciesTypeModel)
        {
            Client.Setup(p => p.SaveReportAudit(speciesTypeModel)).ReturnsAsync(BaseArrangement.Fixture.Create<ReportAuditSaveResponseModel>());
            return Client.Object.SaveReportAudit(speciesTypeModel);
        }

        public Task<APIPostResponseModel> SaveStreet(StreetSaveRequestModel request)
        {
            throw new NotImplementedException();
        }

        public Task<APIPostResponseModel> SaveSystemFunctions(SystemFunctionsSaveRequestModel request)
        {
            Client.Setup(p => p.SaveSystemFunctions(request )).ReturnsAsync(BaseArrangement.APIPostResponseMock_200);
            return Client.Object.SaveSystemFunctions(request);
        }
    }
}
