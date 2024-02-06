using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ResponseModels.Administration.Security;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ResponseModels.Vector;
using EIDSS.Domain.ResponseModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.FlexForm;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Repository.ReturnModels;
using Mapster;

namespace EIDSS.Repository
{
    public static class MapsterMapping
    {
        public static TypeAdapterConfig ModelMappingConfiguration()
        {
            // Set case insensitivity for all mappings...
            TypeAdapterConfig.GlobalSettings.Default.NameMatchingStrategy(NameMatchingStrategy.IgnoreCase);

            var config = TypeAdapterConfig.GlobalSettings;

            ConfigureBaseReferenceEditorMappings(ref config);

            ReportsMappings(ref config);

            AdministrationMappings(ref config);

            AdministrationSecurityMappings(ref config);

            HumanModuleMappings(ref config);

            CrossCusttingMappings(ref config);

            ConfigureAPIPostResponseModelMappings(ref config);

            config.NewConfig<USP_ADMIN_SITE_GETDetailResult, SiteGetDetailViewModel>();

            config.NewConfig<usp_SettlementType_GetLookupResult, SettlementTypeModel>();

            config.NewConfig<USP_ASPNetUser_GetRolesAndPermissionsResult, UserRolesAndPermissionsViewModel>();

            config.NewConfig<USP_ASPNetUser_GetDetailResult, AspNetUserDetailModel>();

            config.NewConfig<USP_ADMIN_ACTOR_GETListResult, ActorGetListViewModel>();

            config.NewConfig<USP_ADMIN_ACCESS_RULE_ACTOR_GETListResult, AccessRuleGetListViewModel>();

            config.NewConfig<USP_ADMIN_ACCESS_RULE_GETDetailResult, AccessRuleGetDetailViewModel>();

            config.NewConfig<USP_REF_AccessRule_SETResult, APISaveResponseModel>();

            config.NewConfig<USP_ADMIN_ACCESS_RULE_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_ADMIN_OBJECT_ACCESS_GETListResult, ObjectAccessGetListViewModel>();

            config.NewConfig<USP_ADMIN_OBJECT_ACCESS_SETResult, APISaveResponseModel>();

            config.NewConfig<USP_ADMIN_ORG_GETListResult, OrganizationGetListViewModel>();

            config.NewConfig<USP_ADMIN_ORG_GETDetailResult, OrganizationGetDetailViewModel>();

            config.NewConfig<USP_ADMIN_ORG_SETResult, APISaveResponseModel>();

            config.NewConfig<USP_ADMIN_ORG_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_ADMIN_IE_Resource_GETListResult, InterfaceEditorResourceViewModel>();

            config.NewConfig<USP_ADMIN_SYSTEM_PREFERENCE_GETDetailResult, SystemPreferenceViewModel>();

            config.NewConfig<USP_ADMIN_SYSTEM_PREFERENCE_SETResult, SystemPreferenceSaveResponseModel>();

            config.NewConfig<usp_Country_GetLookupResult, CountryModel>();

            config.NewConfig<USP_GBL_DISEASE_MTX_GETResult, HumanDiseaseMatrixListViewModel>();

            config.NewConfig<USP_GBL_DISEASE_MTX_GET_BY_UsingTypeResult, HumanDiseaseDiagnosisListViewModel>();

            config.NewConfig<USP_CONF_HumanAggregateCaseMatrixReport_POSTResult, HumanAggregateCaseMatrixResponseModel>();

            config.NewConfig<USP_CONF_GetVetDiseaseList_GETResult, VeterinaryDiseaseMatrixListViewModel>();

            config.NewConfig<USP_GBL_Languages_GETListResult, LanguageModel>();

            config.NewConfig<USP_GBL_GIS_Location_CurrentLevel_GetResult, GisLocationCurrentLevelModel>();

            config.NewConfig<USP_GBL_GIS_Location_ChildLevel_GetResult, GisLocationChildLevelModel>();

            config.NewConfig<USP_GBL_GIS_Location_Levels_GetResult, GisLocationLevelModel>();

            config.NewConfig<USP_GBL_STREET_GETListResult, StreetModel>();

            config.NewConfig<USP_GBL_STREET_SETResult, APISaveResponseModel>()
                .Map(d => d.KeyId, s => s.idfStreet);

            config.NewConfig<USP_GBL_POSTAL_CODE_GETLISTResult, PostalCodeViewModel>();

            config.NewConfig<USP_GBL_POSTALCODE_SETResult, APISaveResponseModel>()
               .Map(d => d.KeyId, s => s.idfPostalCode);

            config.NewConfig<usp_Settlement_GetLookupResult, SettlementViewModel>();

            config.NewConfig<USP_GBL_LKUP_REFERENCETYPE_GETLISTResult, BaseReferenceTypeListViewModel>()
                .Map(d => d.BaseReferenceId, s => s.idfsBaseReference)
                .Map(d => d.ReferenceId, s => s.idfsBaseReference)
                .Map(d => d.Default, s => s.strDefault)
                .Map(d => d.Name, s => s.strName);

            config.NewConfig<USP_HACode_GetCheckListResult, HACodeListViewModel>();

            config.NewConfig<USP_GBL_MENU_GETListResult, MenuViewModel>();
            config.NewConfig<USP_GBL_MENU_ByUser_GETListResult, MenuByUserViewModel>();

            config.NewConfig<USP_GBL_BASE_REFERENCE_GETListResult, BaseReferenceViewModel>();

            config.NewConfig<USP_CONF_ADMIN_AggregateHumanCaseMatrixReport_GETResult, HumanAggregateDiseaseMatrixViewModel>();

            config.NewConfig<USP_CONF_ADMIN_ProphylacticMatrixReportGet_GETResult, VeterinaryProphylacticMeasureMatrixViewModel>();

            config.NewConfig<USP_CONF_HumanAggregateCaseMatrixVersionByMatrixType_GETResult, MatrixVersionViewModel>();

            config.NewConfig<USP_CONF_GetSpeciesList_GETResult, SpeciesViewModel>();

            config.NewConfig<USP_CONF_AggregateSetting_GetListResult, AggregateSettingsModel>();

            config.NewConfig<USP_CONF_ADMIN_SanitaryMatrixReportGet_GETResult, VeterinarySanitaryActionMatrixViewModel>();

            config.NewConfig<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_GETLISTResult, ConfigurationMatrixViewModel>()
                .Map(d => d.KeyId, s => s.idfSpeciesTypeToAnimalAge)
                .Map(d => d.KeyIdName, s => "idfSpeciesTypeToAnimalAge");

            config.NewConfig<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_SETResult, APISaveResponseModel>()
                .Map(d => d.KeyId, s => s.idfSpeciesTypeToAnimalAge)
                .Map(d => d.KeyIdName, s => "idfSpeciesTypeToAnimalAge");

            config.NewConfig<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_GETLISTResult, ConfigurationMatrixViewModel>()
                .Map(d => d.KeyId, s => s.idfDerivativeForSampleType)
                .Map(d => d.KeyIdName, s => "idfDerivativeForSampleType");

            config.NewConfig<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_SETResult, APISaveResponseModel>()
                .Map(d => d.KeyId, s => s.idfDerivativeForSampleType)
                .Map(d => d.KeyIdName, s => "idfDerivativeForSampleType");

            config.NewConfig<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_ADMIN_SanitaryMatrixReportGet_GETResult, VeterinarySanitaryActionMatrixViewModel>();

            config.NewConfig<USP_CONF_ADMIN_VetDiagnosisInvesitgationMatrixReport_GETResult, VeterinaryDiagnosticInvestigationMatrixReportModel>();

            config.NewConfig<USP_CONF_ADMIN_AggregateVetCaseMatrixReport_GETResult, VeterinaryAggregateDiseaseMatrixViewModel>();

            config.NewConfig<USP_CONF_GetInvestigationTypes_GETResult, InvestigationTypeViewModel>();

            config.NewConfig<USP_CONF_VeterinaryDiagnosticInvestigationMatrixReport_SETResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_VeterinaryAggregateCaseMatrixReport_SETResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_HumanAggregateCaseMatrixReport_SETResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_VeterinaryProphylacticMatrixReport_SETResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_DISEASEAGEGROUPMATRIX_GETLISTResult, DiseaseAgeGroupMatrixViewModel>();

            config.NewConfig<USP_CONF_CUSTOMREPORT_GETLISTResult, ConfigurationMatrixViewModel>()
               .Map(d => d.KeyId, s => s.idfReportRows)
               .Map(d => d.KeyIdName, s => "idfReportRows");

            config.NewConfig<USP_CONF_CUSTOMREPORT_SETResult, APISaveResponseModel>()
               .Map(d => d.KeyId, s => s.idfReportRows)
               .Map(d => d.KeyIdName, s => "idfReportRows");

            config.NewConfig<USP_CONF_CUSTOMREPORT_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_DISEASEGROUPDISEASEMATRIX_GETLISTResult, ConfigurationMatrixViewModel>()
              .Map(d => d.KeyId, s => s.idfDiagnosisToDiagnosisGroup)
              .Map(d => d.KeyIdName, s => "idfReportRows");

            config.NewConfig<USP_CONF_DISEASEGROUPDISEASEMATRIX_SETResult, APISaveResponseModel>()
              .Map(d => d.KeyId, s => s.idfDiagnosisToDiagnosisGroup)
              .Map(d => d.KeyIdName, s => "idfReportRows");

            config.NewConfig<USP_CONF_DISEASEGROUPDISEASEMATRIX_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_HUM_HUMAN_DISEASE_SETResult, SetHumanDiseaseReportResponseModel>();

            return config;
        }

