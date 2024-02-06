using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class StatisticalTypeGetRequestModel : BaseGetRequestModel
    {
        public string AdvancedSearch { get; set; }
        public long? idfsStatisticDataType { get; set; }
    }
}
