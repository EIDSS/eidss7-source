using EIDSS.Repository.ReturnModels;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Repository.Contexts
{
    public partial class EIDSSAuditingContext
    {
        private IEIDSSAuditingContextProcedures _procedures;

        public virtual IEIDSSAuditingContextProcedures Procedures
        {
            get
            {
                if (_procedures is null) _procedures = new EIDSSAuditingContextProcedures(this);
                return _procedures;
            }
            set
            {
                _procedures = value;
            }
        }

        public IEIDSSAuditingContextProcedures GetProcedures()
        {
            return Procedures;
        }

        protected void OnModelCreatingGeneratedProcedures(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<USP_ADMIN_DATAAUDITLOG_GETDetailResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<USP_ADMIN_DATAAUDITLOG_GETListResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<USP_DataAudit_AuditEvents_GetListResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<USP_GBL_AuditEventSystemLog_SETResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<USP_GBL_DataAuditEvent_DeleteResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<USP_GBL_DataAuditEvent_SETResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<USP_GBL_DataAuditEvent_UpdateResult>().HasNoKey().ToView(null);
            modelBuilder.Entity<USP_GBL_GIS_LocationAncestry_GETListResult>().HasNoKey().ToView(null);
        }
    }

    public partial class EIDSSAuditingContextProcedures : IEIDSSAuditingContextProcedures
    {
        private readonly EIDSSAuditingContext _context;

        public EIDSSAuditingContextProcedures(EIDSSAuditingContext context)
        {
            _context = context;
        }

        public virtual async Task<List<USP_ADMIN_DATAAUDITLOG_GETDetailResult>> USP_ADMIN_DATAAUDITLOG_GETDetailAsync(long? idfDataAuditEvent, string LangID, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
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
                    ParameterName = "idfDataAuditEvent",
                    Value = idfDataAuditEvent ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                new SqlParameter
                {
                    ParameterName = "LangID",
                    Size = 100,
                    Value = LangID ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<USP_ADMIN_DATAAUDITLOG_GETDetailResult>("EXEC @returnValue = [dbo].[USP_ADMIN_DATAAUDITLOG_GETDetail] @idfDataAuditEvent, @LangID", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<List<USP_ADMIN_DATAAUDITLOG_GETListResult>> USP_ADMIN_DATAAUDITLOG_GETListAsync(string languageId, DateTime? startDate, DateTime? endDate, long? idfUserId, long? idfSiteId, long? idfActionId, long? idfObjetType, long? idfObjectId, string SortColumn, string SortOrder, int? Page, int? PageSize, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
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
                    ParameterName = "languageId",
                    Size = 100,
                    Value = languageId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                new SqlParameter
                {
                    ParameterName = "startDate",
                    Value = startDate ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.DateTime,
                },
                new SqlParameter
                {
                    ParameterName = "endDate",
                    Value = endDate ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.DateTime,
                },
                new SqlParameter
                {
                    ParameterName = "idfUserId",
                    Value = idfUserId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                new SqlParameter
                {
                    ParameterName = "idfSiteId",
                    Value = idfSiteId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                new SqlParameter
                {
                    ParameterName = "idfActionId",
                    Value = idfActionId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                new SqlParameter
                {
                    ParameterName = "idfObjetType",
                    Value = idfObjetType ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                new SqlParameter
                {
                    ParameterName = "idfObjectId",
                    Value = idfObjectId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                new SqlParameter
                {
                    ParameterName = "SortColumn",
                    Size = 60,
                    Value = SortColumn ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                new SqlParameter
                {
                    ParameterName = "SortOrder",
                    Size = 8,
                    Value = SortOrder ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                new SqlParameter
                {
                    ParameterName = "Page",
                    Value = Page ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Int,
                },
                new SqlParameter
                {
                    ParameterName = "PageSize",
                    Value = PageSize ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Int,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<USP_ADMIN_DATAAUDITLOG_GETListResult>("EXEC @returnValue = [dbo].[USP_ADMIN_DATAAUDITLOG_GETList] @languageId, @startDate, @endDate, @idfUserId, @idfSiteId, @idfActionId, @idfObjetType, @idfObjectId, @SortColumn, @SortOrder, @Page, @PageSize", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<List<USP_DataAudit_AuditEvents_GetListResult>> USP_DataAudit_AuditEvents_GetListAsync(OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
        {
            var parameterreturnValue = new SqlParameter
            {
                ParameterName = "returnValue",
                Direction = System.Data.ParameterDirection.Output,
                SqlDbType = System.Data.SqlDbType.Int,
            };

            var sqlParameters = new[]
            {
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<USP_DataAudit_AuditEvents_GetListResult>("EXEC @returnValue = [dbo].[USP_DataAudit_AuditEvents_GetList]", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<List<USP_GBL_AuditEventSystemLog_SETResult>> USP_GBL_AuditEventSystemLog_SETAsync(string AuditPrimaryTable, string AuditDataPreXML, string AuditDataPostXML, string AuditCreateDBObjectName, string AuditUpdateDBObjectName, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
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
                    ParameterName = "AuditPrimaryTable",
                    Size = 200,
                    Value = AuditPrimaryTable ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.VarChar,
                },
                new SqlParameter
                {
                    ParameterName = "AuditDataPreXML",
                    Value = AuditDataPreXML ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Xml,
                },
                new SqlParameter
                {
                    ParameterName = "AuditDataPostXML",
                    Value = AuditDataPostXML ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.Xml,
                },
                new SqlParameter
                {
                    ParameterName = "AuditCreateDBObjectName",
                    Size = 200,
                    Value = AuditCreateDBObjectName ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.VarChar,
                },
                new SqlParameter
                {
                    ParameterName = "AuditUpdateDBObjectName",
                    Size = -1,
                    Value = AuditUpdateDBObjectName ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.VarChar,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<USP_GBL_AuditEventSystemLog_SETResult>("EXEC @returnValue = [dbo].[USP_GBL_AuditEventSystemLog_SET] @AuditPrimaryTable, @AuditDataPreXML, @AuditDataPostXML, @AuditCreateDBObjectName, @AuditUpdateDBObjectName", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<List<USP_GBL_DataAuditEvent_DeleteResult>> USP_GBL_DataAuditEvent_DeleteAsync(string userName, string JSONUpdates, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
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
                    ParameterName = "userName",
                    Size = 512,
                    Value = userName ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                new SqlParameter
                {
                    ParameterName = "JSONUpdates",
                    Size = -1,
                    Value = JSONUpdates ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<USP_GBL_DataAuditEvent_DeleteResult>("EXEC @returnValue = [dbo].[USP_GBL_DataAuditEvent_Delete] @userName, @JSONUpdates", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<List<USP_GBL_DataAuditEvent_SETResult>> USP_GBL_DataAuditEvent_SETAsync(string userName, long? idfSiteId, string JSONUpdates, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
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
                    ParameterName = "userName",
                    Size = 5152,
                    Value = userName ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                new SqlParameter
                {
                    ParameterName = "idfSiteId",
                    Value = idfSiteId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                new SqlParameter
                {
                    ParameterName = "JSONUpdates",
                    Size = -1,
                    Value = JSONUpdates ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<USP_GBL_DataAuditEvent_SETResult>("EXEC @returnValue = [dbo].[USP_GBL_DataAuditEvent_SET] @userName, @idfSiteId, @JSONUpdates", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<List<USP_GBL_DataAuditEvent_UpdateResult>> USP_GBL_DataAuditEvent_UpdateAsync(long? idfUserID, string JSONUpdates, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
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
                    ParameterName = "idfUserID",
                    Value = idfUserID ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                new SqlParameter
                {
                    ParameterName = "JSONUpdates",
                    Size = -1,
                    Value = JSONUpdates ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<USP_GBL_DataAuditEvent_UpdateResult>("EXEC @returnValue = [dbo].[USP_GBL_DataAuditEvent_Update] @idfUserID, @JSONUpdates", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<List<USP_GBL_GIS_LocationAncestry_GETListResult>> USP_GBL_GIS_LocationAncestry_GETListAsync(string languageId, long? locationId, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
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
                    ParameterName = "languageId",
                    Size = 20,
                    Value = languageId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.NVarChar,
                },
                new SqlParameter
                {
                    ParameterName = "locationId",
                    Value = locationId ?? Convert.DBNull,
                    SqlDbType = System.Data.SqlDbType.BigInt,
                },
                parameterreturnValue,
            };
            var _ = await _context.SqlQueryAsync<USP_GBL_GIS_LocationAncestry_GETListResult>("EXEC @returnValue = [dbo].[USP_GBL_GIS_LocationAncestry_GETList] @languageId, @locationId", sqlParameters, cancellationToken);

            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }

        public virtual async Task<int> usp_GetDataAuditEventAsync(OutputParameter<long?> @event, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default)
        {
            var parameterevent = new SqlParameter
            {
                ParameterName = "event",
                Direction = System.Data.ParameterDirection.InputOutput,
                Value = @event?._value ?? Convert.DBNull,
                SqlDbType = System.Data.SqlDbType.BigInt,
            };
            var parameterreturnValue = new SqlParameter
            {
                ParameterName = "returnValue",
                Direction = System.Data.ParameterDirection.Output,
                SqlDbType = System.Data.SqlDbType.Int,
            };

            var sqlParameters = new[]
            {
                parameterevent,
                parameterreturnValue,
            };
            var _ = await _context.Database.ExecuteSqlRawAsync("EXEC @returnValue = [dbo].[usp_GetDataAuditEvent] @event OUTPUT", sqlParameters, cancellationToken);

            @event.SetValue(parameterevent.Value);
            returnValue?.SetValue(parameterreturnValue.Value);

            return _;
        }
    }
}
