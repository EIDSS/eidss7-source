using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportPrintViewModel
    {
        public List<KeyValuePair<string, string>> Parameters { get; set; }

        public string ReportName { get; set; }

        public string ReportHeading { get; set; }


    }
}
