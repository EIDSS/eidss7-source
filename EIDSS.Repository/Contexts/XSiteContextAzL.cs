using Microsoft.EntityFrameworkCore;

namespace EIDSS.Repository.Contexts
{
    public class XSiteContextAzL : XSiteContextBase
    {
        public XSiteContextAzL(DbContextOptions<XSiteContextAzL> options)
            : base(options)
        {
        }

        public override string LanguageCode => "az-Latn-AZ";
    }
}
