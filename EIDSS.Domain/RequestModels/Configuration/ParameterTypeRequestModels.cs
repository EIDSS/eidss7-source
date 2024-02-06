using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class ParameterTypeGetRequestModel : BaseGetRequestModel
    {
        [MapToParameter("searchString")]
        public string AdvancedSearch { get; set; }

    }

    public class ParameterFixedPresetValueGetRequestModel : BaseGetRequestModel
    {
        public long idfsParameterType { get; set; }
    }

    public class ParameterReferenceValueGetRequestModel : BaseGetRequestModel
    {
        public long idfsReferenceType { get; set; }
    }

    public class ParameterReferenceGetRequestModel : BaseGetRequestModel
    {
        //just a marker class because only langId is required from base
    }

    public class ParameterTypeSaveRequestModel
    {
        public long? idfsParameterType { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public long? idfsReferenceType { get; set; }
        public int HACode { get; set; }
        public int Order { get; set; }
        public string user { get; set; }
        public string langId { get; set; }


    }

    public class ParameterFixedPresetValueSaveRequestModel
    {
        public long? IdfsParameterType { get; set; }
        public long? IdfsParameterFixedPresetValue { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public int intOrder { get; set; }
        public string LangId { get; set; }
    }
}
