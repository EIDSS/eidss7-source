using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class GetHumanDiseaseDiagnosisMatrixListAsync : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.HumanAggregateDiseaseMatrixController;
        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType => typeof(List<HumanDiseaseDiagnosisListViewModel>);
        public string MethodParameters => "long usingType, long intHACode, string strLanguageID, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;
        public Type RepositoryReturnType => typeof(List<USP_GBL_DISEASE_MTX_GET_BY_UsingTypeResult>);
        public string SummaryInfo => "Get a list of human disease diagnosis";
    }

    public class GetHumanAggregateDiseaseMatrixList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanAggregateDiseaseMatrixController; }
        public Type APIReturnType { get => typeof(List<HumanAggregateDiseaseMatrixViewModel>); }
        public string MethodParameters { get => "HumanAggregateCaseMatrixGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_CONF_ADMIN_AggregateHumanCaseMatrixReport_GETResult>); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Get Human Aggregate Disease Report Matrix";        
    }

    public class SaveHumanAggregateDiseaseMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanAggregateDiseaseMatrixController; }
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters { get => "MatrixViewModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_HumanAggregateCaseMatrixReport_SETResult); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Save Human Aggregate Disease Report Matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class DeleteHumanAggregateDiseaseMatrixRecord : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.HumanAggregateDiseaseMatrixController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "MatrixViewModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_HumanAggregateCaseMatrixReportRecord_DELETEResult); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Delete Human Aggregate Disease Report Matrix Record";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
}