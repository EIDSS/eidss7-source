using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using System;
using EIDSS.CodeGenerator;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.RequestModels.Human;

namespace EIDSS.Api.CodeGeneration.Human
{
    public class GetILIAggregateList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ILIAggregateFormController; }
        public Type APIReturnType { get => typeof(List<ILIAggregateViewModel>); }
        public string MethodParameters { get => "ILIAggregateFormSearchRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ILI_Aggregate_GetListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class GetILIAggregateDetailList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ILIAggregateFormController; }
        public Type APIReturnType { get => typeof(List<ILIAggregateDetailViewModel>); }
        public string MethodParameters { get => "ILIAggregateFormDetailRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_ILI_Aggregate_Detail_GetListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class SaveILIAggregate : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ILIAggregateFormController; }
        public Type APIReturnType { get => typeof(ILIAggregateSaveRequestModel); }
        public string MethodParameters { get => "ILIAggregateSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ILI_Aggregate_SetResult); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class DeleteILIAggregateHeader : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ILIAggregateFormController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "long idfAggregateHeader, string auditUserName, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_ILI_Aggregate_DeleteResult); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "Deletes record from tlbBasicSyndromicSurveillanceAggregateHeader and tlbBasicSyndromicSurveillanceAggregateDetail";
    }

    public class DeleteILIAggregateDetail : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ILIAggregateFormController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "string userId, long idfAggregateDetail, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }
        public Type RepositoryReturnType { get => typeof(USP_ILI_Aggregate_Form_DeleteResult); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "Deletes record from tlbBasicSyndromicSurveillanceAggregateDetail";
    }


}
