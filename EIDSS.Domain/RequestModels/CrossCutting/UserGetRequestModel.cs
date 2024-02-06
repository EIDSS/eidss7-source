using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public  class UserGetRequestModel : BaseGetRequestModel
    {
        public long? SiteId { get; set; }
        public bool ApplySiteFiltrationIndicator { get; set; } = false;
    }
}
