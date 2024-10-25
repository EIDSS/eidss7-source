using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Domain.ViewModels.Human;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Human.Person.ViewModels
{
    public class PersonSearchPageViewModel
    {
        public string PINSearchStatus { get; set; }

        public HumanPersonSearchRequestModel SearchCriteria { get; set; }

        public List<PersonViewModel> SearchResults { get; set; }

        public UserPermissions PersonsListPermissions { get; set; }

        public UserPermissions HumanDiseaseReportDataPermissions { get; set; }

        public LocationViewModel SearchLocationViewModel { get; set; }
        public IList<PersonViewModel> SelectedRecords { get; set; }
        public bool ShowSelectedRecordsIndicator { get; set; }

    }
}