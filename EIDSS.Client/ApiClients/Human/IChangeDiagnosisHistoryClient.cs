using EIDSS.Domain.ResponseModels.Human;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Human;

public interface IChangeDiagnosisHistoryClient
{
    Task<IEnumerable<ChangeDiagnosisHistoryResponseModel>> GetChangeDiagnosisHistoryAsync(long humanCaseId, string languageIsoCode);
}
