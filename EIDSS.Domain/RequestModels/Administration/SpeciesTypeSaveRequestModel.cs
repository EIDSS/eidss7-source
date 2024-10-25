using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SpeciesTypeSaveRequestModel : BaseReferenceEditorRequestModel
    {
        [MapToParameter("IdfsSpeciesType")]
        public long? SpeciesTypeId { get; set; }
        public bool DeleteAnyway { get; set; }
        public string strCode { get; set; }
    }
}
