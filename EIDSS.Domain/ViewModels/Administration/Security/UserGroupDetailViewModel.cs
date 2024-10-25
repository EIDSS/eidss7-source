using EIDSS.Localization.Helpers;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels.Administration.Security
{
    public class UserGroupDetailViewModel
    {
        public long? idfEmployeeGroup { get; set; }
        public long? idfsEmployeeGroupName { get; set; }
        [LocalizedRequired]
        [StringLength(200)]
        public string strDefault { get; set; }
        [StringLength(200)]
        public string strName { get; set; }
        [StringLength(200)]
        public string strDescription { get; set; }
    }
}
