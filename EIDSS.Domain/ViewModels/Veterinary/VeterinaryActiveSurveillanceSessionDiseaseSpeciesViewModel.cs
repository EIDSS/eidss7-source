using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel : BaseModel
    {
        public VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel ShallowCopy()
        {
            return (VeterinaryActiveSurveillanceSessionDiseaseSpeciesViewModel)MemberwiseClone();
        }

        public long MonitoringSessionToDiseaseID { get; set; }
        public long MonitoringSessionID { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public long? DiseaseUsingType { get; set; }
        public long? SpeciesTypeID { get; set; }
        public string SpeciesTypeName { get; set; }
        public int AvianOrLivestock { get; set; }
        public long? SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public int OrderNumber { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
        public int RowNumber { get; set; }
        public int RecordCount { get; set; }
    }
}