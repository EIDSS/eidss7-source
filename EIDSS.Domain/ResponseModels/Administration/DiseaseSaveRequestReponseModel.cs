using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class DiseaseSaveRequestReponseModel : APIPostResponseModel
    {
        public long IdfsDiagnosis { get; set; }
    }
}
