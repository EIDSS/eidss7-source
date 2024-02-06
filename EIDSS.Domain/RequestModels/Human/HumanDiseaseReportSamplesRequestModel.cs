using System;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Human
{
    public class HumanDiseaseReportSamplesRequestModel 
    {
        public string LangID { get; set; }
        public  long? idfHumanCase { get; set; }
        public long? SearchDiagnosis { get; set; }
    }
   
}