using EIDSS.Domain.ViewModels;
using EIDSS.Localization.Helpers;
using EIDSS.Web.Abstracts;
using System.Collections.Generic;
using static System.String;

namespace EIDSS.Web.Components.HelpFiles
{
    public class HelpFileComponentViewModel : BaseComponent
    {
        public HelpFileComponentViewModel()
        {
            HelpFileUserPermissions = new UserPermissions();
            XSiteDocumentList = new List<XSiteDocumentListViewModel>();
            FileNames = new List<string>();
        }

        public long? SessionKey { get; set; }
        public bool IsReadonly { get; set; }

        public UserPermissions HelpFileUserPermissions;

        public List<XSiteDocumentListViewModel> XSiteDocumentList;
        public List<string> FileNames;

        public string FileName { get; set; } = Empty;
        public string URL { get; set; } = Empty;
        public string BaseURL { get; set; } = Empty;

        public string Area = Empty;
        public string SubArea = Empty;

        public string StrAction = Empty;
        public string Controller = Empty;

        [LocalizedRequired]
        public long? UserSiteID { get; set; }
        [LocalizedRequired]
        public long? UserOrganizationID { get; set; }
        [LocalizedRequired]
        public long? UserEmployeeID { get; set; }
        [LocalizedRequired]
        public long? EIDSSUserID { get; set; }
        public long? EIDSSMenuId { get; set; }
    }
}