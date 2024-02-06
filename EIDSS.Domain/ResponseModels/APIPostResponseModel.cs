using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels
{
    /// <summary>
    /// Standard API response message for requests that change state
    /// </summary>
    public class APIPostResponseModel 
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public string StrDuplicateField { get; set; }
    }
}
