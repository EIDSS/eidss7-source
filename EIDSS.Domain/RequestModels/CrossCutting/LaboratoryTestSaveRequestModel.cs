﻿using EIDSS.Domain.Attributes;
using System;

namespace EIDSS.Domain.RequestModels.CrossCutting
{
    [DataUpdateType(Enumerations.DataUpdateTypeEnum.Update)]
    public class LaboratoryTestSaveRequestModel
    {
        public long TestID { get; set; }
        public long? TestNameTypeID { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public long? TestResultTypeID { get; set; }
        public long TestStatusTypeID { get; set; }
        public long DiseaseID { get; set; }
        public long? SampleID { get; set; }
        public long? BatchTestID { get; set; }
        public long? ObservationID { get; set; }
        public int? TestNumber { get; set; }
        public string Comments { get; set; }
        public DateTime? StartedDate { get; set; }
        public DateTime? ResultDate { get; set; }
        public long? TestedByOrganizationID { get; set; }
        public long? TestedByPersonID { get; set; }
        public long? ResultEnteredByOrganizationID { get; set; }
        public long? ResultEnteredByPersonID { get; set; }
        public long? ValidatedByOrganizationID { get; set; }
        public long? ValidatedByPersonID { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public bool NonLaboratoryTestIndicator { get; set; }
        public bool? ExternalTestIndicator { get; set; }
        public long? PerformedByOrganizationID { get; set; }
        public DateTime? ReceivedDate { get; set; }
        public string ContactPersonName { get; set; }
        public long? MonitoringSessionID { get; set; }
        public long? VectorID { get; set; }
        public long? VectorSessionID { get; set; }
        public long? HumanDiseaseReportID { get; set; }
        public long? VeterinaryDiseaseReportID { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }
    }
}