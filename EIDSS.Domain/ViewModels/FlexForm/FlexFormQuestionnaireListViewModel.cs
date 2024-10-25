namespace EIDSS.Domain.ViewModels.FlexForm
{
    public class FlexFormQuestionnaireListViewModel
    {
        public long? idfsParentSection { get; set; }
        public long? idfsSection { get; set; }
        public long idfsParameter { get; set; }
        public string SectionName { get; set; }
        public string ParameterName { get; set; }
        public string parameterType { get; set; }
        public long? idfsParameterType { get; set; }
        public long? idfsReferenceType { get; set; }
        public long? idfsEditor { get; set; }
        public int? SectionOrder { get; set; }
        public int ParameterOrder { get; set; }
        public bool? blnGrid { get; set; }
        public bool? blnFixedRowSet { get; set; }
        public long? idfsEditMode { get; set; }
    }
}
