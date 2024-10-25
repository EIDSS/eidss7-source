using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class BaseReferenceSaveRequestModel : BaseReferenceEditorRequestModel
    {
        [MapToParameter("idfsBaseReference")]
        public long? BaseReferenceId { get; set; }
     
        [MapToParameter("idfsReferenceType")]
        public long? ReferenceTypeId { get; set; }
    }
}
