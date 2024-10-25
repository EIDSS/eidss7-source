using EIDSS.Domain.Abstracts;
using System;

namespace EIDSS.Domain.ViewModels.Veterinary
{
    public class PensideTestGetListViewModel : BaseModel 
    {
        public PensideTestGetListViewModel ShallowCopy()
        {
            return (PensideTestGetListViewModel)MemberwiseClone();
        }

        public long PensideTestID { get; set; }
        public long? SampleID { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string SampleTypeName { get; set; }
        public long? SpeciesID { get; set; }
        public string SpeciesTypeName { get; set; }
        public long? AnimalID { get; set; }
        public string EIDSSAnimalID { get; set; }
        public long? PensideTestResultTypeID { get; set; }
        /// <summary>
        /// Used to determine which notification to log for the site and/or user.
        /// If brand new result; then log a result was register.
        /// If changed result; then log a result was amended.
        /// </summary>
        public long? OriginalPensideTestResultTypeID { get; set; }
        public string PensideTestResultTypeName { get; set; }
        public long? PensideTestNameTypeID { get; set; }
        public string PensideTestNameTypeName { get; set; }
        public int RowStatus { get; set; }
        public long? TestedByPersonID { get; set; }
        public string TestedByPersonName { get; set; }
        public long? TestedByOrganizationID { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseIDC10Code { get; set; }
        public DateTime? TestDate { get; set; }
        public long? PensideTestCategoryTypeID { get; set; }
        public string PensideTestCategoryTypeName { get; set; }
        public string Species { get; set; }
        public int RowAction { get; set; }
    }
}
