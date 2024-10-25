using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    /// <summary>
    /// Model used for requesting data for the base reference editor view
    /// </summary>
    public class BaseReferenceEditorGetRequestModel : BaseGetRequestModel
    {
        public string AdvancedSearch { get; set; }
        public long? IdfsReferenceType { get; set; }


    }
}
