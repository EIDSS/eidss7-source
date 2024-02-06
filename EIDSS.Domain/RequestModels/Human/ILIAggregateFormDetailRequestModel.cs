using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Human
{
    public class ILIAggregateFormDetailRequestModel : BaseGetRequestModel
    {        
		public long IdfAggregateHeader { get; set; }
        public string FormID { get; set; }
    }
}
