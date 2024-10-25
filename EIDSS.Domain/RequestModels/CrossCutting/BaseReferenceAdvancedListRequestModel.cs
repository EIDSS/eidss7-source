using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class BaseReferenceAdvancedListRequestModel : BaseGetRequestModel
    {
        public string ReferenceTypeName { get; set; }
        public long? intHACode { get; set; }
        public string advancedSearch { get; set; }
    }
}
