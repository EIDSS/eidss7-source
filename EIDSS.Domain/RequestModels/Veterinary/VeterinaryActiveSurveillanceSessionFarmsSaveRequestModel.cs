using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VeterinaryActiveSurveillanceSessionFarmsSaveRequestModel
    {
        public long FarmMasterID { get; set; }
        public long? FarmID { get; set; }
        public int? TotalAnimalQuantity { get; set; }
        public int RowStatus { get; set; }
        public int? RowAction { get; set; }
    }
}
