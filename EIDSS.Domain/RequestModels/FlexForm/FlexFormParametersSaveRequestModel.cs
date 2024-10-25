using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FlexFormParametersSaveRequestModel
    {
        public string LangID { get; set; }
        public long? idfsSection { get; set; }
        public long? idfsFormType { get; set; }
        public long? idfsParameterType { get; set; }
        public long? idfsEditor { get; set; }
        public int? intHACode { get; set; } = 0;
        public int? intOrder { get; set; } = 0;
        public string strNote { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string DefaultLongName { get; set; }
        public string NationalLongName { get; set; }
        public long? idfsParameter { get; set; }
        public long? idfsParameterCaption { get; set; }
        public string User { get; set; }
        public int? intRowStatus { get; set; } = 0;
        public int? CopyOnly { get; set; } = 0;
    }
}
