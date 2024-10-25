using EIDSS.Repository.ReturnModels;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace EIDSS.Repository.EntityTypeConfigurations;

public class TlbHumanActualConfiguration : IEntityTypeConfiguration<TlbHumanActual>
{
    public void Configure(EntityTypeBuilder<TlbHumanActual> entity)
    {
        entity.ToTable("tlbHumanActual", tbl => tbl.HasTrigger("TR_tlbHumanActual_A_Update"));
        entity.HasKey(p => p.IdfHumanActual).HasName("XPKtlbHumanActual");
        entity.Property(p => p.IdfHumanActual).HasColumnName("idfHumanActual");
        entity.Property(p => p.DatDateOfBirth).HasColumnType("datDateofBirth");
        entity.Property(p => p.DatDateOfDeath).HasColumnName("datDateOfDeath");
        entity.Property(p => p.StrPersonID).HasColumnName("strPersonID");
    }
}
