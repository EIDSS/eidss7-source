using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using static EIDSS.Web.ViewModels.VaildationRuleType;

namespace EIDSS.Web.ViewModels
{
    public class ValidatorSettings
    {
        public ValidatorSettings()
        {

        }

        /// <summary>
        /// Validation Message for Required Fields
        /// </summary>
        public string ValidatorMessage { get; set; }

        /// <summary>
        /// Validation Message For Range
        /// </summary>
        public string RangeValidationMessage { get; set; }

        /// <summary>
        /// Validation Message For Date
        /// </summary>
        public string DateValidationMessage { get; set; }

        public string PhoneValidationMessage { get; set; }

        public ValidationRuleType ValidationRuleTypes { get; set; }

        public string ValidationRule { get; set; }
        public rules rules { get; set; }
    }
    


    public class rules
    {
        public rules()
        {

        }
        public bool requred { get; set; }
    }

}
