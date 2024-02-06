using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Vector
{
    public class USP_VCTS_VecSessionSummary_GETListResponseModel
    {
        public long? idfsVSSessionSummary { get; set; }
        public long? idfVectorSurveillanceSession { get; set; }
        public string strVSSessionSummaryID { get; set; }
        public long? idfGeoLocation { get; set; }
        public string Country { get; set; }
        public string Region { get; set; }
        public string Rayon { get; set; }
        public string Settlement { get; set; }
        public DateTime? datCollectionDateTime { get; set; }
        public long? idfsVectorType { get; set; }
        public string strVectorType { get; set; }
        public long? idfsVectorSubType { get; set; }
        public string strVectorSubType { get; set; }
        public long? idfsSex { get; set; }
        public string strSex { get; set; }
        public long? intQuantity { get; set; }
        public int? intRowStatus { get; set; }
        public string intPositiveQuantity { get; set; }
    }
}
