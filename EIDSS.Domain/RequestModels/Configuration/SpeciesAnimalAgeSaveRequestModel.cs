using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Configuration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SpeciesAnimalAgeSaveRequestModel : BaseSaveRequestModel
    {
        public long? idfSpeciesTypeToAnimalAge { get; set; }
        public long? idfsSpeciesType { get; set; }
        public long? idfsAnimalAge { get; set; }
        public bool DeleteAnyway { get; set; }
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }

    public class SpeciesAnimalAgeGetRequestModel : BaseGetRequestModel
    {
        public long? idfsSpeciesType { get; set; }
    }
}
