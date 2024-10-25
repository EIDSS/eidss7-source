using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class AdminUserListForUtilityViewModel
    {
        public long? RowNum { get; set; }
        public int? TotalCount { get; set; }
        public long idfPerson { get; set; }
        public string strAccountName { get; set; }
        public string strFirstName { get; set; }
        public string strFamilyName { get; set; }
        public string strSecondName { get; set; }
        public string Institution { get; set; }
        public long idfUserID { get; set; }
        public long? idfInstitution { get; set; }

        public string Site { get; set; }
        public long idfsSite { get; set; }
        public bool? DuplicateUsername { get; set; }
        public bool? Converted { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }

        public string GroupName { get; set; }
    }
}
