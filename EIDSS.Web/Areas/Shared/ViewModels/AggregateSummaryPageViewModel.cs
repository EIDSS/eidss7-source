using System.Collections.Generic;
using System.Collections.Specialized;
using EIDSS.ClientLibrary.Enumerations;
using EIDSS.Domain.ViewModels.Reports;

namespace EIDSS.Web.Areas.Shared.ViewModels
{
    public class AggregateSummaryPageViewModel
    {
        public string Title { get; set; }
        public List<AggregateSummaryViewModel> AggregateSummaryRecords { get; set; }
        public List<string> MatrixColumnHeadings { get; set; }
        public Dictionary<string, int> DisplayFields { get; set; }
    }
}