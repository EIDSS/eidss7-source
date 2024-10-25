using System;


namespace EIDSS.Domain.ViewModels.Outbreak
{
    public class OutbreakSessionListViewModel
    {
        public long idfOutbreak { get; set; }
        public string OutbreakID { get; set; }
        public string DiseaseName { get; set; }
        public string OutbreakStatusTypeName { get; set; }
        public string OutbreakTypeName { get; set; }
        public string AdministrativeLevel1Name { get; set; }
        public string AdministrativeLevel2Name { get; set; }
        public string AdministrativeLevel3Name { get; set; }
        public string AdministrativeLevel4Name { get; set; }
        public string AdministrativeLevel5Name { get; set; }
        public string AdministrativeLevel6Name { get; set; }
        public string AdministrativeLevel7Name { get; set; }
        public DateTime? StartDate { get; set; }
        public long SiteID { get; set; }
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
