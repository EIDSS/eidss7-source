using EIDSS.Domain.RequestModels.Veterinary;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Veterinary;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.Veterinary.ActiveSurveillanceSession
{
    public class SearchActiveSurveillanceSessionPageViewModel
    {
        public SearchActiveSurveillanceSessionPageViewModel()
        {
            SearchCriteria = new();
            ActiveSurveillanceSessionPermissions = new();
        }
 
        public VeterinaryActiveSurveillanceSessionSearchRequestModel SearchCriteria { get; set; }
        public List<VeterinaryActiveSurveillanceSessionViewModel> SearchResults { get; set; }
        public UserPermissions ActiveSurveillanceSessionPermissions { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public long BottomAdminLevel { get; set; }


    }

  

}
