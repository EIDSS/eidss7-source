using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    public class CaseLogGetListRequestModel : BaseGetRequestModel
    {
        public long DiseaseReportID { get; set; }
    }
}
