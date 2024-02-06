using System;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;

namespace EIDSS.Domain.ViewModels.Outbreak
{
    public class OutbreakSessionNoteDetailsViewModel
    {
        public long idfOutbreakNote { get; set; }
        public long NoteRecordUID { get; set; }
        public long idfOutbreak { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakUpdatesRecordDetailsFieldLabel))]
        [LocalizedRequired]
        public string strNote { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakUpdatesDateTimeFieldLabel))]
        [LocalizedRequired]
        public DateTime? datNoteDate { get; set; }
        public long idfPerson { get; set; }
        public string UserName { get; set; }
        public string Organization { get; set; }
        public int intRowStatus { get; set; }
        public string strMaintenanceFlag { get; set; }
        public string strReservedAttribute { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakUpdatesPriorityFieldLabel))]
        [LocalizedRequired]
        public long? UpdatePriorityID { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakUpdatesPriorityFieldLabel))]
        [LocalizedRequired]
        public string strPriority { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.OutbreakUpdatesRecordTitleFieldLabel))]
        [LocalizedRequired]
        public string UpdateRecordTitle { get; set; }
        public string UploadFileName { get; set; }
        public string UploadFileDescription { get; set; }
        public byte[] UploadFileObject { get; set; }
    }
}