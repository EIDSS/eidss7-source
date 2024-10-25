using System.Collections.Generic;
using System.ComponentModel;
using EIDSS.Domain.ViewModels.Reports;
using EIDSS.Web.Areas.Reports.ViewModels;
using EIDSS.Localization.Helpers;

namespace EIDSS.Web.Areas.Reports.SubAreas.AJ.ViewModels
{
    public class LaboratoryTestingResultsViewModel : ReportBaseModel
    {

        public List<LABTestingResultsDepartmentViewModel> LABTestingResultsDepartmentList { get; set; }
          

        [DisplayName("Sample ID")]
        [LocalizedRequired]
        public string SampleID { get; set; }

        [DisplayName("Lab Department")]
        [LocalizedRequired]
        public string DepartmentID { get; set; }

        public string JavascriptToRun { get; set; }
    }

    public class LaboratoryTestingResultsQueryModel : ReportQueryBaseModel
    {
        public string SampleID { get; set; }
        public string DepartmentID { get; set; }
    }
}

