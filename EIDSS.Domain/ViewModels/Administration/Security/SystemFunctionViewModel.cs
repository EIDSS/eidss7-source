using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class SystemFunctionViewModel :BaseModel
    {
        public long? idfsBaseReference { get; set; }
        public long? idfsReferenceType { get; set; }
        public string SystemFunction { get; set; }
     
    }
}
