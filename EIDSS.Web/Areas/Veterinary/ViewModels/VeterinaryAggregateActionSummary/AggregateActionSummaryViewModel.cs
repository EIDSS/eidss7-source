using EIDSS.Domain.RequestModels.FlexForm;

namespace EIDSS.Web.Areas.Veterinary.ViewModels.VeterinaryAggregateActionSummary
{
    public class AggregateActionSummaryViewModel
    {
        public long? idfDiagnosticVersion { get; set; }
        public long? idfsDiagnosticObservationFormTemplate { get; set; }
        public long? idfDiagnosticObservation { get; set; }
        public FlexFormQuestionnaireGetRequestModel DiagnosticInvestigations { get; set; }

        public long? idfProphylacticVersion { get; set; }
        public long? idfsProphylacticObservationFormTemplate { get; set; }
        public long? idfProphylacticObservation { get; set; }
        public FlexFormQuestionnaireGetRequestModel ProphylacticMeasure { get; set; }

        public long? idfSanitaryVersion { get; set; }
        public long? idfsSanitaryObservationFormTemplate { get; set; }
        public long? idfSanitaryObservation { get; set; }
        public FlexFormQuestionnaireGetRequestModel VeterinarySanitaryMeasures { get; set; }
    }
}
