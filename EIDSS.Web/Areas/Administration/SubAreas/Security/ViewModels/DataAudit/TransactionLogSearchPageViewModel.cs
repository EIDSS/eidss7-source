using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.DataAudit
{
    public class TransactionLogSearchPageViewModel
    {

        public DataAuditLogGetRequestModel SearchCriteria { get; set; }

        public List<DataAuditTransactionLogGetListViewModel> SearchResults { get; set; }

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

        public IEnumerable<SiteGetListViewModel> siteList;

        public IEnumerable<EmployeeListViewModel> userList;

        public IEnumerable<BaseReferenceViewModel> ActionList;

        public IEnumerable<BaseReferenceViewModel> ObjectTypeList;

        public IList<DataAuditTransactionLogGetListViewModel> SelectedRecords { get; set; }

        public bool ShowSelectedRecordsIndicator { get; set; }
    }
}
