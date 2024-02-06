using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.CrossCutting
{
    public class ObservationSaveResponseModel : APIPostResponseModel
    {
        public long? idfObservation { get; set; }
    }
}
