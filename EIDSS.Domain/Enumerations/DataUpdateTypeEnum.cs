using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.Enumerations
{
    /// <summary>
    /// Decorated on save and update models to signal the audit infrastructure what type of state change is occuring.
    /// </summary>
    public enum DataUpdateTypeEnum
    {
        /// <summary>
        /// Indicates that this is a fetch operation...
        /// </summary>
        Fetch = 0,

        Create = 10016001,

         /// <summary>
         /// Indicates that this is an update operation...
         /// </summary>
        Update = 10016003,

        /// <summary>
        /// Indicates that this is a delete operation...
        /// </summary>
        Delete = 10016002,

        Restore = 10016005,

        FreeDataUpdate = 10016004
    }
}
