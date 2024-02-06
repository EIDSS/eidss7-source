using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class CustomReportRowsMatrixSaveRequestResponseModel : APIPostResponseModel
    {
        public long? idfReportRows { get; set; }
    }
}
