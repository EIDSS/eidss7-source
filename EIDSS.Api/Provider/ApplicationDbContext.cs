using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Api.Providers;
using EIDSS.Api.Provider;

namespace EIDSS.Api.Providers
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {

        }

        public virtual TstUserTable TstUserTaklble { get; set; }
        public virtual IList<ASPNetUserPreviousPasswords> PasswordHistory { get; set; }


        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            builder.Entity<ASPNetUserPreviousPasswords>()
                .HasOne(a => a.ApplicationUser)
                .WithMany(x => x.PasswordHistory);

            builder.Entity<TstUserTable>()
              .HasOne(a => a.ApplicationUser);





        }
    }

}  

