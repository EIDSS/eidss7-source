using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using EIDSS.Repository.ReturnModels;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Threading;

namespace EIDSS.Repository.Contexts
{
    public partial class EIDSSAuditingContext : DbContext
    {
        public EIDSSAuditingContext()
        {
        }

        public EIDSSAuditingContext(DbContextOptions<EIDSSAuditingContext> options)
            : base(options)
        {
        }

        public virtual DbSet<TauDataAuditDetailCreate> TauDataAuditDetailCreate { get; set; }
        public virtual DbSet<TauDataAuditDetailDelete> TauDataAuditDetailDelete { get; set; }
        public virtual DbSet<TauDataAuditDetailRestore> TauDataAuditDetailRestore { get; set; }
        public virtual DbSet<TauDataAuditDetailUpdate> TauDataAuditDetailUpdate { get; set; }
        public virtual DbSet<TauDataAuditEvent> TauDataAuditEvent { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<TauDataAuditDetailCreate>(entity =>
            {
                entity.HasKey(e => e.IdfDataAuditDetailCreate)
                    .HasName("XPKtauDataAuditDetailCreate")
                    .IsClustered(false);

                entity.ToTable("tauDataAuditDetailCreate");

                entity.HasComment("Object Creation Audit ");

                entity.HasIndex(e => e.IdfObject);

                entity.HasIndex(e => new { e.IdfObject, e.IdfDataAuditEvent, e.IdfObjectTable })
                    .HasName("IX_tauDataAuditDetailCreate_idfDataAuditEvent_idfObjectTable");

                entity.Property(e => e.IdfDataAuditDetailCreate)
                    .HasColumnName("idfDataAuditDetailCreate")
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.AuditCreateDtm)
                    .HasColumnName("AuditCreateDTM")
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.AuditCreateUser).HasMaxLength(200);

                entity.Property(e => e.AuditUpdateDtm)
                    .HasColumnName("AuditUpdateDTM")
                    .HasColumnType("datetime");

                entity.Property(e => e.AuditUpdateUser).HasMaxLength(200);

                entity.Property(e => e.IdfDataAuditEvent)
                    .HasColumnName("idfDataAuditEvent")
                    .HasComment("Audit event identifier");

                entity.Property(e => e.IdfObject)
                    .HasColumnName("idfObject")
                    .HasComment("Object identifier");

                entity.Property(e => e.IdfObjectDetail)
                    .HasColumnName("idfObjectDetail")
                    .HasComment("Corresponding Created object identifier");

                entity.Property(e => e.IdfObjectTable)
                    .HasColumnName("idfObjectTable")
                    .HasComment("Table identifier");

                entity.Property(e => e.SourceSystemNameId).HasColumnName("SourceSystemNameID");

                entity.Property(e => e.StrMaintenanceFlag)
                    .HasColumnName("strMaintenanceFlag")
                    .HasMaxLength(20);

                entity.HasOne(d => d.IdfDataAuditEventNavigation)
                    .WithMany(p => p.TauDataAuditDetailCreate)
                    .HasForeignKey(d => d.IdfDataAuditEvent)
                    .HasConstraintName("FK_tauDataAuditDetailCreate_tauDataAuditEvent__idfDataAuditEvent_R_1024");
            });

            modelBuilder.Entity<TauDataAuditDetailDelete>(entity =>
            {
                entity.HasKey(e => e.IdfDataAuditDetailDelete)
                    .HasName("XPKtauDataAuditDetailDelete")
                    .IsClustered(false);

                entity.ToTable("tauDataAuditDetailDelete");

                entity.HasComment("Object Deletion Audit ");

                entity.HasIndex(e => e.IdfObject);

                entity.Property(e => e.IdfDataAuditDetailDelete)
                    .HasColumnName("idfDataAuditDetailDelete")
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.AuditCreateDtm)
                    .HasColumnName("AuditCreateDTM")
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.AuditCreateUser).HasMaxLength(200);

                entity.Property(e => e.AuditUpdateDtm)
                    .HasColumnName("AuditUpdateDTM")
                    .HasColumnType("datetime");

                entity.Property(e => e.AuditUpdateUser).HasMaxLength(200);

                entity.Property(e => e.IdfDataAuditEvent)
                    .HasColumnName("idfDataAuditEvent")
                    .HasComment("Audit event identifier");

