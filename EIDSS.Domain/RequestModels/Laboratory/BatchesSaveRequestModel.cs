using EIDSS.Domain.Attributes;
using System;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class BatchesSaveRequestModel
    {
        public long BatchTestID { get; set; }
        public long? TestNameTypeID { get; set; }
        public long? BatchStatusTypeID { get; set; }
        public long? PerformedByOrganizationID { get; set; }
        public long? PerformedByPersonID { get; set; }
        public long? ValidatedByOrganizationID { get; set; }
        public long? ValidatedByPersonID { get; set; }
        public long? ObservationID { get; set; }
        public long SiteID { get; set; }
        public DateTime? PerformedDate { get; set; }
        public DateTime? ValidationDate { get; set; }
        public string EIDSSBatchTestID { get; set; }
        public int RowStatus { get; set; }
        public long? ResultEnteredByPersonID { get; set; }
        public long? ResultEnteredByOrganizationID { get; set; }
        public int RowAction { get; set; }
    }
}