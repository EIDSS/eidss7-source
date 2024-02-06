using EIDSS.Domain.ViewModels.Administration;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.Collections.Generic;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.TagHelpers.Models.EIDSSModal;

namespace EIDSS.Web.ViewModels
{
    public class SampleTypePageViewModel
    {
        public SampleTypePageViewModel()
        {

        }
        //public List<SampleTypesListViewModel> sampleTypesListViewModel { get; set; }
        public List<BaseReferenceEditorsViewModel> sampleTypesListViewModel { get; set; }
        public string strSearchSampleType { get; set; }
        public SelectList HACodeList { get; set; }
        public List<string> haCodes { get; set; }

        EIDSSGridConfiguration _gridViewComponentBuilder;

        public EIDSSGridConfiguration eidssGridConfiguration { get { return _gridViewComponentBuilder; } set { _gridViewComponentBuilder = value; } }

        /// <summary>
        /// Defines Modal For Model
        /// </summary>
        public EIDSSModalConfiguration eIDSSModalConfiguration { get; set; }
    }
}
