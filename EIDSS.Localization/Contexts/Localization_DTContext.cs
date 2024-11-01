﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

#nullable disable

namespace EIDSS.Localization
{
    public partial class Localization_DTContext : DbContext
    {
        public Localization_DTContext()
        {
        }

        public Localization_DTContext(DbContextOptions<Localization_DTContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Language> Language { get; set; }
        public virtual DbSet<TrtResource> TrtResource { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.HasAnnotation("Relational:Collation", "Cyrillic_General_CI_AS");

            modelBuilder.Entity<Language>(entity =>
            {
                entity.Property(e => e.LanguageId).HasColumnName("LanguageID");

                entity.Property(e => e.Country)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.CultureName)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.DisplayName)
                    .IsRequired()
                    .HasMaxLength(255);

                entity.Property(e => e.Region)
                    .IsRequired()
                    .HasMaxLength(255);
            });

            modelBuilder.Entity<TrtResource>(entity =>
            {
                entity.HasKey(e => e.IdfsResource)
                    .HasName("PK_Resource");

                entity.ToTable("trtResource");

                entity.Property(e => e.IdfsResource).HasColumnName("idfsResource");

                entity.Property(e => e.AuditCreateDtm)
                    .HasColumnType("datetime")
                    .HasColumnName("AuditCreateDTM")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.AuditCreateUser)
                    .IsRequired()
                    .HasMaxLength(100)
                    .IsUnicode(false)
                    .HasDefaultValueSql("(user_name())");

                entity.Property(e => e.AuditUpdateDtm)
                    .HasColumnType("datetime")
                    .HasColumnName("AuditUpdateDTM")
                    .HasDefaultValueSql("(getdate())");

                entity.Property(e => e.AuditUpdateUser)
                    .IsRequired()
                    .HasMaxLength(100)
                    .IsUnicode(false)
                    .HasDefaultValueSql("(user_name())");

                entity.Property(e => e.IdfsLanguage).HasColumnName("idfsLanguage");

                entity.Property(e => e.IdfsResourceSet).HasColumnName("idfsResourceSet");

                entity.Property(e => e.IdfsResourceType).HasColumnName("idfsResourceType");

                entity.Property(e => e.IntRowStatus).HasColumnName("intRowStatus");

                entity.Property(e => e.ResourceValue).IsRequired();

                entity.Property(e => e.Rowguid)
                    .HasColumnName("rowguid")
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.StrResourceName)
                    .IsRequired()
                    .HasMaxLength(512)
                    .HasColumnName("strResourceName");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}