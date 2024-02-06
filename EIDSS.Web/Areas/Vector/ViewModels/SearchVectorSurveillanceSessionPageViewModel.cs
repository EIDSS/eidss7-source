using EIDSS.Domain.RequestModels.Vector;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Vector;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace EIDSS.Web.Areas.Vector.ViewModels
{
    public class SearchVectorSurveillanceSessionPageViewModel
    {
        public SearchVectorSurveillanceSessionPageViewModel()
        {
            SearchCriteria = new();
            VectorSurveillanceSessionPermissions = new();
        }
 
        public VectorSurveillanceSessionSearchRequestModel SearchCriteria { get; set; }
        public List<VectorSurveillanceSessionViewModel> SearchResults { get; set; }
        public UserPermissions VectorSurveillanceSessionPermissions { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }
        public LocationViewModel SearchExposureLocationViewModel { get; set; }
        public long BottomAdminLevel { get; set; }


    


    }

  

}
