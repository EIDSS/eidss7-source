using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class BaseReferenceViewModel
    {
        public long IdfsBaseReference { get; set; }
        public long IdfsReferenceType { get; set; }
        public string StrBaseReferenceCode { get; set; }
        public string StrDefault { get; set; }
        public string Name { get; set; }
        public int? IntHACode { get; set; }
        public int? IntOrder { get; set; }
        public int IntRowStatus { get; set; }
        public bool? BlnSystem { get; set; }
        public long? IntDefaultHACode { get; set; }
        public string StrHACode { get; set; }
        public long? EditorSettings { get; set; }
    }
}
