using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VeterinaryActiveSurveillanceSessionDiseaseSpecieSamplesSaveRequestModel
    {
        public long MonitoringSessionToDiagnosisID { get; set; }
        public long DiseaseID { get; set; }
        public int Order { get; set; }
        public long? SpeciesTypeID { get; set; }
        public long? SampleTypeID { get; set; }
        public int RowStatus { get; set; }
        public int? RowAction { get; set; }
    }
}
