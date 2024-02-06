using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class VeterinarySanitaryActionMatrixViewModel : BaseModel
    {
        public int? IntNumRow { get; set; }
        public long IdfAggrSanitaryActionMTX { get; set; }
        public long IdfsSanitaryAction { get; set; }
        public string StrDefault { get; set; }
        public string StrActionCode { get; set; }
        public List<InvestigationTypeViewModel> SanitaryActionList { get; set; }        
    }
}
