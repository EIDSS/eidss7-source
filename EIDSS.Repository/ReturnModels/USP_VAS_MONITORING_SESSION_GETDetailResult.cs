﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace EIDSS.Repository.ReturnModels
{
    public partial class USP_VAS_MONITORING_SESSION_GETDetailResult
    {
        public long VeterinaryMonitoringSessionID { get; set; }
        public string EIDSSSessionID { get; set; }
        public long? SessionStatusTypeID { get; set; }
        public string SessionStatusTypeName { get; set; }
        public long? ReportTypeID { get; set; }
        public string ReportTypeName { get; set; }
        public DateTime? EnteredDate { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string DiseaseIdentifiers { get; set; }
        public string DiseaseNames { get; set; }
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
        public long SiteID { get; set; }
        public string SiteName { get; set; }
        public string LegacyID { get; set; }
        public long? CampaignKey { get; set; }
        public string CampaignID { get; set; }
        public string CampaignName { get; set; }
        public long? CampaignTypeID { get; set; }
        public string CampaignTypeName { get; set; }
        public bool? ReadPermissionindicator { get; set; }
        public bool? AccessToPersonalDataPermissionIndicator { get; set; }
        public bool? AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool? WritePermissionIndicator { get; set; }
        public bool? DeletePermissionIndicator { get; set; }
    }
}
