using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FlexFormParameterTemplateSaveRequestModel
    {
        public long idfsParameter { get; set; }
        public long idfsFormTemplate { get; set; }
        public string LangID { get; set; }
        public long? idfsEditMode { get; set; }
        public int? intLeft { get; set; }
        public int? intTop { get; set; }
        public int? intWidth { get; set; }
        public int? intHeight { get; set; }
        public int? intScheme { get; set; }
        public int? intLabelSize { get; set; }
        public int? intOrder { get; set; }
        public bool? blnFreeze { get; set; }
        public string User { get; set; }
        public int? CopyOnly { get; set; } = 0;
        public int? FunctionCall { get; set; } = 0;
    }
}
