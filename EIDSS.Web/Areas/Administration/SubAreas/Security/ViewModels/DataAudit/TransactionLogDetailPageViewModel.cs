using System.Collections.Generic;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.DataAudit
{
    public class TransactionLogDetailPageViewModel
    {

        public DataAuditTransactionLogGetListViewModel SelectedRecord { get; set; }

        public List<DataAuditTransactionLogGetDetailViewModel> SearchResults { get; set; }

        public UserPermissions Permissions { get; set; }
        public UserPermissions VetActiveSurveillanceCampPermissions { get; set; }
        public UserPermissions VetActiveSurveillanceSessionPermissions { get; set; }
        public UserPermissions VectorSurveillanceSessionPermissions { get; set; }
        public UserPermissions HumanAggregateDiseaseRepPermissions { get; set; }
        public UserPermissions WeeklyReportFormPermissions { get; set; }
        public UserPermissions IliAggregateReportPermissions { get; set; }
        public UserPermissions HumanDiseaseReportPermissions { get; set; }
        public UserPermissions OutBreakSessionPermissions { get; set; }
        public UserPermissions VetAggregateActionReportPermissions { get; set; }
        public UserPermissions VetAggregateDiseaseReportPermissions { get; set; }
        public UserPermissions VetDiseaseReportPermissions { get; set; }
        public UserPermissions HumanActiveSurveillanceCampPermissions { get; set; }
        public UserPermissions HumanActiveSurveillanceSessionPermissions { get; set; }



    }
}
