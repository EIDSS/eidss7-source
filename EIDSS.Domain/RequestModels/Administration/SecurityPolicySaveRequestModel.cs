using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SecurityPolicySaveRequestModel : BaseSaveRequestModel
    {
        public int Id { get; set; }
        public int MinPasswordLength { get; set; }
        public int EnforcePasswordHistoryCount { get; set; }
        public int MinPasswordAgeDays { get; set; }
        public bool ForceUppercaseFlag { get; set; } 
        public bool ForceLowercaseFlag { get; set; } 
        public bool ForceNumberUsageFlag { get; set; } 
        public bool ForceSpecialCharactersFlag { get; set; }
        public bool AllowUseOfSpaceFlag { get; set; }
        public bool PreventSequentialCharacterFlag { get; set; }
        public bool PreventUsernameUsageFlag { get; set; }
        public int? LockoutThld { get; set; }
        public int? SesnInactivityTimeOutMins { get; set; }
        public int? MaxSessionLength { get; set; }
        public int? SesnIdleTimeoutWarnThldMins { get; set; }
        public int? SesnIdleCloseoutThldMins { get; set; } 
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
        public string AuditUserName { get; set; }
    }
}
