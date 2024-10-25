using EIDSS.Repository.ReturnModels;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace EIDSS.Repository.Interfaces
{
    public interface ITrtBaseReferenceRepository
    {
        Task<IEnumerable<TrtBaseReference>> GetAgeTypesAsync(
            string languageIsoCode,
            string searchText,
            params long[] excludeIds);
    }
}
