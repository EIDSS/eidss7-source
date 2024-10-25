using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class PersonalIdentificationTypeMatrixViewModel : BaseModel
    {
        public long IdfPersonalIDType { get; set; }
        public string StrPersonalIDType { get; set; }
        public string StrFieldType { get; set; }
        public int? Length { get; set; }
        public int? IntOrder { get; set; }
    }
}
