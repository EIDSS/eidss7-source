using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Repository.Connections;
using EIDSS.Repository.ReturnModels;
using Microsoft.EntityFrameworkCore;

namespace EIDSS.Repository.Contexts
{
    public partial class EIDSSContext : DbContext
    {

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                var connectionString = DbManager.connectionString;
                optionsBuilder.UseSqlServer(connectionString);
            }
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<USP_ADMIN_DATAAUDITLOG_GETDetailResult>().Property(p => p.strNewValue).HasColumnType("sql_variant");
            modelBuilder.Entity<USP_ADMIN_DATAAUDITLOG_GETDetailResult>().Property(p => p.strOldValue).HasColumnType("sql_variant");
        }
    }
}
