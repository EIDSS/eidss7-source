using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class VeterinaryProphylacticMeasureMatrixGetRequestModel : BaseGetRequestModel
    {
        public long IdfVersion { get; set; }
    }
}
