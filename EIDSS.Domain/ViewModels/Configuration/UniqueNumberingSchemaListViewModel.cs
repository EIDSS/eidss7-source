using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class UniqueNumberingSchemaListViewModel : BaseModel
    {
        public long IdfsNumberName { get; set; }
        public string StrDefault { get; set; }
        public string StrName { get; set; }
        public string StrPrefix { get; set; }
        public string StrSpecialChar { get; set; }
        public string IntNumberValue { get; set; }
        public string intPreviousNumberValue { get; set; }
        public int IntMinNumberLength { get; set; }
        public string StrSuffix { get; set; }
        public bool BlnUsePrefix { get; set; }
        public bool BlnUseYear { get; set; }
        public bool BlnUseAlphaNumericValue { get; set; }
        public bool BlnUseSiteID { get; set; }
        public string intNumberNextValue { get; set; }
        public int? PreviousNumber { get; set; }
        public int? NextNumber { get; set; }
        public bool? blnUseHACSCodeSite { get; set; }

    }
}
