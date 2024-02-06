using EIDSS.Api.CodeGeneration.Control;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.CodeGenerator;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class GetStatisticalAgeGroupMatrixList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.StatisticalAgeGroupMatrixController; }

        public Type APIReturnType { get => typeof(List<StatisticalAgeGroupMatrixViewModel>); }

        public string MethodParameters { get => "StatisticalAgeGroupMatrixGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_GETLISTResult>); }
        
        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Gets a Statistical Age Group Matrix";
    }

    public class DeleteStatisticalAgeGroupMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.StatisticalAgeGroupMatrixController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "StatisticalAgeGroupMatrixSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_DELResult); }

        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Delete a Statistical Age Group Matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class SaveStatisticalAgeGroupMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.StatisticalAgeGroupMatrixController; }

        public Type APIReturnType { get => typeof(APISaveResponseModel); }

        public string MethodParameters { get => "StatisticalAgeGroupMatrixSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_CONF_AGEGROUPSTATISTICALAGEGROUPMATRIX_SETResult); }

        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Create or update a Statistical Age Group Matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

}
