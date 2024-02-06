using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class CaseLogGetListViewModel : BaseModel
    {
        public CaseLogGetListViewModel ShallowCopy()
        {
            return (CaseLogGetListViewModel)MemberwiseClone();
        }

        public long DiseaseReportLogID { get; set; }
        public long? LogStatusTypeID { get; set; }
        public string LogStatusTypeName { get; set; }
        public long? DiseaseReportID { get; set; }
        public long? EnteredByPersonID { get; set; }
        public string EnteredByPersonName { get; set; }
        public DateTime? LogDate { get; set; }
        public string ActionRequired { get; set; }
        public string Comments { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}
