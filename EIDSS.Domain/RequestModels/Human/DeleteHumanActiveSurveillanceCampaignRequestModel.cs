using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Human
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class DeleteHumanActiveSurveillanceCampaignRequestModel
    {
        public string LanguageId { get; set; }
        public long CampaignID { get; set; }
      
    }

}
