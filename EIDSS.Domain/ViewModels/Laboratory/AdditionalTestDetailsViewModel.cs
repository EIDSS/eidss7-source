using EIDSS.Domain.Abstracts;
using EIDSS.Domain.RequestModels.FlexForm;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class AdditionalTestDetailsViewModel : BaseModel
    {
        public long TestID { get; set; }
        public string Notes { get; set; }
        public string EIDSSBatchID { get; set; }
        public string BatchStatusTypeName { get; set; }        
    }
}
