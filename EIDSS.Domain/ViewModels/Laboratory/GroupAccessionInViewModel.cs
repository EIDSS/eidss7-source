using EIDSS.Domain.Abstracts;
using EIDSS.Localization.Helpers;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class GroupAccessionInViewModel : BaseModel
    {
        [LocalizedStringLength(36)]
        [LocalizedRequired]
        public string EIDSSLocalOrFieldSampleID { get; set; }
    }
}