        /// <summary>
        /// Base Reference Editor Mappings
        /// </summary>
        /// <param name="config"></param>
        private static void ConfigureBaseReferenceEditorMappings(ref TypeAdapterConfig config)
        {
            #region Grid Configuration

            config.NewConfig<USP_CONF_USER_GRIDS_GETDETAILResult, USP_CONF_USER_GRIDS_GETDETAILResponseModel>();

            #endregion Grid Configuration

            #region Age Groups

            config.NewConfig<USP_REF_AGEGROUP_GETListResult, BaseReferenceEditorsViewModel>()
                .Map(d => d.KeyId, s => s.idfsAgeGroup)
                .Map(d => d.KeyIdName, s => "idfsAgeGroup");

            config.NewConfig<USP_REF_AGEGROUP_SETResult, AgeGroupSaveRequestResponseModel>();

            #endregion Age Groups

            #region Base Reference

            config.NewConfig<USP_GBL_DISEASE_MTX_GET_BY_UsingTypeResult, HumanDiseaseDiagnosisListViewModel>();

            config.NewConfig<USP_CONF_HumanAggregateCaseMatrixReport_POSTResult, HumanAggregateCaseMatrixResponseModel>();

            config.NewConfig<USP_CONF_GetVetDiseaseList_GETResult, VeterinaryDiseaseMatrixListViewModel>();

            config.NewConfig<USP_GBL_Languages_GETListResult, LanguageModel>();

            config.NewConfig<USP_GBL_Resource_GETListResult, ResourceModel>();

            config.NewConfig<USP_REP_Languages_GETResult, ReportLanguageModel>();

            config.NewConfig<USP_REP_Years_GETResult, ReportYearModel>();

            config.NewConfig<USP_REP_MonthNames_GETResult, ReportMonthNameModel>();

            config.NewConfig<USP_REF_BASEREFERENCE_Filtered_GETListResult, BaseReferenceEditorsViewModel>()
                .Map(d => d.KeyId, s => s.idfsBaseReference)
                .Map(d => d.KeyIdName, s => "idfsBaseReference");

            config.NewConfig<USP_REF_BASEREFERENCE_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_REF_BASEREFERENCE_SETResult, BaseReferenceSaveRequestResponseModel>();

            config.NewConfig<USP_REF_SearchDuplicates_GetListResult, BaseReferenceCheckForDuplicatesResponseModel>();

            #endregion Base Reference

            #region Case Classifications

            config.NewConfig<USP_REF_CASECLASSIFICATION_GETListResult, BaseReferenceEditorsViewModel>()
                 .Map(d => d.KeyId, s => s.idfsCaseClassification)
                 .Map(d => d.KeyIdName, s => "idfsCaseClassification");

            config.NewConfig<USP_REF_CASECLASSIFICATION_SETResult, CaseClassificationSaveRequestResponseModel>();

            #endregion Case Classifications

            #region Diseases

            config.NewConfig<USP_REF_DIAGNOSISREFERENCE_GETListResult, BaseReferenceEditorsViewModel>()
                 .Map(d => d.KeyId, s => s.idfsDiagnosis)
                 .Map(d => d.KeyIdName, s => "idfsDiagnosis");

            config.NewConfig<USP_REF_DIAGNOSISREFERENCE_GETDetailResult, BaseReferenceEditorsViewModel>()
                .Map(d => d.KeyId, s => s.idfsDiagnosis)
                .Map(d => d.KeyIdName, s => "idfsDiagnosis");

            config.NewConfig<USP_REF_DIAGNOSISREFERENCE_SETResult, DiseaseSaveRequestReponseModel>();

            config.NewConfig<USP_GBL_LKUP_DISEASE_GETList_PagedResult, DiseaseGetListPagedResponseModel>();

            #endregion Diseases

            #region "Flex Form"

            config.NewConfig<USP_ADMIN_FF_TemplatesByParameter_GETResult, FlexFormTemplateByParameterListModel>();
            config.NewConfig<USP_ADMIN_FF_Template_GetDetailResult, FlexFormTemplateDetailViewModel>();
            config.NewConfig<USP_ADMIN_FF_TemplateDeterminantValues_GETResult, FlexFormTemplateDeterminantValuesListViewModel>();
            config.NewConfig<USP_ADMIN_FF_ParameterInUseResult, FlexFormParameterInUseDetailViewModel>();
            config.NewConfig<USP_ADMIN_FF_Rules_GETListResult, FlexFormRulesListViewModel>();
            config.NewConfig<USP_ADMIN_FF_Rule_GetDetailsResult, FlexFormRuleDetailsViewModel>();
            config.NewConfig<USP_ADMIN_FF_TemplateDesign_GETResult, FlexFormTemplateDesignListViewModel>();

            #endregion "Flex Form"

            #region Human

            config.NewConfig<USP_HAS_CAMPAIGN_DELResult, DeleteHumanActiveSurveillanceCampaignDetailsResponseModel>();

            #endregion Human

            #region Measures

            config.NewConfig<USP_REF_MEASURELIST_GETListResult, MeasuresDropDownViewModel>();

            config.NewConfig<USP_REF_MEASUREREFERENCE_GETListResult, BaseReferenceEditorsViewModel>()
                .Map(d => d.KeyId, s => s.idfsAction)
                .Map(d => d.KeyIdName, s => "idfsAction");


            #endregion Measures

            #region Report Disease Groups

            config.NewConfig<USP_REF_ReportDiagnosisGroup_GETListResult, BaseReferenceEditorsViewModel>()
                .Map(d => d.KeyId, s => s.idfsReportDiagnosisGroup)
                .Map(d => d.KeyIdName, s => "idfsReportDiagnosisGroup");

            config.NewConfig<USP_REF_REPORTDIAGNOSISGROUP_SETResult, ReportDiseaseGroupsSaveRequestResponseModel>();

            #endregion Report Disease Groups

            #region Sample Types

            config.NewConfig<USP_REF_SampleTypeReference_GetListResult, BaseReferenceEditorsViewModel>()
                  .Map(d => d.KeyId, s => s.idfsSampleType)
                  .Map(d => d.KeyIdName, s => "idfsSampleType");

            config.NewConfig<USP_REF_SAMPLETYPEREFERENCE_SETResult, APISaveResponseModel>()
                  .Map(d => d.KeyId, s => s.idfsSampleType)
                  .Map(d => d.KeyIdName, s => "idfsSampleType");

            config.NewConfig<USP_GBL_LKUP_DISEASE_GETList_PagedResult, DiseaseSampleTypeByDiseaseResponseModel>();

            config.NewConfig<USP_GBL_LKUP_SAMPLESFORDISEASESResult, BaseReferenceEditorsViewModel>()
                  .Map(d => d.KeyId, s => s.idfsSampleType)
                  .Map(d => d.KeyIdName, s => "idfsSampleType");

            #endregion Sample Types

            #region Species Types

            config.NewConfig<USP_REF_SPECIESTYPEREFERENCE_SETResult, SpeciesTypeSaveRequestResponseModel>();

            config.NewConfig<USP_REF_SPECIESTYPE_GETListResult, BaseReferenceEditorsViewModel>()
                .Map(d => d.KeyId, s => s.idfsSpeciesType)
                .Map(d => d.KeyIdName, s => "idfsSpeciesType");

            #endregion Species Types

            #region Statistical Data Types

            config.NewConfig<USP_REF_STATISTICDATATYPE_GETListResult, BaseReferenceEditorsViewModel>()
                 .Map(d => d.KeyId, s => s.idfsStatisticDataType)
                 .Map(d => d.KeyIdName, s => "idfsStatisticDataType");

            config.NewConfig<USP_REF_STATISTICDATATYPE_SETResult, StatisticalTypeSaveRequestResponseModel>();
            config.NewConfig<USP_ADMIN_STAT_GetListResult, StatisticalDataResponseModel>();
            config.NewConfig<USP_ADMIN_STAT_SETResult, USP_ADMIN_STAT_SETResultResponseModel>();
            config.NewConfig<USP_ADMIN_STAT_GetDetailResult, USP_ADMIN_STAT_GetDetailResultResponseModel>();
            config.NewConfig<USP_ADMIN_STAT_DELResult, USP_ADMIN_STAT_DELResultResponseModel>();

            #endregion Statistical Data Types

            #region Vector Species Types

            config.NewConfig<USP_REF_VectorSubType_GETListResult, BaseReferenceEditorsViewModel>()
                 .Map(d => d.KeyId, s => s.idfsVectorSubType)
                 .Map(d => d.KeyIdName, s => "idfsVectorSubType");

            config.NewConfig<USP_REF_VectorSubType_SETResult, VectorSpeciesTypesSaveRequestResponseModel>();

            #endregion Vector Species Types

            #region VectorTypes

            config.NewConfig<USP_REF_VECTORTYPEREFERENCE_SETResult, APISaveResponseModel>()
                 .Map(d => d.KeyId, s => s.idfsVectorType)
                  .Map(d => d.KeyIdName, s => "idfsVectorType"); ;
            config.NewConfig<USP_CONF_VECTORTYPEFIELDTESTMATRIX_SETResult, VectorTypeFieldTestMatrixSaveRequestResponseModel>();

            #endregion VectorTypes

            #region VectorSurveillanceSessions

            config.NewConfig<USP_VCTS_SURVEILLANCE_SESSION_GetListResult, VectorSurveillanceSessionViewModel>();
            config.NewConfig<USP_VCTS_VECT_RW_SETResult, USP_VCTS_VECT_SET_ResponseModel>();
            config.NewConfig<USP_VCTS_SESSIONSUMMARY_SETResult, USP_VCTS_SESSIONSUMMARY_SETResponseModel>();
            config.NewConfig<USP_VCTS_SESSIONSUMMARY_GETListResult, USP_VCTS_VecSessionSummary_GETListResponseModel>();
            config.NewConfig<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResult, USP_VCTS_SESSIONSUMMARYDIAGNOSIS_GetDetailResponseModel>();
            config.NewConfig<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_DELResult, USP_VCTS_SESSIONSUMMARYDIAGNOSIS_DELResponseModel>();
            config.NewConfig<USP_VCTS_SESSIONSUMMARYDIAGNOSIS_SETResult, USP_VCTS_SESSIONSUMMARYDIAGNOSIS_SETResponseModel>();
            config.NewConfig<USP_VCTS_VECTCollection_GetDetailResult, USP_VCTS_VECTCollection_GetDetailResponseModel>();
            config.NewConfig<USP_VCTS_VECT_STRUCTURED_SETResult, USP_VCTS_VECT_STRUCTURED_SETResponseModel>();
            config.NewConfig<USP_VCTS_SESSIONSUMMARY_DELResult, USP_VCTS_SESSIONSUMMARY_DELResponseModel>();
            config.NewConfig<USP_VCTS_VECT_DELResult, USP_VCTS_VECT_DELResponseModel>();
            config.NewConfig<USSP_VCT_SAMPLE_DETAILEDCOLLECTIONS_SETResult, USSP_VCT_SAMPLE_DETAILEDCOLLECTIONS_SETResponseModel>();
            config.NewConfig<USP_VCTS_SAMPLE_DELResult, USP_VCTS_SAMPLE_DELResponseModel>();
            config.NewConfig<USP_VCTS_FIELDTEST_GetListResult, USP_VCTS_FIELDTEST_GetListResponseModel>();
            config.NewConfig<USP_VCTS_SAMPLE_GetListResult, VectorSampleGetListViewModel>();
            config.NewConfig<USP_VCTS_DetailedCollections_CopyResult, APIPostResponseModel>();

            #endregion VectorSurveillanceSessions

            #region Employee

            config.NewConfig<USP_ADMIN_EMPLOYEE_GETLISTResult, EmployeeListViewModel>();
            config.NewConfig<USP_GBL_EMPLOYEESITE_GETDETAILResult, AdminEmployeeSiteDetailsViewModel>();

            #endregion Employee
        }

