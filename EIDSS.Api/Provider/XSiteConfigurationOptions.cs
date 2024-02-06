using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Api.Provider
{
    public class XSiteConfigurationOptions
    {
        public const string SectionName = "XSite";
        public virtual List<XSiteLanguageConfiguration> LanguageConfigurations { get; set; } = new List<XSiteLanguageConfiguration>();
    }

    public class XSiteLanguageConfiguration
    {
        private string[] isosynonyms;
        public virtual string CountryISOCode { get; set; }
        public virtual string DataDirectory { get; set; }
        public virtual string ConnectionString { get; set; }
        public virtual bool Default { get; set; }
        public virtual string ISOSynonym { get; set; }

    }

}