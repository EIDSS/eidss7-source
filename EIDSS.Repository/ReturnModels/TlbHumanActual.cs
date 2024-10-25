using EIDSS.Repository.EntityTypeConfigurations;
using Microsoft.EntityFrameworkCore;
using System;

namespace EIDSS.Repository.ReturnModels;

[EntityTypeConfiguration(typeof(TlbHumanActualConfiguration))]
public class TlbHumanActual
{
    public long IdfHumanActual { get; set; }

    public DateTime? DatDateOfBirth { get; set; }

    public DateTime? DatDateOfDeath { get; set; }

    public string? StrPersonID { get; set; }
}
