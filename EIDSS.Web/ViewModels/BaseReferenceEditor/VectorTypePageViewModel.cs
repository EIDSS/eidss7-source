using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using System.Collections.Generic;

namespace EIDSS.Web.ViewModels.BaseReferenceEditor
{
    public class VectorTypePageViewModel
    {
        public VectorTypePageViewModel()
        {

        }

        public List<VectorTypeListViewModel> VectorTypeListViewModel { get; set; }

        EIDSSGridConfiguration _gridViewComponentBuilder;

        public EIDSSGridConfiguration eidssGridConfiguration { get { return _gridViewComponentBuilder; } set { _gridViewComponentBuilder = value; } }

    }
}
