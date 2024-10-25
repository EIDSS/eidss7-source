using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Veterinary
{
    public class FarmDedupeResponseModel
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public string StrDuplicateField { get; set; }
        public long? SessionKey { get; set; }
        public string SessionID { get; set; }
    }
}
