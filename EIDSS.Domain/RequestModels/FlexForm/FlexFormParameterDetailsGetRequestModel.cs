using System.Threading;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormParameterDetailsGetRequestModel : BaseGetRequestModel
    {
        public long idfsParameter { get; set; }
    }
}
