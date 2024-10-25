using System;
using System.Collections.Generic;
using System.Text;

namespace EIDSS.ClientLibrary.Responses
{
    /// <summary>
    /// Specifies actions that a user is granted at other sites as a part of configurable site filtration.
    /// </summary>
    public class AccessRulePermission
    {
        /// <summary>
        /// Identifier of the access rule.
        /// </summary>
        public Int64 AccessRuleID { get; set; }

        /// <summary>
        /// Identifier of the site.
        /// </summary>
        public Int64 SiteID { get; set; }

        /// <summary>
        /// Indicates if the user has read permission granted.
        /// </summary>
        public bool ReadPermissionIndicator { get; set; }

        /// <summary>
        /// Indicates if the user has access to personal data permission granted.
        /// </summary>
        public bool AccessToPersonalDataPermissionIndicator { get; set; }

        /// <summary>
        /// Indicates if the user has access to gender and age data permission granted.
        /// </summary>
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }

        /// <summary>
        /// Indicates if the user has write permission granted.
        /// </summary>
        public bool WritePermissionIndicator { get; set; }

        /// <summary>
        /// Indicates if the user has delete permission granted.
        /// </summary>
        public bool DeletePermissionIndicator { get; set; }

        /// <summary>
        /// Instantiates a new instance of the class.
        /// </summary>
        public AccessRulePermission()
        {
        }
    }
}