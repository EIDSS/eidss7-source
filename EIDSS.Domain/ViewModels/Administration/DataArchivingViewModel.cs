using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class DataArchivingViewModel
    {
        public long? archiveSettingUID { get; set; }
        public DateTime? archiveBeginDate { get; set; }
        public string archiveScheduledStartTime { get; set; }
        public int? dataAgeforArchiveInYears { get; set; }
        public int? archiveFrequencyInDays { get; set; }
        public int? intRowStatus { get; set; }
        public string auditCreateUser { get; set; }
        public DateTime? auditCreateDTM { get; set; }
        public string auditUpdateUser { get; set; }
        public DateTime? auditUpdateDTM { get; set; }
    }
}
