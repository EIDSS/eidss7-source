using EIDSS.Domain.RequestModels.Human;
using System.Threading.Tasks;

namespace EIDSS.Repository.Interfaces
{
    public interface ITlbHumanActualRepository
    {
        Task<bool> IsPersonIDExistsAsync(string strPersonID, long? idfHumanActual);

        Task<int> UpdateAsync(UpdateHumanActualRequestModel request);
    }
}
