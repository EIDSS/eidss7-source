using EIDSS.Localization.Helpers;
using System;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class TransferGetDetailViewModel
    {
        public long? TransferID { get; set; }
        public string EIDSSTransferID { get; set; }
        public long TransferredOutSampleID { get; set; }
        public long? TransferredInSampleID { get; set; }
        [LocalizedRequired]
        public long TransferredToOrganizationID { get; set; }
        public string TransferredToOrganizationName { get; set; }
        public bool ExternalOrganizationIndicator { get; set; }
        [LocalizedRequired]
        public long TransferredFromOrganizationID { get; set; }
        public string TransferredFromOrganizationName { get; set; }
        [LocalizedRequired]
        public long TransferredFromOrganizationSiteID { get; set; }
        [LocalizedRequired]
        public long SentByPersonID { get; set; }
        public string SentByPersonName { get; set; }
        [LocalizedRequired]
        [LocalizedDateLessThanOrEqualToToday]
        public DateTime TransferDate { get; set; }
        [LocalizedRequired]
        public string TestRequested { get; set; }
        public long? TestID { get; set; }
        public string PurposeOfTransfer { get; set; }
        public long SiteID { get; set; }
        public long TransferStatusTypeID { get; set; }
        public int RowStatus { get; set; }

        public bool PrintBarcodeIndicator { get; set; }
        public bool AllowDatesInThePast { get; set; }
        public bool CanEditSampleTransferFormsAfterTransferIsSaved { get; set; }
    }
}
