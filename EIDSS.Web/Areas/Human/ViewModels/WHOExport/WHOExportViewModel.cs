using EIDSS.Domain.RequestModels.Human;
using EIDSS.Domain.ResponseModels.Human;
using EIDSS.Domain.ViewModels;
using System.Collections.Generic;

namespace EIDSS.Web.Areas.Human.ViewModels.WHOExport
{
    public class WHOExportViewModel
    {
        public WHOExportViewModel()
        {
            SearchCriteria = new();
            Permissions = new();
        }

        public WHOExportRequestModel SearchCriteria { get; set; }
        public List<WHOExportGetListViewModel> SearchResults { get; set; }
        public UserPermissions Permissions { get; set; }
    }

}
