using EIDSS.Repository.EntityTypeConfigurations;
using Microsoft.EntityFrameworkCore;
using System;

namespace EIDSS.Repository.ReturnModels;

[EntityTypeConfiguration(typeof(TlbChangeDiagnosisHistoryConfiguration))]
public class TlbChangeDiagnosisHistory
{
    public long IdfChangeDiagnosisHistory { get; set; }

    public long IdfHumanCase { get; set; }

    public long? IdfsPreviousDiagnosis { get; set; }

    public long? IdfsCurrentDiagnosis { get; set; }

    public DateTime DatChangedDate { get; set; }

    public string? StrReason { get; set; }

    public int IntRowStatus { get; set; }

    public Guid Rowguid { get; set; }

    public long? IdfsChangeDiagnosisReason { get; set; }

    public string? StrMaintenanceFlag { get; set; }

    public string? StrReservedAttribute { get; set; }

    public long IdfPerson { get; set; }

    public long? SourceSystemNameId { get; set; }

    public string? SourceSystemKeyValue { get; set; }

    public string? AuditCreateUser { get; set; }

    public DateTime? AuditCreateDtm { get; set; }

    public string? AuditUpdateUser { get; set; }

    public DateTime? AuditUpdateDtm { get; set; }

    public virtual TlbPerson IdfPersonNavigation { get; set; } = null!;

    public virtual TrtBaseReference? IdfsChangeDiagnosisReasonNavigation { get; set; }

    public virtual TrtDiagnosis? IdfsCurrentDiagnosisNavigation { get; set; }

    public virtual TrtDiagnosis? IdfsPreviousDiagnosisNavigation { get; set; }
}