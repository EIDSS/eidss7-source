using EIDSS.Domain.RequestModels.Administration.Security;
using EIDSS.Domain.ViewModels.Administration.Security;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.SubAreas.Security.ViewModels.SystemFunctions
{
    public class SystemFunctionSearchViewModel   {
        public SystemFunctionsGetRequestModel SearchCriteria { get; set; }
        public List<SystemFunctionViewModel> SearchResults { get; set; }
        public EIDSSGridConfiguration SystemFunctionsGridConfiguration { get; set; }
        public bool ShowSearchResults { get; set; }
        public string InformationalMessage { get; set; }
        public bool SysemFunctionListWritePermission { get; set; }
        public bool SysemFunctionListReadPermission { get; set; }
        public bool AcccessRightWritePermission { get; set; }
        public bool AcccessRightReadPermission { get; set; }
        public string NoAccessInformationMessage { get; set; }


    }
}
