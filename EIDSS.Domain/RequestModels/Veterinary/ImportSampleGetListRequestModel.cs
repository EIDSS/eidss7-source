using EIDSS.Domain.Abstracts;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class ImportSampleGetListRequestModel : BaseGetRequestModel
    {
        [StringLength(36)]
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public long FarmMasterID { get; set; }
        public string SpeciesTypeIDList { get; set; }
        public long DiseaseID { get; set; }
    }
}
