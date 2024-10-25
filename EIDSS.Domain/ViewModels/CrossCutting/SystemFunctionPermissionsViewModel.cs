using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class SystemFunctionPermissionsViewModel :BaseModel
    {
   
       // public string SystemFunctions { get; set; }
       // public PermissionViewModel Read { get; set; }

        public long? RoleID { get; set; }
        public long SystemFunctionId { get; set; }
        public string Permission { get; set; }

        public bool HasReadPermission { get; set; } = false;
        public int? ReadPermission { get; set; }
        public bool HasWritePermission { get; set; } = false;
        public int? WritePermission { get; set; }
        public bool HasCreatePermission { get; set; } = false;
        public int? CreatePermission { get; set; }
        public bool HasExecutePermission { get; set; } = false;
        public int? ExecutePermission { get; set; }
        public bool HasDeletePermission { get; set; } = false;
        public int? DeletePermission { get; set; }

        public bool HasAccessToPersonalDataPermission { get; set; } = false;
        public int? AccessToPersonalDataPermission { get; set; }
        public bool HasAccessToGenderAndAgeDataPermission { get; set; } = false;
        public int? AccessToGenderAndAgeDataPermission { get; set; }

    }
}
