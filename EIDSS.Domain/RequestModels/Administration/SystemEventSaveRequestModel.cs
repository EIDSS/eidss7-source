using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SystemEventSaveRequestModel
    {
        public string UserName { get; set; }
        public long? idfsEventTypeId { get; set; }
        public long? idfObjectId { get; set; }
        public string strInformationString { get; set; }
        public string strNote { get; set; }
        public string ClientID { get; set; }
        public DateTime? datEventDatatime { get; set; }
        public int? intProcessed { get; set; }
        public long? idfUserID { get; set; }
        public long? idfsSite { get; set; }
        public long? idfsDiagnosis { get; set; }

    }
}
