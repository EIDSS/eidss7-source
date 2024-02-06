using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels
{
    /// <summary>
    /// 
    /// </summary>
    public class APIFileResponseModel : APIPostResponseModel
    {
        public byte[] Results { get; set; }
    }
}
