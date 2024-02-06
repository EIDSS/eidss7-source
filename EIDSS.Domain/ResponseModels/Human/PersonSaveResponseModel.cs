using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class PersonSaveResponseModel : APIPostResponseModel
    {
        public long? HumanMasterID { get; set; }
        public string EIDSSPersonID { get; set; }
        public long? HumanID { get; set; }
        public string DuplicateMessage { get; set; }
        public long? SessionKey { get; set; }
        public string SessionID { get; set; }
    }
}
