using System.Collections.Generic;
using EIDSS.Domain.Attributes;
using EIDSS.Domain.ResponseModels;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class FlexFormActivityParametersSaveRequestModel
    {
        public long? idfObservation { get; set; }
        public long idfsFormTemplate { get; set; }
        public string Answers { get; set; }
        public string User { get; set; }
    }

    public class FlexFormObservationAnswers
    {
        public long idfsParameter { get; set; }
        public long? idfsEditor { get; set; }
        public string answer { get; set; }
        public long? idfRow { get; set; }
    }
}
