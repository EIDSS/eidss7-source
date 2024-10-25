using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class CountryModel:BaseModel
    {
        public long idfsCountry { get; set; }
        public string strCountryName { get; set; }
        public string strCountryExtendedName { get; set; }
        public string strCountryCode { get; set; }
        public int intRowStatus { get; set; }
    }
}
