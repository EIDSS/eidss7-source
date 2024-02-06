using System;
using System.Collections.Generic;
using System.Text;

namespace EIDSS.Domain.ViewModels
{
    // <summary>
    /// Container class for the list of organizations a user is employed by.
    /// </summary>
    public class UserOrganization
    {
        /// <summary>
        /// Identifier of the user organization.
        /// </summary>
        public Int64 RowID { get; set; }

        /// <summary>
        /// Identifier of the organiation the user is employed with.
        /// </summary>
        public Int64 OrganizationID { get; set; }

        public string StrOrganizationID { get; set; }


        /// <summary>
        /// The name of the organization the user is employed with.
        /// </summary>
        public string OrganizationName { get; set; }

        /// <summary>
        /// The name of the OrganizationFullName the user is employed with.
        /// </summary>
        public string OrganizationFullName { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public Int64? SiteGroupID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public Int64 SiteID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public Int64 SiteTypeID { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public Int64 EmployeeID { get; set; }

        /// <summary>
        /// Indicates if the user has access to gender and age data permission granted.
        /// </summary>
        public string UserGroup { get; set; }

        /// <summary>
        /// Indicates if this organization is the user's default.
        /// </summary>
        public bool DefaultOrganizationIndicator { get; set; }

        /// <summary>
        /// Indicates if this organization is currently selected by the user in the profile menu.
        /// </summary>
        public bool CurrentOrganizationIndicator { get; set; }

        /// <summary>
        /// Instantiates a new instance of the class.
        /// </summary>
        public UserOrganization()
        {
        }
    }
}
