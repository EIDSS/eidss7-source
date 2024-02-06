using EIDSS.Domain.Abstracts;
using EIDSS.Domain.ViewModels.Administration;
using System;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class SampleToDiseaseGetListViewModel : BaseModel
    {
        public SampleToDiseaseGetListViewModel ShallowCopy()
        {
            return (SampleToDiseaseGetListViewModel)MemberwiseClone();
        }

        public long MonitoringSessionToMaterialID { get; set; }
        public long MonitoringSessionID { get; set; }
        public long SampleID { get; set; }
        public long SampleTypeID { get; set; }
        public long DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}
