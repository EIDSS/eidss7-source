using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class DeleteDiseaseHumanGenderMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseaseHumanGenderMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APIPostResponseModel);

        public string MethodParameters => "DiseaseHumanGenderMatrixSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_DISEASEHUMANGENDERMATRIX_DELResult);

        public string SummaryInfo => "Deletes a Disease Human Gender Matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class GetDiseaseHumanGenderMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseaseHumanGenderMatrixController;

        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType => typeof(List<DiseaseHumanGenderMatrixViewModel>);

        public string MethodParameters => "DiseaseHumanGenderMatrixGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_CONF_DISEASEHUMANGENDERMATRIX_GETLISTResult>);

        public string SummaryInfo => "Gets a list of disease human gender matrix";
    }

    public class SaveDiseaseHumanGenderMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseaseHumanGenderMatrixController;

        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType => typeof(APISaveResponseModel);

        public string MethodParameters => "DiseaseHumanGenderMatrixSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_DISEASEHUMANGENDERMATRIX_SETResult);

        public string SummaryInfo => "Save a disease human gender matrix";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class GetGenderForDiseaseOrDiagnosisGroupMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.DiseaseHumanGenderMatrixController;

        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType => typeof(List<GenderForDiseaseOrDiagnosisGroupViewModel>);

        public string MethodParameters => "GenderForDiseaseOrDiagnosisGroupDiseaseMatrixGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_CONF_LKUP_DISEASE_GENDER_MATRIXResult>);

        public string SummaryInfo => "Gets a Gender for disease or diagnosis group";
    }
}
