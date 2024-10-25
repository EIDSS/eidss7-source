using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class VeterinaryProphylacticMeasureMatrixViewModel : BaseModel
    {
        public long? IntNumRow { get; set; }
        public long? IdfVersion { get; set; }
        public string InJsonString { get; set; }
        public long? IdfAggrProphylacticActionMTX { get; set; }        
        public long? IdfsProphilacticAction { get; set; }
        public string StrInvestigationType { get; set; }
        public long? IdfsSpeciesType { get; set; }
        public string StrSpeciesTypeName { get; set; }
        public long? IdfsDiagnosis { get; set; }
        public string StrDiagnosisName { get; set; }
        public string StrOIECode { get; set; }
        public string StrActionCode { get; set; }
        public List<VeterinaryDiseaseMatrixListViewModel> DiseaseList { get; set; }
        public List<SpeciesViewModel> SpeciesList { get; set; }
        public List<InvestigationTypeViewModel> MeasureTypesList { get; set; }
    }
}
