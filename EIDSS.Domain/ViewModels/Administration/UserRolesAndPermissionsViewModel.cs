using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class UserRolesAndPermissionsViewModel : BaseModel
    {
        public long idfEmployee { get; set; }
        public long PermissionId { get; set; }
        public string Role { get; set; }
        public string Permission { get; set; }
        public long PermissionLevelId { get; set; }
        public string PermissionLevel { get; set; }
    }
}
