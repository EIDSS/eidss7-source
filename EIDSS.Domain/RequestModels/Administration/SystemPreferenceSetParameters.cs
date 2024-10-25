using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SystemPreferenceSetParameters
    {
        [Required]
        public long SystemPreferenceID { get; set; }

        [Required]
        public string PreferenceDetail { get; set; }
    }
}
