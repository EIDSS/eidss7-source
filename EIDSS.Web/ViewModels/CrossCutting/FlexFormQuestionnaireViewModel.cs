using EIDSS.Domain.Abstracts;

namespace EIDSS.Web.ViewModels.CrossCutting
{
    public class FlexFormQuestionnaireViewModel : BaseModel
    {
        public string QuestionnaireHTML { get; set; }
        public string FlexFormScript { get; set; }
    }
}
