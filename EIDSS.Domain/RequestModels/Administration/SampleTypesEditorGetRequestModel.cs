using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Administration
{
    public class SampleTypesEditorGetRequestModel : BaseGetRequestModel
    {
        /// <summary>
        /// Performs an advanced search across all returned columns.  This search supercedes all other searches.
        /// </summary>
        [MapToParameter("advancedSearch")]
        public string AdvancedSearch { get; set; }
        public int intHACode { get; set; }

        /// <summary>
        /// Performs a simple search
        /// </summary>
        [MapToParameter("strSearchSampleType")]
        public string SampleTypeSearch { get; set; }
    }

    public class SampleTypesByDiseaseGetRequestModel
    {
        public string LangId { get; set; }
        
        public long? IdfsDiagnosis { get; set; }
        
        public int? AccessoryCode { get; set; }

    }
}
