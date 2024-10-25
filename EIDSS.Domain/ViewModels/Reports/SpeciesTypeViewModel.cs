using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Reports
{
    public class SpeciesTypeViewModel:BaseModel
    {
        public long idfsReference { get; set; }
        public string name { get; set; }
        public int? intHACode { get; set; }
        public int? intOrder { get; set; }
        public int intRowStatus { get; set; }
    }
}
