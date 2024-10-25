using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class PermissionsbyRoleGetRequestModel
    {
        public string RoleId { get; set; }
        public string LangId { get; set; }
        public string User { get; set; }
    }
}
