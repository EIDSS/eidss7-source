using EIDSS.Repository.ReturnModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace EIDSS.Repository.Contexts
{
    public partial interface IEIDSSAuditingContextProcedures
    {
        Task<List<USP_ADMIN_DATAAUDITLOG_GETDetailResult>> USP_ADMIN_DATAAUDITLOG_GETDetailAsync(long? idfDataAuditEvent, string LangID, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<USP_ADMIN_DATAAUDITLOG_GETListResult>> USP_ADMIN_DATAAUDITLOG_GETListAsync(string languageId, DateTime? startDate, DateTime? endDate, long? idfUserId, long? idfSiteId, long? idfActionId, long? idfObjetType, long? idfObjectId, string SortColumn, string SortOrder, int? Page, int? PageSize, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<USP_DataAudit_AuditEvents_GetListResult>> USP_DataAudit_AuditEvents_GetListAsync(OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<USP_GBL_AuditEventSystemLog_SETResult>> USP_GBL_AuditEventSystemLog_SETAsync(string AuditPrimaryTable, string AuditDataPreXML, string AuditDataPostXML, string AuditCreateDBObjectName, string AuditUpdateDBObjectName, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<USP_GBL_DataAuditEvent_DeleteResult>> USP_GBL_DataAuditEvent_DeleteAsync(string userName, string JSONUpdates, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<USP_GBL_DataAuditEvent_SETResult>> USP_GBL_DataAuditEvent_SETAsync(string userName, long? idfSiteId, string JSONUpdates, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<USP_GBL_DataAuditEvent_UpdateResult>> USP_GBL_DataAuditEvent_UpdateAsync(long? idfUserID, string JSONUpdates, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<List<USP_GBL_GIS_LocationAncestry_GETListResult>> USP_GBL_GIS_LocationAncestry_GETListAsync(string languageId, long? locationId, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
        Task<int> usp_GetDataAuditEventAsync(OutputParameter<long?> @event, OutputParameter<int> returnValue = null, CancellationToken cancellationToken = default);
    }
}
