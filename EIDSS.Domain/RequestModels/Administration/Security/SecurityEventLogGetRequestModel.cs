using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class SecurityEventLogGetRequestModel : BaseGetRequestModel
    {

        public DateTime? ActionStartDate { get; set; }
        public DateTime? ActionEndDate { get; set; }
        public long? Action { get; set; }
        public long? ProcessType { get; set; }
        public long? ResultType { get; set; }
        public long? ObjectId { get; set; }
        public long? UserId { get; set; }
        public string ErrorText { get; set; }
        public string ProcessId { get; set; }
        public string Description { get; set; }

    }
}
