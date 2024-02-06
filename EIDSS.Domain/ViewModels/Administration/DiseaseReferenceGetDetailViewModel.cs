namespace EIDSS.Domain.ViewModels.Administration
{
    public class DiseaseReferenceGetDetailViewModel
    {
        public long idfsDiagnosis { get; set; }
        public string strDefault { get; set; }
        public string strName { get; set; }
        public string strIDC10 { get; set; }
        public string strOIECode { get; set; }
        public string strSampleType { get; set; }
        public string strSampleTypeNames { get; set; }
        public string strLabTest { get; set; }
        public string strLabTestNames { get; set; }
        public string strPensideTest { get; set; }
        public string strPensideTestNames { get; set; }
        public string strHACode { get; set; }
        public string strHACodeNames { get; set; }
        public long idfsUsingType { get; set; }
        public string strUsingType { get; set; }
        public int? intHACode { get; set; }
        public int intRowStatus { get; set; }
        public bool blnZoonotic { get; set; }
        public bool? blnSyndrome { get; set; }
        public int? intOrder { get; set; }
    }
}
