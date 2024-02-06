using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Dashboard
{
    public class DashboardNotificationsListViewModel : BaseModel
    {        
        public long? HumanCaseID { get; set; }
        public long? HumanID { get; set; }
        public string ReportID { get; set; }
        public DateTime? DateEntered { get; set; }
        public string PersonName { get; set; }
        public string DiseaseName { get; set; }
        public string NotifyingOrganizationName { get; set; }
        public string InpatientOrOutpatient { get; set; }
        public string NotifiedBy { get; set; }        
        public DateTime DateOfDisease { get; set; }
        public string Classification { get; set; }
        public string InvestigatedBy { get; set; }
        

    }
}
