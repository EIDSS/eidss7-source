using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SecurityEventLog
{
    public class SecurityEventLogSearchPageViewModel
    {
        public SecurityEventLogGetRequestModel SearchCriteria { get; set; }

        public List<SecurityEventLogGetListViewModel> SearchResults { get; set; }

        public UserPermissions Permissions { get; set; }

        public IEnumerable<EmployeeListViewModel> UserList;

        public IEnumerable<BaseReferenceViewModel> ActionList;

        public IEnumerable<BaseReferenceViewModel> ProcessTypeList;

        public IEnumerable<BaseReferenceViewModel> ResultList;

        public IList<SecurityEventLogGetListViewModel> SelectedRecords { get; set; }

        public bool ShowSelectedRecordsIndicator { get; set; }

    }
}
