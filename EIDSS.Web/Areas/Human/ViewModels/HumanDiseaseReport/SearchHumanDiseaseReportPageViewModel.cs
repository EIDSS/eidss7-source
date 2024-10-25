using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace EIDSS.Web.Areas.Human.ViewModels.Human
{
    public class SearchHumanDiseaseReportPageViewModel
    {
        public SearchHumanDiseaseReportPageViewModel()
        {
            SearchCriteria = new();
            HumanDiseaseReportPermissions = new();
        }
 
        public HumanDiseaseReportSearchRequestModel SearchCriteria { get; set; }
        public List<HumanDiseaseReportViewModel> SearchResults { get; set; }
        public UserPermissions HumanDiseaseReportPermissions { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public LocationViewModel SearchExposureLocationViewModel { get; set; }
        public long BottomAdminLevel { get; set; }

        public IList<HumanDiseaseReportViewModel> SelectedRecords { get; set; }
        public bool ShowSelectedRecordsIndicator { get; set; }





    }

  

}
