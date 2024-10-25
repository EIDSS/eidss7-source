using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class DiseaseGetListPagedRequestModel : BaseGetRequestModel
    {
        public long intHACode { get; set; }
        public string advancedSearch { get; set; }
    }
}
