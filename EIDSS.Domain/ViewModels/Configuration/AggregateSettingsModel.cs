using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    /// <summary>
    ///  AggregateSettingsModel
    /// </summary>
    public class AggregateSettingsModel: BaseModel
    {
        public long idfsAggrCaseType { get; set; }
        public long idfCustomizationPackage { get; set; }
        public long idfsStatisticAreaType { get; set; }
        public long idfsStatisticPeriodType { get; set; }
    }
}
