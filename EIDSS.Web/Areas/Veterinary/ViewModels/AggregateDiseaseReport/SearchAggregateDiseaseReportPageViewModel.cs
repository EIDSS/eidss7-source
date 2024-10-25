using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.AggregateDiseaseReport
{
    public class SearchAggregateDiseaseReportPageViewModel
    {
        public SearchAggregateDiseaseReportPageViewModel()
        {
            SearchCriteria = new AggregateReportSearchRequestModel();
            Permissions = new UserPermissions();
        }

        public AggregateReportSearchRequestModel SearchCriteria { get; set; }
        public List<AggregateReportGetListViewModel> SearchResults { get; set; }
        public UserPermissions Permissions { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public long BottomAdminLevel { get; set; }
        public bool RecordSelectionIndicator { get; set; }
        public bool RefreshResultsIndicator { get; set; }
    }
}