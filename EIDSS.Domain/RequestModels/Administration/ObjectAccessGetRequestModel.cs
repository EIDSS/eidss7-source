using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class ObjectAccessGetRequestModel : BaseGetRequestModel
    {
        public long? ActorID { get; set; }
        public long? SiteID { get; set; }
        public long ObjectID { get; set; }
    }
}
