using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using EIDSS.Web.Enumerations;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.VeterinaryDiseaseReport
{
    public class SearchVeterinaryDiseaseReportPageViewModel
    {
        public SearchVeterinaryDiseaseReportPageViewModel()
        {
            SearchCriteria = new VeterinaryDiseaseReportSearchRequestModel();
            VeterinaryDiseaseReportPermissions = new UserPermissions();
        }

        public VeterinaryDiseaseReportSearchRequestModel SearchCriteria { get; set; }
        public List<VeterinaryDiseaseReportViewModel> SearchResults { get; set; }
        public UserPermissions VeterinaryDiseaseReportPermissions { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }

        public VeterinaryReportTypeEnum ReportType { get; set; }
        public bool RefreshResultsIndicator { get; set; }

        public IList<VeterinaryDiseaseReportViewModel> SelectedRecords { get; set; }
        public bool ShowSelectedRecordsIndicator { get; set; }
    }
}