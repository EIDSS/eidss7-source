using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class InvestigationTypeViewModel : BaseModel
    {
        public long IdfsBaseReference { get; set; }
        public string StrDefault { get; set; }
        public string StrName { get; set; }
        public long IntOrder { get; set; }
    }
}
