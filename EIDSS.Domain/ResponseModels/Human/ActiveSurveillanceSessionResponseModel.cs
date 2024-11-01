﻿using System;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class ActiveSurveillanceSessionResponseModel
    {
        public long SessionKey { get; set; }
        public string SessionID { get; set; }
        public long? CampaignKey { get; set; }
        public string CampaignID { get; set; }
        public string SessionStatusTypeName { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string DiseaseIdentifiers { get; set; }
        public string DiseaseNames { get; set; }
        public string AdministrativeLevel1Name { get; set; }
        public string AdministrativeLevel2Name { get; set; }
        public string AdministrativeLevel3Name { get; set; }
        public string AdministrativeLevel4Name { get; set; }
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
}
