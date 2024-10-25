using EIDSS.Domain.Attributes;
using System;

namespace EIDSS.Domain.RequestModels.Human
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class HumanActiveSurveillanceSessionCreateRequestModel
    {
        public string LanguageID { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? MonitoringSessionStatusTypeID { get; set; }
        public long? CountryID { get; set; }
        public long? RegionID { get; set; }
        public long? RayonID { get; set; }
        public long? SettlementID { get; set; }
        public long? EnteredByPersonID { get; set; }
        public long? CampaignID { get; set; }
        public string CampaignName { get; set; }
        public long? CampaignTypeID { get; set; }
        public long? SiteID { get; set; }
        public DateTime? EnteredDate { get; set; }
        public string EIDSSSessionID { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public DateTime? CampaignStartDate { get; set; }
        public DateTime? CampaignEndDate { get; set; }
        public long? DiseaseID { get; set; }
        public long? SessionCategoryTypeID { get; set; }
        public int? RowStatus { get; set; }
        public long? CreateDiseaseReportHumanID { get; set; }
        public string AuditUserName { get; set; }
        public string DiseaseCombinations { get; set; }
        public string SampleTypeCombinations { get; set; }
        public string Samples { get; set; }
        public string Tests { get; set; }
        public string Actions { get; set; }
    }
}
