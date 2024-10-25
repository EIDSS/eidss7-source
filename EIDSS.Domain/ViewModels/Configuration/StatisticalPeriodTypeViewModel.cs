using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class StatisticalPeriodTypeViewModel : BaseModel
    {
        public long IdfsBaseReference { get; set; }
        public string StrDefault { get; set; }
    }
}
