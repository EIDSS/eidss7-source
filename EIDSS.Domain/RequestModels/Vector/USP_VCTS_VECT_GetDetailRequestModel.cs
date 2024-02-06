using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Vector
{
    public class USP_VCTS_VECT_GetDetailRequestModel
    {
       public long? idfVectorSurveillanceSession { get; set; }
        public string LangID { get; set; }

        public bool? bitCollectionByPool { get; set; }
        public string SortColumn { get; set; }
        public string SortOrder { get; set; }
        public int? PageNumber { get; set; }
        public int? PageSize { get; set; }
    }
}
