using System;
using System.Collections.Generic;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class VeterinaryActiveSurveillanceSessionAggregateDiseaseViewModel : BaseModel
    {
        public VeterinaryActiveSurveillanceSessionAggregateDiseaseViewModel ShallowCopy() => (VeterinaryActiveSurveillanceSessionAggregateDiseaseViewModel)this.MemberwiseClone();

        public long MonitoringSessionSummaryID { get; set; }
        public long DiseaseID { get; set; }
        public string DiseaseName { get; set; }
    }
}