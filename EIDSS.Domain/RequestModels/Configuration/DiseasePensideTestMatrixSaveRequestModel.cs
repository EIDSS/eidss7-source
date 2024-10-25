using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Configuration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class DiseasePensideTestMatrixSaveRequestModel
    {
        public long IdfPensideTestForDisease { get; set; }
        public long IdfsDiagnosis { get; set; }
        public long IdfsPensideTestName { get; set; }
    }
}
