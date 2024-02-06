using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Human
{
	[DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
	public class AggregateDiseaseReportSaveRequestModel
    {
		public long? idfAggrCase { get; set; }
		public string strCaseID { get; set; }
		public long? idfsAggrCaseType { get; set; }
		public long? GeographicalAdministrativeUnitID { get; set; }
		public long? OrganizationalAdministrativeUnitID { get; set; }
		public long? idfReceivedByOffice { get; set; }
		public long? idfReceivedByPerson { get; set; }
		public long? idfSentByOffice { get; set; }
		public long? idfSentByPerson { get; set; }
		public long? idfEnteredByOffice { get; set; }
		public long? idfEnteredByPerson { get; set; }
		public long? idfCaseObservation { get; set; }
		public long? idfsCaseObservationFormTemplate { get; set; }
		public long? idfDiagnosticObservation { get; set; }
		public long? idfsDiagnosticObservationFormTemplate { get; set; }
		public long? idfProphylacticObservation { get; set; }
		public long? idfsProphylacticObservationFormTemplate { get; set; }
		public long? idfSanitaryObservation { get; set; }
		public long? idfVersion { get; set; }
		public long? idfDiagnosticVersion { get; set; }
		public long? idfProphylacticVersion { get; set; }
		public long? idfSanitaryVersion { get; set; }
		public long? idfsSanitaryObservationFormTemplate { get; set; }
		public DateTime? datReceivedByDate { get; set; }
		public DateTime? datSentByDate { get; set; }
		public DateTime? datEnteredByDate { get; set; }
		public DateTime? datStartDate { get; set; }
		public DateTime? datFinishDate { get; set; }
		public DateTime? datModificationForArchiveDate { get; set; }
		public long? SiteID{ get; set; }
	}
}
