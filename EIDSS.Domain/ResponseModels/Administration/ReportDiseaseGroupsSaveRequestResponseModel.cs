using EIDSS.Domain.Abstracts;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Administration
{
    public class ReportDiseaseGroupsSaveRequestResponseModel : APIPostResponseModel
    {
        public long? IdfsReportDiagnosisGroup { get; set; }

        public string StrDuplicatedField { get; set; }
    }
}
