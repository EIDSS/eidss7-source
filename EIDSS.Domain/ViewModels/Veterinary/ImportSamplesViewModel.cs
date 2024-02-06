using EIDSS.Domain.Abstracts;
using EIDSS.Localization.Helpers;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class ImportSamplesViewModel : BaseModel
    {
        [LocalizedStringLength(36)]
        [LocalizedRequired]
        public string EIDSSLocalOrFieldSampleID { get; set; }
    }
}