using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration
{
    public  class EventGetListRequestModel : BaseGetRequestModel
    {
        public long UserId { get; set; }
        public int DaysFromReadDate { get; set; }
    }
}
