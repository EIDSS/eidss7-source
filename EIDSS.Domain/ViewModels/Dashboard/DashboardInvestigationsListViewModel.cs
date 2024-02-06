using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ViewModels.Dashboard
{
    public class DashboardInvestigationsListViewModel : BaseModel
    {        
        public long? VetCaseID { get; set; }
        public long? FarmID { get; set; }
        public string ReportID { get; set; }
        public int? HACode { get; set; }
        public DateTime? DateEntered { get; set; }
        public string Species { get; set; }
        public string DiseaseName { get; set; }
        public DateTime? DateInvestigation { get; set; }
        public string InvestigatedBy { get; set; }
        public string Classification { get; set; }
        public string Address { get; set; }
    }
}
