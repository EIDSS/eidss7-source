using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Vector
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class USSP_VCT_AGGREGATE_DISEASEDIAGNOSIS_SETRequestModel
    {
        public string DiseaseDiagnosisParameters { get; set; }
        public string AuditUser { get; set; }
    }
}
