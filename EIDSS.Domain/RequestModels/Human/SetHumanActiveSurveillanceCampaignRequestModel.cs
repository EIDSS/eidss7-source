using System;
using System.Collections.Generic;
using System.Linq;

using EIDSS.Domain.Abstracts;


namespace EIDSS.Domain.RequestModels.Human
{
    public class SetHumanActiveSurveillanceCampaignRequestModel : BaseSaveRequestModel
    {
      
        public long ? idfCampaign { get; set; }
        public long ? CampaignTypeID { get; set; }
        public long? CampaignStatusTypeID { get; set; }
        public DateTime? CampaignDateStart { get; set; }
        public DateTime? CampaignDateEnd { get; set; }
        public string strCampaignID { get; set; }
        public string CampaignName { get; set; }
        public long ? CampaignCategoryTypeID { get; set; }
        public string CampaignAdministrator { get; set; }
        public string Conclusion { get; set; }
        public long? SiteID { get; set; }
       // public string AuditUserName { get; set; }
        public string CampaignToDiagnosisCombo { get; set; }

        public string MonitoringSessions { get; set; }
        

    }
}
