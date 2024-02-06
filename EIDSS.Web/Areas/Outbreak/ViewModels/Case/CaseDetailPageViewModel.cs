using EIDSS.Domain.ViewModels.Outbreak;

namespace EIDSS.Web.Areas.Outbreak.ViewModels.Case
{
    public class CaseDetailPageViewModel
    {
        public CaseGetDetailViewModel VeterinaryCase { get; set; }
        public bool IsReadOnly { get; set; }
    }
}
