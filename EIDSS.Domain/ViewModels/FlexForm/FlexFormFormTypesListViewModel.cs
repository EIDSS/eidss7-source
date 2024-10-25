using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.FlexForm
{
    public class FlexFormFormTypesListViewModel : BaseModel
    {
        public long idfsFormType { get; set; }
        public string Name { get; set; }
        public string LongName { get; set; }
        public int HasParameters { get; set; }
        public int HasNestedSections { get; set; }
        public int HasTemplates { get; set; }
        public long? idfsMatrixType { get; set; }
    }
}
