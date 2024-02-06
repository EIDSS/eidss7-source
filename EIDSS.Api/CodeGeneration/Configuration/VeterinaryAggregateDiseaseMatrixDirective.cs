using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class GetVeterinaryAggregateDiseaseMatrixReport : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryAggregateDiseaseMatrixController; }
        public Type APIReturnType { get => typeof(List<VeterinaryAggregateDiseaseMatrixViewModel>); }
        public string MethodParameters { get => "string versionList, string LangID, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_CONF_ADMIN_AggregateVetCaseMatrixReport_GETResult>); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Get Veterinary Aggregate Disease Report Matrix";
    }

    public class SaveVeterinaryAggregateDiseaseMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryAggregateDiseaseMatrixController; }
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters { get => "MatrixViewModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_VeterinaryAggregateCaseMatrixReport_SETResult); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Save Veterinary Aggregate Disease Report Matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class DeleteVeterinaryAggregateDiseaseMatrixRecord : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VeterinaryAggregateDiseaseMatrixController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "MatrixViewModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_VETAggregateCaseMatrixReportRecord_DELETEResult); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "Delete Veterinary Aggregate Disease Report Matrix Record";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

}
