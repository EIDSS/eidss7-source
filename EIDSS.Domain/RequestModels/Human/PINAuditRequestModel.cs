using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Human
{
    public class PINAuditRequestModel
    {
        public string strPIN { get; set; }
        public long idfUser { get; set; }
        public long idfsSite { get; set; }

        public long? idfHumanCase { get; set; }
        public long? idfH0Form { get; set; }
        
        public DateTime? datEIDSSAccessAttempt { get; set; }
        public DateTime? datPINAccessAttempt { get; set; }

    }
}
