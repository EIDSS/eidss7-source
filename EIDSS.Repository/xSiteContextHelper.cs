using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;

namespace EIDSS.Repository
{
    /// <summary>
    /// XSite context helper service that manages configured language instances of the XSite help system.
    /// </summary>
    public interface IXSiteContextHelper
    {
        /// <summary>
        /// Gets a language instance of the XSite help system.
        /// </summary>
        /// <param name="langCode">A valid language code.</param>
        /// <returns>Returns an instance of <see cref="IXSiteContext"/>.</returns>
        IXSiteContext GetXSiteInstance(string langCode);
    }

    /// <summary>
    /// XSite context helper service that manages configured language instances of the XSite help system.
    /// </summary>
    public class XSiteContextHelper : IXSiteContextHelper
    {
        private readonly XSiteContextEnUS _contextsEnUS;
        private readonly List<IXSiteContext> contexts = new();

        public XSiteContextHelper(
            XSiteContextEnUS contextsEnUS,
            XSiteContextAzL contextsAzL,
            XSiteContextKaGe contextsKaGe)
        {
            _contextsEnUS = contextsEnUS;

            if (contextsEnUS != null) contexts.Add(contextsEnUS);
            if (contextsAzL != null) contexts.Add(contextsAzL);
            if (contextsKaGe != null) contexts.Add(contextsKaGe);
        }
        /// <summary>
        /// Gets a language instance of the XSite help system.
        /// </summary>
        /// <param name="langCode">A valid language code.</param>
        /// <returns>Returns an instance of <see cref="IXSiteContext"/>.</returns>
        public IXSiteContext GetXSiteInstance(string langCode)
        {
            return contexts.FirstOrDefault(f => f.LanguageCode.Equals(langCode, StringComparison.InvariantCultureIgnoreCase)) ?? _contextsEnUS;
        }
    }
}
