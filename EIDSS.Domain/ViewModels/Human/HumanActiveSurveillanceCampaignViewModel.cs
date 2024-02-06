using System;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Human
{
    public class HumanActiveSurveillanceCampaignViewModel : BaseModel
    {

        public long CampaignKey { get; set; }
        public string CampaignId { get; set; }
        public string CampaignTypeName { get; set; }
        public string CampaignStatusTypeName { get; set; }
        public string DiseaseName { get; set; }
        public DateTime CampaignStartDate { get; set; }
        public DateTime CampaignEndDate { get; set; }
        public string CampaignName { get; set; }
        public string CampaignAdministrator { get; set; }

        public DateTime EnteredDate { get; set; }
        public long SiteID { get; set; }

        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }

    }
}
