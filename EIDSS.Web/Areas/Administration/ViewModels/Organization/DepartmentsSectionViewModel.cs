using EIDSS.Domain.RequestModels.CrossCutting;
using EIDSS.Domain.ViewModels;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;

namespace EIDSS.Web.Areas.Administration.ViewModels.Organization
{
    public class DepartmentsSectionViewModel
    {
        /// <summary>
        /// Modal Id to Launch from Page Level Button
        /// </summary>
        public string AddDepartmentButtonModal { get; set; }

        /// <summary>
        /// Page button Text that Launches Modal
        /// </summary>
        public string AddDepartmentButtonModalText { get; set; }

        /// <summary>
        /// ID of Add Button On Page
        /// </summary>
        public string AddDepartmentButtonID { get; set; }

        public EIDSSGridConfiguration DepartmentsGridConfiguration { get; set; }
        public DepartmentSaveRequestModel DepartmentDetails { get; set; }
        public UserPermissions OrganizationAccessRightsUserPermissions { get; set; }
    }
}
