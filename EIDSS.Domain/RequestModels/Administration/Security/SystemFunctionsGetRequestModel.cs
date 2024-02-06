using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class SystemFunctionsGetRequestModel: BaseGetRequestModel
    {
        public string FunctionName { get; set; }
    }
}
