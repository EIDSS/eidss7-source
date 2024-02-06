using EIDSS.Domain.Attributes;
using System;

namespace EIDSS.Domain.RequestModels.Laboratory
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class TestAmendmentsSaveRequestModel
    {
        public long TestAmendmentID { get; set; }
        public long TestID { get; set; }
        public long? AmendedByOrganizationID { get; set; }
        public long? AmendedByPersonID { get; set; }
        public DateTime? AmendmentDate { get; set; }
        public long? OldTestResultTypeID { get; set; }
        public long? ChangedTestResultTypeID { get; set; }
        public string OldNote { get; set; }
        public string ChangedNote { get; set; }
        public string ReasonForAmendment { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public long? DataAuditEventID { get; set; }
    }
}
