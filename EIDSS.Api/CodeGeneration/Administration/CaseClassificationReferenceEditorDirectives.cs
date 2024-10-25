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
    public class DeleteCaseClassification : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.CaseClassificationsReferenceEditorController; }

        public string APIGroupName => "Administration - Base Reference Editors";
        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "CaseClassificationSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_REF_CASECLASSIFICATION_DELResult); }
        public string SummaryInfo => "";

        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }

    public class GetCaseClassificationList : ICodeGenDirective
    {
        public string APIClassName { get =>  TargetedClassNames.CaseClassificationsReferenceEditorController; }

        public string APIGroupName => "Administration - Base Reference Editors";
        public Type APIReturnType { get => typeof(List<BaseReferenceEditorsViewModel>); }

        public string MethodParameters { get => "CaseClassificationGetRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_REF_CASECLASSIFICATION_GETListResult>); }
        public string SummaryInfo => "";
    }

    public class SaveCaseClassification : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.CaseClassificationsReferenceEditorController; }

        public string APIGroupName => "Administration - Base Reference Editors";

        public Type APIReturnType { get => typeof(APISaveResponseModel); }

        public string MethodParameters { get => "CaseClassificationSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_REF_CASECLASSIFICATION_SETResult); }
        public string SummaryInfo => "";

        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }
}
