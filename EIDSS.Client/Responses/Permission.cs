using System;
using System.Collections.Generic;
using System.Text;

namespace EIDSS.ClientLibrary.Responses
{
    /// <summary>
    /// Specifies actions that a user is authorized to perform.
    /// </summary>
    public class Permission
    {
        /// <summary>
        /// Indicates the System Function Operation Identifier of this permission (System Function)
        /// </summary>
        public Int64 PermissionId { get;  set; }

        /// <summary>
        /// Indicates the type of action.
        /// </summary>
        public string PermissionType { get;  set; }

        /// <summary>
        /// Specifies the level of the action in more granularity.
        /// </summary>
        public List<PermissionLevel> PermissionLevels { get;  set; }

        /// <summary>
        /// Instantiates a new instance of the class.
        /// </summary>
        public Permission()
        {
            PermissionLevels = new List<PermissionLevel>();
        }


    }

    /// <summary>
    /// Specifies the lowest level of granularity of a permission and indicates if the account is authorized to create, write, read, etc.
    /// </summary>
    public class PermissionLevel
    {

        /// <summary>
        /// Represents the identifier for the permission level.
        /// </summary>
        public Int64 PermissionLevelId { get; internal set; }

        /// <summary>
        /// Indicates the permission level name, i.e., Create, Read, Write, etc.
        /// </summary>
        public string PermissionLevelName { get; internal set; }

        /// <summary>
        /// Instantiates a new instance of the class.
        /// </summary>
        /// <param name="id"></param>
        /// <param name="name"></param>
        public PermissionLevel(Int64 id, string name)
        {
            this.PermissionLevelId = id;
            this.PermissionLevelName = name;
        }
    }
}