using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class AggregateCaseMatrixViewModel : BaseModel
    {
        public int? IntNumRow { get; set; }
        public long IdfHumanCaseMtx { get; set; }
        public long IdfsDiagnosis { get; set; }
        public string StrDefault { get; set; }
        public string StrIDC10 { get; set; }
    }
}
