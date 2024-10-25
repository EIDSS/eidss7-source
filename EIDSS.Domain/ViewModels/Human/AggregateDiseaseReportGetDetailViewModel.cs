using EIDSS.Localization.Constants;
using EIDSS.Localization.Helpers;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels.Human
{
    public class AggregateDiseaseReportGetDetailViewModel
    {
        public long? idfAggrCase { get; set; }
        public long idfsAggrCaseType { get; set; }
        public long? idfsAdministrativeUnit { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanAggregateDiseaseReportNotificationReceivedByInstitutionFieldLabel))]
        public long? idfReceivedByOffice { get; set; }
        public string strReceivedByOffice { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanAggregateDiseaseReportNotificationReceivedByOfficerFieldLabel))]
        public long? idfReceivedByPerson { get; set; }
        public string strReceivedByPerson { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanAggregateDiseaseReportNotificationSentByInstitutionFieldLabel))]
        public long? idfSentByOffice { get; set; }
        public string strSentByOffice { get; set; }
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanAggregateDiseaseReportNotificationSentByOfficerFieldLabel))]
        public long? idfSentByPerson { get; set; }
        public string strSentByPerson { get; set; }
        public long idfEnteredByOffice { get; set; }
        public string strEnteredByOffice { get; set; }
        public long idfEnteredByPerson { get; set; }
        public string strEnteredByPerson { get; set; }
        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanAggregateDiseaseReportNotificationReceivedByDateFieldLabel))]
        public DateTime? datReceivedByDate { get; set; }
        [LocalizedDateLessThanOrEqualToToday]
        [LocalizedRequiredIfTrue(nameof(FieldLabelResourceKeyConstants.HumanAggregateDiseaseReportNotificationSentByDateFieldLabel))]
        public DateTime? datSentByDate { get; set; }
        public DateTime? datEnteredByDate { get; set; }
        public DateTime? datStartDate { get; set; }
        public DateTime? datFinishDate { get; set; }
        public string strCaseID { get; set; }
        public long? idfsAreaType { get; set; }
        public long? idfsCountry { get; set; }
        public string strCountry { get; set; }
        public long? idfsRegion { get; set; }
        public string strRegion { get; set; }
        public long? idfsRayon { get; set; }
        public string strRayon { get; set; }
        public long? idfsSettlement { get; set; }
        public string strSettlement { get; set; }
        public long? idfsPeriodType { get; set; }
        public string strPeriodName { get; set; }
        public long? idfCaseObservation { get; set; }
        public long? idfDiagnosticObservation { get; set; }
        public long? idfProphylacticObservation { get; set; }
        public long? idfSanitaryObservation { get; set; }
        public long? idfsDiagnosticFormTemplate { get; set; }
        public long? idfsProphylacticFormTemplate { get; set; }
        public long? idfsSanitaryFormTemplate { get; set; }
        public long? idfsCaseFormTemplate { get; set; }
        public long? idfDiagnosticVersionID { get; set; }
        public long? idfProphylacticVersionID { get; set; }
        public long? idfSanitaryVersionID { get; set; }
        public long? Organization { get; set; }
        public long? idfsSite { get; set; }
        public string strOrganization { get; set; }
        public long? idfVersion { get; set; }
    }
}
