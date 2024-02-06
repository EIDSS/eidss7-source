namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class DiseasePensideTestMatrixGetRequestResponseModel
    {
        public int? TotalRowCount { get; set; }
        public long? idfPensideTestForDisease { get; set; }
        public long? idfsPensideTestName { get; set; }
        public string strPensideTestName { get; set; }
        public long? idfsDiagnosis { get; set; }
        public string strDisease { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}