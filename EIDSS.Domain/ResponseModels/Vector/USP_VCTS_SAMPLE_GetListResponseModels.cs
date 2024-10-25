using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Vector
{
    public class USP_VCTS_SAMPLE_GetListResponseModels
    {
        public long? idfVector { get; set; }
        public long idfsVectorType { get; set; }
        public long idfsVectorSubType { get; set; }
        public long idfMaterial { get; set; }
        public long? idfRootMaterial { get; set; }
        public string strBarcode { get; set; }
        public string strFieldBarcode { get; set; }
        public long idfsSampleType { get; set; }
        public string strSampleName { get; set; }
        public DateTime? datFieldCollectionDate { get; set; }
        public long? idfSendToOffice { get; set; }
        public string strSendToOffice { get; set; }
        public long? idfFieldCollectedByOffice { get; set; }
        public string strFieldCollectedByOffice { get; set; }
        public DateTime? datFieldSentDate { get; set; }
        public DateTime? datEnteringDate { get; set; }
        public string strNote { get; set; }
        public DateTime? datAccession { get; set; }
        public long? idfsAccessionCondition { get; set; }
        public string strCondition { get; set; }
        public long? idfCase { get; set; }
        public long? idfVectorSurveillanceSession { get; set; }
        public string strVectorTypeName { get; set; }
        public string strVectorSubTypeName { get; set; }
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
        public int intQuantity { get; set; }
        public DateTime datCollectionDateTime { get; set; }
        public string strVectorID { get; set; }
        public int Used { get; set; }
        public string RecordAction { get; set; }
        public string Disease { get; set; }
        public long idfsDiagnosis { get; set; }
    }
}
