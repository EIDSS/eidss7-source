using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.FlexForm;
using EIDSS.Domain.ResponseModels.FlexForm;
using System;
using System.Collections.Generic;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class BatchesGetListViewModel : BaseModel
    {
        public long BatchTestID { get; set; }
        public string EIDSSBatchTestID { get; set; }
        public long? BatchStatusTypeID { get; set; }
        public string BatchStatusTypeName { get; set; }
        public long? PerformedByOrganizationID { get; set; }
        public long? PerformedByPersonID { get; set; }
        public long? ResultEnteredByOrganizationID { get; set; }
        public long? ResultEnteredByPersonID { get; set; }
        public long? ValidatedByOrganizationID { get; set; }
        public long? ValidatedByPersonID { get; set; }
        public long? DiseaseID { get; set; }
        public long? BatchTestTestNameTypeID { get; set; }
        public string BatchTestTestNameTypeName { get; set; }
        public string TestRequested { get; set; }
        public long? ObservationID { get; set; }
        public DateTime? PerformedDate { get; set; }
        public DateTime? ValidationDate { get; set; }
        public long SiteID { get; set; }
        public int RowStatus { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public int RowAction { get; set; }
        public int RowSelectionIndicator { get; set; }
        public int InProgressCount { get; set; }
        public List<TestingGetListViewModel> Tests { get; set; }

        public FlexFormQuestionnaireGetRequestModel QualityControlValuesFlexFormRequest { get; set; }
        public IList<FlexFormActivityParametersListResponseModel> QualityControlValuesFlexFormAnswers { get; set; }
        public string QualityControlValuesObservationParameters { get; set; }
    }
}
