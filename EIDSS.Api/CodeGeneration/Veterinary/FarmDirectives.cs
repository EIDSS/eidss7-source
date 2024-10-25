using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Veterinary;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;


namespace EIDSS.Api.CodeGeneration.Veterinary
{
    public class FarmDirectives
    {
        public class FarmGetListAsync : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.FarmController; }

            public Type APIReturnType { get => typeof(List<FarmViewModel>); }

            public string MethodParameters { get => "FarmSearchRequestModel request, CancellationToken cancellationToken = default"; }

            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

            public Type RepositoryReturnType { get => typeof(List<USP_VET_FARM_GETListResult>); }

            public string APIGroupName => "Veterinary";

            public string SummaryInfo => "Search for a list of farms given a set of search criteria.";

        }

        public class FarmMasterGetListAsync : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.FarmController; }

            public Type APIReturnType { get => typeof(List<FarmViewModel>); }

            public string MethodParameters { get => "FarmMasterSearchRequestModel request, CancellationToken cancellationToken = default"; }

            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

            public Type RepositoryReturnType { get => typeof(List<USP_VET_FARM_MASTER_GETListResult>); }

            public string APIGroupName => "Veterinary";

            public string SummaryInfo => "Search for a list of farms from the master farm list given a set of search criteria.";
        }

        public class GetFarmMasterDetail : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.FarmController; }

            public Type APIReturnType { get => typeof(List<FarmMasterGetDetailViewModel>); }

            public string MethodParameters { get => "FarmMasterGetDetailRequestModel request, CancellationToken cancellationToken = default"; }

            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

            public Type RepositoryReturnType { get => typeof(List<USP_VET_FARM_MASTER_GETDetailResult>); }

            public string APIGroupName => "Veterinary";

            public string SummaryInfo => "Get farm master detail record.";

        }

        public class GetFarmDetail : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.FarmController; }

            public Type APIReturnType { get => typeof(List<FarmGetListDetailViewModel>); }

            public string MethodParameters { get => "FarmGetListDetailRequestModel request, CancellationToken cancellationToken = default"; }

            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

            public Type RepositoryReturnType { get => typeof(List<USP_VET_FARM_GETDetailResult>); }

            public string APIGroupName => "Veterinary";

            public string SummaryInfo => "Get farm detail record.";
        }

        public class SaveFarm : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.FarmController; }

            public Type APIReturnType { get => typeof(FarmSaveRequestResponseModel); }

            public string MethodParameters { get => "FarmSaveRequestModel request, CancellationToken cancellationToken = default"; }

            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

            public Type RepositoryReturnType { get => typeof(USP_VET_FARM_MASTER_SETResult); }

            public string APIGroupName => "Veterinary";

            public string SummaryInfo => "Farm Save";

        }

        public class FarmUpdate : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.FarmController; }

            public Type APIReturnType { get => typeof(FarmSaveRequestResponseModel); }

            public string MethodParameters { get => "long farmID, CancellationToken cancellationToken = default"; }

            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

            public Type RepositoryReturnType { get => typeof(USP_VET_FARM_MASTER_SETResult); }

            public string APIGroupName => "Veterinary";

            public string SummaryInfo => "Farm Update";


        }
      
        public class DeleteFarmMaster : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.FarmController; }

            public Type APIReturnType { get => typeof(APIPostResponseModel); }

            public string MethodParameters { get => "long farmMasterID, bool deduplicationIndicator, string auditUserName, CancellationToken cancellationToken = default"; }

            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

            public Type RepositoryReturnType { get => typeof(USP_VET_FARM_MASTER_DELResult); }

            public string APIGroupName => "Veterinary";

            public string SummaryInfo => "Delete a master farm record.";

        }

        public class DedupeFarmRecords : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.FarmController; }

            public Type APIReturnType { get => typeof(FarmDedupeResponseModel); }

            public string MethodParameters { get => "FarmDedupeRequestModel request, CancellationToken cancellationToken = default"; }

            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

            public Type RepositoryReturnType { get => typeof(USP_ADMIN_DEDUPLICATION_FARM_SETResult); }

            public string APIGroupName => "Veterinary";

            public string SummaryInfo => "Deduplicate Farm Records";
        }
    }

}
