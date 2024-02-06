using System;

namespace EIDSS.Domain.ResponseModels.Vector
{
    public class USP_VCTS_LABTEST_GetListResponseModel
    {
        public long idfTesting { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public string strFieldSampleID { get; set; }
        public string strSampleTypeName { get; set; }
        public string strSpeciesName { get; set; }
        public string strTestName { get; set; }
        public string strTestResultName { get; set; }
        public DateTime? datConcludedDate { get; set; }
        public string strDiseaseName { get; set; }
        public int TotalRowCount { get; set; }

    }
}
