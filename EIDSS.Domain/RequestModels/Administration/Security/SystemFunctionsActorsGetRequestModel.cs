using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class SystemFunctionsActorsGetRequestModel:BaseGetRequestModel
    {
        public long Id { get; set; }
        public string Name { get; set; }
        public long? UserSiteID { get; set; }
        public long UserOrganizationID { get; set; }
        public long UserEmployeeID { get; set; }
    }
}
