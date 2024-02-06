using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.FlexForm
{
    public class FlexFormParameterDetailViewModel : BaseModel
    {
        public long? idfsEditor { get; set; }
        public string Editor { get; set; }
        public long? idfsParameterType { get; set; }
        public string ParameterTypeName { get; set; }
        public string DefaultName { get; set; }
        public string DefaultLongName { get; set; }
        public string NationalName { get; set; }
        public string NationalLongName { get; set; }
        public int? ParameterUsed { get; set; }
    }
}
