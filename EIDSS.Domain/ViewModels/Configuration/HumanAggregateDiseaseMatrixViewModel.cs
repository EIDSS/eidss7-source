using EIDSS.Domain.Abstracts;
using System.Collections.Generic;


namespace EIDSS.Domain.ViewModels.Configuration
{
    public class HumanAggregateDiseaseMatrixViewModel : BaseModel
    {
        public long IntNumRow { get; set; }
        public long IdfHumanCaseMTX { get; set; }  
        public long IdfsDiagnosis { get; set; }
        public string StrDefault { get; set; }
        public string StrIDC10 { get; set; }
        
        public List<HumanDiseaseDiagnosisListViewModel> DiseaseList { get; set; }        
        
    }
}
