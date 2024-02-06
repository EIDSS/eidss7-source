using AutoMapper;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.FlexForm;
using EIDSS.Repository.ReturnModels;
using System.Reflection;

namespace EIDSS.Repository
{
    public class BaseReferenceEditorProfile : Profile
    {
        /// <summary>
        /// Maps All base reference editor grid models map to the <see cref="BaseReferenceEditorsViewModel"/> and source primary key identifier
        /// to the destination KeyId property.  The KeyIdName property indicates the source key's field name.
        /// </summary>
        public BaseReferenceEditorProfile()
        {
            #region Age Groups

            CreateMap<USP_REF_AGEGROUP_GETListResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsAgeGroup));

            CreateMap<USP_REF_AGEGROUP_SETResult, AgeGroupSaveRequestResponseModel>();

            #endregion Age Groups

            #region Base Reference
            CreateMap<USP_GBL_DISEASE_MTX_GET_BY_UsingTypeResult, HumanDiseaseDiagnosisListViewModel>();
            CreateMap<USP_CONF_HumanAggregateCaseMatrixReport_POSTResult, HumanAggregateCaseMatrixResponseModel>();
            CreateMap<USP_CONF_GetVetDiseaseList_GETResult, VeterinaryDiseaseMatrixListViewModel>();
            CreateMap<USP_CONF_VETAggregateCaseMatrixReportRecord_DELETEResult, VeterinaryAggregateCaseMatrixReportRecordDeleteModel>();
            CreateMap<USP_GBL_Language_GETListResult, LanguageModel>();
            CreateMap<USP_GBL_Resource_GETListResult, ResourceModel>();
            CreateMap<USP_REP_Languages_GETResult, ReportLanguageModel>();
            CreateMap<USP_REP_Years_GETResult, ReportYearModel>();
            CreateMap<USP_REP_MonthNames_GETResult, ReportMonthNameModel>();

