using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.FlexForm
{
    public class FlexFormTemplateDetailViewModel

    {
        public long idfsFormTemplate { get; set; }
        public string FormTemplate { get; set; }
        public string NationalName { get; set; }
        public long? idfsFormType { get; set; }
        public string strNote { get; set; }
        public bool blnUNI { get; set; }
    }
}
