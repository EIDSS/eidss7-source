using System;
using System.Collections.Generic;
using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Repository.ReturnModels;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class DeleteLabTestMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseaseLabTestMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APIPostResponseModel);

        public string MethodParameters =>
            "DiseaseLabTestMatrixGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_DISEASELABTESTMATRIX_DELResult);

        public string SummaryInfo => "Deletes a disease lab test matrix";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class GetLabTestMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseaseLabTestMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(List<DiseaseLabTestMatrixGetRequestResponseModel>);

        public string MethodParameters =>
            "DiseaseLabTestMatrixGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_CONF_DISEASELABTESTMATRIX_GETLISTResult>);

        public string SummaryInfo => "Gets a list of disease lab test matrix results";
    }

    public class SaveLabTestMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseaseLabTestMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APISaveResponseModel);

        public string MethodParameters =>
            "DiseaseLabTestMatrixGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_DISEASELABTESTMATRIX_SETResult);

        public string SummaryInfo => "Saves a disease lab test matrix";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
}