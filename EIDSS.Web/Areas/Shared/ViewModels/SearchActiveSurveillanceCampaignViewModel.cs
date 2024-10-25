using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Common;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Shared.ViewModels
{
    public class SearchActiveSurveillanceCampaignViewModel
    {

        public SearchActiveSurveillanceCampaignViewModel()
        {
            SearchCriteria = new();
            Permissions = new();
        }

        public ActiveSurveillanceCampaignRequestModel SearchCriteria { get; set; }
        public List<ActiveSurveillanceCampaignListViewModel> SearchResults { get; set; }
        public UserPermissions Permissions { get; set; }


    }
}
