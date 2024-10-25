using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using System;
using EIDSS.CodeGenerator;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels.Human;

namespace EIDSS.Api.CodeGeneration.Human
{
    public class GetPersonListForOfficeAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.PersonController; }
        public Type APIReturnType { get => typeof(List<PersonForOfficeViewModel>); }
        public string MethodParameters { get => "GetPersonForOfficeRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_GBL_LKUP_PERSON_GETListResult>); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class DeletePerson : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.PersonController; }

        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "long HumanMasterID, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.DELETE; }

        public Type RepositoryReturnType { get => typeof(USP_HUM_HUMAN_MASTER_DELResult); }

        public string APIGroupName => "Human";

        public string SummaryInfo => "Delete Person";

    }

    public class DedupePersonFarm : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.PersonController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "PersonDedupeRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_DEDUPLICATION_PERSONID_FARM_SETResult); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class DedupePersonHumanDisease : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.PersonController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "PersonDedupeRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_ADMIN_DEDUPLICATION_PERSONID_HUMAN_DISEASE_SETResult); }
        public string APIGroupName => "Human";
        public string SummaryInfo => "";
    }

    public class DedupePersonRecords : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.PersonController; }

        public Type APIReturnType { get => typeof(PersonSaveResponseModel); }

        public string MethodParameters { get => "PersonRecordsDedupeRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_ADMIN_DEDUPLICATION_PERSON_SETResult); }

        public string APIGroupName => "Human";

        public string SummaryInfo => "Deduplicate Person Records";
    }

    public class AuditPINSystemAccess : ICodeGenDirective
    {
        public string APIClassName {get => TargetedClassNames.PersonController;}
        public Type APIReturnType { get => typeof(APIPostResponseModel); }

        public string MethodParameters { get => "PINAuditRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_PIN_Audit_SetResult); }

        public string APIGroupName => "Human";

        public string SummaryInfo => "Audits requests to the PIN System.";
    }
}