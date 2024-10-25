using EIDSS.Domain.Abstracts;
using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    public class AdvancedSearchGetRequestModel : BaseGetRequestModel
    {
        public long? ReportOrSessionTypeID { get; set; }
        public long? SurveillanceTypeID { get; set; }
        public IEnumerable<long> SampleStatusTypeList { get; set; }
        public string SampleStatusTypes { get; set; }
        public string AccessionIndicatorList { get; set; }
        [StringLength(36)]
        public string EIDSSLocalOrFieldSampleID { get; set; }
        [StringLength(36)]
        public string EIDSSReportSessionOrCampaignID { get; set; }
        public long? SentToOrganizationID { get; set; }
        public long? SentToOrganizationSiteID { get; set; }
        public long? TransferredToOrganizationID { get; set; }
        [StringLength(36)]
        public string EIDSSTransferID { get; set; }
        public long? ResultsReceivedFromOrganizationID { get; set; }
        [LocalizedRequired]
        [LocalizedDateLessThanOrEqualToToday]
        public DateTime? DateFrom { get; set; }
        [LocalizedRequired]
        [LocalizedDateLessThanOrEqualToToday]
        public DateTime? DateTo { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.LaboratoryAdvancedSearchLaboratorySampleIDFieldLabel))]
        [StringLength(36)]
        public string EIDSSLaboratorySampleID { get; set; }
        public long? SampleTypeID { get; set; }
        public long? TestNameTypeID { get; set; }
        public string TestNameTypeName { get; set; }
        public long? DiseaseID { get; set; }
        public long? TestStatusTypeID { get; set; }
        public long? TestResultTypeID { get; set; }
        [LocalizedDateLessThanOrEqualToToday]
        public DateTime? TestResultDateFrom { get; set; }
        [LocalizedDateLessThanOrEqualToToday]
        public DateTime? TestResultDateTo { get; set; }
        [StringLength(200)]
        public string PatientName { get; set; }
        [StringLength(200)]
        public string FarmOwnerName { get; set; }
        public long? SpeciesTypeID { get; set; }
        public string SampleList { get; set; }
        public bool? TestUnassignedIndicator { get; set; }
        public bool? TestCompletedIndicator { get; set; }
        public bool? BatchTestAssociationIndicator { get; set; }
        public bool FiltrationIndicator { get; set; }
        public long UserID { get; set; }
        public long UserEmployeeID { get; set; }
        public long UserSiteID { get; set; }
        public long? UserOrganizationID { get; set; }
        public long? UserSiteGroupID { get; set; }
    }
}
