using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class AdminUserListForUtilityRequestModel
    {
        public string advancedSearch { get; set; }
        public long? idfsSite { get; set; }
        public long? idfInstitution { get; set; }
        public int? pageNo { get; set; }
        public int? pageSize { get; set; }
        public bool? showUnconvertedOnly { get; set; }
        public string sortColumn { get; set; }
        public string sortOrder { get; set; }

    }
}
