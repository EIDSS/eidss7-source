using System;

namespace EIDSS.Repository.ReturnModels.Custom;

public class ChangeDiagnosisHistoryReturnModel
{
    public DateTime DateOfChange { get; set; }

    public string? ChangedByOrganization { get; set; }

    public string? ChangedByPerson { get; set; }

    public string? PreviousDisease { get; set; }

    public string? ChangedDisease { get; set; }

    public string? Reason { get; set; }
}