        /// <summary>
        /// Reports Mappings
        /// </summary>
        /// <param name="config"></param>
        private static void ReportsMappings(ref TypeAdapterConfig config)
        {
            config.NewConfig<USP_REP_ReportingPeriodResult, ReportingPeriodTypeViewModel>();
            config.NewConfig<USP_REP_ReportingPeriodTypeResult, ReportingPeriodTypeViewModel>();
            config.NewConfig<USP_REP_VET_NameOfInvestigationOrMeasureSelectLookupResult, VetNameOfInvestigationOrMeasureViewModel>();
            config.NewConfig<USP_REP_VET_SummarySurveillanceTypeResult, VetSummarySurveillanceTypeViewModel>();
            config.NewConfig<USP_REP_HUM_WhoMeaslesRubella_DiagnosisResult, WhoMeaslesRubellaDiagnosisViewModel>();
            config.NewConfig<USP_REP_HUM_ComparitiveCounter_GETResult, HumanComparitiveCounterViewModel>();
            config.NewConfig<USP_REP_REPORT_AUDIT_SETResult, ReportAuditSaveResponseModel>();
            config.NewConfig<USP_REP_HUM_TuberculosisDiagnosisSelectLookupResult, TuberculosisDiagnosisViewModel>();
            config.NewConfig<USP_REP_SpeciesType_GetListResult, SpeciesTypeViewModel>();
            config.NewConfig<USP_REP_GetCurrentCountryResult, CurrentCountryViewModel>();
            config.NewConfig<USP_REP_LAB_AssignmentDiagnosticAZSendToLookupResult, LABAssignmentDiagnosticAZSendToViewModel>();
            config.NewConfig<USP_REP_LAB_TestingResultsDepartmentLookupResult, LABTestingResultsDepartmentViewModel>();
            config.NewConfig<USP_REP_Reports_GetListResult, ReportListViewModel>();
            config.NewConfig<USP_REP_HUM_DateFieldSource_GETResult, HumDateFieldSourceViewModel>();
            config.NewConfig<USP_REP_Organization_GETResult, ReportOrganizationViewModel>();
            config.NewConfig<USP_REP_VET_DateFieldSource_GETResult, VetDateFieldSourceViewModel>();
            config.NewConfig<USP_REP_HUM_ComparitiveCounter_GET_GGResult, HumanComparitiveCounterGGViewModel>();
            config.NewConfig<USP_REP_Quarter_GGResult, ReportQuarterModelGG>();
        }

