using EIDSS.Domain.ViewModels;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Human.ViewModels.Person
{
    public class DiseaseReportsViewModel
    {
        public long HumanMasterID { get; set; }
        public EIDSSGridConfiguration eidssGridConfiguration { get; set; }
        public UserPermissions PermissionsAccessToHumanDiseaseReportData { get; set; }
    }
}
