using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Administration
{
    public class DeleteVectorSpeciesType : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.VectorSpeciesTypesReferenceEditorController;

        public Type APIReturnType => typeof(APIPostResponseModel);

        public string MethodParameters => "VectorSpeciesTypesSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_REF_VectorSubType_DELResult);
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }

    public class GetVectorSpeciesTypeList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.VectorSpeciesTypesReferenceEditorController;

        public Type APIReturnType => typeof(List<BaseReferenceEditorsViewModel>);

        public string MethodParameters => "VectorSpeciesTypesGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_REF_VectorSubType_GETListResult>);
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
    }

    public class SaveVectorSpeciesType : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.VectorSpeciesTypesReferenceEditorController;

        public Type APIReturnType => typeof(APISaveResponseModel);

        public string MethodParameters => "VectorSpeciesTypesSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_REF_VectorSubType_SETResult);
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }
}
