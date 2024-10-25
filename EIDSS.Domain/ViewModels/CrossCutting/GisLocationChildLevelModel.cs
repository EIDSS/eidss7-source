using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class GisLocationChildLevelModel
    {
        public short? Level { get; set; }
        public long? idfsGISReferenceType { get; set; }
        public string strGISReferenceTypeName { get; set; }
        public long? idfsReference { get; set; }
        public string Name { get; set; }
        public string strNode { get; set; }
        public string strHASC { get; set; }
        public string strCode { get; set; }
        public long? LevelType { get; set; }

    }
}
