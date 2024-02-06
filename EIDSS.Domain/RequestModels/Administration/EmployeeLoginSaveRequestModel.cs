using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class EmployeeLoginSaveRequestModel
    {
        public long? idfEmployee { get; set; }

        public long? idfsPersonSite { get; set; }

        public string strAccountName { get; set; }

        public byte[] binPassword { get; set; }
        
    }
}
