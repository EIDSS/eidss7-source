using System;

namespace EIDSS.Domain.ResponseModels.Outbreak
{
    public class OutbreakSessionParametersListModel
    {
        public long OutbreakSpeciesParameterUID { get; set; }
        public long idfOutbreak { get; set; }
        public long? OutbreakSpeciesTypeID { get; set; }
        public int? CaseMonitoringDuration { get; set; }
        public int? CaseMonitoringFrequency { get; set; }
        public int? ContactTracingDuration { get; set; }
        public int? ContactTracingFrequency { get; set; }
        public int intRowStatus { get; set; }
        public long? CaseQuestionaireTemplateID { get; set; }
        public long? CaseMonitoringTemplateID { get; set; }
        public long? ContactTracingTemplateID { get; set; }
    }
}
