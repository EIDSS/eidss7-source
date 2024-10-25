using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class DeleteDiseasePensideTestMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseasePensideTestMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APIPostResponseModel);

        public string MethodParameters => "DiseasePensideTestMatrixSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_DISEASEPENSIDETESTMATRIX_DELResult);

        public string SummaryInfo => "Deletes a disease penside test matrix";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class GetDiseasePensideTestMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseasePensideTestMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(List<DiseasePensideTestMatrixGetRequestResponseModel>);

        public string MethodParameters => "DiseasePensideTestMatrixGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_CONF_DISEASEPENSIDETESTMATRIX_GETListResult>);

        public string SummaryInfo => "Gets a list of disease penside test matrix results";
    }

    public class SaveDiseasePensideTestMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseasePensideTestMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APISaveResponseModel);

        public string MethodParameters => "DiseasePensideTestMatrixSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_DISEASEPENSIDETESTMATRIX_SETResult);

        public string SummaryInfo => "Saves a disease penside test matrix";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
}