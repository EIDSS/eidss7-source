using EIDSS.Repository.ReturnModels;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace EIDSS.Repository.EntityTypeConfigurations;

public class TrtDiagnosisConfiguration : IEntityTypeConfiguration<TrtDiagnosis>
{
    public void Configure(EntityTypeBuilder<TrtDiagnosis> entity)
    {
        entity.HasKey(e => e.IdfsDiagnosis).HasName("XPKtrtDiagnosis");

        entity.ToTable("trtDiagnosis", tb =>
        {
            tb.HasComment("Diagnosis");
            tb.HasTrigger("TR_trtDiagnosis_A_Update");
            tb.HasTrigger("TR_trtDiagnosis_I_Delete");
        });

        entity.Property(e => e.IdfsDiagnosis)
            .ValueGeneratedNever()
            .HasComment("Diagnosis identifier")
            .HasColumnName("idfsDiagnosis");
        entity.Property(e => e.AuditCreateDtm)
            .HasDefaultValueSql("(getdate())")
            .HasColumnType("datetime")
            .HasColumnName("AuditCreateDTM");
        entity.Property(e => e.AuditCreateUser).HasMaxLength(200);
        entity.Property(e => e.AuditUpdateDtm)
            .HasColumnType("datetime")
            .HasColumnName("AuditUpdateDTM");
        entity.Property(e => e.AuditUpdateUser).HasMaxLength(200);
        entity.Property(e => e.BlnSyndrome).HasColumnName("blnSyndrome");
        entity.Property(e => e.BlnZoonotic).HasColumnName("blnZoonotic");
        entity.Property(e => e.IdfsUsingType).HasColumnName("idfsUsingType");
        entity.Property(e => e.IntRowStatus).HasColumnName("intRowStatus");
        entity.Property(e => e.Rowguid)
            .HasDefaultValueSql("(newid())")
            .HasColumnName("rowguid");
        entity.Property(e => e.SourceSystemNameId).HasColumnName("SourceSystemNameID");
        entity.Property(e => e.StrIdc10)
            .HasMaxLength(200)
            .HasComment("IDC10 Code")
            .HasColumnName("strIDC10");
        entity.Property(e => e.StrMaintenanceFlag)
            .HasMaxLength(20)
            .HasColumnName("strMaintenanceFlag");
        entity.Property(e => e.StrOiecode)
            .HasMaxLength(200)
            .HasComment("OIE Code")
            .HasColumnName("strOIECode");
        entity.Property(e => e.StrReservedAttribute).HasColumnName("strReservedAttribute");
    }
}
