using System;
using System.Collections.Generic;
using System.Linq;

using EIDSS.Domain.Abstracts;


namespace EIDSS.Domain.RequestModels.Human
{
    public class HumanActiveSurveillanceCampaignDetailsRequestModel 
    {
        public string LanguageId { get; set; }
        public long CampaignID { get; set; }
       

    }
}
