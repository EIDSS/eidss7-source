using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    public class DiseaseTestGetRequestModel
    {
        public string LanguageID { get; set; }
        public string DiseaseIDList { get; set; }
    }
}