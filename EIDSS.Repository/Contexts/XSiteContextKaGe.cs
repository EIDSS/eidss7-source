using Microsoft.EntityFrameworkCore;

namespace EIDSS.Repository.Contexts
{
    public class XSiteContextKaGe : XSiteContextBase
    {
        public XSiteContextKaGe(DbContextOptions<XSiteContextKaGe> options)
            : base(options)
        {
        }

        public override string LanguageCode => "ka-GE";
    }
}
