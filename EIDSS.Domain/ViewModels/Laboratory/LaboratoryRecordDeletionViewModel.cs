using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class LaboratoryRecordDeletionViewModel : BaseModel
    {
        [LocalizedStringLength(500)]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.LaboratorySamplesReasonForDeletionFieldLabel))]
        public string ReasonForDeletion { get; set; }
        public List<LaboratoryRecordDeletionItemViewModel> RecordsToDelete { get; set; }
    }
}