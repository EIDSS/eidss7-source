namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class LaboratorySelectionViewModel
    {
        public long SampleID { get; set; }
        public long? TestID { get; set; }
        public long? BatchTestID { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
    }
}
