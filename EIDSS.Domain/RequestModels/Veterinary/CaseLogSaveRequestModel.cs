using EIDSS.Domain.Attributes;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class CaseLogSaveRequestModel
    {
        [Required]
        public long CaseLogID { get; set; }
        public long? LogStatusTypeID { get; set; }
        public long? LoggedByPersonID { get; set; }
        public DateTime? LogDate { get; set; }
        public string ActionRequired { get; set; }
        public string Comments { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}
