using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Administration.Security.ViewModels
{
    public class UserGroupSearchViewModel
    {
        public UserGroupGetRequestModel SearchCriteria { get; set; }
        public string InformationalMessage { get; set; }
        public EIDSSGridConfiguration GridConfiguration { get; set; }
        public bool ShowSearchResults { get; set; }
        public UserPermissions UserGroupPermissions { get; set; }
        public bool RecordSelectionIndicator { get; set; }
    }
}
