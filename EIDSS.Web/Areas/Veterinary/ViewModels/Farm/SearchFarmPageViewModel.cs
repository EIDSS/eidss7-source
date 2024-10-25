using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.Farm
{
    public class SearchFarmPageViewModel
    {
        public SearchFarmPageViewModel()
        {
            SearchCriteria = new();
            FarmSearchPermissions = new();
        }

        public FarmSearchRequestModel SearchCriteria { get; set; }
        public List<FarmViewModel> SearchResults { get; set; }
        public UserPermissions FarmSearchPermissions { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public long BottomAdminLevel { get; set; }

        public bool RecordSelectionIndicator { get; set; }
        public IList<FarmViewModel> SelectedRecords { get; set; }
        public bool ShowSelectedRecordsIndicator { get; set; }
    }
}
