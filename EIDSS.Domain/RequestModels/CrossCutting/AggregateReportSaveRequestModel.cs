using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
	public class AggregateReportSaveRequestModel : BaseSaveRequestModel
	{
		public long? AggregateReportID { get; set; }

        public string EIDSSAggregateReportID { get; set; }

        public long? AggregateReportTypeID { get; set; }

        public long? GeographicalAdministrativeUnitID { get; set; }

        public long? OrganizationalAdministrativeUnitID { get; set; }

        public long? ReceivedByOrganizationID { get; set; }

        public long? ReceivedByPersonID { get; set; }

        public long? SentByOrganizationID { get; set; }

        public long? SentByPersonID { get; set; }

        public long? EnteredByOrganizationID { get; set; }

        public long? EnteredByPersonID { get; set; }

        public long? CaseObservationID { get; set; }

        public long? CaseObservationFormTemplateID { get; set; }

        public long? DiagnosticObservationID { get; set; }
		public long? DiagnosticObservationFormTemplateID { get; set; }

        public long? ProphylacticObservationID { get; set; }
		public long? ProphylacticObservationFormTemplateID { get; set; }

        public long? SanitaryObservationID { get; set; }
        public long? SanitaryObservationFormTemplateID { get; set; }

        public long? CaseVersion { get; set; }

        public long? DiagnosticVersion { get; set; }

        public long? ProphylacticVersion { get; set; }

        public long? SanitaryVersion { get; set; }

        public DateTime? ReceivedByDate { get; set; }

        public DateTime? SentByDate { get; set; }

        public DateTime? EnteredByDate { get; set; }

        public DateTime? StartDate { get; set; }

        public DateTime? FinishDate { get; set; }
		public DateTime? ModificationForArchiveDate { get; set; }
		public long? SiteID{ get; set; }
        public long UserID { get; set; }
		public string Events { get; set; }
	}
}
