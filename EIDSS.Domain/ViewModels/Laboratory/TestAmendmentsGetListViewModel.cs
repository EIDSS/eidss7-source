using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class TestAmendmentsGetListViewModel : BaseModel
    {
        public long AmendmentHistoryID { get; set; }
        public string AmendedByOrganizationName { get; set; }
        public string AmendedByPersonName { get; set; }
        public DateTime AmendmentDate { get; set; }
        public string OriginalTestResultTypeName { get; set; }
        public string ChangedTestResultTypeName { get; set; }
        public string ReasonForAmendment { get; set; }
    }
}
