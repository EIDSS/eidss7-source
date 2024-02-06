using Newtonsoft.Json;
using System.Collections.Generic;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;

namespace EIDSS.Web.ViewModels.BaseReferenceEditor
{
    public class SpeciesTypePageViewModel
    {
        public SpeciesTypePageViewModel(){
        
        
        
        }
        public List<SpeciesTypeListViewModel> speciesTypesListViewModel { get; set; }

        EIDSSGridConfiguration _gridViewComponentBuilder;

        public EIDSSGridConfiguration eidssGridConfiguration { get { return _gridViewComponentBuilder; } set { _gridViewComponentBuilder = value; } }


    }
}