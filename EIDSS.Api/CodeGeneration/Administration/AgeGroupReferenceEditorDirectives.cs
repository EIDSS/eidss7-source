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

    public class DeleteAgeGroup : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AgeGroupReferenceEditorController; }

        public string APIGroupName => "Administration - Base Reference Editors";
        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "AgeGroupSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_REF_AGEGROUP_DELResult); }

        public string SummaryInfo => "";

        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;

    }

    public class GetAgeGroupList : ICodeGenDirective
    {

        public string APIClassName { get => TargetedClassNames.AgeGroupReferenceEditorController; }

        public string APIGroupName => "Administration - Base Reference Editors";

        public Type APIReturnType { get => typeof(List<BaseReferenceEditorsViewModel>); }

        public string MethodParameters { get => "AgeGroupGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_REF_AGEGROUP_GETListResult>); }
        public string SummaryInfo => "";
    }

    public class SaveAgeGroup : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AgeGroupReferenceEditorController; }

        public string APIGroupName => "Administration - Base Reference Editors";

        public Type APIReturnType { get => typeof(APISaveResponseModel); }

        public string MethodParameters { get => "AgeGroupSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_REF_AGEGROUP_SETResult); }
        public string SummaryInfo => "";

        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }
}
