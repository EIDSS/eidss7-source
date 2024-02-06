using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using System.Collections.Generic;
using EIDSS.Web.ViewModels.Human;

namespace EIDSS.Web.ViewModels.CrossCutting
{
    public class AggregateReportDetailsViewModel
    {
        public List<OrganizationAdvancedGetListViewModel> lstSentToOrganizations { get; set; }
        public List<OrganizationAdvancedGetListViewModel> lstRecvByOrganizations { get; set; }
        public List<EventSaveRequestModel> PendingSaveEvents { get; set; }
        public long? idfAggrCase { get; set; }
        public string ErrorMessage { get; set; }
        public string InformationalMessage { get; set; }
        public string WarningMessage { get; set; }
        public ReportDetailsSectionViewModel ReportDetailsSection { get; set; }
        public DiseaseMatrixSectionViewModel DiseaseMatrixSection { get; set; }
        public UserPermissions Permissions { get; set; }
        public int StartIndex { get; set; } = 0;
        public bool IsReadOnly { get; set; }
        public long duplicateKey { get; set; }
        public string PrintReportName { get; set; } = "HumanAggregateDiseaseReport";
        public bool EnableFinishButton { get; set; }

        public DiseaseReportPrintViewModel ReportPrintViewModel { get; set; }

    }
}