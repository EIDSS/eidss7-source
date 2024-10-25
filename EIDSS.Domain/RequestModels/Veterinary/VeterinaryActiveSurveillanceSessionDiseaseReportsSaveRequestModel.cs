using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VeterinaryActiveSurveillanceSessionDiseaseReportSaveRequestModel
    {
        public long LinkedDiseaseReportID { get; set; }
        public int RowStatus { get; set; }
        public int? RowAction { get; set; }
    }
}
