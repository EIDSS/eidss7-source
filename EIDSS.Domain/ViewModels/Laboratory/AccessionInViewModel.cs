namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class AccessionInViewModel
    {
        public long? SampleID { get; set; }
        public long? AccessionConditionTypeID { get; set; }
        public bool PrintBarcodesIndicator { get; set; }
        public bool DisablePrintBarcodeIndicator { get; set; }
        public string AccessionInComment { get; set; }
        public bool? WritePermissionIndicator { get; set; }
    }
}
