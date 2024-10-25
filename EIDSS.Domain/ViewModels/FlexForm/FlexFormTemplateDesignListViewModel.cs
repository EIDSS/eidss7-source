using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.FlexForm
{
    public class FlexFormTemplateDesignListViewModel
    {
        public long? idfsParentSection { get; set; }
        public long? idfsSection { get; set; }
        public string SectionName { get; set; }
        public int? intSectionOrder { get; set; }
        public long? idfsParameter { get; set; }
        public string ParameterName { get; set; }
        public int? intParameterOrder { get; set; }
        public long? idfsEditor { get; set; }
        public long? idfsParameterType { get; set; }
        public long? idfsParameterCaption { get; set; }
        public long? idfsEditMode { get; set; }
        public int Observations { get; set; }
    }
}