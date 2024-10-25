using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ViewModels.Configuration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;

namespace EIDSS.Api.CodeGeneration.Configuration
{
    public class DeletePersonalIdentificationTypeMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.PersonalIdentificationTypeMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APIPostResponseModel);

        public string MethodParameters => "PersonalIdentificationTypeMatrixSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_PERSONALIDTYPEMATRIX_DELResult);

        public string SummaryInfo => "Delete a personal ID type matrix";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class GetPersonalIdentificationTypeMatrixList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.PersonalIdentificationTypeMatrixController;

        public string APIGroupName => "Configurations - Matrices";
        public Type APIReturnType => typeof(List<PersonalIdentificationTypeMatrixViewModel>);

        public string MethodParameters => "PersonalIdentificationTypeMatrixGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_CONF_PERSONALIDTYPEMATRIX_GETLISTResult>);

        public string SummaryInfo => "Get a personal ID type matrix";
    }

    public class SavePersonalIdentificationTypeMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.PersonalIdentificationTypeMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APISaveResponseModel);

        public string MethodParameters => "PersonalIdentificationTypeMatrixSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_PERSONALIDTYPEMATRIX_SETResult);

        public string SummaryInfo => "Save a personal ID type matrix";

        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }
}
