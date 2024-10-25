using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration.Security
{
    public  class DataAuditRestoreResponseModel : APIPostResponseModel
    {
        public int? RecordStatus { get; set; }
    }
}
