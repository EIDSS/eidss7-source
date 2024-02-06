using System;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Human
{
    public class HumanDiseaseContactListRequestModel
    {
        public string LangId { get; set; }
        public long? idfHumanCase { get; set; }

  }
   
}