using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Localization.Helpers;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Administration
{
    public class EmployeeLoginViewModel
    {
        [LocalizedRequired()]
        public string Login { get; set; }

        public string LastLogin { get; set; }

        public string strIdentity { get; set; }

        [LocalizedRequired()]
        public string Password { get; set; }

        [LocalizedRequired()]
        public string ConfirmPassword { get; set; }

        public bool MustChangePassword { get; set; } = false;

        public bool PasswordResetRequired { get; set; }
        public DateTime? DateDisabled { get; set; }

        public UserPermissions UserPermissions { get; set; }

    }
}
