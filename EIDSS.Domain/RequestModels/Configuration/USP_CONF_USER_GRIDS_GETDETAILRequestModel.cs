using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class USP_CONF_USER_GRIDS_GETDETAILRequestModel
    {
        public long? idfUserID { get; set; }
        public string GridID { get; set; }
    }
}
