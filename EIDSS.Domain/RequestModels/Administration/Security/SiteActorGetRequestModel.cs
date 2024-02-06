using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration.Security
{
    public class SiteActorGetRequestModel : BaseGetRequestModel
    {
        public long SiteID { get; set; }
    }
}