using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class StreetModel :BaseModel
    {
        public string StreetID { get; set; }
        public string StreetName { get; set; }
        public long? idfsLocation { get; set; }
        public int RowStatus { get; set; }
    }
}
