using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class VeterinaryActiveSurveillanceSessionViewModel
    {
        public long SessionKey { get; set; }
        public string SessionID { get; set; }
        public long? CampaignKey { get; set; }
        public string CampaignID { get; set; }
        public long? SessionStatusTypeID { get; set; }
        public string SessionStatusTypeName { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string DiseaseIdentifiers { get; set; }
        public string DiseaseNames { get; set; }
        public string DiseaseName { get; set; }
        public string AdministrativeLevel0Name { get; set; }
        public string AdministrativeLevel1Name { get; set; }
        public string AdministrativeLevel2Name { get; set; }
        public string SettlementName { get; set; }
        public DateTime? EnteredDate { get; set; }
        public string EnteredByPersonName { get; set; }
        public long SiteKey { get; set; }
        public string SiteName { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public int? RecordCount { get; set; }
        public int? TotalCount { get; set; }
        public int? CurrentPage { get; set; }
        public int? TotalPages { get; set; }

    }

    public class VeterinaryActiveSurveillanceSessionDetailViewModel
    {
        public long VeterinaryMonitoringSessionID { get; set; }
        public string EIDSSSessionID { get; set; }
        public long? SessionStatusTypeID { get; set; }
        public string SessionStatusTypeName { get; set; }
        public long? ReportTypeID { get; set; }
        public string ReportTypeName { get; set; }
        public string DiseaseIdentifiers { get; set; }
        public string DiseaseNames { get; set; }
        public DateTime? EnteredDate { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public long? CountryID { get; set; }
        public long? RegionID { get; set; }
        public string RegionName { get; set; }
        public long? RayonID { get; set; }
        public string RayonName { get; set; }
        public long? SettlementID { get; set; }
        public string SettlementName { get; set; }
        public long? LocationID { get; set; }
        public long? EnteredByPersonID { get; set; }
        public string EnteredByPersonName { get; set; }
        public long? SiteID { get; set; }
        public string SiteName { get; set; }
        public string LegacyID { get; set; }
        public long? CampaignKey { get; set; }   
        public string CampaignID { get; set; }
        public string CampaignName { get; set; }
        public long? CampaignTypeID { get; set; }
        public string CampaignTypeName { get; set; }
    }

}
