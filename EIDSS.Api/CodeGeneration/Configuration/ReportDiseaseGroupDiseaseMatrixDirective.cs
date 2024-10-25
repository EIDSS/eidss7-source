using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class DeleteReportDiseaseGroupDiseaseMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportDiseaseGroupDiseaseMatrixController;
        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType => typeof(APIPostResponseModel);
        public string MethodParameters => "ReportDiseaseGroupDiseaseMatrixSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;
        public Type RepositoryReturnType => typeof(USP_CONF_REPORTDISEASEGROUPDISEASEMATRIX_DELResult);
        public string SummaryInfo => "Delete a Report Disease Group - Disease Matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class GetReportDiseaseGroupDiseaseMatrixList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportDiseaseGroupDiseaseMatrixController;
        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType => typeof(List<ReportDiseaseGroupDiseaseMatrixViewModel>);
        public string MethodParameters => "ReportDiseaseGroupDiseaseMatrixGetRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;
        public Type RepositoryReturnType => typeof(List<USP_CONF_REPORTDISEASEGROUPDISEASEMATRIX_GETLISTResult>);
        public string SummaryInfo => "Get Report Disease Group - Disease Matrix list";
    }

    public class SaveReportDiseaseGroupDiseaseMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.ReportDiseaseGroupDiseaseMatrixController;
        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType => typeof(APISaveResponseModel);
        public string MethodParameters => "ReportDiseaseGroupDiseaseMatrixSaveRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;
        public Type RepositoryReturnType => typeof(USP_CONF_REPORTDISEASEGROUPDISEASEMATRIX_SETResult);
        public string SummaryInfo => "Save a Report Disease Group - Disease matrix record";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
}
