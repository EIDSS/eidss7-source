using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Veterinary
{
public    class FarmGetListDetailRequestModel
    {
        public string LanguageID { get; set; }
        public long FarmID { get; set; }
        public string SortColumn { get; set; }
        public string SortOrder { get; set; }
        public int Page { get; set; }
    }
}
