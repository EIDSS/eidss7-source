using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels
{
    public sealed class LockUserAccountParams
    {
        public string UserName { get; set; }
        public DateTime EndDate { get; set; } = DateTime.Now.AddDays(7);
    }

    public sealed class UnLockUserAccountParams
    {
        public string UserName { get; set; }
    }

    public sealed class DisableUserAccountParams
    {
        public string UserName { get; set; }
        public string disableReason { get; set; }
    }

    public sealed class EnableUserAccountParams
    {
        public string UserName { get; set; }
        public string disableReason { get; set; }
    }

    public sealed class UpdateUserNameParams
    {
        public string UserID { get; set; }

        public string NewUserName { get; set; }
    }

    public sealed class ResetPasswordParams
    {
        public string userId { get; set; }
        public string password { get; set; }
        public bool passwordResetRequired { get; set; }
        public string updatingUser { get; set; }
    }

    public sealed class ResetPasswordByUserParams
    {
        public string UserName { get; set; }
        public string CurrentPassword { get; set; }
        public string NewPassword { get; set; }
        public string ConfirmNewPassword { get; set; }
        public bool PasswordResetRequired { get; set; } = false;
        public bool ChkPasswordHistory { get; set; } = true;
        public string UpdatingUser { get; set; }
    }

    public sealed class PasswordResetRequiredParams
    {
        public string UserName { get; set; }
        public bool PasswordResetRequired { get; set; }
    }
}

