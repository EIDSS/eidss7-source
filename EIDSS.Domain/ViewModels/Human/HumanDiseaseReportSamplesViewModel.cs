using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ViewModels.Human
{
    public class HumanDiseaseReportSamplesViewModel : BaseModel
    {
        public long idfHumanCase { get; set; }
        public long? idfMaterial { get; set; }
        public string strBarcode { get; set; }
        public string strFieldBarcode { get; set; }
        public long? idfsSampleType { get; set; }
        public string strSampleTypeName { get; set; }
        public DateTime? datFieldCollectionDate { get; set; }
        public long? idfSendToOffice { get; set; }
        public string strSendToOffice { get; set; }
        public long? idfFieldCollectedByOffice { get; set; }
        public string strFieldCollectedByOffice { get; set; }
        public DateTime? datFieldSentDate { get; set; }
        public string strNote { get; set; }
        public DateTime? datAccession { get; set; }
        public long? idfsAccessionCondition { get; set; }
        public string strCondition { get; set; }
        public long? idfsRegion { get; set; }
        public string strRegionName { get; set; }
        public long? idfsRayon { get; set; }
        public string strRayonName { get; set; }
        public bool? blnAccessioned { get; set; }
        public long? idfsSampleKind { get; set; }
        public string SampleKindTypeName { get; set; }
        public long? idfsSampleStatus { get; set; }
        public string SampleStatusTypeName { get; set; }
        public long? idfFieldCollectedByPerson { get; set; }
        public string strFieldCollectedByPerson { get; set; }
        public DateTime? datSampleStatusDate { get; set; }
        public string sampleGuid { get; set; }

        public int intRowStatus { get; set; }

        public int? blnNumberingSchema { get; set; } = 0;

        public long? idfsSite { get; set; }

        public long? FunctionalAreaID { get; set; }
        public string FunctionalAreaName { get; set; }

        public long? DiseaseID { get; set; }
    }
}
