using EIDSS.Domain.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
   

    public class ActorsViewModel
    {
        public ActorTypeEnum ActorTypeId { get; set; }
        public string ActorType { get; set; }
        public string ActorTypeName { get; set; }
        public List<ActorPermissionsViewModel> Permissions { get; set; }
    }

    public class ActorPermissionsViewModel
    {
        public PermissionLevelEnum PermissionId  { get; set; }
        public string PermissionName { get; set; }
        public bool Status { get; set; }
    }
}
