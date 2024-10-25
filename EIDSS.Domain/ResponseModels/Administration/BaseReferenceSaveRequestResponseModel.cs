using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;
namespace EIDSS.Domain.ResponseModels.Administration
{
    public class BaseReferenceSaveRequestResponseModel : APIPostResponseModel
    {
        public long? idfsBaseReference { get; set; }
        public string strClientPageMessage { get; set; }
        public string strDuplicatedField { get; set; }
        public PageActions PageAction { get; set; }
    }
}
