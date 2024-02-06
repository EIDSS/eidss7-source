using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class BarcodeRecordViewModel : BaseModel
    {
        public string EIDSSReportOrSessionID { get; set; }
        public string Barcode { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
    }
}
