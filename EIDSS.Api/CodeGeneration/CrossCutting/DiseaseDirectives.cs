using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Repository.ReturnModels;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.FlexForm;
using System;
using EIDSS.CodeGenerator;
using System.Collections.Generic;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ResponseModels.CrossCutting;
using EIDSS.Domain.ResponseModels.Configuration;

namespace EIDSS.Api.CodeGeneration.CrossCutting
{
    public class DiseaseDirectives
    {
        public class GetDiseasesByIdsPaged : ICodeGenDirective
        {
            public string APIClassName { get => TargetedClassNames.CrossCuttingController; }
            public Type APIReturnType { get => typeof(List<DiseaseGetListPagedResponseModel>); }
            public string MethodParameters { get => "DiseaseGetListPagedRequestModel request, CancellationToken cancellationToken = default"; }
            public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
            public Type RepositoryReturnType { get => typeof(List<USP_GBL_LKUP_DISEASE_GETList_PagedResult>); }
            public string APIGroupName => "Human";
            public string SummaryInfo => "";
        }



    
    }
}