                entity.Property(e => e.IdfObject)
                    .HasColumnName("idfObject")
                    .HasComment("Object identifier");

                entity.Property(e => e.IdfObjectDetail)
                    .HasColumnName("idfObjectDetail")
                    .HasComment("Corresponding Deleted object identifier");

                entity.Property(e => e.IdfObjectTable)
                    .HasColumnName("idfObjectTable")
                    .HasComment("Table identifier");

                entity.Property(e => e.SourceSystemNameId).HasColumnName("SourceSystemNameID");

                entity.Property(e => e.StrMaintenanceFlag)
                    .HasColumnName("strMaintenanceFlag")
                    .HasMaxLength(20);

                entity.HasOne(d => d.IdfDataAuditEventNavigation)
                    .WithMany(p => p.TauDataAuditDetailDelete)
                    .HasForeignKey(d => d.IdfDataAuditEvent)
                    .HasConstraintName("FK_tauDataAuditDetailDelete_tauDataAuditEvent__idfDataAuditEvent_R_1558");
            });

            modelBuilder.Entity<TauDataAuditDetailRestore>(entity =>
            {
                entity.HasKey(e => e.IdfDataAuditDetailRestore)
                    .HasName("XPKidfDataAuditDetailRestore")
                    .IsClustered(false);

                entity.ToTable("tauDataAuditDetailRestore");

                entity.HasComment("Deleted object resoring audit ");

                entity.HasIndex(e => e.IdfObject);

                entity.Property(e => e.IdfDataAuditDetailRestore)
                    .HasColumnName("idfDataAuditDetailRestore")
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.AuditCreateDtm)
                    .HasColumnName("AuditCreateDTM")
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.AuditCreateUser).HasMaxLength(200);

                entity.Property(e => e.AuditUpdateDtm)
                    .HasColumnName("AuditUpdateDTM")
                    .HasColumnType("datetime");

                entity.Property(e => e.AuditUpdateUser).HasMaxLength(200);

                entity.Property(e => e.IdfDataAuditEvent)
                    .HasColumnName("idfDataAuditEvent")
                    .HasComment("Audit event identifier");

                entity.Property(e => e.IdfObject)
                    .HasColumnName("idfObject")
                    .HasComment("Object identifier");

                entity.Property(e => e.IdfObjectDetail)
                    .HasColumnName("idfObjectDetail")
                    .HasComment("Corresponding Deleted object identifier");

                entity.Property(e => e.IdfObjectTable)
                    .HasColumnName("idfObjectTable")
                    .HasComment("Table identifier");

                entity.Property(e => e.SourceSystemNameId).HasColumnName("SourceSystemNameID");

                entity.Property(e => e.StrMaintenanceFlag)
                    .HasColumnName("strMaintenanceFlag")
                    .HasMaxLength(20);

                entity.HasOne(d => d.IdfDataAuditEventNavigation)
                    .WithMany(p => p.TauDataAuditDetailRestore)
                    .HasForeignKey(d => d.IdfDataAuditEvent)
                    .HasConstraintName("FK_tauDataAuditDetailRestore_tauDataAuditEvent__idfDataAuditEvent_R_1558");
            });

            modelBuilder.Entity<TauDataAuditDetailUpdate>(entity =>
            {
                entity.HasKey(e => e.IdfDataAuditDetailUpdate)
                    .HasName("XPKtauDataAuditDetailUpdate")
                    .IsClustered(false);

                entity.ToTable("tauDataAuditDetailUpdate");

                entity.HasComment("Object Change Audit ");

                entity.HasIndex(e => e.IdfObject);

                entity.HasIndex(e => new { e.IdfDataAuditEvent, e.IdfObjectTable, e.IdfColumn });

                entity.Property(e => e.IdfDataAuditDetailUpdate)
                    .HasColumnName("idfDataAuditDetailUpdate")
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.AuditCreateDtm)
                    .HasColumnName("AuditCreateDTM")
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.AuditCreateUser).HasMaxLength(200);

                entity.Property(e => e.AuditUpdateDtm)
                    .HasColumnName("AuditUpdateDTM")
                    .HasColumnType("datetime");

                entity.Property(e => e.AuditUpdateUser).HasMaxLength(200);

                entity.Property(e => e.IdfColumn)
                    .HasColumnName("idfColumn")
                    .HasComment("Changed column identifier");

                entity.Property(e => e.IdfDataAuditEvent)
                    .HasColumnName("idfDataAuditEvent")
                    .HasComment("Audit event identifier");

                entity.Property(e => e.IdfObject)
                    .HasColumnName("idfObject")
                    .HasComment("Object identifier");

                entity.Property(e => e.IdfObjectDetail)
                    .HasColumnName("idfObjectDetail")
                    .HasComment("Corresponding Changed object identifier");

                entity.Property(e => e.IdfObjectTable)
                    .HasColumnName("idfObjectTable")
                    .HasComment("Table identifier");

                entity.Property(e => e.SourceSystemNameId).HasColumnName("SourceSystemNameID");

                entity.Property(e => e.StrMaintenanceFlag)
                    .HasColumnName("strMaintenanceFlag")
                    .HasMaxLength(20);

                entity.Property(e => e.StrNewValue)
                    .HasColumnName("strNewValue")
                    .HasColumnType("sql_variant")
                    .HasComment("New value");

                entity.Property(e => e.StrOldValue)
                    .HasColumnName("strOldValue")
                    .HasColumnType("sql_variant")
                    .HasComment("Old value");

                entity.HasOne(d => d.IdfDataAuditEventNavigation)
                    .WithMany(p => p.TauDataAuditDetailUpdate)
                    .HasForeignKey(d => d.IdfDataAuditEvent)
                    .HasConstraintName("FK_tauDataAuditDetailUpdate_tauDataAuditEvent__idfDataAuditEvent_R_1557");
            });

            modelBuilder.Entity<TauDataAuditEvent>(entity =>
            {
                entity.HasKey(e => e.IdfDataAuditEvent)
                    .HasName("XPKtauDataAuditEvent");

                entity.ToTable("tauDataAuditEvent");

                entity.HasComment("Audit Events");

                entity.Property(e => e.IdfDataAuditEvent)
                    .HasColumnName("idfDataAuditEvent")
                    .HasComment("Audit event identifier")
                    .ValueGeneratedNever();

                entity.Property(e => e.AuditCreateDtm)
                    .HasColumnName("AuditCreateDTM")
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.AuditCreateUser).HasMaxLength(200);

                entity.Property(e => e.AuditUpdateDtm)
                    .HasColumnName("AuditUpdateDTM")
                    .HasColumnType("datetime");

                entity.Property(e => e.AuditUpdateUser).HasMaxLength(200);

                entity.Property(e => e.DatEnteringDate)
                    .HasColumnName("datEnteringDate")
                    .HasColumnType("datetime")
                    .HasComment("Date/time of event creation");

                entity.Property(e => e.DatModificationForArchiveDate)
                    .HasColumnName("datModificationForArchiveDate")
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.IdfMainObject)
                    .HasColumnName("idfMainObject")
                    .HasComment("Main audit object identifier");

                entity.Property(e => e.IdfMainObjectTable)
                    .HasColumnName("idfMainObjectTable")
                    .HasComment("Main audit object table identifier");

                entity.Property(e => e.IdfUserId)
                    .HasColumnName("idfUserID")
                    .HasComment("User caused audit event identifier");

                entity.Property(e => e.IdfsDataAuditEventType)
                    .HasColumnName("idfsDataAuditEventType")
                    .HasComment("Audit event type");

                entity.Property(e => e.IdfsDataAuditObjectType)
                    .HasColumnName("idfsDataAuditObjectType")
                    .HasComment("Audit object type");

                entity.Property(e => e.IdfsSite)
                    .HasColumnName("idfsSite")
                    .HasDefaultValueSql("([dbo].[fnSiteID]())")
                    .HasComment("Site event created on identifier");

                entity.Property(e => e.Rowguid)
                    .HasColumnName("rowguid")
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.SourceSystemNameId).HasColumnName("SourceSystemNameID");

                entity.Property(e => e.StrHostname)
                    .HasColumnName("strHostname")
                    .HasMaxLength(200)
                    .HasComment("Host name caused event");

                entity.Property(e => e.StrMaintenanceFlag)
                    .HasColumnName("strMaintenanceFlag")
                    .HasMaxLength(20);
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}
