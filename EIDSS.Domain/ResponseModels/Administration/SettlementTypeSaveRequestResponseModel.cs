using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class SettlementTypeSaveRequestResponseModel : APIPostResponseModel
    {
        public long? idfsGISBaseReference { get; set; }
    }
}
