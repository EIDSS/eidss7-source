using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class SiteGblGetRequestModel : BaseGetRequestModel
    {

        public long? UserId  { get; set; }
        public bool ApplySiteFiltrationIndicator { get; set; } =false;
    }
}