        /// <summary>
        /// { Mappings
        /// </summary>
        /// <param name="config"></param>
        private static void AdministrationMappings(ref TypeAdapterConfig config)
        {
            config.NewConfig<USP_SecurityConfiguration_GetResult, SecurityConfigurationViewModel>();
            config.NewConfig<USP_SecurityConfiguration_SetResult, SecurityConfigurationSaveRsponseModel>();
            config.NewConfig<USP_ADMIN_ADMINLEVEL_GETLISTResult, AdministrativeUnitsGetListViewModel>()
                .Map(dest => dest.idfsCountry, src => src.idfsCountry)
                .Map(dest => dest.NationalCountryName, src => src.strNationalCountryName)
                .Map(dest => dest.DefaultCountryName, src => src.strDefaultCountryName)
                .Map(dest => dest.NationalRegionName, src => src.strNationalRegionName)
                .Map(dest => dest.DefaultRegionName, src => src.strDefaultRegionName)
                .Map(dest => dest.NationalRayonName, src => src.strNationalRayonName)
                .Map(dest => dest.DefaultRayonName, src => src.strDefaultRayonName)
                .Map(dest => dest.idfsRegion, src => src.idfsRegion)
                .Map(dest => dest.idfsRayon, src => src.idfsRayon)
                .Map(dest => dest.idfsSettlement, src => src.idfsSettlement)
                .Map(dest => dest.idfsSettlementType, src => src.idfsSettlementType)
                .Map(dest => dest.NationalSettlementName, src => src.strNationalSettlementName)
                .Map(dest => dest.DefaultSettlementName, src => src.strDefaultSettlementName)
                .Map(dest => dest.SettlementTypeNationalName, src => src.strSettlementTypeNationalName)
                .Map(dest => dest.SettlementTypeDefaultName, src => src.strSettlementTypeDefaultName)
                .Map(dest => dest.Latitude, src => src.Latitude)
                .Map(dest => dest.Longitude, src => src.Longitude)
                .Map(dest => dest.Elevation, src => src.Elevation);

            config.NewConfig<USP_ADMIN_GISDATA_SETResult, APISaveResponseModel>()
                  .Map(dest => dest.KeyId, src => src.idfsGISBaseReference);

            config.NewConfig<USP_ADMIN_GISDATA_DELResult, ApiPostGisDataResponseModel>();
        }

