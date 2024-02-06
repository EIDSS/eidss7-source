using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class BaseReferenceAdvanceGetRequestModel : BaseGetRequestModel
    {
        public string AdvancedSearch { get; set; }
        public string ReferenceTypeName { get; set; }
        public long? intHACode { get; set; }
    }
}