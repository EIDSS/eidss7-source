using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class VeterinaryDiseaseMatrixListViewModel: BaseModel
    {
        public long IdfsBaseReference { get; set; }
        public string StrDefault { get; set; }
        public string Name { get; set; }
        public string StrIDC10 { get; set; }
        public string StrOIECode { get; set; }
    }
}
