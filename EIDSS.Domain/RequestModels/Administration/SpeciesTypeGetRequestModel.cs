using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class SpeciesTypeGetRequestModel : BaseGetRequestModel
    {
        [MapToParameter("strSpeciesType")]
        public string SpeciesType { get; set; }
        public string AdvancedSearch { get; set; }
    }
}
