using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Repository.ReturnModels;

namespace EIDSS.Repository.Contexts
{
    public partial interface IEIDSSContextProcedures
    {
        Task<List<USP_GBL_ORG_GETSearchResult>> USP_GBL_ORG_GETSearch(string LanguageID, int? PageNumber, int? PageSize, string SortColumn, string SortOrder, string FilterValue, int? AccessoryCode, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<USP_Country_GetLookupResult>> USP_Country_GetLookupAsync(string LangID, string NameFilter, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
    }
}