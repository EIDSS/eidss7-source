using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class UserPermissionByRoleViewModel
    {
        public string Permission { get; set; }
        public bool? Read { get; set; }
        public bool? Write { get; set; }
        public bool? Create { get; set; }
        public bool? Execute { get; set; }
        public bool? Delete { get; set; }
        public bool? AccessToPersonalData { get; set; }
        public bool? AccessToGenderAndAgeData { get; set; }
    }
}
