using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class ParameterTypeViewModel : BaseModel
    {
        public long IdfsParameterType {get; set;}
        public long? IdfsReferenceType { get; set; }
        public string BaseReferenceListName { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string System { get; set; }
        public string ParameterTypeName { get; set; }

    }

    public class ParameterFixedPresetValueViewModel : BaseModel
    {
        public long IdfsParameterType { get; set; }
        public long IdfsParameterFixedPresetValue { get; set; }
        public long? IdfsReferenceType { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public int? IntOrder { get; set; }
        public string LangId { get; set; }
    }

    public class ParameterReferenceViewModel : BaseModel
    {
        public long IdfsReferenceType { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string LangId { get; set; }
    }

    public class ParameterReferenceValueViewModel : BaseModel
    {
        public long IdfsBaseReference { get; set; }
        public long? IdfsReferenceType { get; set; }
        public string DefaultName { get; set; }
        public string NationalName { get; set; }
        public string LangId { get; set; }
    }
}
