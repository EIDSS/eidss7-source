using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class CaseClassificationSaveRequestModel : BaseReferenceEditorRequestModel
    {
        [MapToParameter("idfsCaseClassification")]
        public long? IdfsCaseClassification { get; set; }
        public bool DeleteAnyway { get; set; }
        [MapToParameter("blnInitialHumanCaseClassification")]
        public bool? BlnInitialHumanCaseClassification { get; set; }
        [MapToParameter("blnFinalHumanCaseClassification")]
        public bool? BlnFinalHumanCaseClassification { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
        public string AuditUserName { get; set; }
    }
}
