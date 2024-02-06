using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class EmployeeOrganizationSaveRequestModel
    {
        public string aspNetUserId { get; set; }
        public long? idfUserId { get; set; }
        public bool? IsDefault { get; set; }
        public int? intRowStatus { get; set; }
        public bool? active { get; set; }
    }
}
