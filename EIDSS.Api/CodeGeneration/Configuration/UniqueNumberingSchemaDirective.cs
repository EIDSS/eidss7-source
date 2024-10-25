using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class GetUniqueNumberingSchemaList : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UniqueNumberingSchemaController; }
        public Type APIReturnType { get => typeof(List<UniqueNumberingSchemaListViewModel>); }
        public string MethodParameters { get => "UniqueNumberingSchemaGetRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_CONF_UNIQUENUMBERINGSCHEMA_GETLISTResult>); }
        public string APIGroupName => "Configurations - Unique Numbering Schema";
        public string SummaryInfo => "Get Unique Numbering Schema List";
    }

    public class SaveUniqueNumberingSchema : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.UniqueNumberingSchemaController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); } 
        public string MethodParameters { get => "UniqueNumberingSchemaSaveRequestModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_UNIQUENUMBERINGSCHEMA_SETResult); }
        public string APIGroupName => "Configurations - Unique Numbering Schema";
        public string SummaryInfo => "Save Unique Numering Schema";        
    }
}
