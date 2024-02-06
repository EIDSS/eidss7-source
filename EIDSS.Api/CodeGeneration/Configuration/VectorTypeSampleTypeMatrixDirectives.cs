using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class GetVectorTypeSampleTypeMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.VectorTypeSampleTypeMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(List<VectorTypeSampleTypeMatrixViewModel>);

        public string MethodParameters => "VectorTypeSampleTypeMatrixGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_CONF_VECTORTYPESAMPLETYPEMATRIX_GETLISTResult>);

        public string SummaryInfo => "Gets the vector Type sample type matrix";
    }

    public class DeleteVectorTypeSampleTypeMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.VectorTypeSampleTypeMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APIPostResponseModel);

        public string MethodParameters { get => "VectorTypeSampleTypeMatrixSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType => typeof(USP_CONF_VECTORTYPESAMPLETYPEMATRIX_DELResult);

        public string SummaryInfo => "Deletes a vector type sample type matrix";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class SaveVectorTypeSampleTypeMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorTypeSampleTypeMatrixController; }

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType { get => typeof(APISaveResponseModel); }

        public string MethodParameters { get => "VectorTypeSampleTypeMatrixSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_CONF_VECTORTYPESAMPLETYPEMATRIX_SETResult); }

        public string SummaryInfo => "";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
}