        /// <summary>
        /// AdministrationSecurityMappings Mappings
        /// </summary>
        /// <param name="config"></param>
        private static void AdministrationSecurityMappings(ref TypeAdapterConfig config)
        {
            config.NewConfig<USP_ADMIN_SYSTEMFUNCTION_GETLISTResult, SystemFunctionViewModel>();
            config.NewConfig<USP_Admin_UserGoupAndUser_GetListResult, SystemFunctionUserGroupAndUserViewModel>();
            config.NewConfig<USP_ADMIN_SYSTEMFUNCTION_USERPERMISSION_GetListResult, SystemFunctionUserPermissionViewModel>();
            config.NewConfig<USP_ADMIN_EMPLOYEEGROUP_SYSTEMFUNCTION_SETResult, SystemFunctionUserPermissionSaveResponseModel>();
            config.NewConfig<USP_Admin_SystemFunction_PersonANDEmployeeGroup_GetListResult, SystemFunctionPersonANDEmployeeGroupViewModel>();
            config.NewConfig<USP_ADMIN_SYSTEMFUNCTION_PersonANDEmployeeGroup_DELResult, SystemFunctionPersonANDEmployeeGroupDelResponseModel>();
        }

        /// <summary>
        /// HumanModuleMappings Mappings
        /// </summary>
        /// <param name="config"></param>
        private static void HumanModuleMappings(ref TypeAdapterConfig config)
        {
            config.NewConfig<USP_GBL_ReportForm_GetListResult, ReportFormViewModel>();
            config.NewConfig<USP_GBL_ReportForm_GETDETAILResult, ReportFormDetailViewModel>();
            config.NewConfig<USP_HUM_DISEASE_REPORT_GETListResult, HumanDiseaseReportViewModel>();
        }

