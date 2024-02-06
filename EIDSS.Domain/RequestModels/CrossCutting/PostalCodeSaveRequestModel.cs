using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class PostalCodeSaveRequestModel
    {
        public string strPostCode { get; set; }
        public long idfsLocation { get; set; }
        public long? idfPostalCode { get; set; }
        public string user { get; set; }
   }
  
}
