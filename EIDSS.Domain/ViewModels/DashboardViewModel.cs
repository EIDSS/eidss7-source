using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels
{
    public class DashboardViewModel
    {
        public long userId { get; set; }

        [Display(Name = "Language")]
        public string languageId { get; set; }

        //public List<MenuViewModel> menuList { get; set; }

        //public List<MenuViewModel> parentMenuList { get; set; }

        public List<MenuByUserViewModel> menuList { get; set; }

        public List<MenuByUserViewModel> parentMenuList { get; set; }

        public List<LanguageModel> LanguageModels { get; set; }

        public string AreaName { get; set; } = "Administration";
        public string ActionName { get; set; } = "SystemPreferenceSettings";

        public string UserName { get; set; }
        public string OrganizationName { get; set; }
        public Int64 OrganizationID { get; set; }

        public string StrOrganizationID { get; set; }


        public List<UserOrganization> UserOrganizations { get; set; }

        public bool CanReadArchivedData { get; set; }

        public string MenuIdExclusionList { get; set; }

        public bool IsInArchiveMode { get; set; }

        public bool ReadAccessToReports  { get; set; }
        public bool ReadAccessToHDRData { get; set; }
        public bool ReadAccessToVDRData { get; set; }
        public bool AccessoryCodeChecked { get; set; }


        public Dictionary<string, string> PaperFormMenuFileNames { get; set; }


    }


}
