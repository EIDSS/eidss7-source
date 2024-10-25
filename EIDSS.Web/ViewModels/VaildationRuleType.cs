using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.ViewModels
{
    public class VaildationRuleType
    {
        public enum ValidationRuleType
        {
            REQUIRED,
            RANGE,
            CHARACTERRANGE,
            DATE,
            DATECOMPARE_2_FIELDS,
            DATECOMPARE_3_FIELDS,
            NUMERIC,
            ZIP,
            RANGE_AND_REQUIRED,
            DROPDOWN_REQUIRED,
            RANGE_AND_REQUIRED_COMPARE_LOWER_RANGE,
            RANGE_AND_REQUIRED_COMPARE_UPPER_RANGE,
            PHONE
        }
    }
}
