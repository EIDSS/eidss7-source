using EIDSS.Api.CodeGeneration.Control;
using EIDSS.CodeGenerator;
using EIDSS.Domain.ResponseModels;
using EIDSS.Domain.ResponseModels.Administration;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
namespace EIDSS.Api.CodeGeneration.Administration
{
    public class GetStatisticalData : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.StatisticalDataController;

        public Type APIReturnType => typeof(List<StatisticalDataResponseModel>);

        public string MethodParameters { get => "StatisticalDataRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_ADMIN_STAT_GetListResult>);
        public string APIGroupName => "Administration - StatisticalData";

        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }

    public class SaveStatisticalData : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.StatisticalDataController;

        public Type APIReturnType => typeof(List<USP_ADMIN_STAT_SETResultResponseModel>);

        public string MethodParameters { get => "USP_ADMIN_STAT_SETResultRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_ADMIN_STAT_SETResult>);
        public string APIGroupName => "Administration - StatisticalData";

        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }

    public class GetStatisticalDetails : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.StatisticalDataController;

        public Type APIReturnType => typeof(List<USP_ADMIN_STAT_GetDetailResultResponseModel>);
        
        public string MethodParameters { get => "USP_ADMIN_STAT_GetDetailResultRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_ADMIN_STAT_GetDetailResult>);
        public string APIGroupName => "Administration - StatisticalData";

        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }

    public class DeleteStatisticalData : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.StatisticalDataController;

        public Type APIReturnType => typeof(List<USP_ADMIN_STAT_DELResultResponseModel>);

        public string MethodParameters { get => "USP_ADMIN_STAT_DELResultRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_ADMIN_STAT_DELResult>);
        public string APIGroupName => "Administration - StatisticalData";

        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Reference_Data_Changed;
    }
}
