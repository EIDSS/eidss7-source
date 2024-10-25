using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using System;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Outbreak
{
    public class CaseMonitoringGetListViewModel : BaseModel
    {
        public CaseMonitoringGetListViewModel ShallowCopy()
        {
            return (CaseMonitoringGetListViewModel)MemberwiseClone();
        }

        public long? CaseMonitoringId { get; set; }
        public long? CaseId { get; set; }
        public long? HumanCaseId { get; set; }
        public long? VeterinaryCaseId { get; set; }
        public DateTime? MonitoringDate { get; set; }
        public long? InvestigatedByOrganizationId { get; set; }
        public string InvestigatedByOrganizationName { get; set; }
        public long? InvestigatedByPersonId { get; set; }
        public string InvestigatedByPersonName { get; set; }
        public long? ObservationId { get; set; }
        public FlexFormQuestionnaireGetRequestModel CaseMonitoringFlexFormRequest { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> CaseMonitoringFlexFormAnswers { get; set; }
        public string CaseMonitoringObservationParameters { get; set; }
        public string AdditionalComments { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}
