using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SecurityPolicy
{
    public class SecurityPolicyDetailsViewModel
    {
        public string InformationalMessage { get; set; }
        public SecurityConfigurationViewModel  SecurityConfigurationViewModel { get; set; }
        public bool ReadAccessToSecurityPolicy { get; set; }
        public bool WriteAccessToSecurityPolicy { get; set; }

    }
}
