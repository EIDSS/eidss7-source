using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.CrossCutting;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class CustomReportRowsMatrixGetRequestModel : BaseGetRequestModel
    {
        public long? idfsCustomReportType { get; set; }
    }

    public class CustomReportRowsMatrixSaveRequestModel : BaseSaveRequestModel
    {
        public long? idfReportRows { get; set; }
        public long? idfsCustomReportType { get; set; }
        public long? idfsDiagnosisOrReportDiagnosisGroup { get; set; }
        public long? idfsReportAdditionalText { get; set; }
        public long? idfsICDReportAdditionalText { get; set; }
        public int intRowOrder { get; set; }
        public bool DeleteAnyway { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
        public string AuditUserName { get; set; }
    }

    public class CustomReportRowsRowOrderSaveRequestModel
    {
        public RowOrderModel[] Rows { get; set; }
        
    }
}
