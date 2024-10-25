using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ResponseModels.Outbreak
{
    public class OutbreakCaseListModel2 : BaseModel
    {
        //public int? TotalRowCount { get; set; }
        public long? OutbreakCaseReportUID { get; set; }
        public string strOutbreakCaseID { get; set; }
        public string FarmOwner { get; set; }
        public string CaseType { get; set; }
        public string CaseFarmStatus { get; set; }
        public DateTime? DateOfSymptomOnset { get; set; }
        public string CaseClassification { get; set; }
        public string CaseLocation { get; set; }
        public DateTime? DateEntered { get; set; }
        public int? IsPrimaryCaseFlag { get; set; }
        public long? CaseMonitoringDuration { get; set; }
        public long? CaseMonitoringFrequency { get; set; }
        //public int? TotalPages { get; set; }
        //public int? CurrentPage { get; set; }
    }
}
