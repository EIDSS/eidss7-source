using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class ReportDiseaseGroupDiseaseMatrixViewModel : BaseModel
    {
        public long IdfDiagnosisToGroupForReportType { get; set; }

        public long IdfsCustomReportType { get; set; }

        public string StrCustomReportType { get; set; }

        public long IdfsDiagnosis { get; set; }

        public string StrDiagnosis { get; set; }

        public long IdfsUsingType { get; set; }

        public string StrUsingType { get; set; }

        public string StrAccessoryCode { get; set; }

        public long IdfsReportDiagnosisGroup { get; set; }

        public string StrReportDiagnosisGroup { get; set; }

        public string StrIsDelete { get; set; }
    }
}
