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
    public class DeleteMeasure : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.MeasuresReferenceEditorController;

        public Type APIReturnType => typeof(APIPostResponseModel);

        public string MethodParameters => "MeasuresSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_REF_MEASUREREFEFENCE_DELResult);
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }

    public class GetMeasuresDropDownList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.MeasuresReferenceEditorController;

        public Type APIReturnType => typeof(List<MeasuresDropDownViewModel>);

        public string MethodParameters => "string languageId, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;

        public Type RepositoryReturnType => typeof(List<USP_REF_MEASURELIST_GETListResult>);
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
    }

    public class GetMeasureReferenceList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.MeasuresReferenceEditorController;

        public Type APIReturnType => typeof(List<BaseReferenceEditorsViewModel>);

        public string MethodParameters => "MeasuresGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_REF_MEASUREREFERENCE_GETListResult>);
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
    }

    public class SaveMeasures : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.MeasuresReferenceEditorController;

        public Type APIReturnType => typeof(APISaveResponseModel);

        public string MethodParameters => "MeasuresSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_REF_MEASUREREFERENCE_SETResult);
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }
}
