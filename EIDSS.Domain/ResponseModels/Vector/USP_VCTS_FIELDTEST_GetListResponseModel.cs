using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Vector
{
    public class USP_VCTS_FIELDTEST_GetListResponseModel
    {
        public long idfTesting { get; set; }
        public string strFieldBarcode { get; set; }
        public long? idfsTestName { get; set; }
        public string strTestName { get; set; }
        public long? idfsTestCategory { get; set; }
        public string strTestCategoryName { get; set; }
        public long? idfTestedByOffice { get; set; }
        public string strTestedByOfficeName { get; set; }
        public long? idfsTestResult { get; set; }
        public string strTestResultName { get; set; }
        public long? idfTestedByPerson { get; set; }
        public string strTestedByPersonName { get; set; }
        public long idfsDiagnosis { get; set; }
        public string strDiagnosisName { get; set; }
        public string RecordAction { get; set; }
        public long idfsSampleType { get; set; }
        public string SampleType { get; set; }
        public DateTime?  datReceivedDate { get; set; }
        public DateTime? datConcludedDate { get; set; }
        public int intRowStatus { get; set; }
        public long idfVector { get; set; }
        public long idfMaterial { get; set; }
        public bool blnNonLaboratoryTest { get; set; }
        public bool blnExternalTest { get; set; }
    }


}
