using System.Threading.Tasks;
using EIDSS.Domain.ResponseModels.PIN;

namespace EIDSS.ClientLibrary.ApiClients.PIN
{
    public interface IPINClient
    {
        Task<PersonalDataModel> GetPersonData(string personalID, string birthYear);
    }
}
