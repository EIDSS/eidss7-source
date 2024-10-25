using System;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class VeterinaryActiveSurveillanceSessionActionsViewModel : BaseModel
    {
        public VeterinaryActiveSurveillanceSessionActionsViewModel ShallowCopy() => (VeterinaryActiveSurveillanceSessionActionsViewModel)this.MemberwiseClone();

        public long? MonitoringSessionActionID { get; set; }
        public long MonitoringSessionID { get; set; }
        public long? EnteredByPersonID { get; set; }
        public string EnteredByPersonName { get; set; }
        public long? MonitoringSessionActionTypeID { get; set; }
        public string MonitoringSessionActionTypeName { get; set; }
        public long? MonitoringSessionActionStatusTypeID { get; set; }
        public string MonitoringSessionActionStatusTypeName { get; set; }
        public DateTime? ActionDate { get; set; }
        public string Comments { get; set; }
        public int RowStatus { get; set; } = (int)RowStatusTypeEnum.Active;
        public int RowAction { get; set; } = (int)RowActionTypeEnum.Insert;
    }
}
