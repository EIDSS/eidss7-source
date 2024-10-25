using System;

namespace EIDSS.Web.Areas.Outbreak.ViewModels
{
    public class OutbreakCaseSummaryModel
    {
        public string EIDSSPersonID { get; set; }
        public long HumanMasterID { get; set; }
        public string Name { get; set; }
        public DateTime? DateEntered { get; set; }
        public DateTime? LastUpdated { get; set; }
        public string CaseClassification { get; set; }
    }
}
