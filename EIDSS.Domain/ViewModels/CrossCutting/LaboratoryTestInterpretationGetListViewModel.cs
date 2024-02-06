using EIDSS.Domain.Abstracts;
using EIDSS.Domain.Enumerations;
using System;

namespace EIDSS.Domain.ViewModels.CrossCutting
{
    public class LaboratoryTestInterpretationGetListViewModel : BaseModel
    {
        public LaboratoryTestInterpretationGetListViewModel ShallowCopy()
        {
            return (LaboratoryTestInterpretationGetListViewModel)MemberwiseClone();
        }

        public long TestInterpretationID { get; set; }
        public long? TestInterpretationIDOriginal { get; set; }
        public long? DiseaseID { get; set; }
        public string DiseaseName { get; set; }
        public long? DiseaseUsingType { get; set; }
        public long? InterpretedStatusTypeID { get; set; }
        public string InterpretedStatusTypeName { get; set; }
        public long? ValidatedByOrganizationID { get; set; }
        public long? ValidatedByPersonID { get; set; }
        public string ValidatedByPersonName { get; set; }
        public long? InterpretedByOrganizationID { get; set; }
        public long? InterpretedByPersonID { get; set; }
        public string InterpretedByPersonName { get; set; }
        public long TestID { get; set; }
        public bool ValidatedStatusIndicator { get; set; }
        public bool? ReportSessionCreatedIndicator { get; set; }
        public string ValidatedComment { get; set; }
        public string InterpretedComment { get; set; }
        public DateTime? ValidatedDate { get; set; }
        public DateTime? InterpretedDate { get; set; }
        public bool ReadOnlyIndicator { get; set; }
        public long? SampleID { get; set; }
        public string EIDSSLocalOrFieldSampleID { get; set; }
        public string EIDSSLaboratorySampleID { get; set; }
        public string SampleTypeName { get; set; }
        public long? SpeciesID { get; set; }
        public string SpeciesTypeName { get; set; }
        public string Species { get; set; }
        public long? AnimalID { get; set; }
        public string EIDSSAnimalID { get; set; }
        public long? TestNameTypeID { get; set; }
        public string TestNameTypeName { get; set; }
        public long? TestCategoryTypeID { get; set; }
        public string TestCategoryTypeName { get; set; }
        public long? TestResultTypeID { get; set; }
        public string TestResultTypeName { get; set; }
        public bool IndicativeIndicator { get; set; }
        public long? FarmID { get; set; }
        public long? FarmMasterID { get; set; }
        public string EIDSSFarmID { get; set; }
        public int RowStatus { get; set; }
        public long? DiseaseReportID { get; set; }

        public string EIDSSReportID { get; set; }
        public int RowAction { get; set; }
        public bool CanInterpretTestResultPermissionIndicator { get; set; }
        public bool CanValidateTestResultPermissionIndicator { get; set; }
        private bool _canCreateConnectedDiseaseReportIndicator;

        public bool CanCreateConnectedDiseaseReportIndicator
        {
            get
            {
                _canCreateConnectedDiseaseReportIndicator = false;

                if (InterpretedStatusTypeID == (long)InterpretedStatusTypeEnum.RuledIn && ValidatedStatusIndicator)
                    return true;

                return _canCreateConnectedDiseaseReportIndicator;
            }
        }
    }
}