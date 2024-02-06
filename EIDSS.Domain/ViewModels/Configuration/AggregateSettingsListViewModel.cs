using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.CrossCutting;
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
    public class AggregateSettingsListViewModel : BaseModel
    {
        public List<AggregateSettingsViewModel> AggregateSettings { get; set; }

        public List<BaseReferenceViewModel> AreaType { get; set; }
        public List<BaseReferenceViewModel> PeriodType { get; set; }

        public bool AccessToAggregateSettingsRead { get; set; }

        public bool AccessToAggregateSettingsWrite { get; set; }

        public bool AccessToHumanAggregateCaseRead { get; set; }

        public bool AccessToHumanAggregateCaseWrite { get; set; }

        public bool AccessToVetAggregateCaseRead { get; set; }

        public bool AccessToVetAggregateCaseWrite { get; set; }

        public bool AccessToVetAggregateActionRead { get; set; }

        public bool AccessToVetAggregateActionWrite { get; set; }
        public Dictionary<string,UserPermissions> permissions { get; set; }
    }
}
