using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class AgeGroupGetRequestModel : BaseGetRequestModel
    {
        public string AdvancedSearch { get; set; }
    }
}
