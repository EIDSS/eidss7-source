using System;
using EIDSS.Domain.Abstracts;

namespace EIDSS.Domain.ViewModels.Administration
{
    public class EventGetListViewModel : BaseModel
    {
        public long EventId { get; set; }
        public long EventTypeId { get; set; }
        public string EventTypeName { get; set; }
        public long? ObjectId { get; set; }
        public string DiseaseName { get; set; }
        public long? SiteId { get; set; }
        public string EIDSSSiteId { get; set; }
        public string AdministrativeLevel2Name { get; set; }
        public string AdministrativeLevel3Name { get; set; }
        public DateTime EventDate { get; set; }
        public int? ProcessedIndicator { get; set; }
    }
}