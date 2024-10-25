using EIDSS.Repository.EntityTypeConfigurations;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;

namespace EIDSS.Repository.ReturnModels;

/// <summary>
/// Diagnosis
/// </summary>
[EntityTypeConfiguration(typeof(TrtDiagnosisConfiguration))]
public class TrtDiagnosis
{
    /// <summary>
    /// Diagnosis identifier
    /// </summary>
    public long IdfsDiagnosis { get; set; }

    public long IdfsUsingType { get; set; }

    /// <summary>
    /// IDC10 Code
    /// </summary>
    public string? StrIdc10 { get; set; }

    /// <summary>
    /// OIE Code
    /// </summary>
    public string? StrOiecode { get; set; }

    public int IntRowStatus { get; set; }

    public Guid Rowguid { get; set; }

    public bool BlnZoonotic { get; set; }

    public string? StrMaintenanceFlag { get; set; }

    public string? StrReservedAttribute { get; set; }

    public bool? BlnSyndrome { get; set; }

    public long? SourceSystemNameId { get; set; }

    public string? SourceSystemKeyValue { get; set; }

    public string? AuditCreateUser { get; set; }

    public DateTime? AuditCreateDtm { get; set; }

    public string? AuditUpdateUser { get; set; }

    public DateTime? AuditUpdateDtm { get; set; }

    public virtual TrtBaseReference IdfsDiagnosisNavigation { get; set; } = null!;

    public virtual TrtBaseReference IdfsUsingTypeNavigation { get; set; } = null!;

    public virtual ICollection<TlbChangeDiagnosisHistory> TlbChangeDiagnosisHistoryIdfsCurrentDiagnosisNavigation { get; set; } = new List<TlbChangeDiagnosisHistory>();

    public virtual ICollection<TlbChangeDiagnosisHistory> TlbChangeDiagnosisHistoryIdfsPreviousDiagnosisNavigation { get; set; } = new List<TlbChangeDiagnosisHistory>();
}