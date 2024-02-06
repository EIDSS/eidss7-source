using System;

namespace EIDSS.Domain.ViewModels.Outbreak
{
    public class OutbreakSessionDetailViewModel
    {
        public long idfOutbreak { get; set; }
        public long? idfsDiagnosisOrDiagnosisGroup { get; set; }
        public string strDiagnosis { get; set; }
        public long? idfsOutbreakStatus { get; set; }
        public string strOutbreakStatus { get; set; }
        public long? OutbreakTypeId { get; set; }
        public string strOutbreakType { get; set; }
        public long? AdminLevel0Value { get; set; }
        public long? AdminLevel1Value { get; set; }
        public string AdminLevel1Text { get; set; }
        public long? AdminLevel2Value { get; set; }
        public string AdminLevel2Text { get; set; }
        public int? AdminLevel3Value { get; set; }
        public int? AdminLevel3Text { get; set; }
        public long? PostalCodeID { get; set; }
        public string PostalCode { get; set; }
        public long? StreetID { get; set; }
        public string StreetName { get; set; }
        public string House { get; set; }
        public string Building { get; set; }
        public string Apartment { get; set; }
        public DateTime? datStartDate { get; set; }
        public DateTime? datCloseDate { get; set; }
        public string strOutbreakID { get; set; }
        public string strDescription { get; set; }
        public int intRowStatus { get; set; }
        public Guid rowguid { get; set; }
        public DateTime? datModificationForArchiveDate { get; set; }
        public long? idfPrimaryCaseOrSession { get; set; }
        public long idfsSite { get; set; }
        public string strMaintenanceFlag { get; set; }
        public string strReservedAttribute { get; set; }
    }
}
