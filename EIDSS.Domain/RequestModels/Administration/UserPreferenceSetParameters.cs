using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    /// <summary>
    /// Body parameters for satisfying User Preferences API methods parameters.
    /// </summary>
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class UserPreferenceSetParameters
    {
        
        public long? UserPreferenceID { get; set; }

        [Required]
        public long UserId { get; set; }

        public long? ModuleConstantId { get; set; }

        [Required]
        public string PreferenceDetail { get; set; }

        public string AuditUserName { get; set; } = null;
    }
}

