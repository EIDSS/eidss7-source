using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class SecurityConfigurationViewModel
    {
        public int SecurityPolicyConfigurationUID { get; set; }

        [LocalizedRequired]
        [LocalizedRangeFrom("8","128")]
        public int MinPasswordLength { get; set; }

        [LocalizedRequired]
        [LocalizedRangeFrom("12", "100")]
        public int? EnforcePasswordHistoryCount { get; set; }

        [LocalizedRequired]
        [LocalizedRangeFrom("1", "365")]
        public int? MinPasswordAgeDays { get; set; } = 60;

        [LocalizedRequired]
        public bool ForceUppercaseFlag { get; set; }

        [LocalizedRequired]
        public bool ForceLowercaseFlag { get; set; }

        [LocalizedRequired]
        public bool ForceNumberUsageFlag { get; set; } 

        [LocalizedRequired]
        public bool ForceSpecialCharactersFlag { get; set; } 

        [LocalizedRequired]
        public bool AllowUseOfSpaceFlag { get; set; } 

        [LocalizedRequired]
        public bool PreventSequentialCharacterFlag { get; set; } 

        [LocalizedRequired]
        public bool PreventUsernameUsageFlag { get; set; } 

        [LocalizedRequired]
        [LocalizedRangeFrom("1", "10")]
        public int? LockoutThld { get; set; } = 3;
        public int? LockoutDurationMinutes { get; set; }

        [LocalizedRequired]
        [LocalizedRangeFrom("1", "720")]
        public int SesnInactivityTimeOutMins { get; set; } = 15;

        [LocalizedRequired]
        [LocalizedRangeFrom("1", "12")]
        public int? MaxSessionLength { get; set; } = 2;

        [LocalizedRequired]
        [LocalizedRangeFrom("1", "30")]
        public int? SesnIdleTimeoutWarnThldMins { get; set; } = 10;

        [LocalizedRequired]
        [LocalizedRangeFrom("1", "10")]
        public int? SesnIdleCloseoutThldMins { get; set; } = 5;

      
        public int intRowStatus { get; set; }

        public Guid rowguid { get; set; }

        public string AuditCreateUser { get; set; }
        public DateTime AuditCreateDTM { get; set; }
        public string AuditUpdateUser { get; set; }
        public DateTime? AuditUpdateDTM { get; set; }
        public long? SourceSystemNameID { get; set; }
        public string SourceSystemKeyValue { get; set; }

        


    }
}
