using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Domain.ViewModels.CrossCutting;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;
using EIDSS.Web.ViewModels.Administration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels
{
    public class EmployeePageViewModel
    {

        public List<Select2Configruation> Select2Configurations { get; set; }
        public List<EmployeeListViewModel> EmployeeList { get; set; }

        public List<string> basereferenceTypes { get; set; }


        EIDSSGridConfiguration _gridViewComponentBuilder;

        /// <summary>
        /// Defines The Grid for the Model
        /// </summary>
        public EIDSSGridConfiguration eidssGridConfiguration { get { return _gridViewComponentBuilder; } set { _gridViewComponentBuilder = value; } }

        /// <summary>
        /// Defines Modal For Model
        /// </summary>
        public List<EIDSSModalConfiguration> eIDSSModalConfiguration { get; set; }

        /// <summary>
        /// Modal Id to Launch from Page Level Button
        /// </summary>
        public string PageLevelAddButtonModal { get; set; }

        /// <summary>
        /// Page button Text that Launches Modal
        /// </summary>
        public string PageLevelAddButtonModalText { get; set; }

        /// <summary>
        /// ID of Add Button On Page
        /// </summary>
        public string PageLevelAddButtonID { get; set; }

        public SearchActorViewModel SearchActorViewModel { get; set; }
        public bool ReadPermissionIndicator { get; set; }

        public UserPermissions UserPermissions { get; set; }

        public UserPermissions AddEmployeeUserPermissions { get; set; }

        public SystemFunctionsPagesViewModel SystemFunctionPageViewModel { get; set; }


    }
}
