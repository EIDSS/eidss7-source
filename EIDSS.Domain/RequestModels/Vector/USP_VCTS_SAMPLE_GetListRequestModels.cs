using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Vector
{
    public class USP_VCTS_SAMPLE_GetListRequestModels
    {
        public long idfVector { get; set; }
        public long? idfMaterial { get; set; }
        public string LangID { get; set; }
    }
}
