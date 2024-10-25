using EIDSS.Api.CodeGeneration.Control;
using System;
using System.Collections.Generic;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Repository.ReturnModels;

namespace EIDSS.Api.CodeGeneration.Human
{
    public class GetWHOExportList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.WHOExportController;
        public Type APIReturnType => typeof(List<WHOExportGetListViewModel>);
        public string MethodParameters => "WHOExportRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;
        public Type RepositoryReturnType => typeof(List<USP_HUM_REP_WHOEXPORTResult>);
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }
}
