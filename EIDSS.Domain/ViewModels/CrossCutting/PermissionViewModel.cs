using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class PermissionViewModel :BaseModel
    {
        public long Key { get; set; }
        public bool Value { get; set; }     
    }
}
