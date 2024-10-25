using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Vector
{
   public class USP_VCTS_VECT_SET_ResponseModel
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public long? idfVector { get; set; }
        public string strVectorID { get; set; }
        public long? idfDetailedLocation { get; set; }
    }
}
