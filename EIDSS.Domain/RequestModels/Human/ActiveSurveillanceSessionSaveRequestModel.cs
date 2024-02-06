using System;
using EIDSS.Domain.Attributes;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.RequestModels.Human
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class ActiveSurveillanceSessionSaveRequestModel
    {
        public string LanguageID { get; set; }
        
        public long? MonitoringSessionID { get; set; }

        public long? MonitoringSessionStatusTypeID { get; set; }

        public long idfsLocation { get; set; }

        public long? EnteredByPersonID { get; set; }

        public long? CampaignID { get; set; }
        public long? SiteID { get; set; }

        public string EIDSSSessionID { get; set; }

        public DateTime? StartDate { get; set; }

        public DateTime? EndDate { get; set; }

        public long? DiseaseID { get; set; }
        public long? SessionCategoryTypeID { get; set; }
        public int? RowStatus { get; set; } = (int)RowStatusTypeEnum.Active;
        public long? CreateDiseaseReportHumanID { get; set; }
        public string AuditUserName { get; set; }
        public string DiseaseCombinations { get; set; }
        public string SampleTypeCombinations { get; set; }
        public string Samples { get; set; }
        public string SamplesToDiseases { get; set; }
        public string Tests { get; set; }
        public string Actions { get; set; }
        public string Events { get; set; }
        public long UserId { get; set; }
    }
}
