using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.CrossCutting
{
   public class DiseaseGetListPagedResponseModel
    {
        public int? TotalRowCount { get; set; }
        public long? idfsBaseReference { get; set; }
        public string strName { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
