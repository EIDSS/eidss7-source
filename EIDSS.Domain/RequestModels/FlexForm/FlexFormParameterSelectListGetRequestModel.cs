namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormParameterSelectListGetRequestModel
    {
        public string LangID { get; set; }
        public long? idfsParameter { get; set; }
        public long? idfsParameterType { get; set; }
        public long? intHACode { get; set; }
    }
}
