using System;
using System.Collections.Generic;
using System.Linq;

using EIDSS.Domain.Abstracts;


namespace EIDSS.Domain.RequestModels.Human
{
    public class HumanActiveSurveillanceCampaignRequestModel : BaseGetRequestModel
    {
        public string CampaignID { get; set; }
        public string CampaignName { get; set; }
        public long ? CampaignTypeID { get; set; }
        public long ? CampaignStatusTypeID { get; set; }
        public DateTime ? StartDateFrom { get; set; }
        public DateTime ? StartDateTo { get; set; }
        public long ? DiseaseID { get; set; }
        public long  UserSiteID { get; set; }
        public long UserOrganizationID { get; set; }
        public long  UserEmployeeID { get; set; }
        public bool ? ApplySiteFiltrationIndicator { get; set; }
        public long ? @AdministrativeLevelID { get; set; }

    }
}
