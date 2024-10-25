using EIDSS.Localization.Helpers;
using EIDSS.Domain.Enumerations;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class ActiveSurveillanceSessionSamplesResponseModel
    {
        public int? TotalRowCount { get; set; }
        public long? MonitoringSessionToSampleType { get; set; }
        public long? MonitoringSessionToDiagnosisID { get; set; }
        public long? MonitoringSessionID { get; set; }
        [LocalizedRequired()]
        public long? SampleTypeID { get; set; }
        public string SampleTypeName { get; set; }
        public int OrderNumber { get; set; } = 0;
        public int RowStatus { get; set; } = (int)RowStatusTypeEnum.Active;
        public string RowAction { get; set; } = "I";
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
        public long NewMonitoringSessionToSampleTypeID { get; set; } = -1;
    }
}