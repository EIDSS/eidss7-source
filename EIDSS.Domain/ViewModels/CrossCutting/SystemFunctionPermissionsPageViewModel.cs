using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class SystemFunctionPermissionsPageViewModel :BaseModel
    {
   
       // public string SystemFunctions { get; set; }
       // public PermissionViewModel Read { get; set; }

        public long? RoleID { get; set; }
        public long SystemFunctionId { get; set; }
        public string Permission { get; set; }

        public bool HasReadPermission { get; set; } = false;
        public bool ReadPermission { get; set; } = false;
        public bool HasWritePermission { get; set; } = false;
        public bool WritePermission { get; set; } = false;
        public bool HasCreatePermission { get; set; } = false;
        public bool CreatePermission { get; set; } = false;
        public bool HasExecutePermission { get; set; } = false;
        public bool ExecutePermission { get; set; } = false;
        public bool HasDeletePermission { get; set; } = false;
        public bool DeletePermission { get; set; } = false;

        public bool HasAccessToPersonalDataPermission { get; set; } = false;
        public bool AccessToPersonalDataPermission { get; set; } = false;
        public bool HasAccessToGenderAndAgeDataPermission { get; set; } = false;
        public bool AccessToGenderAndAgeDataPermission { get; set; } = false;

    }
}
