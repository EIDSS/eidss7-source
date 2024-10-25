using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using EIDSS.Repository.ReturnModels;
using Microsoft.Data.SqlClient;

namespace EIDSS.Repository.Contexts
{

    public partial class EidssArchiveContext
    {
        private EidssArchiveContextProcedures _procedures;

        public EidssArchiveContextProcedures Procedures
        {
            get
            {
                if (_procedures is null) _procedures = new EidssArchiveContextProcedures(this);
                return _procedures;
            }
            set { _procedures = value; }
        }

        public EidssArchiveContextProcedures GetProcedures()
        {
            return Procedures;
        }
    }

    public partial class EidssArchiveContextProcedures
    {
        private readonly EidssArchiveContext _context;

        public EidssArchiveContextProcedures(EidssArchiveContext context)
        {
            _context = context;
        }

        public virtual async Task<List<USP_GBL_MENU_ByUser_GETListResult>> USP_GBL_MENU_ByUser_GETListAsync(long? idfUserId, string LangID, long? EmployeeID, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
        {
            var parameterreturnValue = new SqlParameter
            {
                ParameterName = "returnValue",
                Direction = System.Data.ParameterDirection.Output,
                SqlDbType = System.Data.SqlDbType.Int,
            };

            var sqlParameters = new[]
            {
                new SqlParameter
                {
                    ParameterName = "idfUserId",
                    Value = idfUserId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                new SqlParameter
                {
                    ParameterName = "LangID",
                    Size = 100,
                    Value = LangID ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                new SqlParameter
                {
                    ParameterName = "EmployeeID",
                    Value = EmployeeID ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<USP_GBL_MENU_ByUser_GETListResult>("EXEC @returnValue = [dbo].[USP_GBL_MENU_ByUser_GETList] @idfUserId, @LangID, @EmployeeID", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

    }
}
