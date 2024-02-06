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
    public class DeleteCustomReportRowsMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.CustomReportMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(APIPostResponseModel);

        public string MethodParameters => "CustomReportRowsMatrixSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_CUSTOMREPORT_DELResult);

        public string SummaryInfo => "Delete custom report rows";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }

    public class GetCustomReportRowsMatrixListAsync : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.CustomReportMatrixController;

        public string APIGroupName => "Configurations - Matrices";

        public Type APIReturnType => typeof(List<ConfigurationMatrixViewModel>);

        public string MethodParameters => "CustomReportRowsMatrixGetRequestModel request, CancellationToken cancellationToken";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_CONF_CUSTOMREPORT_GETLISTResult>);

        public string SummaryInfo => "Get custom report rows";
    }

    public class SaveCustomReportRowsMatrix : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.CustomReportMatrixController;

        public string APIGroupName => "Configurations - Matrices" ;

        public Type APIReturnType => typeof(APISaveResponseModel);

        public string MethodParameters => "CustomReportRowsMatrixSaveRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.SAVE;

        public Type RepositoryReturnType => typeof(USP_CONF_CUSTOMREPORT_SETResult);

        public string SummaryInfo => "Save custom report rows";
    }
}
