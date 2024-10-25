using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.ViewModels
{
    public class SystemPreferencePageViewModel
    {
        public SystemPreferences systemPreferences { get; set; }
        public UserPermissions permissions;
        public string InformationalMessage { get; set; } = string.Empty;

    }
}
