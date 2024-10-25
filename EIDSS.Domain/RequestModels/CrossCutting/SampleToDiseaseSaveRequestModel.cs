using EIDSS.Domain.Attributes;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class SampleToDiseaseSaveRequestModel
    {
        [Required]
        public long MonitoringSessionToMaterialID { get; set; }
        [Required]
        public long? MonitoringSessionID { get; set; }
        [Required]
        public long SampleID { get; set; }
        public long? SampleTypeID { get; set; }
        [Required]
        public long DiseaseID { get; set; }
        [Required]
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}