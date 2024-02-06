using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Human
{
    public class ReportFormDetailViewModel 
    {
        public long idfReportForm { get; set; }
        public long idfsReportFormType { get; set; }
        public long idfsAdministrativeUnit { get; set; }
        public long idfSentByOffice { get; set; }
        public long idfSentByPerson { get; set; }
        public long idfEnteredByOffice { get; set; }
        public string strEnteredByOffice { get; set; }
        public long idfEnteredByPerson { get; set; }
        public string strEnteredByPerson { get; set; }
        public string datSentByDate { get; set; }
        public string datEnteredByDate { get; set; }
        public string datStartDate { get; set; }
        public string datFinishDate { get; set; }
        public string strReportFormID { get; set; }
        public long? idfsAreaType { get; set; }
        public long? AdminLevel0 { get; set; }
        public string AdminLevel0Name { get; set; }
        public long? AdminLevel1 { get; set; }
        public string AdminLevel1Name { get; set; }
        public long? AdminLevel2 { get; set; }
        public string AdminLevel2Name { get; set; }
        public long? idfsSettlement { get; set; }
        public string SettlementName { get; set; }
        public long? idfsPeriodType { get; set; }
        public string strPeriodName { get; set; }
        public long idfsDiagnosis { get; set; }
        public string diseaseName { get; set; }
        public int Total { get; set; }
        public int? Notified { get; set; }
        public string Comments { get; set; }
    }
}