using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Vector
{
    public class USP_VCTS_VECT_GetDetailResponseModel
    {


        public int? TotalRowCount { get; set; }
        public long idfVector { get; set; }
        public long? idfVectorSurveillanceSession { get; set; }
        public string strSessionID { get; set; }
        public long idfsVectorType { get; set; }
        public string strVectorType { get; set; }
        public string strSpecies { get; set; }
        public long? idfsSex { get; set; }
        public string strSex { get; set; }
        public long idfsVectorSubType { get; set; }
        public string strVectorID { get; set; }
        public string strFieldVectorID { get; set; }
        public int? intCollectionEffort { get; set; }
        public DateTime datCollectionDateTime { get; set; }
        public string strRegion { get; set; }
        public string strRayon { get; set; }
        public string strComment { get; set; }
        public long? AdminLevel0Value { get; set; }
        public string AdminLevel0Text { get; set; }
        public long? AdminLevel1Value { get; set; }
        public string AdminLevel1Text { get; set; }
        public long? AdminLevel2Value { get; set; }
        public string AdminLevel2Text { get; set; }
        public long? AdminLevel3Value { get; set; }
        public string AdminLevel3Text { get; set; }
        public long? AdminLevel4Value { get; set; }
        public string AdminLevel4Text { get; set; }
        public long? AdminLevel5Value { get; set; }
        public string AdminLevel5Text { get; set; }
        public long? AdminLevel6Value { get; set; }
        public string AdminLevel6Text { get; set; }
        public string CollectedByInstitution { get; set; }
        public string Disease { get; set; }
        public string FieldSampleID { get; set; }
        public string SampleType { get; set; }
        public DateTime ResultDate { get; set; }
        public string TestName { get; set; }
        public string TestResult { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
