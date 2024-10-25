using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Human
{
    public class DiseaseReportDetailPageViewModel 
    {

        public string PersonID { get; set; }

        public long? HumanActualID { get; set; }

        public long? HumanID { get; set; }
        public DiseaseReportSummaryPageViewModel ReportSummary { get; set; }

        public DiseaseReportComponentViewModel ReportComponent { get; set; }
    }
}
