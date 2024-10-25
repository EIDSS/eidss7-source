using EIDSS.Repository.ReturnModels;
using Microsoft.Data.SqlClient;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Repository.Extensions;

namespace EIDSS.Repository.Contexts
{
    public partial class EIDSSContextProcedures
    {
        public virtual async Task<List<USP_Country_GetLookupResult>> USP_Country_GetLookupAsync(string LangID, string NameFilter,
            OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
        {
            var parameterreturnValue = new SqlParameter
            {
                ParameterName = "returnValue",
                Direction = System.Data.ParameterDirection.Output,
                SqlDbType = System.Data.SqlDbType.Int,
            };

            var sqlParameters = new[]
            {
                LangID.ToSqlParam("LangID", 100),
                NameFilter.ToSqlParam("NameFilter", 100),
                parameterreturnValue,
            };
            var results = await _context.SqlQueryAsync<USP_Country_GetLookupResult>(
                "EXEC @returnValue = [dbo].[USP_Country_GetLookup] @LangID, @NameFilter", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return results;
        }
    }
}