using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class GISLocationModel : BaseModel
    {
        public long idfsLocation { get; set; }
        public string LevelName { get; set; }
        public string Node { get; set; }
        public string strHASC { get; set; }
        public string strCode { get; set; }
        public string strGISReferenceTypeName { get; set; }
    }
}


