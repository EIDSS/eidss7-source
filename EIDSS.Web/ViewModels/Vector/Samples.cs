using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels.Vector
{
    public class Samples
    {
        public string FieldSampleID { get; set; }
        public string SampleTypeName { get; set; }
        public long? idfSampleType { get; set; }
        public string Disease { get; set; }
        public long? idfdiagnosis { get; set; }
        public DateTime? CollectionDate { get; set; }
        public string SentToOrganization { get; set; }
        public long?  idfToOrganization { get; set; }
        public string CollectedByInstitution { get; set; }
        public long?idfCollectedByInstitution { get; set; }
        public string Comment { get; set; }
        public DateTime? AccessionDate { get; set; }
        public string SampleConditionReceived { get; set; }
        public long? idfSampleConditionReceived { get; set; }
        public long? SampleType { get; set; }
        public bool IsSampleModel { get; set; } = true;
        public string DialogName { get; set; }
        public long idfMaterial { get; set; }
    }

    public class SaveSampleModel
    {
        public string LangID { get; set; }
        public long idfMaterial { get; set; }
        public string strFieldBarcode { get; set; }
        public long idfsSampleType { get; set; }
        public long idfVectorSurveillanceSession { get; set; }
        public long? idfVector { get; set; }
        public long idfSendToOffice { get; set; }
        public long idfFieldCollectedByOffice { get; set; }
        public string strNote { get; set; }
        public DateTime? datFieldCollectionDate { get; set; }
        public DateTime? EnteredDate { get; set; }
        public long SiteID { get; set; }
        public long idfsDiagnosis { get; set; }
        public int intRowStatus { get; set; }
        public string RowAction { get; set; }
    }
}
