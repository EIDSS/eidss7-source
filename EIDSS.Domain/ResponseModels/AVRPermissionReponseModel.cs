using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels
{
    public partial class AVRPermissionResponseModel
    {
        public long idfEmployee { get; set; }
        public long idfUserID { get; set; }
        public long idfsSite { get; set; }
        public string strFirstName { get; set; }
        public string strFamilyName { get; set; }
        public string GroupName { get; set; }
        public string ObjectType { get; set; }
        public long idfObjectOperation { get; set; }
        public string ObjectOperation { get; set; }
    }
}
