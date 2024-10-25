namespace EIDSS.Domain.ResponseModels.FlexForm
{
    public class FlexFormParameterSelectListResponseModel
    {
        public long? idfsParameter { get; set; }
        public long? idfsParameterType { get; set; }
        public long? idfsReferenceType { get; set; }
        public long? idfsValue { get; set; }
        public string strValueCaption { get; set; }
        public string langid { get; set; }
        public int? intOrder { get; set; }
        public int? intHACode { get; set; }
        public int? intRowStatus { get; set; }
    }
}
