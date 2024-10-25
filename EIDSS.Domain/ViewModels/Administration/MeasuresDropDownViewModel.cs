using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Administration
{
    /// <summary>
    /// Model that provides data for the Measure Reference Type drop down on the Administration->Measures List page and other pages that require measure base reference information
    /// </summary>
    public class MeasuresDropDownViewModel : BaseModel
    {
        public long IdfsReferenceType { get; set; }
        public string StrReferenceTypeName { get; set; }
        public int IntStandard { get; set; }
        public long? IdfsCurrentReferenceType { get; set; }
    }
}
