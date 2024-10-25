using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FlexFormTemplateSaveRequestModel 
    {
        public long? idfsFormType { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string strNote { get; set; }
        public string LangID { get; set; }
        public bool? blnUNI { get; set; }
        public long? idfsFormTemplate { get; set; }
        public int? intRowStatus { get; set; } = 0;
        public string User { get; set; }
        public int? FunctionCall { get; set; } = 0;
        public int? CopyOnly { get; set; } = 0;
        public long EventTypeId { get; set; }
        public long SiteId { get; set; }
        public long UserId { get; set; }
        public long LocationId { get; set; }
    }
}
