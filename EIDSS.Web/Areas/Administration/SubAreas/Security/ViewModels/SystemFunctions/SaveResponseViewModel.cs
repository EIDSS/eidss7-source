using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SystemFunctions
{
    public class SaveResponseViewModel
    {

        public string ErrorMessage { get; set; }
        public string InformationalMessage { get; set; }
        public string WarningMessage { get; set; }
    }
}
