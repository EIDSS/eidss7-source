using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ViewModels.Configuration
{
    public class MatrixVersionViewModel : BaseModel
    {        
        public long? IdfVersion { get; set; }
        public long? IdfsMatrixType { get; set; }
        public string MatrixName { get; set; }
        public DateTime? DatStartDate { get; set; }
        public string ActivationDateDisplay { get; set; }
        public bool? BlnIsActive { get; set; }
        public int? IntRowStatus { get; set; }
        public Guid? Rowguid { get; set; }
        public bool? BlnIsDefault { get; set; }
        public string StrMaintenanceFlag { get; set; }
        public string StrReservedAttribute { get; set; }  
        public string ActiveColor { get; set; }
        public bool IsCheckmarkVisible { get; set; }
    }
}
