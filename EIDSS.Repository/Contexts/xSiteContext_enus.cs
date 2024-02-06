using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using EIDSS.Repository.ReturnModels;
using EIDSS.Repository.Interfaces;

#nullable disable

namespace EIDSS.Repository.Contexts
{
    public partial class xSiteContext_enus : DbContext, IXSiteContext
    {
        public string LanguageCode { get; set; } = "en-US";

        public xSiteContext_enus()
        {
        }

        public xSiteContext_enus(DbContextOptions<xSiteContext_enus> options)
            : base(options)
        {
        }

        public virtual DbSet<TContainer> TContainers { get; set; }
        public virtual DbSet<TContainersLayout> TContainersLayouts { get; set; }
        public virtual DbSet<TContainersType> TContainersTypes { get; set; }
        public virtual DbSet<TDocument> TDocuments { get; set; }
        public virtual DbSet<TDocumentContainerMapping> TDocumentContainerMappings { get; set; }
        public virtual DbSet<TDocumentGroup> TDocumentGroups { get; set; }
        public virtual DbSet<TDocumentGroupMapping> TDocumentGroupMappings { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.HasAnnotation("Relational:Collation", "SQL_Latin1_General_CP1_CI_AS");

            modelBuilder.Entity<TContainer>(entity =>
            {
                entity.HasKey(e => e.ContainerId);

                entity.ToTable("tContainers");

                entity.Property(e => e.ContainerId).HasColumnName("ContainerID");

                entity.Property(e => e.ContainerName)
                    .HasMaxLength(100)
                    .IsUnicode(false);

                entity.Property(e => e.ContainerTypeId).HasColumnName("ContainerTypeID");

                entity.Property(e => e.DateCreated).HasColumnType("datetime");

                entity.Property(e => e.DateModified).HasColumnType("datetime");

                entity.Property(e => e.DocColumn1Header).HasMaxLength(50);

                entity.Property(e => e.DocColumn2Header).HasMaxLength(50);

                entity.Property(e => e.ExpirationDate).HasColumnType("datetime");

                entity.Property(e => e.LayoutId).HasColumnName("LayoutID");

                entity.Property(e => e.ParentId).HasColumnName("ParentID");

                entity.Property(e => e.PostHtml)
                    .HasColumnType("text")
                    .HasColumnName("PostHTML");

                entity.Property(e => e.PreHtml)
                    .IsRequired()
                    .HasColumnType("text")
                    .HasColumnName("PreHTML");

                entity.Property(e => e.PublishDate).HasColumnType("datetime");

                entity.Property(e => e.ReelId).HasColumnName("ReelID");

                entity.Property(e => e.SideHtml)
                    .HasColumnType("text")
                    .HasColumnName("SideHTML");

                entity.Property(e => e.SortOrder).HasColumnType("decimal(18, 2)");

                entity.Property(e => e.TargetContainerId).HasColumnName("TargetContainerID");

                entity.Property(e => e.Url)
                    .HasMaxLength(250)
                    .IsUnicode(false)
                    .HasColumnName("URL");
            });

            modelBuilder.Entity<TContainersLayout>(entity =>
            {
                entity.HasNoKey();

                entity.ToTable("tContainersLayout");

                entity.Property(e => e.ContainerLayoutId)
                    .ValueGeneratedOnAdd()
                    .HasColumnName("ContainerLayoutID");

                entity.Property(e => e.ContainerLayoutName)
                    .HasMaxLength(50)
                    .IsUnicode(false);
            });

            modelBuilder.Entity<TContainersType>(entity =>
            {
                entity.HasKey(e => e.ContainerTypeId)
                    .HasName("PK_tCcontainersType");

                entity.ToTable("tContainersType");

                entity.Property(e => e.ContainerTypeId).HasColumnName("ContainerTypeID");

                entity.Property(e => e.ContainerTypeName)
                    .HasMaxLength(50)
                    .IsUnicode(false);
            });

            modelBuilder.Entity<TDocument>(entity =>
            {
                entity.HasKey(e => e.DocumentId);

                entity.ToTable("tDocuments");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.CourseId).HasColumnName("CourseID");

                entity.Property(e => e.CreatedDate).HasColumnType("smalldatetime");

                entity.Property(e => e.DeliveryDate).HasColumnType("smalldatetime");

                entity.Property(e => e.DocumentName)
                    .IsRequired()
                    .HasMaxLength(250)
                    .IsUnicode(false);

                entity.Property(e => e.ExpirationDate).HasColumnType("smalldatetime");

                entity.Property(e => e.FileName)
                    .HasMaxLength(250)
                    .IsUnicode(false);

                entity.Property(e => e.Guid).HasColumnName("GUID");

                entity.Property(e => e.LastModifiedDate).HasColumnType("smalldatetime");

                entity.Property(e => e.PublishDate).HasColumnType("smalldatetime");

                entity.Property(e => e.ShowMePath)
                    .HasMaxLength(250)
                    .IsUnicode(false);

                entity.Property(e => e.SortOrder).HasColumnType("decimal(18, 0)");

                entity.Property(e => e.Swfsize)
                    .HasMaxLength(50)
                    .IsUnicode(false)
                    .HasColumnName("SWFSize");

                entity.Property(e => e.TextOfDocument).HasColumnType("text");

                entity.Property(e => e.Url)
                    .HasMaxLength(1000)
                    .IsUnicode(false)
                    .HasColumnName("URL");
            });

            modelBuilder.Entity<TDocumentContainerMapping>(entity =>
            {
                entity.HasKey(e => new { e.DocumentId, e.ContainerId })
                    .HasName("PK_tDocumentContainer");

                entity.ToTable("tDocumentContainerMapping");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.ContainerId).HasColumnName("ContainerID");

                entity.Property(e => e.SortOrder).HasColumnType("numeric(18, 2)");
            });

            modelBuilder.Entity<TDocumentGroup>(entity =>
            {
                entity.HasKey(e => e.DocumentGroupId);

                entity.ToTable("tDocumentGroups");

                entity.Property(e => e.DocumentGroupId).HasColumnName("DocumentGroupID");

                entity.Property(e => e.DocumentGroupName)
                    .IsRequired()
                    .HasMaxLength(500)
                    .IsUnicode(false);
            });

            modelBuilder.Entity<TDocumentGroupMapping>(entity =>
            {
                entity.HasKey(e => new { e.DocumentId, e.DocumentGroupId })
                    .HasName("PK_tDocumentGroupMapping_1");

                entity.ToTable("tDocumentGroupMapping");

                entity.Property(e => e.DocumentId).HasColumnName("DocumentID");

                entity.Property(e => e.DocumentGroupId).HasColumnName("DocumentGroupID");

                entity.Property(e => e.SortOrder).HasColumnType("decimal(18, 2)");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}