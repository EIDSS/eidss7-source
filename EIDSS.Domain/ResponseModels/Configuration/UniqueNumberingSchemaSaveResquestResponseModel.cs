using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class UniqueNumberingSchemaSaveResquestResponseModel : APIPostResponseModel
    {        
        public string StrDuplicatedField { get; set; }
        public string StrInvalidRange { get; set; }
    }
}
