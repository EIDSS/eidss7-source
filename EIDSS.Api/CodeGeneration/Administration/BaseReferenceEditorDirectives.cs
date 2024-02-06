using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Administration
{
    public class DeleteBaseReference : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.BaseReferenceEditorController; }

        public string APIGroupName => "Administration - Base Reference Editors";
        public Type APIReturnType { get => typeof(APISaveResponseModel); }

        public string MethodParameters { get => " BaseReferenceSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_REF_BASEREFERENCE_DELResult); }

        public string SummaryInfo => "";

        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }


    public class SaveBaseReference : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.BaseReferenceEditorController; }

        public string APIGroupName => "Administration - Base Reference Editors";
        public Type APIReturnType { get => typeof(APISaveResponseModel); }

        public string MethodParameters { get => " BaseReferenceSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_REF_BASEREFERENCE_SETResult); }
        public string SummaryInfo => "";

        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }
}
