using EIDSS.Domain.ViewModels.Administration.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SystemFunctions
{
    public class SystemFunctionsDetailsViewModel
    {
        public long SystemFunctionId { get; set; }
        public string SystemFunctionName { get; set; }
        public string InformationalMessage { get; set; }
        public string ErrorMessage { get; set; }
        public List<SystemFunctionUserGroupAndUserViewModel> SystemFunctionUserGroupAndUserList { get; set; }
        public SearchPersonAndEmployeeGroupViewModel SearchPersonAndEmployeeGroupViewModel { get; set; }
        public bool SysemFunctionListWritePermission { get; set; }
        public bool SysemFunctionListReadPermission { get; set; }
        public bool AcccessRightWritePermission { get; set; }
        public bool AcccessRightReadPermission { get; set; }
        public string NoAccessInformationMessage { get; set; }


    }
}
