using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.FlexForm
{
    public class FlexFormRuleListResponseModel
    {
        public long idfsRule { get; set; }
        public long idfsFormTemplate { get; set; }
        public long? idfsRuleMessage { get; set; }
        public long idfsRuleFunction { get; set; }
        public int? intNumberOfParameters { get; set; }
        public long? idfsCheckPoint { get; set; }
        public string idfsCheckPointDescr { get; set; }
        public int? intRowStatus { get; set; }
        public Guid rowguid { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string MessageText { get; set; }
        public string MessageNationalText { get; set; }
        public string langid { get; set; }
        public bool blnNot { get; set; }
    }
}