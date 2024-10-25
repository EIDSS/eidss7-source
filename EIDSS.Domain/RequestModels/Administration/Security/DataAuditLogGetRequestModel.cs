using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public  class DataAuditLogGetRequestModel : BaseGetRequestModel
    {
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public long? IdfUserId { get; set; }
        public long? IdfSiteId { get; set; }
        public long? IdfActionId { get; set; }
        public long? IdfObjetType { get; set; }
        //[Range(1, 9223372036854775807)]
        public string IdfObjectId { get; set; }

    }

}
