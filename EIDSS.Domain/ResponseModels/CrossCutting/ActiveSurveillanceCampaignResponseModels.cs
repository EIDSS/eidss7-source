using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.CrossCutting
{

    public partial class ActiveSurveillanceCampaignSaveResponseModel: APIPostResponseModel
    {
        public long? idfCampaign { get; set; }
        public string strCampaignID { get; set; }
    }

}

