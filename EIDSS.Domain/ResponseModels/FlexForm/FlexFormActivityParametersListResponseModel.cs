namespace EIDSS.Domain.ResponseModels.FlexForm
{
    public class FlexFormActivityParametersListResponseModel
    {
        public int index { get; set; }
        public long idfActivityParameters { get; set; }
        public long? idfObservation { get; set; }
        public long? idfsFormTemplate { get; set; }
        public long? idfsParameter { get; set; }
        public long? idfsSection { get; set; }
        public long? idfRow { get; set; }
        public int? intNumRow { get; set; }
        public long? Type { get; set; }
        public string varValue { get; set; }
        public string strNameValue { get; set; }
        public int? numRow { get; set; }
        public int FakeField { get; set; }
        public long? ParameterType { get; set; }
    }
}
