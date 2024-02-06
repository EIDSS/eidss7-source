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
    public class AggregateSettingsViewModel: BaseModel
    {
        public int rownum { get; set; }
        public long idfsAggrCaseType { get; set; }
        public long idfCustomizationPackage { get; set; }
        public long idfsStatisticAreaType { get; set; }
        public long idfsStatisticPeriodType { get; set; }
        public string StrCaseType { get; set; }
        public string StrAreaType { get; set; }
        public string StrPeriodType { get; set; }
    }
}
