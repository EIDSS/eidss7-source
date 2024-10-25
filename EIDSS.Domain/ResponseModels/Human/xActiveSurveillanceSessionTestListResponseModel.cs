using System;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class xActiveSurveillanceSessionTestListResponseModel
    {
        public int? TotalRowCount { get; set; }
        public long? ID { get; set; }
        public string LabSampleID { get; set; }
        public string FieldSampleID { get; set; }
        public string SampleType { get; set; }
        public long? SampleTypeID { get; set; }
        public string PersonID { get; set; }
        public string TestName { get; set; }
        public long? TestNameID { get; set; }
        public string Diagnosis { get; set; }
        public long? DiseaseID { get; set; }
        public string TestCategory { get; set; }
        public long? TestCategoryID { get; set; }
        public string TestResult { get; set; }
        public long? TestResultID { get; set; }
        public string TestStatus { get; set; }
        public long? TestStatusID { get; set; }
        public DateTime? ResultDate { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
