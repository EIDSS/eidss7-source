using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Configuration;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Configuration;
namespace EIDSS.Api.CodeGeneration.Configuration
{
    /// <summary>
    /// </summary>
    public class GetSampleTypeDerivativeTypeMatrixListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ConfigurationController;}

        public Type APIReturnType { get => typeof(List<SampleTypeDerivativeMatrixViewModel>);}

        public string MethodParameters { get => "string languageId, CancellationToken cancellationToken = default";}

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }

        public Type RepositoryReturnType { get => typeof(List<USP_CONF_SAMPLETYPEDERIVATIVEMATRIX_GETLISTResult>); }
        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "Gets a list of Sample Types";
    }

    public class GetVeterinarySanitaryActionMatrix : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ConfigurationController;}
        public Type APIReturnType { get => typeof(List<VeterinarySanitaryActionMatrixViewModel>); }
        public string MethodParameters { get => "long idfVersion, CancellationToken cancellationToken";}

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }

        public Type RepositoryReturnType { get => typeof(List<USP_CONF_ADMIN_SanitaryMatrixReportGet_GETResult>); }
        public string APIGroupName => "Configurations - Matrices";

        public string SummaryInfo => "";
    }

    public class GetInvestigationTypeMatrixListAsync : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ConfigurationController; }
        public Type APIReturnType { get => typeof(List<InvestigationTypeViewModel>); }
        public string MethodParameters { get => "long idfsBaseReference, long? intHACode, string strLanguageID, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET; }
        public Type RepositoryReturnType { get => typeof(List<USP_CONF_GetInvestigationTypes_GETResult>); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "";
    }

    public class DeleteVeterinaryDiagnosticInvestigationMatrixRecord : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ConfigurationController; }
        public Type APIReturnType { get => typeof(APIPostResponseModel); }
        public string MethodParameters { get => "MatrixViewModel model, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }
        public Type RepositoryReturnType { get => typeof(USP_CONF_VetDiagnosisMatrixReportRecord_DELETEResult); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class GetDiseaseSampleTypeByDiseasePaged : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ConfigurationController; }
        public Type APIReturnType { get => typeof(List<DiseaseSampleTypeByDiseaseResponseModel>); }
        public string MethodParameters { get => "DiseaseSampleTypeByDiseaseRequestModel request, CancellationToken cancellationToken = default"; }
        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }
        public Type RepositoryReturnType { get => typeof(List<USP_CONF_DISEASESAMPLETYPEMATRIX_BY_DISEASE_GETLISTResult>); }
        public string APIGroupName => "Configurations - Matrices";
        public string SummaryInfo => "";
    }
 
    public class SetUserGridConfiguration : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.ConfigurationController; }

        public Type APIReturnType { get => typeof(List<USP_CONF_USER_GRIDS_SETResponseModel>); }

        public string MethodParameters { get => "USP_CONF_USER_GRIDS_SETRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.GET_USING_POST_VERB; }

        public Type RepositoryReturnType { get => typeof(List<USP_CONF_USER_GRIDS_SETResult>); }
        public string APIGroupName => "Configurations - User Grids";

        public string SummaryInfo => "Sets a User Grid";
    }
}
