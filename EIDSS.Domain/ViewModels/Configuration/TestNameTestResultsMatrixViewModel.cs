using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class TestNameTestResultsMatrixViewModel : BaseModel
    {
        public long? idfsTestName { get; set; }
        public string strTestNameDefault { get; set; }
        public string strTestName { get; set; }
        public long? idfsTestResult { get; set; }
        public string strTestResultDefault { get; set; }
        public string strTestResultName { get; set; }
        public bool? blnIndicative { get; set; }
    }
}

