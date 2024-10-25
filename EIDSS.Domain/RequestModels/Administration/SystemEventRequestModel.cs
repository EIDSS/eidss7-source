using EIDSS.CodeGenerator;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class SystemEventRequestModel
    {
        public SystemEventEnum EventId { get; set; }
        public string ClientId { get; set; }
        public long DiagnosisId { get; set; }
        public long LocationId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }


    }
}
