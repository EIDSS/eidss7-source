using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ResponseModels.CrossCutting;

namespace EIDSS.Api.CodeGeneration.Administration
{
    public class GetHACodeList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.CrossCuttingController;

        public Type APIReturnType => typeof(List<HACodeListViewModel>);

        public string MethodParameters => "string langId, int? intHACodeMask, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;

        public Type RepositoryReturnType => typeof(List<USP_HACode_GetCheckListResult>);

        public string APIGroupName => "Cross Cutting";

        public string SummaryInfo => "";
    }

    public class GetBaseReferenceByIDList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.CrossCuttingController;

        public Type APIReturnType => typeof(List<BaseReferenceEditorsViewModel>);

        public string MethodParameters => "BaseReferenceEditorGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_REF_BASEREFERENCE_Filtered_GETListResult>);

        public string APIGroupName => "Cross Cutting";

        public string SummaryInfo => "";
    }

    public class GetBaseReferenceLookupList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.CrossCuttingController;

        public Type APIReturnType => typeof(List<BaseReferenceEditorsViewModel>);

        public string MethodParameters => "BaseReferenceEditorGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_REF_LKUP_BASE_REFERENCE_GETListResult>);

        public string APIGroupName => "Cross Cutting";

        public string SummaryInfo => "";
    }

    public class GetBaseReferenceTypesByName : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.CrossCuttingController;

        public Type APIReturnType => typeof(List<BaseReferenceTypeListViewModel>);

        public string MethodParameters => "ReferenceTypeRquestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_GBL_LKUP_REFERENCETYPE_FILTERED_PAGED_GETLISTResult>);

        public string APIGroupName => "Cross Cutting";

        public string SummaryInfo => "";
    }

    public class GetBaseReferenceTypesByIdPaged : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.CrossCuttingController;

        public Type APIReturnType => typeof(List<BaseReferenceTypeListViewModel>);

        public string MethodParameters => "ReferenceTypeByIdRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_GBL_LKUP_REFERENCETYPE_BY_IDS_GETLIST_PagedResult>);

        public string APIGroupName => "Cross Cutting";

        public string SummaryInfo => "";
    }


    public class DeleteMatrixVersion : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.CrossCuttingController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "long idfVersion, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_HumanAggregateCaseMatrixVersion_DELETEResult); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class GetBaseReferenceAdvancedList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.CrossCuttingController;

        public Type APIReturnType => typeof(List<BaseReferenceAdvancedListResponseModel>);

        public string MethodParameters => "BaseReferenceAdvancedListRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_GBL_BASE_REFERENCE_Advanced_GETListResult>);

        public string APIGroupName => "Cross Cutting";

        public string SummaryInfo => "";
    }
}
