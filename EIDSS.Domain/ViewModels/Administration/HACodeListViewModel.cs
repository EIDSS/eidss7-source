using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class HACodeListViewModel :BaseModel
    {
        public long intHACode { get; set; }
        public string CodeName { get; set; }
        public int intRowStatus { get; set; }

    }
}
