using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ResponseModels.CrossCutting;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.CrossCutting
{
    public interface IAgeTypeClient
    {
        Task<IEnumerable<AgeTypeResponseModel>> GetAgeTypesAsync(GetAgeTypesRequestModel request);
    }
}
