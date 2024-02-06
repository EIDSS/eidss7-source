using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    
    public class HumanDiseaseMatrixListViewModel : BaseModel
    {
        public long idfsBaseReference { get; set; }
        public string strDefault { get; set; }
        public string strIDC10 { get; set; }

    }
}
