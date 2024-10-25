using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class LaboratoryRecordDeletionItemViewModel
    {
        public string EIDSSLaboratorySampleID { get; set; }
        public string SampleTypeName { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
    }
}
