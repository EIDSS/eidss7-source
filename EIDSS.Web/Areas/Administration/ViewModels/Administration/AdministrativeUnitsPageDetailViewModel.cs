using EIDSS.Domain.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.ViewModels.Administration
{
    public class AdministrativeUnitsPageDetailViewModel 
    {
        public string ErrorMessage { get; set; }
        public string InformationalMessage { get; set; }
        public string WarningMessage { get; set; }
        public AdministrativeUnitsDetailsSectionViewModel AdministrativeUnitsDetails { get; set; }
        public UserPermissions Permissions { get; set; }
        public long id { get; set; }
    }
}
