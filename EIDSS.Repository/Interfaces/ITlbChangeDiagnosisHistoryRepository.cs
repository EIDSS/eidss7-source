using EIDSS.Repository.ReturnModels.Custom;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EIDSS.Repository.Interfaces;

public interface ITlbChangeDiagnosisHistoryRepository
{
    Task<IEnumerable<ChangeDiagnosisHistoryReturnModel>> GetChangeDiagnosisHistoryAsync(long idfHumanCase, string languageIsoCode);
}
