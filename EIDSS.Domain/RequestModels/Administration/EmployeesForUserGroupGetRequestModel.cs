using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class EmployeesForUserGroupGetRequestModel
    {
        public long? idfEmployeeGroup { get; set; }
        public string langId { get; set; }
        public long? Type { get; set; }
        public string Name { get; set; }
        public string Organization { get; set; }
        public string Description { get; set; }
        public int? pageNo { get; set; }
        public int? pageSize { get; set; }
        public string SortColumn { get; set; }
        public string SortOrder { get; set; }
        public string user { get; set; }
        public long? idfsSite { get; set; }
    }
}
