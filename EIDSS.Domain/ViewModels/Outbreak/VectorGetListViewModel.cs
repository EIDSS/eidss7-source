using System;

namespace EIDSS.Domain.ViewModels.Outbreak
{
    public class VectorGetListViewModel
    {
        public long SessionKey { get; set; }
        public string SessionID { get; set; }
        public string FieldSessionID { get; set; }
        public long? OutbreakKey { get; set; }
        public string OutbreakID { get; set; }
        public DateTime? OutbreakStartDate { get; set; }
        public string VectorTypeIDs { get; set; }
        public string Vectors { get; set; }
        public string DiseaseIDs { get; set; }
        public string Diseases { get; set; }
        public long? StatusTypeID { get; set; }
        public string StatusTypeName { get; set; }
        public string AdministrativeLevel1Name { get; set; }
        public string AdministrativeLevel2Name { get; set; }
        public string SettlementName { get; set; }
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public string AdministrativeLevelXName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? CloseDate { get; set; }
        public long SiteID { get; set; }
        public int? RecordCount { get; set; }
        public int? TotalCount { get; set; }
        public int? CurrentPage { get; set; }
        public int? TotalPages { get; set; }
    }
}