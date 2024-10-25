using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EIDSS.Domain.ResponseModels.Veterinary
{
    public class FarmDeleteRequestResponseModel
    {
        public int? ReturnCode { get; set; }
        public string ReturnMessage { get; set; }
        public int? MonitoringSessionCount { get; set; }
        public int? DiseaseReportCount { get; set; }
        public int? LabSampleCount { get; set; }
    }
}
