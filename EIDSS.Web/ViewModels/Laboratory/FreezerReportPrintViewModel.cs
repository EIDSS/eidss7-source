using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Laboratory
{
    public class FreezerReportPrintViewModel
    {
        public List<KeyValuePair<string, string>> Parameters { get; set; }

        public string ReportName { get; set; } = "SearchForFreezer";
    }
}
