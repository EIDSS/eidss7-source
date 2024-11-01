﻿using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Delete)]
    public class FlexFormParameterTemplateDeleteRequestModel
    {
        public long? idfsParameter { get; set; }
        public long? idfsFormTemplate { get; set; }
    }
}
