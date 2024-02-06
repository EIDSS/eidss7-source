using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.FlexForm
{
    public class FlexFormTemplateDeterminantValuesListViewModel : BaseModel
    {
        public long idfDeterminantValue { get; set; }
        public long idfsFormTemplate { get; set; }
        public long? idfsFormType { get; set; }
        public long? DeterminantValue { get; set; }
        public string DeterminantDefaultName { get; set; }
        public string DeterminantNationalName { get; set; }
        public long? idfsBaseReference { get; set; }
        public long? idfsGISBaseReference { get; set; }
        public long? DeterminantType { get; set; }
        public string DeterminantTypeDefaultName { get; set; }
        public string DeterminantTypeNationalName { get; set; }
    }
}
