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
        public virtual async Task<List<USP_GBL_ORG_GETSearchResult>> USP_GBL_ORG_GETSearch(string languageId,
            int? pageNumber, int? pageSize, string sortColumn, string sortOrder, string filterValue, int? accessoryCode,
            OutputParameter<int>? returnValue = null, CancellationToken cancellationToken = default)
        {
            var parameterReturnValue = new SqlParameter
            {
                ParameterName = "returnValue",
                Direction = System.Data.ParameterDirection.Output,
                SqlDbType = System.Data.SqlDbType.Int,
            };

            var sqlParameters = new[]
            {
                languageId.ToSqlParam("LanguageID", 50),
                pageNumber.ToSqlParam("PageNumber"),
                pageSize.ToSqlParam("PageSize"),
                sortColumn.ToSqlParam("SortColumn", 30),
                sortOrder.ToSqlParam("SortOrder", 4),
                filterValue.ToSqlParam("FilterValue", 200),
                accessoryCode.ToSqlParam("AccessoryCode"),
                parameterReturnValue
            };
            
            var results = await _context.SqlQueryAsync<USP_GBL_ORG_GETSearchResult>(
                "EXEC @returnValue = [dbo].[USP_GBL_ORG_GETSearch] @LanguageID, @PageNumber, @PageSize, @SortColumn, @SortOrder, @FilterValue, @AccessoryCode",
                sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterReturnValue.Value);

            return results;
        }
    }
}