            CreateMap<USP_REF_BASEREFERENCE_GETListResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsBaseReference))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsBaseReference")));

            CreateMap<USP_REF_BASEREFERENCE_DELResult, APIPostResponseModel>();
            CreateMap<USP_REF_BASEREFERENCE_SETResult, BaseReferenceSaveRequestResponseModel>();
            CreateMap<USP_REF_SearchDuplicates_GetListResult, BaseReferenceCheckForDuplicatesResponseModel>();

            #endregion

            #region Case Classifications

            CreateMap<USP_REF_CASECLASSIFICATION_GETListResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsCaseClassification))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsCaseClassification")));

            CreateMap<USP_REF_CASECLASSIFICATION_SETResult, CaseClassificationSaveRequestResponseModel>();

            #endregion

            #region Diseases
            CreateMap<USP_REF_DIAGNOSISREFERENCE_GETListResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsDiagnosis))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsDiagnosis")));

            CreateMap<USP_REF_DIAGNOSISREFERENCE_GETDetailResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsDiagnosis))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsDiagnosis")));

            CreateMap<USP_REF_DIAGNOSISREFERENCE_SETResult, DiseaseSaveRequestReponseModel>();

            #endregion

            #region Measures 

            CreateMap<USP_REF_MEASURELIST_GETListResult, MeasuresDropDownViewModel>();

            CreateMap<USP_REF_MEASUREREFERENCE_GETListResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsAction))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsAction")));

            CreateMap<USP_REF_MEASUREREFERENCE_SETResult, MeasuresSaveRequestResponseModel>();

            #endregion
            
            #region Report Disease Groups

            CreateMap<USP_REF_ReportDiagnosisGroup_GETListResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsReportDiagnosisGroup))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsReportDiagnosisGroup")));

            CreateMap<USP_REF_REPORTDIAGNOSISGROUP_SETResult, ReportDiseaseGroupsSaveRequestResponseModel>();

            #endregion

            #region Sample Types 

            CreateMap<USP_REF_SampleTypeReference_GetListResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsSampleType))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsSampleType")));

            CreateMap<USP_REF_SAMPLETYPEREFERENCE_SETResult, SampleTypeSaveRequestResponseModel>();

            #endregion

            #region Species Types

            // Species Type...
            CreateMap<USP_REF_SPECIESTYPEREFERENCE_SETResult, SpeciesTypeSaveRequestResponseModel>();

            CreateMap<USP_REF_SPECIESTYPE_GETListResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsSpeciesType))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsSpeciesType")));

            #endregion Species Types

            #region Statistical Data Types

            CreateMap<USP_REF_STATISTICDATATYPE_GETListResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsStatisticDataType))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsStatisticDataType")));

            CreateMap<USP_REF_STATISTICDATATYPE_SETResult, StatisticalTypeSaveRequestResponseModel>();

            #endregion

            #region  Vector Species Types

            CreateMap<USP_REF_VectorSubType_GETListResult, BaseReferenceEditorsViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsVectorSubType))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsVectorSubType")));

            CreateMap<USP_REF_VectorSubType_SETResult, VectorSpeciesTypesSaveRequestResponseModel>();

            #endregion

            #region VectorTypes

            CreateMap<USP_REF_VECTORTYPEREFERENCE_GETListResult, BaseReferenceEditorsViewModel>()
                 .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfsVectorType))
                 .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfsVectorType")));

            CreateMap<USP_REF_VECTORTYPEREFERENCE_SETResult, VectorTypeSaveRequestResponseModel>();

  
            #endregion VectorTypes

            // Models that map to the APIPostResponseModel...
            CreateMap<USP_REF_AGEGROUP_DELResult, APIPostResponseModel>();
            CreateMap<USP_REF_BASEREFERENCE_DELResult, APIPostResponseModel>();
            CreateMap<USP_REF_CASECLASSIFICATION_DELResult, APIPostResponseModel>();
            CreateMap<USP_REF_MEASUREREFEFENCE_DELResult, APIPostResponseModel>();
            CreateMap<USP_REF_REPORTDIAGNOSISGROUP_DELResult, APIPostResponseModel>();
            CreateMap<USP_REF_SAMPLETYPEREFERENCE_DELResult, APIPostResponseModel>();
            CreateMap<USP_REF_SPECIESTYPE_DELResult, APIPostResponseModel>();
            CreateMap<USP_REF_STATISTICDATATYPE_DELResult, APIPostResponseModel>();
            CreateMap<USP_REF_VectorSubType_DELResult,APIPostResponseModel>();
            CreateMap<USP_REF_VECTORTYPEREFERENCE_DELResult, APIPostResponseModel>();
        }
    }

    public class AdminProfie : Profile
    {
        public AdminProfie()
        {

            CreateMap<USP_ASPNetUser_GetRolesAndPermissionsResult, UserRolesAndPermissionsViewModel>();
            CreateMap<USP_ASPNetUser_GetDetailResult, AspNetUserDetailModel>();
            CreateMap<USP_ADMIN_SYSTEM_PREFERENCE_GETDetailResult, SystemPreferenceViewModel>();
            CreateMap<USP_ADMIN_SYSTEM_PREFERENCE_SETResult, SystemPreferenceSaveResponseModel>();
            CreateMap<USP_GBL_SITE_GETDetailResult, SiteModel>();
            CreateMap<usp_SettlementType_GetLookupResult, SettlementTypeModel>();
            CreateMap< USP_GBL_USER_PREFERENCE_GETDetailResult, UserPreferenceViewModel>();
            CreateMap<USP_GBL_USER_PREFERENCE_SETResult, UserPreferenceSaveResponseModel>();


        }
    }

    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<usp_Country_GetLookupResult, CountryModel>();
            CreateMap<USP_OMM_Case_GetDetailResult, OMMCaseDetailModel>();
            CreateMap<USP_GBL_DISEASE_MTX_GETResult, HumanDiseaseMatrixListViewModel>();
            CreateMap<USP_GBL_DISEASE_MTX_GET_BY_UsingTypeResult, HumanDiseaseDiagnosisListViewModel>();
            CreateMap<USP_CONF_HumanAggregateCaseMatrixReport_POSTResult, HumanAggregateCaseMatrixResponseModel>();
            CreateMap<USP_CONF_GetVetDiseaseList_GETResult, VeterinaryDiseaseMatrixListViewModel>();
            CreateMap<USP_CONF_VETAggregateCaseMatrixReportRecord_DELETEResult, VeterinaryAggregateCaseMatrixReportRecordDeleteModel>();
            CreateMap<USP_GBL_Language_GETListResult, LanguageModel>();
            CreateMap<USP_GBL_Resource_GETListResult, ResourceModel>();
            CreateMap<USP_GBL_GIS_Location_CurrentLevel_GetResult, GisLocationCurrentLevelModel>();
            CreateMap<USP_GBL_GIS_Location_ChildLevel_GetResult, GisLocationChildLevelModel>();
            CreateMap<USP_GBL_GIS_Location_Levels_GetResult, GisLocationLevelModel>();
            CreateMap<USP_GBL_STREET_GETListResult, StreetModel>();
            CreateMap<USP_GBL_MENU_GETListResult, MenuViewModel>();
            CreateMap<USP_GBL_MENU_GETListResult, MenuViewModel>();


            CreateMap<USP_GBL_LKUP_REFERENCETYPE_GETLISTResult, BaseReferenceTypeListViewModel>()
                .ForMember(d => d.BaseReferenceId, o => o.MapFrom(src => src.idfsBaseReference))
                .ForMember(d => d.ReferenceId, o => o.MapFrom(src => src.idfsBaseReference))
                .ForMember(d => d.Default, o => o.MapFrom(src => src.strDefault))
                .ForMember(d => d.Name, o => o.MapFrom(src => src.strName));

            CreateMap<usp_HACode_GetCheckListResult, HACodeListViewModel>();

            CreateMap<USP_GBL_MENU_GETListResult, MenuViewModel>();
        }
    }

    public class CrossCuttingProfile : Profile
    {
        public CrossCuttingProfile()
        {
            CreateMap<USP_GBL_BASE_REFERENCE_GETListResult, BaseReferenceViewModel>();
            CreateMap<USP_CONF_ADMIN_AggregateHumanCaseMatrixReport_GETResult, AggregateCaseMatrixViewModel>();
            CreateMap<USP_CONF_ADMIN_ProphylacticMatrixReportGet_GETResult, VeterinaryProphylacticMeasureMatrixViewModel>();
            CreateMap<USP_CONF_HumanAggregateCaseMatrixVersionByMatrixType_GETResult, MatrixVersionViewModel>();
        }
    }

    public class ConfigurationProfile : Profile
    {
       public ConfigurationProfile()
        {
            CreateMap<USP_CONF_GetSpeciesList_GETResult, SpeciesViewModel>();
            CreateMap<USP_CONF_AggregateSetting_GetListResult, AggregateSettingsModel>();
            CreateMap<USP_CONF_ADMIN_SanitaryMatrixReportGet_GETResult, VeterinarySanitaryActionMatrixViewModel>();

            #region Species Animal Age

            CreateMap<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_GETLISTResult, ConfigurationMatrixViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfSpeciesTypeToAnimalAge))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfSpeciesTypeToAnimalAge")));

            CreateMap<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_SETResult, SpeciesAnimalAgeSaveRequestResponseModel>();

            CreateMap<USP_CONF_SPECIESTYPEANIMALAGEMATRIX_DELResult, APIPostResponseModel>();
            #endregion

            CreateMap<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_GETLISTResult, ConfigurationMatrixViewModel>()
                .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfDerivativeForSampleType))
                .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfDerivativeForSampleType")));
            CreateMap<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_SETResult, SampleTypeDerivativeMatrixSaveRequestResponseModel>();

            CreateMap<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_DELResult, APIPostResponseModel>();

            CreateMap<USP_CONF_ADMIN_SanitaryMatrixReportGet_GETResult, VeterinarySanitaryActionMatrixViewModel>();
            
            CreateMap<USP_CONF_ADMIN_VetDiagnosisInvesitgationMatrixReport_GETResult, VeterinaryDiagnosticInvestigationMatrixReportModel>();
            CreateMap<USP_CONF_GetInvestigationTypes_GETResult, InvestigationTypeViewModel>();
            CreateMap<USP_CONF_AggrDiagnosticActionMTXReportJSON_POSTResult, APIPostResponseModel>();            

            CreateMap<USP_CONF_CUSTOMREPORT_GETLISTResult, ConfigurationMatrixViewModel>()
               .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfReportRows))
               .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfReportRows")));
            CreateMap<USP_CONF_CUSTOMREPORT_SETResult, CustomReportRowsMatrixSaveRequestResponseModel>();
            CreateMap<USP_CONF_CUSTOMREPORT_DELResult, APIPostResponseModel>();

            CreateMap<USP_CONF_DISEASEGROUPDISEASEMATRIX_GETLISTResult, ConfigurationMatrixViewModel>()
              .ForMember(d => d.KeyId, o => o.MapFrom(src => src.idfDiagnosisToDiagnosisGroup))
              .ForMember(d => d.KeyIdName, o => o.MapFrom(o => new string("idfDiagnosisToDiagnosisGroup")));
            CreateMap<USP_CONF_DISEASEGROUPDISEASEMATRIX_SETResult, DiseaseGroupDiseaseMatrixSaveRequestResponseModel>();
            CreateMap<USP_CONF_DISEASEGROUPDISEASEMATRIX_DELResult, APIPostResponseModel>();
        }
    }

    public class FlexFormProfile: Profile
    {
        public FlexFormProfile()
        {
            CreateMap<USP_ADMIN_FF_FormTypes_GETResult, FlexFormFormTypesListViewModel>();
            CreateMap<USP_ADMIN_FF_Parameters_GETResult, FlexFormParametersListViewModel>();
            CreateMap<USP_ADMIN_FF_Sections_GETResult, FlexFormSectionsListViewModel>();
            CreateMap<USP_ADMIN_FF_Templates_GETResult, FlexFormTemplateListViewModel>();
            CreateMap<USP_ADMIN_FF_SectionParameterTree_GETResult, FlexFormSectionParameterListViewModel>();

            CreateMap<USP_ADMIN_FF_Template_GetDetailResult, FlexFormTemplateDetailViewModel>();
            CreateMap<USP_ADMIN_FF_TemplateDesign_GETResult, FlexFormTemplateDesignListViewModel>();
            CreateMap<USP_ADMIN_FF_TemplateDeterminantValues_GETResult, FlexFormTemplateDeterminantValuesListViewModel>();
            CreateMap<USP_ADMIN_FF_ActivityParameters_GETResult, FlexFormActivityParametersListResponseModel>();
        }
    }
}