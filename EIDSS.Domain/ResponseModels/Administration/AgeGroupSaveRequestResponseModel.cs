using EIDSS.Domain.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class AgeGroupSaveRequestResponseModel : APIPostResponseModel
    {
        public long? IdfsAgeGroup { get; set; }
        public string strDuplicatedField { get; set; }
        public string StrInUseMessage { get; set; }
        public PageActions PageAction { get; set; }
    }
}
