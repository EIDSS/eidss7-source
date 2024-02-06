using System;
using System.Collections.Generic;
using System.Linq;

using EIDSS.Domain.Abstracts;


namespace EIDSS.Domain.RequestModels.Human
{
    public class GetHumanActiveCampaignSampleToSampleTypeRequestModel : BaseGetRequestModel
    {
        public long CampaignID { get; set; }

    }
}
