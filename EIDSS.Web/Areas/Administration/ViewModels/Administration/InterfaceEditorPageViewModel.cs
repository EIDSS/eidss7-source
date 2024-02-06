using EIDSS.Domain.ViewModels;
using EIDSS.Domain.ViewModels.Administration;
using EIDSS.Web.TagHelpers.Models.EIDSSGrid;
using EIDSS.Web.ViewModels;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.Rendering;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace EIDSS.Web.Areas.Administration.ViewModels.Administration
{
    public class InterfaceEditorPageViewModel
    {
        public InterfaceEditorPageViewModel()
        {
            ModuleTabs = new List<InterfaceEditorModuleSectionViewModel>();
            Sections = new List<InterfaceEditorModuleSectionViewModel>();
        }

        public string PageName { get; set; }
        public List<InterfaceEditorModuleSectionViewModel> ModuleTabs { get; set; }
        public List<InterfaceEditorModuleSectionViewModel> Sections { get; set; }
        public InterfaceEditorSearchCriteria SearchCriteria { get; set; }
        public long? SelectedModuleResourceSet { get; set; }
        public string SelectedModuleResourceSetName { get; set; }
        public long? SelectedSectionResourceSet { get; set; }
        public InterfaceEditorLanguageUpload LanguageUpload { get; set; }
        


    }

    public class InterfaceEditorResourcePageViewModel
    {
        public InterfaceEditorResourcePageViewModel()
        {

            Items = new List<InterfaceEditorResourceViewModel>();
        }

        public long IdfsResourceSet { get; set; }
        public long ModuleId { get; set; }
        public UserPermissions UserPermissions { get; set; }
        public EIDSSGridConfiguration InterfaceEditorResourceGridConfiguration { get; set; }
        public List<InterfaceEditorResourceViewModel> Items { get; set; }
        public InterfaceEditorSearchCriteria SearchCriteria { get; set; }

    }

    public class InterfaceEditorSearchCriteria
    {
        public string SearchText { get; set; }
        public bool AllModules { get; set; }
        public List<SelectListItem> InterfaceEditorTypes { get; set; }
        //public List<Select2DataItem> InterfaceEditorTypes { get; set; }
        public bool Required { get; set; }
        public bool Hidden { get; set; }
        public string InterfaceEditorSelectedTypes { get; set; }
    }

    public class InterfaceEditorLanguageUpload
    {
        public string LanguageName { get; set; }
        public string LanguageCode { get; set; }
        public SelectList AvailableCultures { get; set; }
        public IFormFile LanguageFile { get; set; }
        public string PageResult { get; set; }

    }
}
