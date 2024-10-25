using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class GetParameterTypeList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ParameterTypeEditorController; }

        public Type APIReturnType { get => typeof(List<ParameterTypeViewModel>); }

        public string MethodParameters { get => "ParameterTypeGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_ParameterTypes_FILTERResult>); }

        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Gets a listing of parameter types filtered by optional search string";
    }

    public class GetParameterFixedPresetValueList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ParameterTypeEditorController; }

        public Type APIReturnType { get => typeof(List<ParameterFixedPresetValueViewModel>); }

        public string MethodParameters { get => "ParameterFixedPresetValueGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_ParameterFixedPresetValue_GETListResult>); }

        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Gets a listing of the fixed preset values that belong to a parameter type.";
    }

    public class GetParameterReferenceValueList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ParameterTypeEditorController; }

        public Type APIReturnType { get => typeof(List<ParameterReferenceValueViewModel>); }

        public string MethodParameters { get => "ParameterReferenceValueGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_ParameterReferenceTypes_GETDetailResult>); }

        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Gets a listing of the reference values that belong to a parameter type.";
    }

    public class GetParameterReferenceList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ParameterTypeEditorController; }

        public Type APIReturnType { get => typeof(List<ParameterReferenceViewModel>); }

        public string MethodParameters { get => "ParameterReferenceGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_ADMIN_FF_ParameterReferenceTypes_GETListResult>); }

        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Gets a listing of the base references that can be used with a parameter type.";
    }
    public class DeleteParameterType : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ParameterTypeEditorController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "long? idfsParameterType, string user, bool? deleteAnyway, string langId, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_ParameterTypes_DELResult); }

        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Delete a parameter type";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class DeleteParameterFixedPresetValue : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ParameterTypeEditorController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "long idfsParameterFixedPresetValue, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_ParameterFixedPresetValue_DELResult); }

        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Delete a fixed preset value from a parameter type.";
    }
    public class SaveParameterType : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ParameterTypeEditorController; }

        public Type APIReturnType { get => typeof(ParameterTypeSaveRequestResponseModel); }

        public string MethodParameters { get => "ParameterTypeSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_ParameterTypes_SETResult); }

        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Create or update a Parameter Type";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
    public class SaveParameterFixedPresetValue : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ParameterTypeEditorController; }

        public Type APIReturnType { get => typeof(ParameterFixedPresetValueSaveRequestResponseModel); }

        public string MethodParameters { get => "ParameterFixedPresetValueSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_FF_ParameterFixedPresetValue_SETResult); }

        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Create or update a Parameter Fixed Preset Value for a parameter type.";
    }
}
