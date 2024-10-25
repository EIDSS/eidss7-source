using Microsoft.EntityFrameworkCore;

namespace EIDSS.Repository.Contexts
{
    public class XSiteContextEnUS : XSiteContextBase
    {
        public XSiteContextEnUS(DbContextOptions<XSiteContextEnUS> options)
            : base(options)
        {
        }

        public override string LanguageCode => "en-US";
    }
}