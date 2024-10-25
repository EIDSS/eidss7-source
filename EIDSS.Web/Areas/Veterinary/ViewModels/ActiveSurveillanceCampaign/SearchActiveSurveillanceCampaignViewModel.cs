
using EIDSS.Domain.RequestModels.Common;
using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Common;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.ActiveSurveillanceCampaign
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
