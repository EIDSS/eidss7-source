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
    public class GetAggregateSettingsList : ICodeGenDirective
    {
        public string APIClassName => TargetedClassNames.AggregateSettingsController;

        public Type APIReturnType => typeof(List<AggregateSettingsViewModel>);

        public string MethodParameters => "AggregateSettingsGetRequestModel request, CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET_USING_POST_VERB;

        public Type RepositoryReturnType => typeof(List<USP_CONF_AggregateSetting_GetList_WithNameResult>);

        public string APIGroupName => "Configurations - Aggregate Settings";

        public string SummaryInfo => "";
    }

    public class SaveAggregateSettings : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.AggregateSettingsController; }

        public string APIGroupName => "Configurations - Aggregate Settings";

        public Type APIReturnType { get => typeof(APISaveResponseModel); }

        public string MethodParameters { get => "AggregateSettingsSaveRequestModel request, CancellationToken cancellationToken = default"; }

        public APIMethodVerbEnumeration MethodVerb { get => APIMethodVerbEnumeration.SAVE; }

        public Type RepositoryReturnType { get => typeof(USP_CONF_AggregateSetting_SETResult); }
        public string SummaryInfo => "";
        public SystemEventEnum FiresEvent => SystemEventEnum.Matrix_Changed;
    }


}
