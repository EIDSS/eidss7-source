using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class EmployeeUserGroupMemberSaveRequestResponseModel
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }

    }
}
