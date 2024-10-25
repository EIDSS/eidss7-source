using EIDSS.ClientLibrary.Responses;
using EIDSS.Domain.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.ViewModels.Administration
{
    public class UserPreferencePageViewModel
    {
        public UserPreferences UserPreferences { get; set; }
        public UserPermissions UserPermissions;
        public string InformationalMessage { get; set; } = string.Empty;
    }
}
