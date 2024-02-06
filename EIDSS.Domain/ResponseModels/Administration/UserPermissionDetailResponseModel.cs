using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class UserPermissionDetailResponseModel
    {
        public long idfObjectAccess { get; set; }

        public string FunctionName { get; set; }
        public Nullable<long> idfsObjectOperation { get; set; }

        public string ObjectOperationName { get; set; }
        public Nullable<long> idfsObjectType { get; set; }
        public Nullable<long> idfsObjectID { get; set; }
        public Nullable<long> idfsSite { get; set; }
        public string strSiteID { get; set; }
        public string strSiteName { get; set; }
        public Nullable<long> idfEmployee { get; set; }
        public Nullable<bool> isAllow { get; set; }
        public Nullable<bool> isDeny { get; set; }
    }
}
