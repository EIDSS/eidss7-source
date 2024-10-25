using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class SystemEventLogGetRequestModel : BaseGetRequestModel
    {
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
        public long? EventTypeId { get; set; }
        public long? @UserId { get; set; }
    }
}
