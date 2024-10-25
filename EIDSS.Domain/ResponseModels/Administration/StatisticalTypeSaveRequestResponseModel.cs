using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class StatisticalTypeSaveRequestResponseModel :APIPostResponseModel
    {
        public long IdfsStatisticDataType { get; set; }
    }
}
