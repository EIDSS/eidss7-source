using System;

namespace EIDSS.Domain.ResponseModels.Human;

public class ChangeDiagnosisHistoryResponseModel
{
    public DateTime DateOfChange { get; set; }

    public string ChangedByOrganization { get; set; }

    public string ChangedByPerson { get; set; }

    public string PreviousDisease { get; set; }

    public string ChangedDisease { get; set; }

    public string Reason { get; set; }
}
