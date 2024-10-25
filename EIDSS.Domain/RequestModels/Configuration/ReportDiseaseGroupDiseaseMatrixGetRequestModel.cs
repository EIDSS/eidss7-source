using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.RequestModels.Configuration
{
    public class ReportDiseaseGroupDiseaseMatrixGetRequestModel : BaseGetRequestModel
    {
        public long IdfsCustomReportType { get; set; }
        public long IdfsReportDiagnosisGroup { get; set; }        
    }
}
