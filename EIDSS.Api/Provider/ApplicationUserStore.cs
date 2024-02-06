using EIDSS.Api.Providers;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Api.Provider
{

 

    public class ApplicationUserStore<TUser> : Microsoft.AspNetCore.Identity.EntityFrameworkCore.UserStore<TUser> where TUser : ApplicationUser, new()
    {
        public ApplicationUserStore(ApplicationDbContext context, IdentityErrorDescriber describer = null) : base(context, describer)
        {
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="user"></param>
        /// <param name="updatingUser"></param>
        /// <returns></returns>
        public async Task CreateAsync(TUser user, string updatingUser)
        {
            await base.CreateAsync(user);
            await AddToPasswordHistoryAsync(user, user.PasswordHash, updatingUser);
        }


        /// <summary>
        /// Adds an entry into the password history table
        /// </summary>
        /// <param name="user"></param>
        /// <param name="userpassword"></param>
        /// <param name="updatinguser"></param>
        /// <returns></returns>
        public Task AddToPasswordHistoryAsync(TUser user, string userpassword, string updatinguser)
        {
            try
            {
                user.PasswordHistory.Add(new ASPNetUserPreviousPasswords()
                { 
                    Id = user.Id, 
                    OldPasswordHash = user.PasswordHash, 
                    AuditCreateUser = updatinguser, 
                    AuditUpdateUser = updatinguser 
                });
            }
            catch (Exception ex)
            {
                throw;
            }

          
            return UpdateAsync(user);

        }

       
    }
}
