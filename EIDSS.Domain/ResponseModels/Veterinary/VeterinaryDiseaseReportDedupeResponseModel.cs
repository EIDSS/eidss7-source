using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Veterinary
{
    public class VeterinaryDiseaseReportDedupeResponseModel : APIPostResponseModel
    {
        public long? DiseaseReportID { get; set; }
        public string EIDSSReportID { get; set; }
        public long? CaseID { get; set; }
        public string EIDSSCaseID { get; set; }
    }
}
