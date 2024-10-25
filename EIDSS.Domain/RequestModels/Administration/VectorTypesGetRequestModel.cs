using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class VectorTypesGetRequestModel : BaseGetRequestModel
    {

        [MapToParameter("strSearchVectorType")]
        public string SearchVectorType { get; set; }
        
        public string AdvancedSearch { get; set; }
        
    }
}
