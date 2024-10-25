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
    /// This is the main list view model for reference types
    /// </summary>
    public class BaseReferenceListViewModel : BaseModel
    {
        public long BaseReferenceId { get; set; } // idfsBaseReference { get; set; }
        public long ReferenceTypeId { get; set; }// idfsReferenceType { get; init; }
        public string Default { get; set; } // strDefault { get; set; }
        public string Name { get; set; } // strName { get; set; }
        public int? intHACode { get; set; }
        public string strHACode { get; set; }
        public string strHACodeNames { get; set; }
        public int? IntOrder { get; set; }
    }
}
