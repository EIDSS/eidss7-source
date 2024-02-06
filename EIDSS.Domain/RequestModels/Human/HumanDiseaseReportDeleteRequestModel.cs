using System;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Human
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class HumanDiseaseReportDeleteRequestModel
    {
       public string LangID { get; set; }
       public  long? idfHumanCase { get; set; }
    }
   
}