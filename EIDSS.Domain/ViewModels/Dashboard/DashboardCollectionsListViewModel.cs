using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ViewModels.Dashboard
{
    public class DashboardCollectionsListViewModel : BaseModel
    {
        public long VectorSurveillanceSessionID { get; set; }
        public string SessionID { get; set; }
        public DateTime DateEntered { get; set; }
        public string Vectors { get; set; }
        public string DiseaseName { get; set; }
        public DateTime DateStarted { get; set; }
        public string Region { get; set; }
        public string Rayon { get; set; }
    }
}
