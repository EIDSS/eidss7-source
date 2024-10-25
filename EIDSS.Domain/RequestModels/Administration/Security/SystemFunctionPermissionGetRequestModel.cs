using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class SystemFunctionPermissionGetRequestModel
    {
        public string LanguageId { get; set; }
        public long UserId { get; set; }
        public long SystemFunctionId { get; set; }
    }
}
