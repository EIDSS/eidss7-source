using EIDSS.Domain.ResponseModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Laboratory.Freezer
{
    public class FreezerSaveRequestResponseModel : APIPostResponseModel
    {
        public long? FreezerID { get; set; }
    }
}
