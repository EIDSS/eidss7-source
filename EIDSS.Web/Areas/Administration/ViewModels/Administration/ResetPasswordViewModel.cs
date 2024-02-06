using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Localization.Helpers;
using Microsoft.AspNetCore.Mvc;

namespace EIDSS.Web.Areas.Administration.ViewModels.Administration
{
    public class ResetPasswordViewModel
    {
        [LocalizedRequired]
        public string  UserName { get; set; }

        [HiddenInput]
        public string UserId { get; set; }

        [DataType(DataType.Password)]
        [LocalizedRequired]
        public string CurrentPassword { get; set; }

        [DataType(DataType.Password)]
        [LocalizedRequired]
        public string NewPassword { get; set; }

        [DataType(DataType.Password)]
        [Compare("NewPassword", ErrorMessage = "The new password and new confirmation password do not match.")]
        [LocalizedRequired]

        public string ConfirmNewPassword { get; set; }

        public string InformationalMessage { get; set; }

        public string ErrorMessage { get; set; }

        public bool ShowUserName { get; set; }
        
        public bool FirstTimeLogin { get; set; }




    }
}
