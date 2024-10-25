using EIDSS.Repository.ReturnModels;
using Microsoft.EntityFrameworkCore;

namespace EIDSS.Repository.Interfaces
{
    /// <summary>
    /// XSite context service
    /// </summary>
    public interface IXSiteContext
    {
        /// <summary>
        /// Indicates the language supported by this XSite instance, represented by either an ISO 3166  country code or 
        /// an ISO 639 language code or a combination of both.
        /// </summary>
        string LanguageCode { get; }

        DbSet<TContainer> TContainers { get; set; }
        DbSet<TContainersLayout> TContainersLayouts { get; set; }
        DbSet<TContainersType> TContainersTypes { get; set; }
        DbSet<TDocumentContainerMapping> TDocumentContainerMappings { get; set; }
        DbSet<TDocumentGroupMapping> TDocumentGroupMappings { get; set; }
        DbSet<TDocumentGroup> TDocumentGroups { get; set; }
        DbSet<TDocument> TDocuments { get; set; }
    }
}
