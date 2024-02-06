using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Enumerations;
namespace EIDSS.Domain.ResponseModels.Administration
{
    public class FiltersViewModel 
    {
        public long? idfsBaseReference { get; set; }
        public string? StrDefault { get; set; }
       
    }

    public class EpidemogistViewModel
    {
        public string? idStrDefault { get; set; }
        public string? StrDefault { get; set; }

    }
}