        /// <summary>
        /// HumanModuleMappings Mappings
        /// </summary>
        /// <param name="config"></param>
        private static void CrossCusttingMappings(ref TypeAdapterConfig config)
        {
            config.NewConfig<USP_ASPNetUser_GetAccessRulesAndPermissionsResult, AccessRulesAndPermissions>();
        }

        /// <summary>
        /// APIPostResponseModel mappings
        /// Place all DELETE response operation mappings here!
        /// </summary>
        /// <param name="config"></param>
        private static void ConfigureAPIPostResponseModelMappings(ref TypeAdapterConfig config)
        {
            config.NewConfig<USP_REF_AGEGROUP_DELResult, APIPostResponseModel>();
            config.NewConfig<USP_REF_AGEGROUP_SETResult, APISaveResponseModel>()
                 .Map(d => d.KeyId, s => s.idfsAgeGroup)
                 .Map(d => d.KeyIdName, s => "idfsAgeGroup");

            config.NewConfig<USP_REF_BASEREFERENCE_DELResult, APIPostResponseModel>();
            config.NewConfig<USP_REF_BASEREFERENCE_SETResult, APISaveResponseModel>()
                 .Map(d => d.KeyId, s => s.idfsBaseReference)
                 .Map(d => d.KeyIdName, s => "idfsBaseReference");

            config.NewConfig<USP_REF_CASECLASSIFICATION_SETResult, APISaveResponseModel>()
                 .Map(d => d.KeyId, s => s.idfsCaseClassification)
                 .Map(d => d.KeyIdName, s => "idfsCaseClassification");
            config.NewConfig<USP_REF_CASECLASSIFICATION_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_REF_DIAGNOSISREFERENCE_SETResult, APISaveResponseModel>()
                 .Map(d => d.KeyId, s => s.idfsDiagnosis)
                 .Map(d => d.KeyIdName, s => "idfsDiagnosis");

            config.NewConfig<USP_REF_DIAGNOSISREFERENCE_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_REF_MEASUREREFERENCE_SETResult, APISaveResponseModel>()
                 .Map(d => d.KeyId, s => s.idfsBaseReference)
                 .Map(d => d.KeyIdName, s => "idfsBaseReference");

            config.NewConfig<USP_REF_MEASUREREFEFENCE_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_REF_REPORTDIAGNOSISGROUP_SETResult, APISaveResponseModel>()
                 .Map(d => d.KeyId, s => s.idfsReportDiagnosisGroup)
                 .Map(d => d.KeyIdName, s => "idfsReportDiagnosisGroup");

            config.NewConfig<USP_REF_REPORTDIAGNOSISGROUP_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_REF_SAMPLETYPEREFERENCE_SETResult, APISaveResponseModel>()
                 .Map(d => d.KeyId, s => s.idfsSampleType)
                 .Map(d => d.KeyIdName, s => "idfsSampleType");

            config.NewConfig<USP_REF_SAMPLETYPEREFERENCE_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_REF_SPECIESTYPE_SETResult, APISaveResponseModel>()
                 .Map(d => d.KeyId, s => s.IdfSpeciesType)
                 .Map(d => d.KeyIdName, s => "idfSpeciesType");

            config.NewConfig<USP_REF_SPECIESTYPE_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_REF_STATISTICDATATYPE_SETResult, APISaveResponseModel>()
                .Map(d => d.KeyId, s => s.idfsStatisticDataType)
                .Map(d => d.KeyIdName, s => "idfsStatisticDataType");

            config.NewConfig<USP_REF_STATISTICDATATYPE_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_REF_VectorSubType_SETResult, APISaveResponseModel>()
                .Map(d => d.KeyId, s => s.idfsVectorSubType)
                .Map(d => d.KeyIdName, s => "idfsVectorSubType");
            config.NewConfig<USP_REF_VectorSubType_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_VECTORTYPEFIELDTESTMATRIX_SETResult, APISaveResponseModel>()
                .Map(d => d.KeyId, s => s.idfPensideTestTypeForVectorType)
                .Map(d => d.KeyIdName, s => "idfPensideTestTypeForVectorType");

            var r = new USP_REF_VECTORTYPEREFERENCE_SETResult().Adapt(new APISaveResponseModel());

            config.NewConfig<USP_REF_VECTORTYPEREFERENCE_SETResult, APISaveResponseModel>()
                .Map(d => d.KeyId, s => s.idfsVectorType)
                .Map(d => d.KeyIdName, s => "idfsVectorType");

            config.NewConfig<USP_REF_VECTORTYPEREFERENCE_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_VECTORTYPEFIELDTESTMATRIX_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_HumanAggregateCaseMatrixVersion_SETResult, APISaveResponseModel>()
                .Map(d => d.KeyId, s => s.idfVersion)
                .Map(d => d.KeyIdName, s => "idfVersion");

            config.NewConfig<USP_CONF_VECTORTYPESAMPLETYPEMATRIX_SETResult, APISaveResponseModel>()
               .Map(d => d.KeyId, s => s.idfSampleTypeForVectorType)
               .Map(d => d.KeyIdName, s => "idfSampleTypeForVectorType");

            config.NewConfig<USP_CONF_VECTORTYPESAMPLETYPEMATRIX_DELResult, APIPostResponseModel>();

            config.NewConfig<USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_SETResult, APISaveResponseModel>()
              .Map(d => d.KeyId, s => s.idfCollectionMethodForVectorType)
              .Map(d => d.KeyIdName, s => "idfCollectionMethodForVectorType");

            config.NewConfig<USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_DELResult, APIPostResponseModel>();
        }
    }
}