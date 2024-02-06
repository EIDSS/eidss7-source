using EIDSS.Web.Components.Administration.Deduplication;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.ViewModels.Administration.HumanDiseaseReportDeduplication
{
    public class HumanDiseaseReportDeduplicationSymptomsSectionViewModel
    {
        public List<Field> ListInfo { get; set; }
        public List<Field> ListInfo2 { get; set; }
        public int? SurvivorSelectorInfo { get; set; }
        public int? SurvivorSelectorInfo2 { get; set; }
        public bool CheckAllIndicator { get; set; }
        public bool CheckAllIndicator2 { get; set; }
    }
}
