using System;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class HumanDiseaseReportLkupCaseClassificationResponseModel
    {
        public long idfsCaseClassification { get; set; }
        public string strDefault { get; set; }
        public string strName { get; set; }
        public int intOrder { get; set; }
        public bool blnInitialHumanCaseClassification { get; set; }
        public bool blnFinalHumanCaseClassification { get; set; }
        public int? intHACode { get; set; }
        public string strHACode { get; set; }
        public string strHACodeNames { get; set; }
    }
}
