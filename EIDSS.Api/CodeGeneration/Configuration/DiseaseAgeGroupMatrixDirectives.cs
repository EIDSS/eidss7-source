using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class GetDiseaseAgeGroupMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseaseAgeGroupMatrixController;
        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType => typeof(List<DiseaseAgeGroupMatrixViewModel>);
        public string MethodParameters => "DiseaseAgeGroupGetRequestModel request, CancellationToken cancellationToken = default";
        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;
        public Type RepositoryReturnType => typeof(List<USP_CONF_DISEASEAGEGROUPMATRIX_GETLISTResult>);
        public string SummaryInfo => "Gets a list of disease age group matrix";
    }

    public class SaveDiseaseAgeGroupMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DiseaseAgeGroupMatrixController; }
        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType { get => typeof(APISaveResponseModel); }
        public string MethodParameters { get => "DiseaseAgeGroupSaveRequestModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_DISEASEAGEGROUPMATRIX_SETResult); }        
        public string SummaryInfo => "Save Disease Age Group Matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class DeleteDiseaseAgeGroupMatrixRecord : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DiseaseAgeGroupMatrixController; }
        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "DiseaseAgeGroupSaveRequestModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_DISEASEAGEGROUPMATRIX_DELResult); }
        public string SummaryInfo => "Delete Disease Age Group Matrix Record";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
}
