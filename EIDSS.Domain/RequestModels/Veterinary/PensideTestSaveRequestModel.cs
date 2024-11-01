﻿using EIDSS.Domain.Attributes;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.RequestModels.Veterinary
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class PensideTestSaveRequestModel
    {
        [Required]
        public long PensideTestID { get; set; }
        [Required]
        public long SampleID { get; set; }
        public long? PensideTestNameTypeID { get; set; }
        public long? PensideTestResultTypeID { get; set; }
        public long? PensideTestCategoryTypeID { get; set; }
        public long? TestedByPersonID { get; set; }
        public long? TestedByOrganizationID { get; set; }
        public long? DiseaseID { get; set; }
        public DateTime? TestDate { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}