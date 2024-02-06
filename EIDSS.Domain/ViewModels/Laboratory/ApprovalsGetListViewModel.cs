using EIDSS.Domain.Abstracts;
using System;
using System.ComponentModel.DataAnnotations;

namespace EIDSS.Domain.ViewModels.Laboratory
{
    public class ApprovalsGetListViewModel : BaseModel
    {
        public long ActionRequestedID { get; set; }
        public string ActionRequested { get; set; }
        public long SampleID { get; set; }
        [StringLength(36)]
        public string EIDSSLaboratorySampleID { get; set; }
        [StringLength(36)]
        public string EIDSSReportOrSessionID { get; set; }
        [StringLength(36)]
        public string EIDSSAnimalID { get; set; }
        public string PatientOrFarmOwnerName { get; set; }
        public string SampleTypeName { get; set; }
        public string DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public string DisplayDiseaseName { get; set; }
        public long? TestID { get; set; }
        public long? TestNameTypeID { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public long? TestResultTypeID { get; set; }
        public long? TestStatusTypeID { get; set; }
        public string TestNameTypeName { get; set; }
        public string TestStatusTypeName { get; set; }
        public string TestResultTypeName { get; set; }
        public long? ResultEnteredByUserID { get; set; }
        public DateTime? AccessionDate { get; set; }
        public long? SampleStatusTypeID { get; set; }
        public string AccessionConditionOrSampleStatusTypeName { get; set; }
        public DateTime? ResultDate { get; set; }
        public long? PreviousSampleStatusTypeID { get; set; }
        public int? PreviousTestStatusTypeID { get; set; }
        public bool ReadPermissionIndicator { get; set; }
        public bool AccessToPersonalDataPermissionIndicator { get; set; }
        public bool AccessToGenderAndAgeDataPermissionIndicator { get; set; }
        public bool WritePermissionIndicator { get; set; }
        public bool DeletePermissionIndicator { get; set; }
        public int RowStatus { get; set; }
        public int RowAction { get; set; }


        public string Approval { get; set; }
        public int? NumberOfRecords { get; set; }
        public string Action { get; set; }
    }
}
