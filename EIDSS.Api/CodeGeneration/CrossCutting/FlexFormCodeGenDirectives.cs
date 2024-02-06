using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.FlexForm;
using System;
using EIDSS.CodeGenerator;
using System.Collections.Generic;
using EIDSS.Domain.ViewModels.Administration;

namespace EIDSS.Api.CodeGeneration
{
    public class GetFormTypesListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormFormTypesListViewModel>); }
        public string MethodParameters { get => "string LangID, long? idfsFormType, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_FormTypes_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetSectionsListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormSectionsListViewModel>); }
        public string MethodParameters { get => "string LangID, long? idfsFormType, long? idfsSection, long? idfsParentSection, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_Sections_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetParametersListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormParametersListViewModel>); }
        public string MethodParameters { get => "string LangID, long? idfsSection, long? idfsFormType, string SectionIDs, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_Parameters_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetTemplateListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormTemplateListViewModel>); }
        public string MethodParameters { get => "string LangID, long? idfsFormTemplate, long? idfsFormType, long? idfOutbreak, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_Templates_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetSectionsParametersListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormSectionParameterListViewModel>); }
        public string MethodParameters { get => "FlexFormSectionsParametersRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_SectionParameterTree_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetTemplateDetailAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormTemplateDetailViewModel>); }
        public string MethodParameters { get => "FlexFormTemplateDetailsGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_Template_GetDetailResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetTemplateDesignAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormTemplateDesignListViewModel>); }
        public string MethodParameters { get => "string langid, long? idfsFormTemplate, string User, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_TemplateDesign_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetTemplateDeterminantValuesAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormTemplateDeterminantValuesListViewModel>); }
        public string MethodParameters { get => "string LangID, long? idfsFormTemplate, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_TemplateDeterminantValues_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class SetParameterAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(FlexFormParametersSaveResponseModel); }
        public string MethodParameters => "FlexFormParametersSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_Parameters_SETResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class SetSectionAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(FlexFormSectionSaveResponseModel); }
        public string MethodParameters => "FlexFormSectionSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_Sections_SETResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class SetTemplateAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(FlexFormParameterTemplateSaveResponseModel); }
        public string MethodParameters { get => "FlexFormTemplateSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_Template_SETResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.FlexibleForm_UNITemplate_Changed;

    }

    public class SetTemplateParameterAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters => "FlexFormParameterTemplateSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_ParameterTemplate_SETResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class CopyParameterAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "FlexFormParameterCopyRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_Parameter_CopyResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class CopySectionAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "FlexFormSectionCopyRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_Section_CopyResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class DeleteTemplateParameterAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(FlexFormDeleteTemplateParameterResponseModel); }
        public string MethodParameters { get => "FlexFormDeleteTemplateParameterRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_ParameterTemplate_DELResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class DeleteSectionAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "long? idfsSection, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_Section_DELResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class DeleteParameterAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<FlexFormDeleteParameterResponseModel>); }
        public string MethodParameters { get => "string LangId, long idfsParameter, string User, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_Parameter_DELResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetParameterAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormParameterDetailViewModel>); }
        public string MethodParameters { get => "string LangID, long? idfsParameter, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_Parameter_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetTemplatesByParameterAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormTemplateByParameterListModel>); }
        public string MethodParameters { get => "string LangID, long? idfsParameter, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_TemplatesByParameter_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class SetRequiredParameterAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters => "FlexFormRequiredParameterSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_RequiredParameter_SETResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class SetTemplateSectionOrderAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters => "FlexFormTemplateSectionOrderRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_TemplateSectionOrder_SetResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class SetTemplateParameterOrderAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters => "FlexFormTemplateParameterOrderRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_TemplateParameterOrder_SetResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class IsParameterInUseAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormParameterInUseDetailViewModel>); }
        public string MethodParameters { get => "long? idfsParameter, long? idfsFormTemplate, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_ParameterInUseResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class SetDeterminantAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters => "FlexFormDeterminantSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_Determinant_SETResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetRulesListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormRulesListViewModel>); }
        public string MethodParameters { get => "string LangID, long? idfsFunctionParameter, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_Rules_GETListResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetFlexFormRulesListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.FlexForm.FlexFormRuleListResponseModel>); }
        public string MethodParameters { get => "FlexFormRuleListGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_Rules_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetFlexFormRuleActionsListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.FlexForm.FlexFormRuleActionsResponseModel>); }
        public string MethodParameters { get => "FlexFormRuleActionsRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_RuleParameterForAction_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class SetRuleAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters => "FlexFormRuleSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_Rules_SETResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class CopyTemplateAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(FlexFormCopyTemplateResponseModel); }
        public string MethodParameters => "FlexFormCopyTemplateRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_Copy_TemplateResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetRuleDetailsAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormRuleDetailsViewModel>); }
        public string MethodParameters => "FlexFormRuleDetailsGetRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_Rule_GetDetailsResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class DeleteTemplateAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "FlexFormTemplateDeleteRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_Template_DELResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetDeterminantDiseaseList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }

        public Type APIReturnType { get => typeof(List<Domain.ViewModels.FlexForm.FlexFormDiagnosisReferenceListViewModel>); }

        public string MethodParameters { get => "FlexFormDiseaseGetListRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_DIAGNOSISREFERENCE_GETListResult>); }
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
    }

    public class GetQuestionnaireAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<Domain.ResponseModels.FlexForm.FlexFormQuestionnaireResponseModel>); }
        public string MethodParameters { get => "FlexFormQuestionnaireGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_FlexForm_GetResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetActivityParametersList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }

        public Type APIReturnType { get => typeof(List<FlexFormActivityParametersListResponseModel>); }

        public string MethodParameters { get => "FlexFormActivityParametersGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_ActivityParameters_GETResult>); }
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
    }

    public class GetParameterSelectList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }

        public Type APIReturnType { get => typeof(List<FlexFormParameterSelectListResponseModel>); }

        public string MethodParameters { get => "FlexFormParameterSelectListGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_ParameterSelectList_GETResult>); }
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
    }

    public class SetActivityParametersAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(FlexFormActivityParametersResponseModel); }
        public string MethodParameters => "FlexFormActivityParametersSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_ActivityParameters_SETResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class SetOutbreakFlexFormAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters => "FlexFormAddToOutbreakSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_OMM_FlexForm_SetResult); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetFormTemplateAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<FlexFormFormTemplateResponeModel>); }
        public string MethodParameters { get => "FlexFormFormTemplateRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_FormTemplate_GETResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }

    public class GetParameterTypeEditorMappingAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FlexFormController; }
        public Type APIReturnType { get => typeof(List<FlexFormParameterTypeEditorMappingResponseModel>); }
        public string MethodParameters { get => "FlexFormParameterTypeEditorMappingRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_ParameterTypeEditorMapping_GetListResult>); }
        public string APIGroupName => "Flexible Forms";
        public string SummaryInfo => "";
    }
}