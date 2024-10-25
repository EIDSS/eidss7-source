using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class VectorSpeciesTypesGetRequestModel : BaseGetRequestModel
    {
        public string AdvancedSearch { get; set; }
        public long? IdfsVectorType { get; set; }
        public string StrVectorSubType { get; set; }
    }
}
