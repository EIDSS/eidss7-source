using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class VectorSpeciesTypesSaveRequestModel : BaseReferenceEditorRequestModel
    {
        [MapToParameter("idfsVectorSubType")]
        public long? IdfsVectorSubType { get; set; }
        public bool DeleteAnyway { get; set; }
        [MapToParameter("idfsVectorType")]
        public long? IdfsVectorType { get; set; }
        public string StrCode { get; set; }
    }
}
