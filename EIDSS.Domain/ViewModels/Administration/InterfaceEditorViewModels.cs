using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class InterfaceEditorModuleSectionViewModel : BaseModel
    {
        public long IdfResourceHierarchy { get; set; }
        public long IdfsResourceSet { get; set; }
        public string DefaultName { get; set;}
        public string ResourceSetNode { get; set; }
        public string ParentSetNode { get; set; }
        public short? Level { get; set; }
        public string TranslatedName { get; set; }

    }

    public class InterfaceEditorResourceViewModel : BaseModel
    {
        public long IdfsResourceSet { get; set; }
        public string StrResourceSet { get; set; }
        public long IdfsResource { get; set; }
        public string StrResourceName { get; set; }
        public long IdfsResourceType {get; set; }
        public string StrResourceType { get; set; }
        public long BaseReferenceId { get; set; }
        public string NationalName { get; set; }
        public bool IsHidden { get; set; }
        public bool IsRequired { get; set; }
        public long? LanguageId { get; set; }
        public long? ModuleId { get; set; }
        public string ModuleName { get; set; }

    }

    public class InterfaceEditorTemplateViewModel
    {
        public long SetId { get; set; }
        public string SetName { get; set; }
        public long ResourceId { get; set; }
        public string ModuleName { get; set; }
        public string SectionName { get; set; }
        public string ResourceType { get; set; }
        public string ResourceDefaultName { get; set; }
        public string ResourceNationalName { get; set; }
    }
}
