using System;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Human
{
    public class HumanSampleForDiseasesRequestModel
    {
        public string LangId { get; set; }
        public long? idfsDiagnosis { get; set; }

        public int? AccessoryCode { get; set; }
    }
   
}