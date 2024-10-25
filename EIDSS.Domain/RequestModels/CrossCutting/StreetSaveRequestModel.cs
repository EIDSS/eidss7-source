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
    public class StreetSaveRequestModel 
    {
        public string StrStreetName { get; set; }
        public long AdminLevelId   { get; set; }
        public long? StreetId { get; set; }
        public string User  { get; set; }


    }



    
}
