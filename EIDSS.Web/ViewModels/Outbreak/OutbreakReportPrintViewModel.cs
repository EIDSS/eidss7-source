using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Outbreak
{
    public class OutbreakReportPrintViewModel
    {
        public List<KeyValuePair<string, string>> Parameters { get; set; }

        public string ReportName { get; set; } = "SearchForFreezer"; 
    }
}
