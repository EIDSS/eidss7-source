using EIDSS.Domain.RequestModels.Outbreak;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Outbreak;
using EIDSS.Web.Enumerations;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Outbreak.ViewModels.Case
{
    public class SearchVeterinaryCasePageViewModel
    {
        public SearchVeterinaryCasePageViewModel()
        {
            SearchCriteria = new VeterinaryCaseSearchRequestModel();
            VeterinaryCasePermissions = new UserPermissions();
        }

        public VeterinaryCaseSearchRequestModel SearchCriteria { get; set; }
        public List<VeterinaryCaseGetListViewModel> SearchResults { get; set; }
        public UserPermissions VeterinaryCasePermissions { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public VeterinaryReportTypeEnum ReportType { get; set; }
        public bool RefreshResultsIndicator { get; set; }
        public IList<VeterinaryCaseGetListViewModel> SelectedRecords { get; set; }
        public bool ShowSelectedRecordsIndicator { get; set; }
    }
}
