using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class SystemFunctionsViewModel : BaseModel
    {
        public long SystemFunctionID { get; set; }
        public string strSystemFunction { get; set; }
        public long SystemFunctionOperationID { get; set; }
        public string strSystemFunctionOperation { get; set; }
        public int intRowStatus { get; set; }
    }
}
