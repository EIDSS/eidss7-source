using EIDSS.Domain.ViewModels;
using System.Runtime.Serialization;

namespace EIDSS.Domain.Abstracts
{
    /// <summary>
    /// Base model that all EIDSS view models derive
    /// </summary>
    [DataContract]
    public abstract class BaseModel
    {
        /// <summary>
        /// A boolean that indicates if the data is archived data.
        /// </summary>
        public bool IsArchivedData { get; set; } = false;

        /// <summary>
        /// Indicates the total number of records the query produced, but may not indicate the total
        /// contained within this modal.
        /// </summary>
        public int TotalRowCount { get; set; }

        /// <summary>
        /// Indicates the total number of pages of data the query produced.
        /// </summary>
        public int TotalPages { get; set; }

        /// <summary>
        /// Indicates the curent page of data.
        /// </summary>
        public int CurrentPage { get; set; }

        public UserPermissions UserPermissions { get; set; }

        /// <summary>
        /// Editor set to use on shared view components that are called by a page and a modal or from different modules.
        /// </summary>
        public int InterfaceEditorSet { get; set; }
    }
}