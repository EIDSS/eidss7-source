using EIDSS.Api.CodeGeneration.Control;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.CodeGeneration.Administration
{
    public class DataArchivingGet : ICodeGenDirective
    {
        public string APIClassName { get => TargetedClassNames.DataArchivingController; }

        public Type APIReturnType => typeof(List<DataArchivingViewModel>);

        public string MethodParameters => "CancellationToken cancellationToken = default";

        public APIMethodVerbEnumeration MethodVerb => APIMethodVerbEnumeration.GET;

        public Type RepositoryReturnType => typeof(List<USP_ADMIN_CONF_DataArchiveSettings_GetResult>);
      
        public string APIGroupName => "Administration - Base Reference Editors";

        public string SummaryInfo => "Get Data Archving ";
    }
}
