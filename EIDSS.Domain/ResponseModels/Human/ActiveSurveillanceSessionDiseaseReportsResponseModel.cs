using System;

namespace EIDSS.Domain.ResponseModels.Human
{
    public class ActiveSurveillanceSessionDiseaseReportsResponseModel
    {
        public long ReportKey { get; set; }
        public string ReportID { get; set; }
        public DateTime? EnteredDate { get; set; }
        public string ClassificationTypeName { get; set; }
        public string DiseaseName { get; set; }
        public string PersonLocation { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public int? RecordCount { get; set; }
        public int? TotalCount { get; set; }
        public int? TotalPages { get; set; }
        public int? CurrentPage { get; set; }
    }
}
