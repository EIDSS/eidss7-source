using System;

namespace EIDSS.Domain.ResponseModels.FlexForm
{
    public class FlexFormParametersSaveResponseModel : APIPostResponseModel
    {
        public Int64 idfsParameter { get; set; }
        public Int64 idfsParameterCaption { get; set; }
    }
}
