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

    public partial class EidssArchiveContext : DbContext
    {



        public EidssArchiveContext()
        {
        }

        public EidssArchiveContext(DbContextOptions<EidssArchiveContext> options) : base(options)
        {
        }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.HasAnnotation("Relational:Collation", "Cyrillic_General_CI_AS");

            modelBuilder.Entity<USP_GBL_MENU_ByUser_GETListResult>().HasNoKey().ToView(null);


            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}