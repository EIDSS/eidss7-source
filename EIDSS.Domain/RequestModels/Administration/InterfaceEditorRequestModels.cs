using EIDSS.Domain.Abstracts;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class InterfaceEditorModuleGetRequestModel : BaseGetRequestModel
    {
        //just a marker class because only langId is required 
    }

    public class InterfaceEditorSectionGetRequestModel : BaseGetRequestModel
    {
        public string ParentNode { get; set; }
    }

    public class InterfaceEditorResourceGetRequestModel : BaseGetRequestModel
    {
        public long? ModuleId { get; set; }
        public long? IdfsResourceSet { get; set; }
        public string SearchString { get; set; }
        public string IncludedTypes { get; set; }
        public bool? AllModules { get; set; }
        public bool? IsRequired { get; set; }
        public bool? IsHidden { get; set; }
    }

    public class InterfaceEditorResourceSaveRequestModel : BaseSaveRequestModel
    {
        public long idfsResource { get; set; }
        public long idfsResourceSet { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public bool isRequired { get; set; }
        public bool isHidden { get; set; }
    }

    public class InterfaceEditorLanguageSaveRequestModel 
    {
        public long? ReferenceId { get; set; }
        public long? ReferenceType { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string strReferenceCode { get; set; }
        public int?  HACode { get; set; }
        public int? Order { get; set; }
        public string LangId { get; set; }
  

    }

    public class InterfaceEditorLangaugeFileSaveRequestModel
    {
        [Required]
        public string LanguageName { get; set; }
        [Required]
        public string LanguageCode { get; set; }
        public string FileName { get; set; }
        [Required]
        public IFormFile LanguageFile { get; set; }
        [Required]
        public string User { get; set; }
        public string CurrentLangId { get; set; }
    }
}
