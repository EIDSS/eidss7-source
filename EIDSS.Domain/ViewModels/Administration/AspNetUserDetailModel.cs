using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public partial class AspNetUserDetailModel
    {
        public string Id { get; set; }
        public long idfsSite { get; set; }
        public long idfUserID { get; set; }
        public string Email { get; set; }
        public DateTimeOffset? LockoutEnd { get; set; }
        public bool LockoutEnabled { get; set; }
        public int AccessFailedCount { get; set; }
        public string UserName { get; set; }
        public long? idfPerson { get; set; }
        public string strFirstName { get; set; }
        public string strSecondName { get; set; }
        public string strFamilyName { get; set; }
        public long idfOffice { get; set; }
        public long Institution { get; set; }
        public string OfficeAbbreviation { get; set; }
        public string OfficeFullName { get; set; }
        public long? idfsRegion { get; set; }
        public long? idfsRayon { get; set; }
        public long? idfsSiteType { get; set; }
        public long? SiteGroupID { get; set; }
        public bool PasswordResetRequired { get; set; }
        public string strHASCsiteID { get; set; }
    }
}
