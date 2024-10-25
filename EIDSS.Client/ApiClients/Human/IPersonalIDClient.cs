using System.Threading.Tasks;

namespace EIDSS.ClientLibrary.ApiClients.Human
{
    public interface IPersonalIDClient
    {
        Task<bool> IsPersonalIDExistsAsync(string personalID, long? humanActualId);
    }
}
