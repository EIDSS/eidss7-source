using EIDSS.Repository.ReturnModels;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace EIDSS.Repository.EntityTypeConfigurations;

public class TlbChangeDiagnosisHistoryConfiguration : IEntityTypeConfiguration<TlbChangeDiagnosisHistory>
{
    public void Configure(EntityTypeBuilder<TlbChangeDiagnosisHistory> entity)
    {
        entity.HasKey(e => e.IdfChangeDiagnosisHistory).HasName("XPKtlbChangeDiagnosisHistory");

        entity.ToTable("tlbChangeDiagnosisHistory", tb =>
        {
            tb.HasTrigger("TR_tlbChangeDiagnosisHistory_A_Update");
            tb.HasTrigger("TR_tlbChangeDiagnosisHistory_I_Delete");
        });

        entity.Property(e => e.IdfChangeDiagnosisHistory)
            .ValueGeneratedNever()
            .HasColumnName("idfChangeDiagnosisHistory");
        entity.Property(e => e.AuditCreateDtm)
            .HasDefaultValueSql("(getdate())")
            .HasColumnType("datetime")
            .HasColumnName("AuditCreateDTM");
        entity.Property(e => e.AuditCreateUser).HasMaxLength(200);
        entity.Property(e => e.AuditUpdateDtm)
            .HasColumnType("datetime")
            .HasColumnName("AuditUpdateDTM");
        entity.Property(e => e.AuditUpdateUser).HasMaxLength(200);
        entity.Property(e => e.DatChangedDate)
            .HasColumnType("datetime")
            .HasColumnName("datChangedDate");
        entity.Property(e => e.IdfHumanCase).HasColumnName("idfHumanCase");
        entity.Property(e => e.IdfPerson).HasColumnName("idfPerson");
        entity.Property(e => e.IdfsChangeDiagnosisReason).HasColumnName("idfsChangeDiagnosisReason");
        entity.Property(e => e.IdfsCurrentDiagnosis).HasColumnName("idfsCurrentDiagnosis");
        entity.Property(e => e.IdfsPreviousDiagnosis).HasColumnName("idfsPreviousDiagnosis");
        entity.Property(e => e.IntRowStatus).HasColumnName("intRowStatus");
        entity.Property(e => e.Rowguid)
            .HasDefaultValueSql("(newid())")
            .HasColumnName("rowguid");
        entity.Property(e => e.SourceSystemNameId)
            .HasDefaultValueSql("((10519001))")
            .HasColumnName("SourceSystemNameID");
        entity.Property(e => e.StrMaintenanceFlag)
            .HasMaxLength(20)
            .HasColumnName("strMaintenanceFlag");
        entity.Property(e => e.StrReason)
            .HasMaxLength(2000)
            .HasColumnName("strReason");
        entity.Property(e => e.StrReservedAttribute).HasColumnName("strReservedAttribute");

        entity.HasOne(d => d.IdfsCurrentDiagnosisNavigation).WithMany(p => p.TlbChangeDiagnosisHistoryIdfsCurrentDiagnosisNavigation)
            .HasForeignKey(d => d.IdfsCurrentDiagnosis)
            .HasConstraintName("FK_tlbChangeDiagnosisHistory_trtDiagnosis__idfsCurrentDiagnosis_R_1799");

        entity.HasOne(d => d.IdfsPreviousDiagnosisNavigation).WithMany(p => p.TlbChangeDiagnosisHistoryIdfsPreviousDiagnosisNavigation)
            .HasForeignKey(d => d.IdfsPreviousDiagnosis)
            .HasConstraintName("FK_tlbChangeDiagnosisHistory_trtDiagnosis__idfsPreviousDiagnosis_R_1798");
    }
}
