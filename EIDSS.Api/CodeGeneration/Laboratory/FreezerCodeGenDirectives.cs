using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using System;
using EIDSS.CodeGenerator;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels.Laboratory.Freezers;
using EIDSS.Domain.RequestModels.Laboratory.Freezer;

namespace EIDSS.Api.CodeGeneration.Laboratory
{
    public class GetFreezerList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FreezerController; }
        public Type APIReturnType { get => typeof(List<FreezerViewModel>); }
        public string MethodParameters { get => "FreezerRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_LAB_FREEZER_GETListResult>); }
        public string APIGroupName => "Freezer";
        public string SummaryInfo => "Gets list of freezers";
    }

    public class GetFreezerSubdivisionList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FreezerController; }
        public Type APIReturnType { get => typeof(List<FreezerSubdivisionViewModel>); }
        public string MethodParameters { get => "FreezerSubdivisionRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_LAB_FREEZER_SUBDIVISION_GETListResult>); }
        public string APIGroupName => "Freezer";
        public string SummaryInfo => "Gets list of freezer subdivions";
    }

    public class SaveFreezer : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.FreezerController; }
        public Type APIReturnType { get => typeof(FreezerSaveRequestResponseModel); }
        public string MethodParameters { get => "FreezerSaveRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_LAB_FREEZER_SETResult); }
        public string APIGroupName => "Freezer";
        public string SummaryInfo => "Save freezer info";
    }
}



