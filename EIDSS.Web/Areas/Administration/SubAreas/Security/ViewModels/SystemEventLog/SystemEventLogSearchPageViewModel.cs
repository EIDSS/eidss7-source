using System.Collections.Generic;
using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Domain.ViewModels.CrossCutting;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SystemEventLog
{
    public class SystemEventLogSearchPageViewModel
    {

        public SystemEventLogGetRequestModel SearchCriteria { get; set; }

        public List<SystemEventLogGetListViewModel> SearchResults { get; set; }

        public UserPermissions Permissions { get; set; }

        public IEnumerable<EmployeeListViewModel> UserList;

        public IEnumerable<BaseReferenceViewModel> EventType;

        public IList<SystemEventLogGetListViewModel> SelectedRecords { get; set; }

        public bool ShowSelectedRecordsIndicator { get; set; }
    }
}


