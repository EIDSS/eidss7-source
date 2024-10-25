using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormSectionsGetRequestModel : BaseGetRequestModel
    {
        public long? idfsFormType { get; set; }
        public long? idfsSection { get; set; }
        public long? idfsParentSection { get; set; }
    }
}
