using EIDSS.Repository.Contexts;
using EIDSS.Repository.Interfaces;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Repository
{
    /// <summary>
    /// XSite context helper service that manages configured language instances of the XSite help system.
    /// </summary>
    public interface IxSiteContextHelper
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
    public class xSiteContextHelper : IxSiteContextHelper
    {
        private List<IXSiteContext> ctxs = new List<IXSiteContext>();

        public xSiteContextHelper( xSiteContext_enus ctxuseng, xSiteContext_azl ctxaz, xSiteContext_kage ctxkage)
        {
            if (ctxuseng != null) ctxs.Add(ctxuseng);
            if (ctxaz != null) ctxs.Add(ctxaz);
            if (ctxkage != null) ctxs.Add(ctxkage);
        }
        /// <summary>
        /// Gets a language instance of the XSite help system.
        /// </summary>
        /// <param name="langCode">A valid language code.</param>
        /// <returns>Returns an instance of <see cref="IXSiteContext"/>.</returns>
        public IXSiteContext GetXSiteInstance(string langCode)
        {
            return ctxs.First(f => f.LanguageCode.ToLower() == langCode.ToLower());
        }
    }
}
