using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class VeterinaryAggregateCaseMatrixReportRecordDeleteModel : BaseModel
    {
        public long? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public long? idfAggrVetCaseMTX { get; set; }
    }
}
