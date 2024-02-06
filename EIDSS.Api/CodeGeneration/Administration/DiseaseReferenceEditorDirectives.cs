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
    public class DeleteDisease : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DiseaseReferenceEditorController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "DiseaseSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_REF_DIAGNOSISREFERENCE_DELResult); }

        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }

    public class GetDiseaseList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DiseaseReferenceEditorController; }

        public Type APIReturnType { get => typeof(List<BaseReferenceEditorsViewModel>); }

        public string MethodParameters { get => "DiseasesGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_REF_DIAGNOSISREFERENCE_GETListResult>); }
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
    }

    public class GetDiseaseDetail : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DiseaseReferenceEditorController; }

        public Type APIReturnType => typeof(List<DiseaseReferenceGetDetailViewModel>); 

        public string MethodParameters {get => "long idfsDiagnosis, string languageId, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;

        public Type RepositoryReturnType => typeof(List<USP_REF_DIAGNOSISREFERENCE_GETDetailResult>);
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
    }

    public class SaveDisease : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseaseReferenceEditorController;

        public Type APIReturnType => typeof(APISaveResponseModel);

        public string MethodParameters => "DiseaseSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_REF_DIAGNOSISREFERENCE_SETResult);
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }
}
