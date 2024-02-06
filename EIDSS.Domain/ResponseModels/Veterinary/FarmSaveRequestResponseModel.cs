using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Veterinary
{
    public class FarmSaveRequestResponseModel : APIPostResponseModel
    {
        public long? SessionKey { get; set; }
        public string SessionID { get; set; }

    }
}


