using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SecurityEventLogSaveRequestModel
    {
        public long? IdfUserId { get; set; }
        public long IdfsAction { get; set; }
        public bool ResultFlag { get; set; }
        public long? IdfObjectId { get; set; }
        public long? IdfsProcessType { get; set; }
        public string StrErrorText { get; set; }
        public string StrDescription { get; set; }
        public long IdfSiteId { get; set; }

	}
}
