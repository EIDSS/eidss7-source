using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class BaseReferenceTypeListViewModel :BaseModel
    {
        public long BaseReferenceId { get; set; } // idfsBaseReference { get; set; }
        public long ReferenceId { get; set; } // idfsReferenceType { get; set; }
        public string Default{ get; set; } //strDefault
        public string Name { get; set; } // strName;
        public int? intHACode { get; set; }
        public int? intOrder { get; set; }
        public string LOINC { get; set; }
    }
}
