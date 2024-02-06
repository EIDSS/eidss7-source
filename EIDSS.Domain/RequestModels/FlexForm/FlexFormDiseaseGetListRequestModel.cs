using System;
using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;

namespace EIDSS.Domain.RequestModels.FlexForm
{
    public class FlexFormDiseaseGetListRequestModel : BaseGetRequestModel
    {
        public Nullable<long> AccessoryCode { get; set; }

        [MapToParameter("search")]
        public string SimpleSearch { get; set; }

        public string AdvancedSearch { get; set; }
        public long idfsFormTemplate { get; set; }
        public long idfsFormType { get; set; }
    }
}
