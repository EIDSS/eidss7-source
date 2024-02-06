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
    public class GetVectorTypeCollectionMethodMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.VectorTypeCollectionMethodMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(List<VectorTypeCollectionMethodMatrixViewModel>);

        public string MethodParameters => "VectorTypeCollectionMethodMatrixGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_GETLISTResult>);

        public string SummaryInfo => "Gets the Vector Type Collection Method Matrix";
    }

    public class DeleteVectorTypeCollectionMethodMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.VectorTypeCollectionMethodMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APIPostResponseModel);

        public string MethodParameters { get => "VectorTypeCollectionMethodMatrixSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType => typeof(USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_DELResult);

        public string SummaryInfo => "Deletes a vector type Collection Method matrix";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class SaveVectorTypeCollectionMethodMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.VectorTypeCollectionMethodMatrixController; }

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType { get => typeof(APISaveResponseModel); }

        public string MethodParameters { get => "VectorTypeCollectionMethodMatrixSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_CONF_VECTORTYPECOLLECTIONMETHODMATRIX_SETResult); }

        public string SummaryInfo => "Adds a new record for Vector Type Collection Method";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
}