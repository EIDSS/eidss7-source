using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EIDSS.Domain.RequestModels.Administration;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;

namespace EIDSS.Web.Areas.Administration.ViewModels.Administration
{
    public class AdministrativeUnitsPageViewModel
    {

        public AdministrativeUnitsSearchRequestModel  SearchCriteria { get; set; }
        public string InformationalMessage { get; set; }
        public UserPermissions Permissions { get; set; }
        public bool RecordSelectionIndicator { get; set; }
        public LocationViewModel SearchLocationViewModel { get; set; }




    }
}
