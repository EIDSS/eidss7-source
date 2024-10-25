using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class USP_CONF_USER_GRIDS_GETDETAILResponseModel
    {
        public long? idfUserID { get; set; }
        public long? idfsSite { get; set; }
        public string ColumnDefinition { get; set; }
        public string GridID { get; set; }
        public Guid? rowguid { get; set; }
        public int intRowStatus { get; set; }
    }
}
