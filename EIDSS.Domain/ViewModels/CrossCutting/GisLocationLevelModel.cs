using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class GisLocationLevelModel
    {
        public short? Level { get; set; }
        public long idfsGISReferenceType { get; set; }
        public string strDefault { get; set; }
        public string Name { get; set; }
    }
}
