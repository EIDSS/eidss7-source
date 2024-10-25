using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Laboratory.Freezer
{
    public class FreezerSubdivisionRequestModel
    {
        public string LanguageID { get; set; }
        public long? FreezerID { get; set; }
        public long SiteID { get; set; }
    }
}
