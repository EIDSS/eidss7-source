using EIDSS.Domain.Abstracts;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class VeterinaryAggregateDiseaseMatrixViewModel : BaseModel
    {
        public long? IdfAggrVetCaseMTX { get; set; }
        public long? IntNumRow { get; set; }
        public long? IdfsDiagnosis { get; set; }
        public long? IdfsSpeciesType { get; set; }
        public string StrOIECode { get; set; }
        public string StrDefault { get; set; }
        
        public List<VeterinaryDiseaseMatrixListViewModel> DiseaseList { get; set; }
        public List<SpeciesViewModel> SpeciesList { get; set; }
        
    }
}
