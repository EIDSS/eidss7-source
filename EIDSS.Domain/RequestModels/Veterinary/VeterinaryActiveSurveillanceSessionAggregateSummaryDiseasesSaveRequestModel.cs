using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VeterinaryActiveSurveillanceSessionAggregateSummaryDiseasesSaveRequestModel
    {
        public long MonitoringSessionSummaryID { get; set; }
        public long? DiseaseID { get; set; }
        public int? IntOrder { get; set; }
        public long? SpeciesTypeID { get; set; }
        public long? SampleTypeID { get; set; }
        public int RowStatus { get; set; }
        public int? RowAction { get; set; }
    }
}