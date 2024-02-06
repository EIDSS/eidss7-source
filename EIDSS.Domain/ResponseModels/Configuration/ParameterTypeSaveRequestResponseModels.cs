using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Configuration
{
    public class ParameterTypeSaveRequestResponseModel : APIPostResponseModel
    {
        public long? idfsParameterType { get; set; }
        public string localizedMessage { get; set; }
    }

    public class ParameterFixedPresetValueSaveRequestResponseModel : APIPostResponseModel
    {
        public long? idfsParameterFixedPresetValue { get; set; }
    }
}
