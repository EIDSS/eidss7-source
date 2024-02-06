using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using System.Collections.Generic;
using EIDSS.Domain.RequestModels.CrossCutting;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.AggregateActionsReport
{
    public class SearchAggregateActionsReportPageViewModel
    {
        public SearchAggregateActionsReportPageViewModel()
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